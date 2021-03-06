function Create_XMLFromCSVWithLevels()
{
    $createData = @(
                    (new-object psobject -Property @{
                                                    Pk = 1
                                        			SerieDocument="Manual"
                                        			NumarDocument="0111232"
                                        			TipDocument ="CC"
                                        			Data = [datetime]"10/15/2012 12:00:00 AM"
                                        			BillTo= "PJ628761"
                                        			Locatie = 22
                                        			CodArticol="Conf1"
                                        		    Cantitate = 1.000
                                        			Pret = 0.0000000000                                        				
                                               }),
                    (new-object psobject -Property @{
                                                    Pk = 2
                                        			SerieDocument="Manual"
                                        			NumarDocument="0111232"
                                        			TipDocument ="CC"
                                        			Data = [datetime]"10/15/2012 12:00:00 AM"
                                        			BillTo= "PJ628761"
                                        			Locatie = 22
                                        			CodArticol="Conf2"
                                        		    Cantitate = 1.000
                                        			Pret = 0.0000000000                                        				
                                               }),
                    (new-object psobject -Property @{
                                                    Pk = 2
                                        			SerieDocument="Manual"
                                        			NumarDocument="0111232"
                                        			TipDocument ="CC"
                                        			Data = [datetime]"10/15/2012 12:00:00 AM"
                                        			BillTo= "PJ628761"
                                        			Locatie = 22
                                        			CodArticol="Conf1"
                                        		    Cantitate = 1.000
                                        			Pret = 0.0000000000                                        				
                                               })
                   )
    $createData|select *|export-csv e:\withLevelsforxml.csv -NoTypeInformation -Delimiter ";"                                                                                                         
    $dataFromCsv = import-csv e:\withLevelsforxml.csv -delimiter ';'
    [xml]$xml = "
        <Message>
            <Documente>
                $($dataFromCsv|group Pk|%{
                        "<Document>
                            <Pk>"+$_.Name+"</Pk>
                            <SerieDocument>"+$_.Group[0].SerieDocument+"</SerieDocument>
                            <NumarDocument>"+$_.Group[0].NumarDocument+"</NumarDocument>
                            <TipDocument>"+$_.Group[0].NumarDocument+"</TipDocument>
                            <Data>"+$_.Group[0].Data+"</Data>
                            <BillTo>"+$_.Group[0].BillTo+"</BillTo>
                            <Locatie>"+$_.Group[0].Locatie+"</Locatie>
                            <DetaliiDocument>"
                                $($_.Group|%{
                                "<DetaliuDocument>
                                    <CodArticol>"+$_.CodArticol+"</CodArticol>
                                    <Cantitate>"+$_.Cantitate+"</Cantitate>
                                    <Pret>"+$_.Pret+"</Pret>
                                 </DetaliuDocument>"}
                                 )
                            "</DetaliiDocument>
                        </Document>"}
                  )
            </Documente>
        </Message>"
        
    $xml.save("e:\fromcsvwithLevels.xml")
}
function Create_CsvFromXMLWithLevels()
{
    [xml]$messages = "<Message>
                          <Documente>
                            <Document>
                              <Pk>1</Pk>
                              <SerieDocument>Manual</SerieDocument>
                              <NumarDocument>0111232</NumarDocument>
                              <TipDocument>CC</TipDocument>
                              <Data>10/15/2012 12:00:00 AM</Data>
                              <BillTo>PJ628761</BillTo>
                              <Locatie>22</Locatie>
                              <DetaliiDocument>
                                <DetaliuDocument>
                                  <CodArticol>Conf1</CodArticol>
                                  <Cantitate>1</Cantitate>
                                  <Pret>0</Pret>
                                </DetaliuDocument>
                              </DetaliiDocument>
                            </Document>
                            <Document>
                              <Pk>2</Pk>
                              <SerieDocument>Manual</SerieDocument>
                              <NumarDocument>0111232</NumarDocument>
                              <TipDocument>CC</TipDocument>
                              <Data>10/15/2012 12:00:00 AM</Data>
                              <BillTo>PJ628761</BillTo>
                              <Locatie>22</Locatie>
                              <DetaliiDocument>
                                <DetaliuDocument>
                                  <CodArticol>Conf2</CodArticol>
                                  <Cantitate>1</Cantitate>
                                  <Pret>0</Pret>
                                </DetaliuDocument>
                                <DetaliuDocument>
                                  <CodArticol>Conf1</CodArticol>
                                  <Cantitate>1</Cantitate>
                                  <Pret>0</Pret>
                                </DetaliuDocument>
                              </DetaliiDocument>
                            </Document>
                          </Documente>
                     </Message>"
    $messages.Save("e:\withlevelsforcsv.xml")
    $messagesFromFile = [xml](Get-Content E:\WithlevelsForcsv.xml) 
    
    $messagesFromFile.Message.Documente.Document|%{
        $_.DetaliiDocument.DetaliuDocument|%{
            $header = $_.ParentNode.ParentNode
            $result =new-object psobject -Property @{
                                                        Pk            = $header.Pk
                                                        SerieDocument = $header.SerieDocument
                                                        NumarDocument = $header.NumarDocument
                                                        TipDocument   = $header.TipDocument
                                                        Data          = $header.Data
                                                        BillTo        = $header.BillTo
                                                        Locatie       = $header.Locatie
                                                        CodArticol    = $_.CodArticol
                                                        Cantitate     = $_.Cantitate
                                                        Pret          = $_.Pret
                                                     }
            $result
        }
    }|select *|export-csv e:\fromxmlWithLevels.csv -NoTypeInformation -Delimiter ";"
}
function Create_XmlFromCSV()
{
    $result = @(
                (new-object psobject -Property @{
                                                    Pk            = 1
                                                    SerieDocument = "aa"
                                                    NumarDocument = 1
                                                    TipDocument   = "CC"
                                                    Data          = [datetime]"2013-01-01"
                                                    BillTo        = "aa"
                                                    Locatie       = "S1"
                                                    CodArticol    = "P1"
                                                    Cantitate     = 10
                                                    Pret          = 2.5
                                               }),
                (new-object psobject -Property @{
                                                    Pk            = 1
                                                    SerieDocument = "aa"
                                                    NumarDocument = 1
                                                    TipDocument   = "CC"
                                                    Data          = [datetime]"2013-01-01"
                                                    BillTo        = "aa"
                                                    Locatie       = "S1"
                                                    CodArticol    = "P2"
                                                    Cantitate     = 15
                                                    Pret          = 2.5
                                                })
            )
   $result| select *|export-csv e:\simpleForxml.csv -NoTypeInformation -Delimiter ";"#nu trebuie neaparat salvat in csv, doar ca exemplu
   $loadFromCsv = import-csv e:\simpleForxml.csv -delimiter ';'
   $xmlResult = [xml]"<Documente>
                        $($loadFromCsv|%{
                            "<Document>
                                <SerieDocument>"+$_.SerieDocument+"</SerieDocument>
                                <NumarDocument>"+$_.NumarDocument+"</NumarDocument>
                                <TipDocument>"+$_.TipDocument+"</TipDocument>
                                <Data>"+$_.Data+"</Data>
                                <BillTo>"+$_.BillTo+"</BillTo>
                                <Locatie>"+$_.Locatie+"</Locatie>
                                <CodArticol>"+$_.CodArticol+"</CodArticol>
                                <Cantitate>"+$_.Cantitate+"</Cantitate>
                                <Pret>"+$_.Pret+"</Pret>
                             </Document>"}
                             )
                      </Documente>"      
    $xmlResult.save("e:\fromcsvsimple.xml")                                                                    
} 
function Create_CsvFromXml()
{
    $xmlResult = [xml]"<Documente>
                        <Document>
                            <Pk>1</Pk>
                            <SerieDocument>Manual</SerieDocument>
                            <NumarDocument>0111232</NumarDocument>
                            <TipDocument>CC</TipDocument>
                            <Data>10/15/2012 12:00:00 AM</Data>
                            <BillTo>PJ628761</BillTo>
                            <Locatie>22</Locatie>
                            <CodArticol>Conf1</CodArticol>
                            <Cantitate>1</Cantitate>
                            <Pret>0</Pret>
                        </Document>
                        <Document>
                            <Pk>2</Pk>
                            <SerieDocument>Manual</SerieDocument>
                            <NumarDocument>0111232</NumarDocument>
                            <TipDocument>CC</TipDocument>
                            <Data>10/15/2012 12:00:00 AM</Data>
                            <BillTo>PJ628761</BillTo>
                            <Locatie>22</Locatie>
                            <CodArticol>Conf2</CodArticol>
                            <Cantitate>1</Cantitate>
                            <Pret>0</Pret>
                         </Document>
                      </Documente>"                        
   $xmlResult.Save("E:\simpleforcsv.xml") #sample de salvare xml
   $xmlLoadFromFile = [xml](Get-Content E:\simpleforcsv.xml) #sample incarcare xml        
   $xmlLoadFromFile.Documente.Document|export-csv e:\fromsimplexml.csv -NoTypeInformation -Delimiter ";"
                                                                    
} 
Create_XmlFromCSV      
Create_CsvFromXml
Create_XMLFromCSVWithLevels
Create_CsvFromXMLWithLevels
    
