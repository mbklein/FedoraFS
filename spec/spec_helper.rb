$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'bundler/setup'
require 'spec'
require 'spec/autorun'

require 'rubygems'
require 'fedorafs'
require File.join(File.dirname(__FILE__), 'fixtures', 'requests.rb')

Spec::Runner.configure do |config|
  
end
