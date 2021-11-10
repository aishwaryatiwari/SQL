--This is an example of gaps and islands problem in SQL
-- Example 1: Return consecutively repeating status 'FREE' more than thrice from a movie theatre seat booking table as follows : 
--	||id_set | number  | status  ||      
--	||-------|---------|---------||
--	||1      | 000001  | ASSIGNED||
--	||1      | 000002  | FREE    ||
--	||1      | 000003  | ASSIGNED||
--	||1      | 000004  | FREE    ||
--	||1      | 000005  | FREE    ||
--	||1      | 000006  | ASSIGNED||
--	||1      | 000007  | ASSIGNED||
--	||1      | 000008  | FREE    ||
--	||1      | 000009  | FREE    ||
--	||1      | 000010  | FREE    ||
--	||1      | 000011  | ASSIGNED||
--	||1      | 000012  | ASSIGNED||
--	||1      | 000013  | ASSIGNED||
--	||1      | 000014  | FREE    ||
--	||1      | 000015  | ASSIGNED||

--Output
--	||id_set | number  ||
--	||1      | 000008  ||
--	||1      | 000009  ||
--	||1      | 000010  ||
WITH partitioned AS (
  SELECT
    *,
    number - ROW_NUMBER() OVER (PARTITION BY id_set) AS grp
  FROM atable
  WHERE status = 'FREE'
),
counted AS (
  SELECT
    *,
    COUNT(*) OVER (PARTITION BY id_set, grp) AS cnt
  FROM partitioned
)
SELECT
  id_set,
  number
FROM counted
WHERE cnt >= 3;


-- Example 2: Find which number appears atleast n times consecutively 
-- ID	 Num	group_id	cnt
--  1	   1	       0		3
--  2	   1	       0		3
--  3	   1	       0		3
--  4	   2	       3		2
--  5	   2	       3		2
--  6	   3	       5		1
--  7	   2	       4		1
Select distinct sal 
from (
    Select id, sal, group_id, count(*) over (partition by sal, group_id) as cnt
    from (
        Select id, sal
        , row_number() over (order by id) 
        - row_number() over (partition by sal order by id) as group_id
        from dbo.del)sub
    )sub2
where sub2.cnt >= n;
