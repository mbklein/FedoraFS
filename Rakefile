require 'rubygems'
require 'rake'
require 'bundler'

Dir.glob('lib/tasks/*.rake').each { |r| import r }

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.pattern = FileList['./spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:functional) do |spec|
  spec.pattern = 'spec/**/*_spec.rb', 'test/**/*.rb'
  spec.rcov = true
  spec.rcov_opts = %w{--exclude spec\/*,gems\/*,ruby\/* --aggregate coverage.data}
end

task :rcov => ["functional"] do
end

task :clean do
  puts 'Cleaning old coverage.data'
  FileUtils.rm('coverage.data') if(File.exists? 'coverage.data')
end

task :default => [:rcov, :doc]

