require 'fakeweb'

FakeWeb.register_uri(:post, "http://fedorafs.example.edu/fedora/risearch", 
  :status => ["200", "OK"], :content_type => "text/plain",
  :body => File.read(File.join(File.dirname(__FILE__), '00001.response.txt')))

FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams.xml",
	:status => ["200", "OK"], :content_type => "text/xml",
	:body => File.read(File.join(File.dirname(__FILE__), '00002.response.xml')))

FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams/DC.xml",
  :status => ["200", "OK"], :content_type => "text/xml", 
  :body => File.read(File.join(File.dirname(__FILE__), '00003.response.xml')))

FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams/RELS-EXT.xml", 
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => File.read(File.join(File.dirname(__FILE__), '00005.response.xml')))

FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams/descMetadata.xml", 
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => File.read(File.join(File.dirname(__FILE__), '00006.response.xml')))

FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/export",
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => File.read(File.join(File.dirname(__FILE__), '00007.response.xml')))

FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams/DC/content", 
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => File.read(File.join(File.dirname(__FILE__), '00017.response.xml')))

FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206?format=xml",
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => File.read(File.join(File.dirname(__FILE__), '00049.response.xml')))

FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams/descMetadata.xml",
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => File.read(File.join(File.dirname(__FILE__), '00051.response.xml')))
