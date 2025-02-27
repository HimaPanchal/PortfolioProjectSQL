
DROP TABLE employee;
CREATE TABLE employee
( emp_ID int
, emp_NAME varchar(50)
, DEPT_NAME varchar(50)
, SALARY int);

INSERT into employee values(101, 'Rajat', 'Admin', 4000);
INSERT into employee values(102, 'Brian', 'HR', 3000);
INSERT into employee values(103, 'Janine', 'IT', 4000);
INSERT into employee values(104, 'Jayesh', 'Finance', 6500);
INSERT into employee values(105, 'Rana', 'HR', 3000);
INSERT into employee values(106, 'Hardeep',  'Finance', 5000);
INSERT into employee values(107, 'Preet', 'HR', 7000);
INSERT into employee values(108, 'Shivam', 'Admin', 4000);
INSERT into employee values(109, 'Karan', 'IT', 6500);
INSERT into employee values(110, 'Nandi', 'IT', 7000);
INSERT into employee values(111, 'Chloe', 'IT', 8000);
INSERT into employee values(112, 'Viren', 'IT', 10000);
INSERT into employee values(113, 'Gautham', 'Admin', 2000);
INSERT into employee values(114, 'Manisha', 'HR', 3000);
INSERT into employee values(115, 'Sanjana', 'IT', 4500);
INSERT into employee values(116, 'Perry', 'Finance', 6500);
INSERT into employee values(117, 'Eden', 'HR', 3500);
INSERT into employee values(118, 'Srivalli', 'Finance', 5500);
INSERT into employee values(119, 'Kary', 'HR', 8000);
INSERT into employee values(120, 'Panna', 'Admin', 5000);
INSERT into employee values(121, 'Deena', 'IT', 6000);
INSERT into employee values(122, 'Argel', 'IT', 8000);
INSERT into employee values(123, 'Albert', 'IT', 8000);
INSERT into employee values(124, 'Dheeren', 'IT', 11000);
COMMIT;


select * from employee;

-- Aggregate function as Window function
-- First query is normally how one can write a query but it won't pull out all the records from the Employee Table 
select  dept_name, max(salary) from employee e
group by dept_name;

-- By using MAX as window function, one can retrieve multiple records according to the condition stated in Window function
select e.*,
max(salary) over(partition by dept_name) as max_salary
from employee e;


-- row_number(), rank() and dense_rank()
select e.*,
row_number() over(partition by dept_name) as rn
from employee e;


-- Retrieve the first 2 employees from each department who joined the company in order 
-- Row number returns the sequential number of a row within a partition of a result set, starting at 1 for the first row in each partition..
select * from (
	select e.*,
	row_number() over(partition by dept_name order by emp_id) as rn
	from employee e) x
where x.rn < 3;


-- Retrieve the top 3 employees in each department earning the max salary.
-- RANK provides the same numeric value for ties (for example 1, 2, 2, 4, 5).
select * from (
	select e.*,
	rank() over(partition by dept_name order by salary desc) as rnk
	from employee e) x
where x.rnk < 4;


-- Checking the difference between rank, dense_rnk and row_number window functions:
-- DENSE_RANK ( ) OVER ( [ <partition_by_clause> ] < order_by_clause > ) - Does not skip the numbering order DENSE_RANK provides the same numeric value for ties (for example 1, 2, 2, 3, 4).
select e.*,
rank() over(partition by dept_name order by salary desc) as rnk,
dense_rank() over(partition by dept_name order by salary desc) as dense_rnk,
row_number() over(partition by dept_name order by salary desc) as rn
from employee e;

-- Lead and Lag function

-- Retrieve a query to display if the salary of an employee is higher, lower or equal to the previous employee.
select e.*,
lag(salary) over(partition by dept_name order by emp_id) as prev_empl_sal,
case when e.salary > lag(salary) over(partition by dept_name order by emp_id) then 'Higher than previous employee'
     when e.salary < lag(salary) over(partition by dept_name order by emp_id) then 'Lower than previous employee'
	 when e.salary = lag(salary) over(partition by dept_name order by emp_id) then 'Same as previous employee' end as sal_range
from employee e;

-- Similarly using lead function to see how it is different from lag.
--LAG - Accesses data from a previous row in the same result set without the use of a self-join starting with SQL Server
--LEAD - Accesses data from a subsequent row in the same result set without the use of a self-join starting with SQL Server 2012
--LEAD ( scalar_expression [ , offset ] [ , default ] ) [ IGNORE NULLS | RESPECT NULLS ]
 --   OVER ( [ partition_by_clause ] order_by_clause )
 --LAG (scalar_expression [ , offset ] [ , default ] ) [ IGNORE NULLS | RESPECT NULLS ]
  --OVER ( [ partition_by_clause ] order_by_clause )  
select e.*,
lag(salary) over(partition by dept_name order by emp_id) as prev_empl_sal,
lead(salary) over(partition by dept_name order by emp_id) as next_empl_sal
from employee e;
