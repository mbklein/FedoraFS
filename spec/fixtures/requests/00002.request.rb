FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/datastreams.xml",
	:status => ["200", "OK"], :content_type => "text/xml",
	:body => %{<?xml version="1.0" encoding="UTF-8"?>
<objectDatastreams xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.fedora.info/definitions/1/0/access/ https://fedora-dev.stanford.edu:443/listDatastreams.xsd" pid="druid:bd935rr8206" baseURL="https://fedora-dev.stanford.edu:443/fedora/">
  <datastream dsid="DC" label="Dublin Core Record for this object" mimeType="text/xml"/>
  <datastream dsid="RELS-EXT" label="RDF Statements about this object" mimeType="application/rdf+xml"/>
  <datastream dsid="descMetadata" label="Descriptive Metadata" mimeType="text/xml"/>
</objectDatastreams>
})
