# -*- encoding: utf-8 -*-
require 'rake'

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "fedora-fs"
  s.version     = '0.2.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael B. Klein"]
  s.email       = ["mbklein@stanford.edu"]
  s.summary     = "FUSE filesystem for Fedora Commons repositories"
  s.description = "Mounts a Fedora Commons repository as a FUSE filesystem"
  s.executables = ["mount_fedora"]
  
  s.required_rubygems_version = ">= 1.3.6"
    
  # Runtime dependencies
  s.add_dependency 'daemons'
  s.add_dependency 'fusefs-osx'
  s.add_dependency 'json_pure'
  s.add_dependency 'nokogiri'
  s.add_dependency 'rest-client'
  s.add_dependency 'rufus-lru'
  
  # Bundler will install these gems too if you've checked out fedora-fs source from git and run 'bundle install'
  # It will not add these as dependencies if you require checksum-tools for other projects
  s.add_development_dependency "rake", ">=0.8.7"
  s.add_development_dependency "rcov"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rspec"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "ruby-debug"
  s.add_development_dependency "yard"
 
  s.files        = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*'].to_a
  s.bindir       = 'bin'
  s.require_path = 'lib'
end