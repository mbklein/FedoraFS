#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'fileutils'
require 'fusefs'
require 'json'
require 'nokogiri'
require 'optparse'
require 'rest-client'
require 'rufus/lru'
require 'mime/types'

include FuseFS

FOXML_XML = 'foxml.xml'
RISEARCH_PARAMS = { :type => 'tuples', :lang => 'itql', :format => 'CSV', :limit => '1000' }
RISEARCH_TEMPLATE = "select $object from <#ri> where $object <dc:identifier> '%s'"

class FedoraFS < FuseFS::FuseDir
  attr_reader :repo, :solr
  
  def initialize(fedora_url, opts = {})
    @cache = LruHash.new(opts.delete(:cache_size) || 1000)
    if opts[:solr]
      @solr = RestClient::Resource.new(opts.delete(:solr))
    end
    @repo = RestClient::Resource.new(fedora_url, opts)
  end
  
  def cache(pid)
    unless @cache.has_key?(pid)
      @cache[pid] = {}
    end
    @cache[pid]
  end

  # atime, ctime, mtime, and utime aren't implemented in FuseFS yet
  def atime(path)
    utime(path)
  end

  def ctime(path)
    utime(path)
  end
  
  def mtime(path)
    utime(path)
  end
  
  def utime(path)
    base, rest = split_path(path)
    if rest.nil?
      Time.now
    else
      Time.parse(ds_properties(base, rest)['dscreatedate'])
    end
  end
  
  def contents(path)
    base, rest = split_path(path)
    if base.nil?
      gather_all_pids
    elsif base
      files = begin
        [FOXML_XML] + datastreams(base).collect do |ds|
          mime = MIME::Types[ds_properties(base,ds)['dsmime']].first
          mime.nil? ? ds : "#{ds}.#{mime.extensions.first}"
        end
      rescue Exception => e
        puts e.inspect
        []
      end
      if rest.nil?
        files
      else
        files.has_key?(rest) ? [rest] : []
      end
    end
  end

  def directory?(path)
    return false if path =~ /\._/
    base, rest = split_path(path)
    if @pids.include?(base) or @cache.has_key?(base)
      return rest.nil?
    else
      params = RISEARCH_PARAMS.merge(:query => RISEARCH_TEMPLATE % (rest || base))
      @repo['risearch'].post(params) =~ /info:fedora/ ? true : false
    end
  end
  
  def file?(path)
    return false if path =~ /\._/
    base, rest = split_path(path)
    contents(base).include?(rest)
  end
  
  def size(path)
    return false if path =~ /\._/
    base, rest = split_path(path)
    if rest == FOXML_XML
      read_file(path).length
    else
      dsid = dsid_from_filename(rest)
      ds_properties(base, dsid)['dssize'].to_i
    end
  end
  
  def read_file(path)
    return '' if path =~ /\._/
    base, rest = split_path(path)
    if rest == FOXML_XML
      @repo["objects/#{base}/export"].get
    else
      dsid = dsid_from_filename(rest)
      @repo["objects/#{base}/datastreams/#{dsid}/content"].get
    end
  end
  
  def can_write?(path)
    return false # for now, until writing doesn't hang
    return false if path =~ /\._/
    base, rest = split_path(path)
    file?(path) and (rest != FOXML_XML)
  end
  
  def write_to(path,content)
    return content if path =~ /\._/
    base, rest = split_path(path)
    dsid = dsid_from_filename(rest)
    mime = ds_properties(base,dsid)['dsmime'] || 'application/octet-stream'
    resource = @repo["object/#{base}/datastreams/#{dsid}?logMessage=Fedora+FUSE+FS"]
    resource.put(content, :content_type => mime)
    read_file(path)
  end
  
  def can_mkdir?(path)
    return false
  end

  def can_rmdir?(path)
    return false
  end
  
  def can_delete?(path)
    return false
  end

#  private
  def datastreams(pid)
    return [] unless pid =~ /^[^\.].+:.+$/
    obj = cache(pid)
    unless obj[:datastreams]
      resource = @repo["objects/#{pid}/datastreams.xml"]
      doc = Nokogiri::XML(resource.get)
      obj[:datastreams] = doc.search('/objectDatastreams/datastream').collect { |ds| ds['dsid'] }
    end
    obj[:datastreams]
  end
  
  def ds_properties(pid, dsid)
    return [] unless pid =~ /^[^\.].+:.+$/ and dsid !~ /^\./
    obj = cache(pid)
    unless obj.has_key?(dsid)
      resource = @repo["objects/#{pid}/datastreams/#{dsid}.xml"]
      doc = Nokogiri::XML(resource.get)
      obj[dsid] = Hash[doc.search('/datastreamProfile/*').collect { |node| [node.name.downcase, node.text] }]
    end
    obj[dsid]
  end
  
  def dsid_from_filename(filename)
    File.basename(filename,File.extname(filename))
  end
  
  def gather_all_pids
    if @solr.nil?
      return []
    else
      begin
        @pids = []
        params = { :q => '*:*', :rows => 1000, :start => 0, :wt => 'json', :fl => 'PID' }
        response = JSON.parse(@solr['select'].post(params))['response']
        total = response['numFound']
        docs = response['docs']
        while params[:start] < total
          @pids += docs.collect { |doc| doc['PID'].first }
          params[:start] += 1000
          docs = JSON.parse(@solr['select'].post(params))['response']['docs']
        end
        return @pids
  #    rescue
  #      return []
      end
    end
  end
  
end
  
if (File.basename($0) == File.basename(__FILE__))
  
  url = nil
  init_opts = { :ssl_client_cert => nil, :ssl_client_key => nil, :key_pass => '', :solr => nil }
  
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename($0)} [options] <fedora-url> <mount-point>"
    
    opts.on('-c', '--cert-file FILE', "Use client certificate from FILE") do |filename|
      init_opts[:ssl_client_cert] = filename
    end

    opts.on('-z', '--cache-size', "Number of objects to hold in memory") do |size|
      init_opts[:cache_size] = size.to_i
    end
    
    opts.on('-k', '--key-file FILE', "Use client key from FILE") do |filename|
      init_opts[:ssl_client_key] = filename
    end
    
    opts.on('-p', '--key-pass STRING', "Password for client key") do |val|
      init_opts[:key_pass] = val
    end
    
    opts.on('-s', '--solr URI', "Base URI of Fedora solr server") do |uri|
      init_opts[:solr] = uri
    end
    
    opts.on_tail('-h', '--help', "Show this help message") do
      puts opts
      exit
    end
  end

  optparse.parse!

  if (ARGV.size != 2)
    puts optparse
    exit
  end
  
  uri = ARGV.shift
  dirname = ARGV.shift
  unless File.directory?(dirname)
    if File.exists?(dirname)
      puts "Usage: #{dirname} is not a directory."
      exit
    else
      FileUtils.mkdir_p(dirname)
    end
  end

  if uri =~ %r{^(.+)/fedora$} and init_opts[:solr].nil?
    init_opts[:solr] = uri.sub(/fedora$/,'solr')
    $stderr.puts "Default solr: #{init_opts[:solr]}"
  end

  root = FedoraFS.new(uri, init_opts)

  # Set the root FuseFS
  FuseFS.set_root(root)
  FuseFS.mount_under(dirname)
  FuseFS.run # This doesn't return until we're unmounted.
end
