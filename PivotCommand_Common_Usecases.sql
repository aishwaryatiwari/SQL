--Pivot table and syntax and usage
--Example 1
--Pivot up sales made by agents country-wise
--Original table - {agent, country, sales}. 
--Required table - {agent, India, US, UK} with the sales values pivoted up
select agent, India, US, UK
from salestbl
pivot(
	sum(sales)
	for country 
	in ('India', 'US', 'UK')
	) as pivottable;
	
--Always remember to remove extra columns present in the sourcetable while applying pivot function. 
--For example - If the table structure is {RecordID, Agent, Country, Sales}
--Required table is {agent, India, US, UK} with the sales values pivoted up, then RecordID is an unnecessary column and must be removed before pivot is applied

select agent, India, UK, US
from (
		select agent, country, sales
		from salestbl
		)sourcetable
pivot(sum(sales)
		for country
		in ('India', 'UK', 'US')
		)as pivottable;

--Example 2
--table is as follows - 
--	||Country	|		City	||
--	||India		|		Hyd		||
--	||India		|		Blr		||
--	||India		|		DEL		||
--	||USA		|		SEA		||
--	||USA		|		NYC		||
--	||USA		|		SF		||

--Requirement is -
--  ||Country	|	City1	|	City2	|	City3	||
--  ||India		|	Hyd		|	Blr		|	DEL		||
--  ||USA		|	SEA		|	NY		|	SF		||

-- Step 1: Subquery should provide the following structure - 
--	||Country	|	City	|	Colseq	||	
--	||India		|	DEL		|	City1	||
--	||India		|	Blr		|	City2	||
--	||India		|	Hyd		|	City3	||
--	||USA		|	SEA		|	City1	||
--	||USA		|	NY		|	City2	||
--	||USA		|	SF		|	City3	||

SELECT Country, City1, City2, City3 from
(
select Country, City, City + cast(row_number() over (partition by country order by country) as varchar(10)) as colseq
from tbl) temp
pivot
( Max(City) 
	for colseq
	in (City1, City2, City3)
	)as pvt;
	
	
	
--Example 4
--Data is as follows - 
--	||Job		|	Name	||	
--	||doctor	|	a		||
--	||singer	|	b		||
--	||doctor	|	c		||

--Requirement is -
-- ||doctor |	singer	||
-- ||a 		|	b 		||
-- ||c		|	null	||

--We need an anchor to get multiple rows, while applying the min/max on the name column in pivot.

select Doctor, Professor, Singer, Actor from
(select occupation, name, row_number() over (partition by occupation order by name) as rn
from occupations)job
pivot (
min(name) for occupation in (Doctor, Professor, Singer, Actor)
)pvt;