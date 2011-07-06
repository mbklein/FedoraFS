require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'traceable'
require 'logger'

describe Traceable do

  class A
    include Traceable
    
    def add(a,b)
      a+b
    end
    trace :add
  end
  
  class B < A
    def logger
      return (@logger ||= StringIO.new(''))
    end
  end

  class C < A
    def logger
      if @logger.nil?
        @logger = Logger.new($stderr)
        @logger.level = Logger::DEBUG
      end
      return @logger
    end
  end
  
  it "should output to STDERR if no logger is defined" do
    A.trace(:add)
    $stderr.should_receive(:puts).twice
    thing = A.new
    thing.respond_to?(:logger).should == false
    thing.add(1,2).should == 3
  end

  it "should #puts() to logger if logger responds to it" do
    B.trace(:add)
    $stderr.should_not_receive(:puts)
    thing = B.new
    thing.logger.should be_a(StringIO)
    thing.logger.should_receive(:puts).twice
    thing.add(1,2).should == 3
  end
  
  it "should #debug() to logger if logger responds to it" do
    C.trace(:add)
    $stderr.should_not_receive(:puts)
    thing = C.new
    thing.logger.should be_a(Logger)
    thing.logger.should_receive(:debug).twice
    thing.add(1,2).should == 3
  end
  
  it "should #untrace()" do
    A.untrace(:add)
    $stderr.should_not_receive(:puts)
    thing = A.new
    thing.add(1,2).should == 3
  end
  
end