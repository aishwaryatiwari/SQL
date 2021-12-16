--1. Second highest salary
-- Returns null when no second highest rank exists

select max(salary) from employee
where salary < (select max(salary) from employee);

--2. nth highest salary
--dense rank is used here to ensure the duplicates, if any, in salary are handled apropriately. If we use row_number, we will not be
--able to handle duplicates.
-- Returns blank when no second highest rank exists

select salary from 
(select salary, dense_rank() over (order by salary desc) as dn
from employee)sub
where dn = n ;

--3. This example reiterates the usage of dense_rank over other rank functions and row_number.
--Rank Scores to give same rank to equal values and to not skip ranks - i.e. Avoid holes in ranks
select score, dense_rank() over (order by score desc) as Rank
from Scores
order by Rank asc;

--4. Given employee table with employee ID, employee name, salary and manager ID, find which employees earn more than the manager
select emp_nm as Employee from
(
select a.name emp_nm, a.salary as emp_sal, b.salary mgr_sal
from employee a 
left join employee b on a.managerId= b.Id)
where emp_sal > mgr_sal;

--5. Return the email that repeats in the table Person with structure {ID (unique), email}
select Email
from Person 
group by Email
having count(*) > 1;

--6. Return customers who never placed an order from the customers table and order table
Select a.Name as customers
from customers a 
left join orders b on a.ID = b.CustomerID
where b.ID is null
order by a.name;

--7. Return employees who have the highest salary in their respective departments
--Approach 1 - using subquery
select b.Name as Department, a.Name as Employee, b.max_sal as Salary
from Employee a join 
(
select Employee.DepartmentID, Department.Name, max(Employee.Salary) as max_sal
    from Employee
    join Department on employee.departmentID = department.ID
    group by Employee.DepartmentID, Department.Name
)b
on a.DepartmentID = b.DepartmentID and a.salary = b.max_sal;

--Approach 2 - using CTE
with empcte as (select empname, deptid, 
                salary, dense_rank() over (partition by deptid order by salary desc) 
                as dr
                from emp)
select * from empcte where dr=1;

--8. Find the three highest salaried employees in every department
-- Approach 1 : using ranking function
select Department, Employee, Salary from (
select b.name as Department, a.name as Employee, a.salary, 
dense_rank() over (partition by a.departmentId order by salary desc) as dn
from employee a
join department b on a.departmentID = b.ID)
where dn < 4 ;

-- Approach 2 : using corelated sub query
select department, employee, salary
from employee e 
inner join department b on a.dept_id = b.dept_id
where (select count(distinct salary) from employee where dept_id = e.dept_id and salary > e.salary ) < 3 ;

--9. A table has duplicate emails for different IDs. Keep the row with the email with minimum ID and delete the rest

delete from Person where id not in( 
        select min(id) as id from Person group by email
    ) t;

--10. select the ID of those days where temperature is greater than that of the previous day

select  b.ID
from weather a
left join weather b on b.recorddate = a.recorddate + 1
where b.temperature - a.temperature > 0;

--11. display class names which have more than 5 students
select class 
from courses
group by class
having count(distinct student) >= 5;

--12. Exchange the sex assignments in the given table. (Set m to f and f to m)
UPDATE salary 
SET sex = IF(sex='m','f','m');

--13. Calculate cumulative average/sum
--table is as follows - {date, salary}

select date, sal, sum(sal) over (order by date asc)
from tbl;

--14. calculate moving average like rolling 3 months etc
-- This method may not work if data has missing months
--Aproach 1: using window functions
select date, sal, sum(sal) over (order by date asc rows between 2 preceding and current row)
from tbl;
--for forward looking moving average - 
select date, sal, sum(sal) over (order by date desc rows between 2 preceding and current row)
from tbl;
--for centered averages eg. 3 preceding and 3 succeeding
select date, sal, sum(sal) over (order by date desc rows between 3 preceding and 3 following)
from tbl;

-- Approach 2: without using window sum - This method takes care of cases where data has missing months
select t1.date, t1.sal, sum(t2.sal)
from tbl t1 
join tbl t2 on t2.date between t1.date-2 and t1.date
group by 1,2;

