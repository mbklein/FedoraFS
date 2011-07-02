FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams/descMetadata.xml", 
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => %{
<?xml version="1.0" encoding="UTF-8"?>
<datastreamProfile xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.fedora.info/definitions/1/0/management/ https://fedora-dev.stanford.edu:443/datastreamProfile.xsd" pid="druid:bd935rr8206" dsID="descMetadata">
  <dsLabel>Descriptive Metadata</dsLabel>
  <dsVersionID>descMetadata.0</dsVersionID>
  <dsCreateDate>2011-06-28T00:01:38.736Z</dsCreateDate>
  <dsState>A</dsState>
  <dsMIME>text/xml</dsMIME>
  <dsFormatURI/>
  <dsControlGroup>X</dsControlGroup>
  <dsSize>9216</dsSize>
  <dsVersionable>true</dsVersionable>
  <dsInfoType/>
  <dsLocation>druid:bd935rr8206+descMetadata+descMetadata.0</dsLocation>
  <dsLocationType/>
  <dsChecksumType>DISABLED</dsChecksumType>
  <dsChecksum>none</dsChecksum>
</datastreamProfile>
})
