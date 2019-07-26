--1. Second highest salary

select max(salary) from employee
where salary < (select max(salary) from employee);

--2. nth highest salary
--dense rank is used here to ensure the duplicates, if any, in salary are handled apropriately. If we use row_number, we will not be
--able to handle duplicates.

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
--Aproach 1: using window functions
select date, sal, sum(sal) over (order by date asc rows between 2 preceding and current row)
from tbl;
--for forward looking moving average - 
select date, sal, sum(sal) over (order by date desc rows between 2 preceding and current row)
from tbl;
--for centered averages eg. 3 preceding and 3 succeeding
select date, sal, sum(sal) over (order by date desc rows between 3 preceding and 3 following)
from tbl;

-- Approach 2: without using window sum
select t1.date, t1.sal, sum(t2.sal)
from tbl t1 
join tbl t2 on t2.date between t1.date-2 and t1.date
group by 1,2;

--15. Do the three dimensions form a triangle?
select x,y,z, case when x+y>z and x+z>y and y+z>x 
					then 'yes'
					else 'no'
				end
from tablet;