--http://msdn.microsoft.com/en-us/library/ms188282.aspx
DECLARE @x xml ='<Entities>
	<Entity>
		<HeaderId>10</HeaderId>
		<HeaderValue>20</HeaderValue>
		<Details>
			<Detail>
				<Id>100</Id>
				<Value>200</Value>
			</Detail>
			<Detail>
				<Id>300</Id>
				<Value>400</Value>
			</Detail>
		</Details>
	</Entity>
	<Entity>
		<HeaderId>30</HeaderId>
		<HeaderValue>40</HeaderValue>
		<Details>
			<Detail>
				<Id>500</Id>
				<Value>600</Value>
			</Detail>
		</Details>
	</Entity>
</Entities>'

SELECT 
 detail.query('Id/text()[1]') DetailIdAsXML
,detail.value('Id[1]', 'nvarchar(20)') DetailId
,detail.value('Value[1]', 'nvarchar(20)') DetailValue
,detail.value('../../HeaderId[1]', 'nvarchar(20)') HeaderId
,detail.value('../../HeaderValue[1]', 'nvarchar(20)') HeaderValue
,detail.value('../..', 'nvarchar(80)') Header
from @x.nodes('/Entities/Entity/Details/Detail') details(detail)