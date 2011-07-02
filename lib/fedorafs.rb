#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'fileutils'
require 'fusefs'
require 'json'
require 'logger'
require 'nokogiri'
require 'optparse'
require 'ostruct'
require 'rest-client'
require 'rufus/lru'
require 'mime/types'

include FuseFS

class FedoraFS < FuseFS::FuseDir
  class PathError < Exception; end

  FOXML_XML = 'foxml.xml'
  PROPERTIES_XML = 'profile.xml'
  RISEARCH_CONTENTS_PARAMS = { :type => 'tuples', :lang => 'itql', :format => 'CSV' }
  RISEARCH_CONTENTS_TEMPLATE = "select $object from <#ri> where $object <info:fedora/fedora-system:def/model#label> $label"
  SPECIAL_FILES = {
    :attributes => ["last_refresh", "next_refresh", "object_cache", "object_count"],
    :signals    => ["log_level", "read_only", "attribute_xml", "refresh_time"]
  }
  DEFAULT_OPTS = {
    :url => 'http://localhost:8983/fedora/', :user => nil, :password => nil,
    :cert_file => nil, :key_file => nil, :key_pass => '',
    :logdev => $stderr, :log_level => Logger::INFO,
    :cache_size => 1000, :refresh_time => 120,
    :attribute_xml => false, :read_only => false,
    :splitters => {},
  }
  DEFAULT_SPLITTERS = { :default => /.+/, 'fedora-system' => /.+/ }
    
  attr_reader :repo, :last_refresh, :logger, :opts
  attr_accessor :read_only, :attribute_xml, :refresh_time
  
  def initialize(init_opts = {})
    @opts = OpenStruct.new(DEFAULT_OPTS.merge(init_opts))

    rest_opts = { :user => opts.user, :password => opts.password }
    unless opts.cert_file.nil?
      rest_opts[:ssl_client_cert] = OpenSSL::X509::Certificate.new(File.read(opts.cert_file))
    end
    unless opts.key_file.nil?
      rest_opts[:ssl_client_key] = OpenSSL::PKey::RSA.new(File.read(opts.key_file), opts.key_pass)
    end
    @repo = RestClient::Resource.new(opts.url, rest_opts)
    
    @last_refresh = nil
    @cache = LruHash.new(opts.cache_size)
    @pids = nil
    
    opts.splitters = DEFAULT_SPLITTERS.merge(opts.splitters)
    opts.splitters.each_pair do |k,v| 
      if v.is_a?(String)
        opts.splitters[k] = Regexp.compile(v.gsub(/^\/|\/$/,''))
      end
    end
  end
  
  def contents(path)
    parts = scan_path(path)
    if parts.empty?
      return pid_tree.keys
    else
      current_dir, dir_part, parts, pid = traverse(parts)
      if current_dir.nil?
        files = [FOXML_XML]
        files << PROPERTIES_XML if attribute_xml
        with_exception_logging([]) do
          datastreams(pid).each do |ds|
            mime = MIME::Types[ds_properties(pid,ds)['dsmime']].first
            files << (mime.nil? ? ds : "#{ds}.#{mime.extensions.first}")
            files << "#{ds}.#{PROPERTIES_XML}" if attribute_xml
          end
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
    return false if is_attribute_file?(path)
    parts = scan_path(path)
    return true if parts.empty?
    current_dir, dir_part, parts, pid = begin
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
    return true if is_attribute_file?(path) or is_signal_file?(path)
    parts = scan_path(path)
    current_dir, dir_part, parts, pid = begin
      traverse(parts)
    rescue PathError
      return false
    end
    if parts.empty?
      return true
    else
      file = parts.last
      list = contents(File.dirname(path))
      list.any? { |entry| entry == file or File.basename(entry,File.extname(entry))+'.'+PROPERTIES_XML == file }
    end
  end
  
  def size(path)
    return false if path =~ /\._/
    if is_attribute_file?(path) or is_signal_file?(path)
      return read_file(path).length
    else
      parts = scan_path(path)
      current_dir, dir_part, parts, pid = begin
        traverse(parts)
      rescue PathError
        return false
      end

      if parts.last == FOXML_XML
        read_file(path).length
      elsif parts.last =~ /#{PROPERTIES_XML}$/
        read_file(path).length
      else
        dsid = dsid_from_filename(parts.last)
        ds_properties(pid, dsid)['dssize'].to_i
      end
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
    current_dir, dir_part, parts, pid = traverse(parts)
    begin
      Time.parse(ds_properties(pid, parts[-1])['dscreatedate'])
    rescue
      Time.now
    end
  end
  
  def read_file(path)
    return '' if path =~ /\._/
    unless write_stack[path].nil?
      write_stack[path]
    else
      with_exception_logging do
        if is_attribute_file?(path) or is_signal_file?(path)
          accessor = File.basename(path,File.extname(path)).sub(/^\.+/,'').to_sym
          content = self.send(accessor)
          "#{content.to_s}\n"
        else
          parts = scan_path(path)
          current_dir, dir_part, parts, pid = traverse(parts)
          fname = parts.last
          if fname == FOXML_XML
            @repo["objects/#{pid}/export"].get
          elsif fname == PROPERTIES_XML
            @repo["objects/#{pid}?format=xml"].get
          elsif fname =~ /^(.+)\.#{PROPERTIES_XML}$/
            dsid = $1
            @repo["objects/#{pid}/datastreams/#{dsid}.xml"].get
          else
            dsid = dsid_from_filename(fname)
            @repo["objects/#{pid}/datastreams/#{dsid}/content"].get
          end
        end
      end
    end
  end
  
  def can_write?(path)
    if is_signal_file?(path) or (path =~ /\._/) # We'll fake it out in #write_to()
      return true
    elsif read_only or is_attribute_file?(path)
      return false
    else
      parts = scan_path(path)
      return (file?(path) and (parts.last != FOXML_XML) and (parts.last !~ /#{PROPERTIES_XML}$/))
    end
  end
  
  def write_to(path,content)
    if content.empty? and write_stack[path].nil?
      write_stack[path] = content
    else
      write_stack.delete(path)
      with_exception_logging do
        if is_signal_file?(path)
          logger.debug("Setting #{File.basename(path)} to #{content.chomp.inspect}")
          accessor = "#{File.basename(path)}=".to_sym
          self.send(accessor, content)
        else
          unless read_only or (path =~ /\._/) or (path =~ /#{FOXML_XML}$/) or (path =~ /#{PROPERTIES_XML}$/)
            parts = scan_path(path)
            current_dir, dir_part, parts, pid = traverse(parts)
            fname = parts.last
            dsid = dsid_from_filename(fname)
            mime = ds_properties(pid,dsid)['dsmime'] || 'application/octet-stream'
            resource = @repo["objects/#{pid}/datastreams/#{dsid}?logMessage=Fedora+FUSE+FS"]
            resource.put(content, :content_type => mime)
          end
        end
      end
    end
    return content
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

  # Attribute accessors
  def attribute_xml
    opts.attribute_xml
  end
  
  def attribute_xml=(value)
    opts.attribute_xml = bool(value)
  end
  
  def cache(pid)
    unless @cache.has_key?(pid)
      @cache[pid] = {}
    end
    @cache[pid]
  end

  def log_level
    logger.level
  end
  
  def log_level=(value)
    logger.level = opts.log_level = value.to_i
  end
  
  def logger
    @logger ||= Logger.new(opts.logdev)
    @logger.level = opts.log_level
    @logger
  end
  
  def next_refresh
    @last_refresh.nil? ? Time.now : (@last_refresh + opts.refresh_time)
  end
  
  def object_cache
    @cache.to_json
  end
  
  def object_count(hash = @pids)
    result = 0
    hash.each_pair { |k,v| result += v.nil? ? 1 : object_count(v) }
    result
  end
  
  def read_only
    opts.read_only
  end
  
  def read_only=(value)
    opts.read_only = bool(value)
  end
  
  def refresh_time=(value)
    opts.refresh_time = value.to_i
  end
  
  private
  # Convenience methods
  def bool(value)
    if value.is_a?(String)
      value.empty? ? value : value.chomp == 'true'
    else
      value ? true : false
    end
  end
  
  def with_exception_logging(default = nil)
    begin
      return yield
    rescue Exception => e
      logger.error(e.message)
      logger.debug(e.backtrace)
      return default
    end
  end
  
  def write_stack
    @write_stack ||= {}
  end
  
  # Content methods
  def dsid_from_filename(filename)
    File.basename(filename,File.extname(filename))
  end
  
  def is_attribute_file?(path)
    File.dirname(path) == '/' and SPECIAL_FILES[:attributes].include?(File.basename(path))
  end

  def is_signal_file?(path)
    File.dirname(path) == '/' and SPECIAL_FILES[:signals].include?(File.basename(path))
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
  
  def pid_tree
    if @pids.nil? or (Time.now >= next_refresh)
      @pids = {}
      params = RISEARCH_CONTENTS_PARAMS.merge(:query => RISEARCH_CONTENTS_TEMPLATE)
      response = @repo['risearch'].post(params)
      pids = response.split(/\n/).collect { |pid| pid.sub(%r{^info:fedora/},'') }
      pids.shift
      pids.each do |pid|
        namespace, id = pid.split(/:/,2)
        splitter = opts.splitters[namespace] || opts.splitters[:default]
        stem = @pids[namespace] ||= {}
        pidtree = id.scan(splitter).flatten
        until pidtree.empty?
          pid_part = pidtree.shift
          stem = stem[pid_part] ||= pidtree.empty? ? nil : {}
        end
      end
      @last_refresh = Time.now
    end
    @pids
  end

  def traverse(parts)
    dir_part = parts.shift
    pid = "#{dir_part}:"
    current_dir = pid_tree[dir_part]
    if current_dir.nil?
      raise PathError, "Path not found: #{File.join(*parts)}"
    end
    until parts.empty? or current_dir.nil?
      dir_part = parts.shift
      if current_dir.has_key?(dir_part)
        pid += dir_part
        current_dir = current_dir[dir_part]
      else
        raise PathError, "Path not found: #{File.join(*parts)}"
      end
    end
    return([current_dir, dir_part, parts, pid])
  end
end