-- Write an SQL query to calculate the cumulative salary summary for every employee in a single unified table.
-- 
-- The cumulative salary summary for an employee can be calculated as follows:
-- 
-- For each month that the employee worked, sum up the salaries in that month and the previous two months. This is their 3-month sum for that month. 
-- If an employee did not work for the company in previous months, their effective salary for those months is 0.
-- Do not include the 3-month sum for the most recent month that the employee worked for in the summary.
-- Do not include the 3-month sum for any month the employee did not work.
-- Return the result table ordered by id in ascending order. In case of a tie, order it by month in descending order.
-- 
-- The query result format is in the following example.
--Input: 
--Employee table:
--+----+-------+--------+
--| id | month | salary |
--+----+-------+--------+
--| 1  | 1     | 20     |
--| 2  | 1     | 20     |
--| 1  | 2     | 30     |
--| 2  | 2     | 30     |
--| 3  | 2     | 40     |
--| 1  | 3     | 40     |
--| 3  | 3     | 60     |
--| 1  | 4     | 60     |
--| 3  | 4     | 70     |
--| 1  | 7     | 90     |
--| 1  | 8     | 90     |
--+----+-------+--------+
--Output: Incomplete - should include one record for  user 1, month 7, as explained in the explantion section below.
--+----+-------+--------+
--| id | month | Salary |
--+----+-------+--------+
--| 1  | 4     | 130    |
--| 1  | 3     | 90     |
--| 1  | 2     | 50     |
--| 1  | 1     | 20     |
--| 2  | 1     | 20     |
--| 3  | 3     | 100    |
--| 3  | 2     | 40     |
--+----+-------+--------+
--Explanation: 
--Employee '1' has five salary records excluding their most recent month '8':
--- 90 for month '7'.
--- 60 for month '4'.
--- 40 for month '3'.
--- 30 for month '2'.
--- 20 for month '1'.
--So the cumulative salary summary for this employee is:
--+----+-------+--------+
--| id | month | salary |
--+----+-------+--------+
--| 1  | 7     | 90     |  (90 + 0 + 0)
--| 1  | 4     | 130    |  (60 + 40 + 30)
--| 1  | 3     | 90     |  (40 + 30 + 20)
--| 1  | 2     | 50     |  (30 + 20 + 0)
--| 1  | 1     | 20     |  (20 + 0 + 0)
--+----+-------+--------+
--Note that the 3-month sum for month '7' is 90 because they did not work during month '6' or month '5'.


-- Note: Cannot using window functions like sum() over (preceding, ), lead, lag etc. because of missing months. 
-- Unoptimized way of doing this with 2 joins - 
with emp_cte as (
    select id
    , max(month) max_mth
    from Employee
    group by id)
select e1.id
, e1.month
, e1.salary + isnull(e2.salary,0) + isnull(e3.salary,0) Salary
from Employee e1
join emp_cte on emp_cte.id = e1.id
left join Employee e2 on e1.id = e2.id and e1.month - 1 = e2.month
left join Employee e3 on e3.id = e2.id and e2.month - 1 = e3.month
where e1.month != emp_cte.max_mth ;

-- Optimized way with only one join - 
with emp_cte as (
    select id
    , max(month) max_mth
    from Employee
    group by id)
select e1.id
, e1.month
, sum(isnull(e2.salary,0)) Salary
from Employee e1
join emp_cte on emp_cte.id = e1.id
left join Employee e2 on e1.id = e2.id and e2.month between e1.month - 2 and e1.month
where e1.month != emp_cte.max_mth
group by e1.id
, e1.month

--15. Do the three dimensions form a triangle?
select x,y,z, case when x+y>z and x+z>y and y+z>x 
					then 'yes'
					else 'no'
				end
from tablet;

--16. Find all unique city names that begin with vowels (a,e,i,o,u). This is an example of regex operators.
select distinct city
from station
where city like '[a,e,i,o,u]%';

--17. Query the Name of any student in STUDENTS who scored higher than 75 Marks. 
-- Order your output by the last three characters of each name. If two or more students both have names ending in the same last three characters, 
-- secondary sort them by ascending ID.
select name
from students
where marks > 75
order by right(name, 3) asc, id asc;

--18. Query the sum of Northern Latitudes (LAT_N) from STATION having values greater than 38.7880 and less than 137.2345. 
-- Truncate your answer to 4 decimal places.

-- SQL server does not have a truncate function, similar to round. If we use round(x,4) here, it simply zeroes out the digits after the 4th decimal place, 
-- but does not actually remove them. Using cast as decimal solves this issue. 
select cast(sum(case when lat_n between 38.7880 and 137.2345 then lat_n else 0 end) as decimal(18,4)) as sum_lat_n
from station;

--19. Display node number and its type - root, inner or leaf. Sample data - 
--| N  | P |
--| 1  | 2 |
--| 3  | 2 |
--| 6  | 8 |
--| 9  | 8 |
--| 2  | 5 |
--| 8  | 5 |
--| 5  |   |

select N, case when P is null then 'root'
	       when N in (select distinct P from bst) then 'inner'
	       else 'leaf'
	       end
from bst
order by N;

