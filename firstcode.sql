With employeeCTE as
(
	select ID, name, salary, rownumber() over (partition by name order by name) as rn
		from employee
)
delete from employeeCTE where rn > 1