FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206?format=xml",
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => %{<?xml version="1.0" encoding="UTF-8"?>
<objectProfile xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.fedora.info/definitions/1/0/access/ https://fedora-dev.stanford.edu:443/objectProfile.xsd" pid="druid:bd935rr8206">
  <objLabel>AMERICA</objLabel>
  <objOwnerId>dor</objOwnerId>
  <objCreateDate>2011-06-28T00:01:37.884Z</objCreateDate>
  <objLastModDate>2011-06-28T00:01:38.736Z</objLastModDate>
  <objDissIndexViewURL>https://fedora-dev.stanford.edu:443/fedora/get/druid:bd935rr8206/fedora-system:3/viewMethodIndex</objDissIndexViewURL>
  <objItemIndexViewURL>https://fedora-dev.stanford.edu:443/fedora/get/druid:bd935rr8206/fedora-system:3/viewItemIndex</objItemIndexViewURL>
  <objState>A</objState>
</objectProfile>
})