--20. Find the shortest distance between any two points in the table. Euclidean distance. 
-- Important to exclude distance calculation between the point and itself. Easier to exclude with a not(x and y) than using a confusing 'or' condition.
select cast(min(sqrt(power(a.x-b.x, 2) + power(a.y-b.y, 2))) as numeric(18,2)) shortest
from point2d a
join point2d b on not(a.x = b.x and a.y = b.y);


-- 21. Input: 
-- Seat table:
-- +----+---------+
-- | id | student |
-- +----+---------+
-- | 1  | Abbot   |
-- | 2  | Doris   |
-- | 3  | Emerson |
-- | 4  | Green   |
-- | 5  | Jeames  |
-- +----+---------+
-- Output: 
-- +----+---------+
-- | id | student |
-- +----+---------+
-- | 1  | Doris   |
-- | 2  | Abbot   |
-- | 3  | Green   |
-- | 4  | Emerson |
-- | 5  | Jeames  |
-- +----+---------+
-- Explanation: 
-- Note that if the number of students is odd, there is no need to change the last one's seat.

select case when id%2=0 then id-1 
            when id%2 != 0 and id < (select max(id) from seat) then id+1
            else id end as id
, student
from seat
order by id asc;

-- 22. Input: 
--Customer table:
--+-------------+-------------+
--| customer_id | product_key |
--+-------------+-------------+
--| 1           | 5           |
--| 2           | 6           |
--| 3           | 5           |
--| 3           | 6           |
--| 1           | 6           |
--+-------------+-------------+
--Product table:
--+-------------+
--| product_key |
--+-------------+
--| 5           |
--| 6           |
--+-------------+
--Output: 
--+-------------+
--| customer_id |
--+-------------+
--| 1           |
--| 3           |
--+-------------+
--Explanation: 
--The customers who bought all the products (5 and 6) are customers with IDs 1 and 3.

select customer_id
from customer
group by customer_id
having count(distinct product_key) = (select count(product_key) from product);

-- 23. List of customers who ordered atleast one of each 'A' and 'B', but none of 'C'

SELECT a.customer_id, b.customer_name
FROM orders a
join customers b on a.customer_id = b.customer_id
GROUP BY a.customer_id, b.customer_name
HAVING sum(case when product_name = 'A' then 1 else 0 end) > 0
   and sum(case when product_name = 'B' then 1 else 0 end) > 0 
   and sum(case when product_name = 'C' then 1 else 0 end) = 0 ;
   
-- 24. List of customers who ordered atleast one of each 'A' and 'B'
SELECT customer_id 
FROM orders
WHERE product_name in ('A','B')
GROUP BY customer_id
having count(distinct product_name) = 2;

-- 25. Write an SQL query to find all the possible page recommendations for every user. Each recommendation should appear as a row in the result table with these columns:

-- user_id: The ID of the user that your system is making the recommendation to.
-- page_id: The ID of the page that will be recommended to user_id.
-- friends_likes: The number of the friends of user_id that like page_id.

--Input: 
--Friendship table:
--+----------+----------+
--| user1_id | user2_id |
--+----------+----------+
--| 1        | 2        |
--| 1        | 3        |
--| 1        | 4        |
--| 2        | 3        |
--| 2        | 4        |
--| 2        | 5        |
--| 6        | 1        |
--+----------+----------+
--Likes table:
--+---------+---------+
--| user_id | page_id |
--+---------+---------+
--| 1       | 88      |
--| 2       | 23      |
--| 3       | 24      |
--| 4       | 56      |
--| 5       | 11      |
--| 6       | 33      |
--| 2       | 77      |
--| 3       | 77      |
--| 6       | 88      |
--+---------+---------+
--Output: 
--+---------+---------+---------------+
--| user_id | page_id | friends_likes |
--+---------+---------+---------------+
--| 1       | 77      | 2             |
--| 1       | 23      | 1             |
--| 1       | 24      | 1             |
--| 1       | 56      | 1             |
--| 1       | 33      | 1             |
--| 2       | 24      | 1             |
--| 2       | 56      | 1             |
--| 2       | 11      | 1             |
--| 2       | 88      | 1             |
--| 3       | 88      | 1             |
--| 3       | 23      | 1             |
--| 4       | 88      | 1             |
--| 4       | 77      | 1             |
--| 4       | 23      | 1             |
--| 5       | 77      | 1             |
--| 5       | 23      | 1             |
--+---------+---------+---------------+

with user_frnd_page as (
    SELECT a.user1_id, b.user_id, b.page_id # user, all user friends, page_id
    FROM Friendship as a
    JOIN Likes as b
    ON a.user2_id=b.user_id
    UNION 
    SELECT a.user2_id,b.user_id,b.page_id
    FROM Friendship as a
    JOIN Likes as b
    ON a.user1_id=b.user_id)
