require 'fakeweb'

Dir[File.join(File.dirname(__FILE__), "requests", "*.request.rb")].each { |f| load f }