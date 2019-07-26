--LeetCode Practise  - 
--1. Second highest salary

select max(salary) from employee
where salary < (select max(salary) from employee)

--2. nth highest salary

select salary from 
(select salary, dense_rank() over (order by salary desc) as dn
from employee)sub
where dn = n 

--3. Rank Scores to give same rank to equal values and to not skip ranks - i.e. Avoid holes in ranks
select score, dense_rank() over (order by score desc) as Rank
from Scores
order by Rank asc

--4. Return consecutively repeating number
--https://dba.stackexchange.com/questions/36943/find-n-consecutive-free-numbers-from-table
id_set  number  status         
-----------------------
1       000001  ASSIGNED
1       000002  FREE
1       000003  ASSIGNED
1       000004  FREE
1       000005  FREE
1       000006  ASSIGNED
1       000007  ASSIGNED
1       000008  FREE
1       000009  FREE
1       000010  FREE
1       000011  ASSIGNED
1       000012  ASSIGNED
1       000013  ASSIGNED
1       000014  FREE
1       000015  ASSIGNED
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
WHERE cnt >= 3
;

--5.Given employee table with employee ID, employee name, salary and manager ID, find which employees earn more than the manager
select emp_nm as Employee from
(
select a.name emp_nm, a.salary as emp_sal, b.salary mgr_sal
from employee a 
left join employee b on a.managerId= b.Id)
where emp_sal > mgr_sal

--6. Return the email that repeats in the table Person with structure {ID (unique), email}
select Email
from Person 
group by Email
having count(*) > 1

--7. Return customers who never placed an order from the customers table and order table
Select a.Name as customers
from customers a 
left join orders b on a.ID = b.CustomerID
where b.ID is null
order by a.name

--8. Return employees who have the highest salary in their respective departments
select b.Name as Department, a.Name as Employee, b.max_sal as Salary
from Employee a join 
(
select Employee.DepartmentID, Department.Name, max(Employee.Salary) as max_sal
    from Employee
    join Department on employee.departmentID = department.ID
    group by Employee.DepartmentID, Department.Name
)b
on a.DepartmentID = b.DepartmentID and a.salary = b.max_sal

--second approach
with empcte as (select empname, deptid, 
                salary, dense_rank() over (partition by deptid order by salary desc) 
                as dr
                from emp)
select * from empcte where dr=1;

--9. Find the three highest salaried employees in every department

select Department, Employee, Salary from (
select b.name as Department, a.name as Employee, a.salary, 
dense_rank() over (partition by a.departmentId order by salary desc) as dn
from employee a
join department b on a.departmentID = b.ID)
where dn < 4 ;

select department, employee, salary
from employee e 
inner join department b on a.dept_id = b.dept_id
where (select count(distinct salary) from employee where dept_id = e.dept_id and salary > e.salary ) < 3

Explanation : https://stackoverflow.com/questions/35653431/how-to-select-the-top-3-salaries-of-the-department

--10. A table has duplicate emails for different IDs. Keep the row with the email with minimum ID and delete the rest

delete from Person where id not in( 
    select t.id from (
        select min(id) as id from Person group by email
    ) t
)

--11. select the ID of those days where temperature is greater than that of the previous day
select  b.ID
from weather a
left join weather b on b.recorddate = a.recorddate + 1
where b.temperature - a.temperature > 0

--12. Calculate cancellation % based on Cab booking data
select a.request_at as Day,
round(sum(case when a.status not in ('completed') then 1 else 0 end)/count(*), 2) as Cancellation_Rate
from trips a 
left join users client on a.client_ID=client.users_ID
left join users driver on a.driver_ID = driver.users_id
where request_at between '2013-10-01' and '2013-10-03'
and client.banned = 'No'
and driver.banned = 'No'
group by a.request_at
order by a.request_at;

--13. display class names which have more than 5 students
select class 
from courses
group by class
having count(distinct student) >= 5;

--14. display a subset of rows based on given conditions
select id, movie, description, rating
from cinema
where lower(description) not in ('boring')
and mod(id, 2) != 0 
order by rating desc;

--15. rearrange id numbers of student seating arrangements

select 
Case when mod(id,2) != 0 then 
	(case when id = (select max(id) from seat)
	then id
	else id + 1
	end)
when mod(id,2) = 0 
then id - 1
end 
as id, student
from seat
order by id asc;
;

--16. exchange the sex assignments. set m to f and f to m
UPDATE salary 
SET sex = IF(sex='m','f','m');

--17. Median of a set of salary values per department
select emp.id, emp.salary, emp.dept_id
from employee emp, employee emp1
on emp.dept_id = emp1.dept_id
group by emp.dept_id, emp.salary
having sum(emp.salary = emp1.salary) >= abs(sum(emp.salary > emp1.salary)-(sum(emp.salary < emp1.salary)))

For distinct salary values
SUM(Employee.Salary = alias.Salary) is the frequency (which is always 1 for distinct values because the row will only match itself)
SUM(Employee.Salary > alias.Salary) is the number of smaller values
SUM(Employee.Salary < alias.Salary) is the number of bigger values
The pseudo code could be HAVING frequency >= abs(smaller_values - bigger_values)

