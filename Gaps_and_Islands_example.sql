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


-- Example 3: 
-- Table: Failed
-- 
-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | fail_date    | date    |
-- +--------------+---------+
-- fail_date is the primary key for this table.
-- This table contains the days of failed tasks.
--
-- Table: Succeeded
-- 
-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | success_date | date    |
-- +--------------+---------+
-- success_date is the primary key for this table.
-- This table contains the days of succeeded tasks.
--  
-- A system is running one task every day. Every task is independent of the previous tasks. The tasks can fail or succeed.
-- Write an SQL query to generate a report of period_state for each continuous interval of days in the period from 2019-01-01 to 2019-12-31.
-- period_state is 'failed' if tasks in this interval failed or 'succeeded' if tasks in this interval succeeded. Interval of days are retrieved as start_date and end_date.
-- Return the result table ordered by start_date.
-- The query result format is in the following example.
--
-- Input: 
-- Failed table:
-- +-------------------+
-- | fail_date         |
-- +-------------------+
-- | 2018-12-28        |
-- | 2018-12-29        |
-- | 2019-01-04        |
-- | 2019-01-05        |
-- +-------------------+
-- Succeeded table:
-- +-------------------+
-- | success_date      |
-- +-------------------+
-- | 2018-12-30        |
-- | 2018-12-31        |
-- | 2019-01-01        |
-- | 2019-01-02        |
-- | 2019-01-03        |
-- | 2019-01-06        |
-- +-------------------+
-- Output: 
-- +--------------+--------------+--------------+
-- | period_state | start_date   | end_date     |
-- +--------------+--------------+--------------+
-- | succeeded    | 2019-01-01   | 2019-01-03   |
-- | failed       | 2019-01-04   | 2019-01-05   |
-- | succeeded    | 2019-01-06   | 2019-01-06   |
-- +--------------+--------------+--------------+
-- Explanation: 
-- The report ignored the system state in 2018 as we care about the system in the period 2019-01-01 to 2019-12-31.
-- From 2019-01-01 to 2019-01-03 all tasks succeeded and the system state was "succeeded".
-- From 2019-01-04 to 2019-01-05 all tasks failed and the system state was "failed".
-- From 2019-01-06 to 2019-01-06 all tasks succeeded and the system state was "succeeded".

select state as period_state
, min(dt) as start_date
, max(dt) as end_date
from (
select state
, dt
, row_number() over (order by dt asc) - row_number() over (partition by state order by dt asc) as state_rn
from (
    select 'failed' state, fail_date dt
    from failed
    where fail_date between '2019-01-01' and '2019-12-31'
    union 
    select 'succeeded' state, success_date dt
    from succeeded
    where success_date between '2019-01-01' and '2019-12-31'
    )sub 
)sub2
group by state, state_rn
order by start_date asc 
