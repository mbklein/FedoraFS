FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams/RELS-EXT.xml", 
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => %{
<?xml version="1.0" encoding="UTF-8"?>
<datastreamProfile xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.fedora.info/definitions/1/0/management/ https://fedora-dev.stanford.edu:443/datastreamProfile.xsd" pid="druid:bd935rr8206" dsID="RELS-EXT">
  <dsLabel>RDF Statements about this object</dsLabel>
  <dsVersionID>RELS-EXT.0</dsVersionID>
  <dsCreateDate>2011-06-28T00:01:37.935Z</dsCreateDate>
  <dsState>A</dsState>
  <dsMIME>application/rdf+xml</dsMIME>
  <dsFormatURI>info:fedora/fedora-system:FedoraRELSExt-1.0</dsFormatURI>
  <dsControlGroup>X</dsControlGroup>
  <dsSize>424</dsSize>
  <dsVersionable>true</dsVersionable>
  <dsInfoType/>
  <dsLocation>druid:bd935rr8206+RELS-EXT+RELS-EXT.0</dsLocation>
  <dsLocationType/>
  <dsChecksumType>DISABLED</dsChecksumType>
  <dsChecksum>none</dsChecksum>
</datastreamProfile>
})