--second approach - 
WITH OrdersBySP (SPID, Value, RowNum, CountOrders) AS  
(
	SELECT SalesPersonID, 
		Value, 
		ROW_NUMBER() OVER (PARTITION BY SalesPersonID ORDER BY Value), 
		COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID)
	FROM Sales.OrdersBySalesperson AS OBSP 
	WHERE SalesPersonID IN (274, 275, 277, 278, 279, 282)
)

SELECT SPID, AVG(Value) as AvgValue 
FROM OrdersBySP
WHERE RowNum BETWEEN (CountOrders + 1)/2 AND (CountOrders + 2)/2 
GROUP BY SPID;

--18. Mode of every department
select dept_id, top 1 freq from 
employee 
group by dept_id, salary
order by count(*) desc
(	select dept_id, salary, count(*) as freq 
	from employee
	group by 1,2
	) sub
	order by freq desc
	
--19. Managers with more than 5 reportees - 
select a.id, a.name
from emp a where a.id in (select mgr_id from emp b group by mgr_id having count(b.id)>=5)

--or 

select a.id, a.name 
from emp a
join emp b on a.id = b.mgr_id
group by a.id, a.name
having count(b.id) >=5

--20. candidate with the highest votes
--Method 1:
select a.id, a.name from (
select a.id, a.name, count(b.id) votes, row_number() over 
  (order by count(b.id) desc) rn
from atbl a
join btbl b on a.id=b.cand_id
group by a.id, a.name)a
where rn=1;

--Method 2:
select a.id, a.name from atbl a join
(select b.cand_id, row_number() over (order by count(b.id) desc) rn
from btbl b
group by b.cand_id)sub on a.id=sub.cand_id and sub.rn=1

--21. Calculate cumulative average/sum
table is as follows - date, salary

select date, sal, sum(sal) over (order by date asc)
from tbl;

--22. calculate moving average like rolling 3 months etc
select date, sal, sum(sal) over (order by date asc rows between 2 preceding and current row)
from tbl;
--for forward looking moving average - 
select date, sal, sum(sal) over (order by date desc rows between 2 preceding and current row)
from tbl;
--for centered averages eg. 3 preceding and 3 succeeding
select date, sal, sum(sal) over (order by date desc rows between 3 preceding and 3 following)
from tbl;
--without using window sum
select t1.date, t1.sal, sum(t2.sal)
from tbl t1 
join tbl t2 on t2.date between t1.date-2 and t1.date
group by 1,2

https://leetcode.com/articles/?page=3&category=database&search=
https://dba.stackexchange.com/questions/36943/find-n-consecutive-free-numbers-from-table
https://dba.stackexchange.com/questions/tagged/gaps-and-islands
https://dba.stackexchange.com/questions/36943/find-n-consecutive-free-numbers-from-table

--23. biggest single number - biggest number which appears only once, there could be duplicates in the list

select max(num) from
(select num, count(*) cnt from tbl
group by 1)sub
where cnt=1;

--24. find all employees with bonus less than 1000
select emp.name, b.bonus
from emp 
left join bonus b on emp.id=b.id
where b.bonus<1000

--25. Pay special attention!!! https://leetcode.com/articles/sales-person/
select p.*
from person p
where p_id not in 
(select distinct p_id from ordert o 
 join comp c on o.c_id=c.c_id
where lower(c.comp_nm) not in ('red'));

--26. Do the three dimensions form a triangle?
select x,y,z, case when x+y>z and x+z>y and y+z>x 
					then 'yes'
					else 'no'
				end
from tablet;

--27. https://leetcode.com/articles/students-report-by-geography/
select c1,c2,c3
from 
(select name, country, row_number() over(partition by name) as rn
 from student)sub
 pivot(max(name) for country
       in ('c1','c2','c3')
       )pvt;
	   
--28. https://leetcode.com/articles/average-salary-departments-vs-company/
create table student
(id int, dept_id int, sal int, month varchar(3));

insert into student
values 
(1,1,9000,'Mar'),
(2,2,6000,'Mar'),
(3,2,10000,'Mar'),
(1,1,7000,'Feb'),
(2,2,6000,'Feb'),
(3,2,8000,'Feb');

select distinct month, dept_id, case when av_mon>av_dept_mon then 'higher'
when av_mon>av_dept_mon then 'lower' 
else 'same'
end as status
from (
select month, dept_id, avg(sal) over (partition by month) av_mon,
avg(sal) over (partition by month, dept_id) av_dept_mon
from student
)sub
order by month, dept_id;

--29. https://leetcode.com/articles/consecutive-available-seats/
find consecutive-available-seats
Data:
(1,'1'),
(2,'0'),
(3,'0'),
(4,'1'),
(5,'1'),
(6,'0'),
(7,'1'),
(8,'1');

with cte1 as(
  select id,status, id - row_number() over (partition by status) as id_rn
  from cine
  where status='1'
  ),
cte2 as(
  select id, count(*) over (partition by status, id_rn) as cnt
  from cte1)
select id from cte2
where cnt>1

--30. https://leetcode.com/articles/friend-requests-i-overall-acceptance-rate/
https://leetcode.com/articles/friend-requests-ii-who-has-most-friend/

