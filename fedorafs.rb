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
RISEARCH_DIRECTORY_PARAMS = { :type => 'triples', :lang => 'spo', :format => 'count' }
RISEARCH_DIRECTORY_TEMPLATE = "<info:fedora/%1$s> <dc:identifier> '%1$s'"
RISEARCH_CONTENTS_PARAMS = { :type => 'tuples', :lang => 'itql', :format => 'CSV' }
RISEARCH_CONTENTS_TEMPLATE = "select $object from <#ri> where $object <info:fedora/fedora-system:def/model#label> $label"
DEFAULT_SPLITTERS = { :default => /.+/, 'fedora-system' => /.+/ }

class FedoraFS < FuseFS::FuseDir
  class PathError < Exception; end
  
  attr_reader :repo, :splitters
  
#  def respond_to?(sym)
#    result = super
#    $stderr.puts("respond_to? #{sym.inspect} :: #{result}")
#    result
#  end
  
  def initialize(opts = {})
    if opts[:cert_file]
      opts[:ssl_client_cert] = OpenSSL::X509::Certificate.new(File.read(opts.delete(:cert_file)))
    end
    if opts[:key_file]
      opts[:ssl_client_key] = OpenSSL::PKey::RSA.new(File.read(opts.delete(:key_file)), opts.delete(:key_pass))
    end
    
    @cache = LruHash.new(opts.delete(:cache_size) || 1000)
    @pids = []
    @repo = RestClient::Resource.new(opts.delete(:url), opts)
    @splitters = DEFAULT_SPLITTERS.merge(opts.delete(:splitters) || {})
  end
  
  def cache(pid)
    unless @cache.has_key?(pid)
      @cache[pid] = {}
    end
    @cache[pid]
  end

  def contents(path)
    parts = scan_path(path)
    if parts.empty?
      return build_pid_tree.keys
    else
      current_dir, dir_part, parts = traverse(parts)
      if current_dir.nil?
        files = begin
          [FOXML_XML] + datastreams(dir_part).collect do |ds|
            mime = MIME::Types[ds_properties(dir_part,ds)['dsmime']].first
            mime.nil? ? ds : "#{ds}.#{mime.extensions.first}"
          end
        rescue Exception => e
          puts e.inspect
          []
        end
        if parts.empty?
          files
        else
          fname = parts.shift
          files.select { |f| f == fname }
        end
      else
        return current_dir.keys
      end
    end
  end

  def directory?(path)
    return false if path =~ /\._/
    parts = scan_path(path)
    return true if parts.empty?
    current_dir, dir_part, parts = begin
      traverse(parts)
    rescue PathError
      return false
    end
    if current_dir.nil?
      return parts.empty?
    else
      return true
    end
  end
  
  def file?(path)
    return false if path =~ /\._/
    parts = scan_path(path)
    current_dir, dir_part, parts = begin
      traverse(parts)
    rescue PathError
      return false
    end
    if parts.empty?
      return true
    else
      contents(File.dirname(path)).include?(parts.last)
    end
  end
  
  def size(path)
    return false if path =~ /\._/
    parts = scan_path(path)
    current_dir, dir_part, parts = begin
      traverse(parts)
    rescue PathError
      return false
    end

    if parts.last == FOXML_XML
      read_file(path).length
    else
      dsid = dsid_from_filename(parts.last)
      ds_properties(dir_part, dsid)['dssize'].to_i
    end
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
    parts = scan_path(path)
    begin
      Time.parse(ds_properties(parts[-2], parts[-1])['dscreatedate'])
    rescue
      Time.now
    end
  end
  
  def read_file(path)
    return '' if path =~ /\._/
    parts = scan_path(path)
    pid, fname = parts[-2..-1]
    if parts.last == FOXML_XML
      @repo["objects/#{pid}/export"].get
    else
      dsid = dsid_from_filename(fname)
      @repo["objects/#{pid}/datastreams/#{dsid}/content"].get
    end
  end
  
  def can_write?(path)
    return true if path =~ /\._/ # We'll fake it out in #write_to()
    parts = scan_path(path)
    file?(path) and (parts.last != FOXML_XML)
  end
  
  def write_to(path,content)
    return content if path =~ /\._/
    begin
      parts = scan_path(path)
      pid, fname = parts[-2..-1]
      dsid = dsid_from_filename(fname)
      mime = ds_properties(pid,dsid)['dsmime'] || 'application/octet-stream'
      resource = @repo["objects/#{pid}/datastreams/#{dsid}?logMessage=Fedora+FUSE+FS"]
      resource.put(content, :content_type => mime)
      return true
    rescue Exception => e
      return false
    end
  end
  
  def can_mkdir?(path)
    return false
  end

  def can_rmdir?(path)
    return false
  end
  
  def can_delete?(path)
    return true # We're never actually going to delete anything, though.
  end

  private
  def traverse(parts)
    dir_part = parts.shift
    current_dir = pid_tree[dir_part]
    if current_dir.nil?
      raise PathError, "Path not found: #{File.join(*parts)}"
    end
    until parts.empty? or current_dir.nil?
      dir_part = parts.shift
      if current_dir.has_key?(dir_part)
        current_dir = current_dir[dir_part]
      else
        raise PathError, "Path not found: #{File.join(*parts)}"
      end
    end
    return([current_dir, dir_part, parts])
  end

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
  
  def build_pid_tree
    @pids = {}
    params = RISEARCH_CONTENTS_PARAMS.merge(:query => RISEARCH_CONTENTS_TEMPLATE)
    response = @repo['risearch'].post(params)
    pids = response.split(/\n/).collect { |pid| pid.sub(%r{^info:fedora/},'') }
    pids.shift
    pids.each do |pid|
      namespace, id = pid.split(/:/,2)
      splitter = @splitters[namespace] || @splitters[:default]
      stem = @pids[namespace] ||= {}
      pidtree = id.scan(splitter).flatten
      until pidtree.empty?
        stem = stem[pidtree.shift] ||= {}
      end
      stem[pid] = nil
    end
    @pids
  end

  def pid_tree
    build_pid_tree if @pids.nil?
    @pids
  end
end
