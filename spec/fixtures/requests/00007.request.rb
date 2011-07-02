FakeWeb.register_uri(:get, "http://fedorafs.example.edu/fedora/objects/druid:bd935rr8206/export",
  :status => ["200", "OK"], :content_type => "text/xml",
  :body => %{<?xml version="1.0" encoding="UTF-8"?>
<foxml:digitalObject xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" VERSION="1.1" PID="druid:bd935rr8206" FEDORA_URI="info:fedora/druid:bd935rr8206" xsi:schemaLocation="info:fedora/fedora-system:def/foxml# http://www.fedora.info/definitions/1/0/foxml1-1.xsd">
  <foxml:objectProperties>
    <foxml:property NAME="info:fedora/fedora-system:def/model#state" VALUE="Active"/>
    <foxml:property NAME="info:fedora/fedora-system:def/model#label" VALUE="AMERICA"/>
    <foxml:property NAME="info:fedora/fedora-system:def/model#ownerId" VALUE="dor"/>
    <foxml:property NAME="info:fedora/fedora-system:def/model#createdDate" VALUE="2011-06-28T00:01:37.884Z"/>
    <foxml:property NAME="info:fedora/fedora-system:def/view#lastModifiedDate" VALUE="2011-06-28T00:01:38.736Z"/>
  </foxml:objectProperties>
  <foxml:datastream ID="AUDIT" FEDORA_URI="info:fedora/druid:bd935rr8206/AUDIT" STATE="A" CONTROL_GROUP="X" VERSIONABLE="false">
    <foxml:datastreamVersion ID="AUDIT.0" LABEL="Audit Trail for this object" CREATED="2011-06-28T00:01:37.884Z" MIMETYPE="text/xml" FORMAT_URI="info:fedora/fedora-system:format/xml.fedora.audit">
      <foxml:xmlContent>
        <audit:auditTrail xmlns:audit="info:fedora/fedora-system:def/audit#">
          <audit:record ID="AUDREC1">
            <audit:process type="Fedora API-M"/>
            <audit:action>addDatastream</audit:action>
            <audit:componentID>descMetadata</audit:componentID>
            <audit:responsibility>fedoraAdmin</audit:responsibility>
            <audit:date>2011-06-28T00:01:38.736Z</audit:date>
            <audit:justification/>
          </audit:record>
        </audit:auditTrail>
      </foxml:xmlContent>
    </foxml:datastreamVersion>
  </foxml:datastream>
  <foxml:datastream ID="DC" FEDORA_URI="info:fedora/druid:bd935rr8206/DC" STATE="A" CONTROL_GROUP="X" VERSIONABLE="false">
    <foxml:datastreamVersion ID="DC1.0" LABEL="Dublin Core Record for this object" CREATED="2011-06-28T00:01:37.935Z" MIMETYPE="text/xml" FORMAT_URI="http://www.openarchives.org/OAI/2.0/oai_dc/" SIZE="558">
      <foxml:xmlContent>
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
          <dc:title>AMERICA</dc:title>
          <dc:identifier>druid:bd935rr8206</dc:identifier>
          <dc:identifier>uuid:1abdd178-7547-40b5-59bf-e13f5d2a8bf3</dc:identifier>
          <dc:identifier>mdtoolkit:bd935rr8206</dc:identifier>
          <dc:identifier>druid:bd935rr8206</dc:identifier>
        </oai_dc:dc>
      </foxml:xmlContent>
    </foxml:datastreamVersion>
  </foxml:datastream>
  <foxml:datastream ID="RELS-EXT" FEDORA_URI="info:fedora/druid:bd935rr8206/RELS-EXT" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
    <foxml:datastreamVersion ID="RELS-EXT.0" LABEL="RDF Statements about this object" CREATED="2011-06-28T00:01:37.935Z" MIMETYPE="application/rdf+xml" FORMAT_URI="info:fedora/fedora-system:FedoraRELSExt-1.0" SIZE="424">
      <foxml:xmlContent>
        <rdf:RDF xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rel="info:fedora/fedora-system:def/relations-external#" xmlns:hydra="http://projecthydra.org/ns/relations#">
          <rdf:Description rdf:about="info:fedora/druid:bd935rr8206">
            <hydra:isGovernedBy rdf:resource="info:fedora/druid:nk327xn8125"/>
          </rdf:Description>
        </rdf:RDF>
      </foxml:xmlContent>
    </foxml:datastreamVersion>
  </foxml:datastream>
  <foxml:datastream ID="descMetadata" FEDORA_URI="info:fedora/druid:bd935rr8206/descMetadata" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
    <foxml:datastreamVersion ID="descMetadata.0" LABEL="Descriptive Metadata" CREATED="2011-06-28T00:01:38.736Z" MIMETYPE="text/xml" SIZE="9216">
      <foxml:xmlContent>
        <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
          <mods:typeOfResource>cartographic</mods:typeOfResource>
          <mods:genre authority="marcgt">map</mods:genre>
          <mods:accessCondition displayLabel="Copyright Stanford University. Stanford, CA 94305. (650) 723-2300." type="useAndReproduction">Stanford University Libraries and Academic Information Resources - Terms of Use SULAIR Web sites are subject to Stanford University's standard Terms of Use (See http://www.stanford.edu/home/atoz/terms.html) These terms include a limited personal, non-exclusive, non-transferable license to access and use           the sites, and to download - where permitted - material for personal,           non-commercial, non-display use only. Please contact the University           Librarian to request permission to use SULAIR Web sites and contents beyond           the scope of the above license, including but not limited to republication           to a group or republishing the Web site or parts of the Web site. SULAIR           provides access to a variety of external databases and resources, which           sites are governed by their own Terms of Use, as well as contractual access           restrictions. The Terms of Use on these external sites always govern the           data available there. Please consult with library staff if you have           questions about data access and availability.</mods:accessCondition>
          <mods:identifier displayLabel="Original McLaughlin Book Number (1995 edition)" type="local">182</mods:identifier>
          <mods:titleInfo>
            <mods:title>AMERICA </mods:title>
            <mods:subTitle>State 1 of 2:</mods:subTitle>
          </mods:titleInfo>
          <mods:name authority="local" type="personal">
            <mods:role>
              <mods:roleTerm authority="marcrelator" type="text">creator</mods:roleTerm>
            </mods:role>
            <mods:namePart>Henry Overton.</mods:namePart>
          </mods:name>
          <mods:subject>
            <mods:cartographics>
              <mods:scale> [ca. 1:33,000,000]. </mods:scale>
            </mods:cartographics>
          </mods:subject>
          <mods:subject authority="">
            <mods:cartographics>
              <mods:scale/>
              <mods:coordinates>W0200000 E1600000 N900000 S900000</mods:coordinates>
              <mods:projection/>
            </mods:cartographics>
          </mods:subject>
          <mods:originInfo>
            <mods:place>
              <mods:placeTerm>London</mods:placeTerm>
            </mods:place>
            <mods:dateCreated keyDate="yes" qualifier="">1711</mods:dateCreated>
          </mods:originInfo>
          <mods:identifier displayLabel="Updated McLaughlin Book Number" type="local">182-01</mods:identifier>
          <mods:identifier displayLabel="call_number" type="local">G 3290 1711 .O933</mods:identifier>
          <mods:physicalDescription>
            <mods:extent>1 map : hand col.; 54.8 x 92.5 cm. ; 56.1 x 93.8 cm. including border.</mods:extent>
          </mods:physicalDescription>
          <mods:name authority="local" type="personal">
            <mods:namePart>Overton, Henry</mods:namePart>
          </mods:name>
          <mods:note displayLabel="state_note">California as an island on Briggs model, with flat northern coast.Text near California: California by former Geographers was always taken for part of ye continent; but by a Mapp (taken by ye Dutch from ye Spaniards) its found to be an Island, to contain where broadest 500 Leagues from Cape Mendocino even to Cape S.t Luke according to Francis Gaule &amp; ye forementioned Mapp to extend in length 1700 leagues.Title and dedication within cartouche/vignette of Native chiefs, workers, and a crocodile (bottom left).  Similar vignette of Native seated near turtle, snake and monkey (bottom center).</mods:note>
          <mods:identifier displayLabel="FileMaker Pro Record Number" type="local">629</mods:identifier>
          <mods:note displayLabel="general_state_note">Tooley  92 &amp; Leighly  163 (State 2) ; The discovery of the world; Maps of the earth and the cosmos, p.65 / The David M. Stewart Museum, 1985.</mods:note>
          <mods:note displayLabel="state_node_1">As above.Inset: Polar projection (W 180-- E 180/N 90-- N 50). Dedication: To Her most Sacred MAJ.TY ANN QUEEN OF GREAT BRITAIN, FRANCE AND IRELAND This MAPP of AMERICA Is Most Humbly Dedicated by Your Majesties most Dutyfull Subject - Henry Overton 1711.  (above title, lower left). Cartouche at upper right states: "Printed and sold by Henry Overton at the White hourse without Newgate".Map includes part of western Africa and Spain.</mods:note>
          <mods:note displayLabel="state_node_4">Issued [1730].57 x 96 cm. Insets: North polar projection (upper left).   Vignettes of beavers in Canada and Niagara Falls (center left) and cod fishery in Newfoundland (bottom right), used on 1705 De Fer map and also by Moll.  Six engravings depicting Native customs, copied from De Bry illustrations (top and center right, replace map of western Africa and Spain as found in State 1).Dedication: To Her most Sacred MAJ.TY CAROLINE QUEEN OF GREAT BRITAIN, FRANCE AND IRELAND This MAPP of AMERICA Is Most Humbly Dedicated by Your Majesties most Dutyfull Subject Henry Overton.  (above title, within vignette).  [Queen Caroline reigned 1727-1737].</mods:note>
          <mods:subject>
            <mods:topic>America--Maps--To 1800</mods:topic>
            <mods:topic>America--Maps--1711</mods:topic>
            <mods:topic>California as an island--Maps--1711</mods:topic>
          </mods:subject>
          <mods:identifier displayLabel="SU DRUID" type="local">druid:bd935rr8206</mods:identifier>
          <mods:genre>Early Maps</mods:genre>
          <mods:genre>Digital Maps</mods:genre>
          <mods:relatedItem type="host">
            <mods:titleInfo>
              <mods:nonSort>The</mods:nonSort>
              <mods:title>mapping of California as an island</mods:title>
              <mods:subTitle>an illustrated checklist</mods:subTitle>
            </mods:titleInfo>
            <mods:titleInfo type="alternative">
              <mods:title>California as an island</mods:title>
            </mods:titleInfo>
            <mods:name type="personal">
              <mods:namePart>McLaughlin, Glen</mods:namePart>
              <mods:namePart type="date">1934-</mods:namePart>
              <mods:role>
                <mods:roleTerm authority="marcrelator" type="text">creator</mods:roleTerm>
              </mods:role>
            </mods:name>
            <mods:name type="personal">
              <mods:namePart>Mayo, Nancy H.</mods:namePart>
            </mods:name>
            <mods:name type="corporate">
              <mods:namePart>California Map Society</mods:namePart>
            </mods:name>
            <mods:typeOfResource>text</mods:typeOfResource>
            <mods:genre authority="marcgt">bibliography</mods:genre>
            <mods:originInfo>
              <mods:place>
                <mods:placeTerm authority="marccountry" type="code">cau</mods:placeTerm>
              </mods:place>
              <mods:place>
                <mods:placeTerm type="text">[Saratoga, CA]</mods:placeTerm>
              </mods:place>
              <mods:publisher>California Map Society</mods:publisher>
              <mods:dateIssued>c1995</mods:dateIssued>
              <mods:dateIssued encoding="marc" keyDate="yes">1995</mods:dateIssued>
              <mods:edition>1st ed.</mods:edition>
              <mods:issuance>monographic</mods:issuance>
            </mods:originInfo>
            <mods:physicalDescription>
              <mods:form authority="marcform">print</mods:form>
              <mods:extent>xvi, 134, [7] p. : ill., maps ; 28 cm.</mods:extent>
            </mods:physicalDescription>
            <mods:note displayLabel="statement of responsibility">Glen McLaughlin with Nancy H. Mayo.</mods:note>
            <mods:note>Includes bibliographical references (p. xv-xvi) and indexes.</mods:note>
            <mods:subject>
              <mods:geographicCode authority="marcgac">n-us-ca</mods:geographicCode>
            </mods:subject>
            <mods:subject authority="lcsh">
              <mods:topic>Cartography</mods:topic>
              <mods:geographic>California</mods:geographic>
              <mods:topic>History</mods:topic>
              <mods:genre>Sources</mods:genre>
            </mods:subject>
            <mods:subject authority="lcsh">
              <mods:geographic>California</mods:geographic>
              <mods:topic>Maps</mods:topic>
              <mods:topic>Early works to 1800</mods:topic>
              <mods:genre>Bibliography</mods:genre>
              <mods:genre>Catalogs</mods:genre>
            </mods:subject>
            <mods:classification authority="lcc">GA413 .M38 1995</mods:classification>
            <mods:classification authority="ddc" edition="21">912.794</mods:classification>
            <mods:identifier displayLabel="Symphony Catalog Key" type="local">3306259</mods:identifier>
            <mods:identifier invalid="yes" type="isbn">01888126000</mods:identifier>
            <mods:identifier type="lccn">97119748</mods:identifier>
            <mods:identifier type="uri">http://collections.stanford.edu/bookreader-public/view.jsp?id=00021264#1</mods:identifier>
            <mods:location>
              <mods:url usage="primary display">http://collections.stanford.edu/bookreader-public/view.jsp?id=00021264#1</mods:url>
            </mods:location>
            <mods:recordInfo>
              <mods:descriptionStandard>aacr2</mods:descriptionStandard>
              <mods:recordContentSource authority="marcorg">DNA</mods:recordContentSource>
              <mods:recordCreationDate encoding="marc">960319</mods:recordCreationDate>
              <mods:recordIdentifier>a3306259</mods:recordIdentifier>
            </mods:recordInfo>
          </mods:relatedItem>
        </mods:mods>
      </foxml:xmlContent>
    </foxml:datastreamVersion>
  </foxml:datastream>
</foxml:digitalObject>
})