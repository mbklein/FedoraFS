$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'bundler/setup'
require 'rspec'
require 'rspec/autorun'

require 'rubygems'
require 'fedorafs'
require File.join(File.dirname(__FILE__), 'fixtures', 'requests.rb')

RSpec.configure do |config|
  
end