select a.user1_id user_id, a.page_id, count(a.user_id) friends_likes
from user_frnd_page a
left join Likes b on a.user1_id = b.user_id and a.page_id = b.page_id
where b.page_id is null
group by a.user1_id, a.page_id ; 


-- 26. The install date of a player is the first login day of that player.
-- We define day one retention of some date x to be the number of players whose install date is x and they logged back in on the day right after x,
-- divided by the number of players whose install date is x, rounded to 2 decimal places.
-- Write an SQL query to report for each install date, the number of players that installed the game on that day, and the day one retention.
-- Input: 
-- Activity table:
-- +-----------+-----------+------------+--------------+
-- | player_id | device_id | event_date | games_played |
-- +-----------+-----------+------------+--------------+
-- | 1         | 2         | 2016-03-01 | 5            |
-- | 1         | 2         | 2016-03-02 | 6            |
-- | 2         | 3         | 2017-06-25 | 1            |
-- | 3         | 1         | 2016-03-01 | 0            |
-- | 3         | 4         | 2016-07-03 | 5            |
-- +-----------+-----------+------------+--------------+
-- Output: 
-- +------------+----------+----------------+
-- | install_dt | installs | Day1_retention |
-- +------------+----------+----------------+
-- | 2016-03-01 | 2        | 0.50           |
-- | 2017-06-25 | 1        | 0.00           |
-- +------------+----------+----------------+
-- Explanation: 
-- Player 1 and 3 installed the game on 2016-03-01 but only player 1 logged back in on 2016-03-02 so the day 1 retention of 2016-03-01 is 1 / 2 = 0.50
-- Player 2 installed the game on 2017-06-25 but didn't log back in on 2017-06-26 so the day 1 retention of 2017-06-25 is 0 / 1 = 0.00

-- Notice that this is written for MySQL and in MySQL, division and rounding works to get the desired result of fraction rounded t 2 decimal places.
-- Similar syntax may not work in SQL Server.

with install_cte as (
    select player_id, min(event_date) install_dt
    from activity
    group by player_id)
select a.install_dt
, count(a.player_id) as installs
, round(count(b.player_id)/count(a.player_id), 2) as Day1_retention
from install_cte a
left join Activity b on a.player_id = b.player_id and a.install_dt + 1 = b.event_date
group by a.install_dt
order by 1;

--27. The following question wants information of all users in the system and the number of orders in 2019.
-- While seemingly simple, it requires attention to the use of case vs where clause. 
-- Instinctively using where clause will eliminate users who have no order for 2019, thus giving incorrect answer.

select u.user_id as buyer_id, u.join_date, count(case when year(o.order_date) = '2019' then o.order_id
                                                 else null end) as orders_in_2019
from users u
left join orders o on u.user_id = o.buyer_id
left join items i on o.item_id = i.item_id
group by u.user_id, u.join_date

--27. Generate rows based on a column value - 
-- Input: 
-- Tasks table:
-- +---------+----------------+
-- | task_id | subtasks_count |
-- +---------+----------------+
-- | 1       | 3              |
-- | 2       | 2              |
-- | 3       | 4              |
-- +---------+----------------+
-- Executed table:
-- +---------+------------+
-- | task_id | subtask_id |
-- +---------+------------+
-- | 1       | 2          |
-- | 3       | 1          |
-- | 3       | 2          |
-- | 3       | 3          |
-- | 3       | 4          |
-- +---------+------------+
-- Output: 
-- +---------+------------+
-- | task_id | subtask_id |
-- +---------+------------+
-- | 1       | 1          |
-- | 1       | 3          |
-- | 2       | 1          |
-- | 2       | 2          |
-- +---------+------------+
-- Explanation: 
-- Task 1 was divided into 3 subtasks (1, 2, 3). Only subtask 2 was executed successfully, so we include (1, 1) and (1, 3) in the answer.
-- Task 2 was divided into 2 subtasks (1, 2). No subtask was executed successfully, so we include (2, 1) and (2, 2) in the answer.
-- Task 3 was divided into 4 subtasks (1, 2, 3, 4). All of the subtasks were executed successfully.

with recursive cte as (
      select task_id, subtasks_count, 1 as subtask_id
      from tasks
      union all
      select task_id, subtasks_count, 1 + subtask_id
      from cte
      where subtask_id < subtasks_count
    )
select a.task_id, a.subtask_id
from cte a
left join Executed b on a.task_id = b.task_id and a.subtask_id = b.subtask_id
where b.subtask_id is null
order by 1,2;
