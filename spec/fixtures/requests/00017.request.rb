FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams/DC/content", 
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => %{<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
  <dc:title>AMERICA</dc:title>
  <dc:identifier>druid:bd935rr8206</dc:identifier>
  <dc:identifier>uuid:1abdd178-7547-40b5-59bf-e13f5d2a8bf3</dc:identifier>
  <dc:identifier>mdtoolkit:bd935rr8206</dc:identifier>
  <dc:identifier>druid:bd935rr8206</dc:identifier>
</oai_dc:dc>
})