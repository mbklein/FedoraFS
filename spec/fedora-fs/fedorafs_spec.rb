require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe FedoraFS do

  def fixture_content(filename)
    File.read(File.join(File.dirname(__FILE__), "..", "fixtures", filename))
  end
  
  before :each do
    opts = YAML.load(fixture_content("spec_config.yaml"))
    @fs = FedoraFS.new(opts)
  end
  
  it "should create the root directory from PID namespaces" do
    @fs.contents('/').should =~ ['changeme','druid','fedora-system']
  end

  it "should use the default 'fedora-system:*' splitter" do
    @fs.contents('/fedora-system/').should =~ ['ContentModel-3.0','FedoraObject-3.0','ServiceDefinition-3.0','ServiceDeployment-3.0']
  end
  
  it "should use the custom 'druid:*' splitter" do
    @fs.contents('/druid/').should =~ ['bb','bc','bd']
    @fs.contents('/druid/bd/').should =~ ['013','017','032','122','343','384','432','483','534','612','619','626','678','763','774','886','935']
    @fs.contents('/druid/bd/935/').should == ['rr']
    @fs.contents('/druid/bd/935/rr/').should == ['8206']
  end
  
  it "should return false from #directory? and #file? when called with nonexistent paths" do
    @fs.directory?('/druid/').should be_true
    @fs.directory?('/namespace/').should be_false

    @fs.directory?('/druid/bd/').should be_true
    @fs.directory?('/druid/bf/').should be_false

    @fs.directory?('/druid/bd/935/').should be_true
    @fs.directory?('/druid/bd/936/').should be_false

    @fs.directory?('/druid/bd/935/rr').should be_true
    @fs.directory?('/druid/bd/935/rs').should be_false

    @fs.directory?('/druid/bd/935/rr/8206').should be_true
    @fs.directory?('/druid/bd/935/rr/8207').should be_false

    @fs.file?('/druid/bd/935/rr/8206/DC.xml').should be_true
    @fs.file?('/druid/bd/936/rr/8206/DC.xml').should be_false
    @fs.file?('/druid/bd/935/rr/8206/NO_FILE.XML').should be_false

    @fs.file?('/druid/bd/935/rr/8206').should be_true
    @fs.file?('/druid/bd/935/rr/8207').should be_false
  end

  it "should list datastreams without attribute XML files" do
    @fs.contents('/druid/bd/935/rr/8206/').should =~ ['foxml.xml','DC.xml','RELS-EXT.rdf','descMetadata.xml']
    @fs.contents('/druid/bd/935/rr/8206/foxml.xml').should == ['foxml.xml']
  end

  it "should list datastreams with attribute XML files" do
    @fs.attribute_xml = true
    @fs.contents('/druid/bd/935/rr/8206/').should =~ ['foxml.xml','DC.xml','RELS-EXT.rdf','descMetadata.xml',
      'profile.xml','DC.profile.xml','RELS-EXT.profile.xml','descMetadata.profile.xml']
  end
  
  it "should retrieve datastream content" do
    @fs.file?('/druid/bd/935/rr/8206/DC.xml').should be_true
    @fs.read_file('/druid/bd/935/rr/8206/DC.xml').should == fixture_content('00017.response.xml')
    @fs.size('/druid/bd/935/rr/8206/DC.xml').should == 558
  end
  
  it "should retrieve datastream profile XML" do
    @fs.file?('/druid/bd/935/rr/8206/DC.profile.xml').should be_true
    @fs.read_file('/druid/bd/935/rr/8206/DC.profile.xml').should == fixture_content('00003.response.xml')
    @fs.size('/druid/bd/935/rr/8206/DC.profile.xml').should == fixture_content('00003.response.xml').length
  end

  it "should retrieve FOXML" do
    @fs.file?('/druid/bd/935/rr/8206/foxml.xml').should be_true
    @fs.read_file('/druid/bd/935/rr/8206/foxml.xml').should == fixture_content('00007.response.xml')
    @fs.size('/druid/bd/935/rr/8206/foxml.xml').should == fixture_content('00007.response.xml').length
  end
  
  it "should retrieve object profile XML" do
    @fs.file?('/druid/bd/935/rr/8206/profile.xml').should be_true
    @fs.read_file('/druid/bd/935/rr/8206/profile.xml').should == fixture_content('00049.response.xml')
    @fs.size('/druid/bd/935/rr/8206/profile.xml').should == fixture_content('00049.response.xml').length
  end
  
  it "should read signal and attribute files" do
    @fs.contents('/')
    @fs.read_file('/last_refresh').chomp.should == @fs.last_refresh.to_s
    @fs.read_file('/next_refresh').chomp.should == @fs.next_refresh.to_s
    @fs.read_file('/refresh_time').chomp.should == @fs.refresh_time.to_s
    @fs.read_file('/object_cache').chomp.should == @fs.object_cache
    @fs.read_file('/object_count').chomp.should == @fs.object_count.to_s
    @fs.read_file('/log_level').chomp.should == @fs.log_level.to_s
    @fs.read_file('/read_only').chomp.should == @fs.read_only.to_s
    @fs.read_file('/attribute_xml').chomp.should == @fs.attribute_xml.to_s

    @fs.size('/attribute_xml').should == 6
    @fs.size('/druid/bf/123').should be_false
  end
  
  it "should write signal files" do
    @fs.contents('/')
    @fs.log_level.should == Logger::INFO
    @fs.read_file('/log_level').chomp.to_i.should == Logger::INFO
    @fs.write_to('/log_level',"#{Logger::DEBUG}\n").chomp.to_i.should == Logger::DEBUG
    @fs.log_level.should == Logger::DEBUG

    @fs.read_only.should == false
    @fs.read_file('/read_only').should == "false\n"
    @fs.write_to('/read_only',"true\n").should == "true\n"
    @fs.read_only.should == true

    @fs.attribute_xml.should == false
    @fs.read_file('/attribute_xml').should == "false\n"
    @fs.write_to('/attribute_xml',"true\n").should == "true\n"
    @fs.attribute_xml.should == true

    @fs.refresh_time.should == 120
    @fs.read_file('/refresh_time').should == "120\n"
    @fs.write_to('/refresh_time',"60\n").should == "60\n"
    @fs.refresh_time.should == 60
  end
  
  it "should know which files can be written" do
    @fs.contents('/')
    @fs.can_write?('/druid/bd/935/rr/8206/DC.xml').should be_true
    @fs.can_write?('/druid/bd/935/rr/8206/DC.profile.xml').should be_false
    @fs.can_write?('/druid/bd/935/rr/8206/foxml.xml').should be_false
    @fs.read_only = true
    @fs.can_write?('/druid/bd/935/rr/8206/DC.xml').should be_false
    @fs.can_write?('/refresh_time').should be_true
    @fs.can_write?('/last_refresh').should be_false
    
    # mkdir, rmdir, and delete are stubs
    @fs.can_mkdir?('/namespace').should be_false
    @fs.can_rmdir?('/druid').should be_false
    @fs.can_delete?('/druid/bd/935/rr/8206/DC.xml').should be_true
  end
  
  it "should write a datastream" do
    @fs.contents('/')
    @fs.write_to('/druid/bd/935/rr/8206/DC.xml','').should == ''
    @fs.read_file('/druid/bd/935/rr/8206/DC.xml').should == ''
    
    new_xml = fixture_content('DC.xml')
    repo = @fs.repo
    resource1 = repo['objects/druid:bd935rr8206/datastreams/DC.xml']
    resource2 = stub("stub_repo")
    repo.should_receive(:[]).with("objects/druid:bd935rr8206/datastreams/DC.xml").and_return(resource1)
    repo.should_receive(:[]).with("objects/druid:bd935rr8206/datastreams/DC?logMessage=Fedora+FUSE+FS").and_return(resource2)
    resource2.should_receive(:put)
    @fs.write_to('/druid/bd/935/rr/8206/DC.xml', new_xml).should == new_xml
  end
  
  it "should support utime, atime, ctime, mtime, even though FuseFS doesn't (yet)" do
    real_time = Time.parse('2011-06-28T00:01:37.935Z')
    @fs.contents('/')
    @fs.utime('/druid/bd/935/rr/8206/DC.xml').should == real_time
    @fs.atime('/druid/bd/935/rr/8206/DC.xml').should == real_time
    @fs.mtime('/druid/bd/935/rr/8206/DC.xml').should == real_time
    @fs.ctime('/druid/bd/935/rr/8206/DC.xml').should == real_time
  end
  
end