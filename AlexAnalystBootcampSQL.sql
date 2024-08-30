select * from employee_demographics
where birth_date > '1985-01-01'
and gender = 'male';

select * from employee_demographics
where first_name = 'Leslie'
and age = 44
or gender = 'male';

select * from employee_demographics
where first_name like '%er%';

select * from employee_demographics
where birth_date like '1989%';

select gender, count(gender) as num_genders, avg(age) as avg_age from employee_demographics
group by gender;

SELECT 
    occupation,
    sum(salary) as salary_sum
FROM
    employee_salary
GROUP BY occupation;

select * from employee_demographics
order by gender, age desc;

select gender, avg(age) from employee_demographics
group by gender
having avg(age) > 40;

select * from employee_demographics
order by age desc
limit 2, 1;

select gender, avg(age) as avg_age from employee_demographics
group by gender
having avg_age > 40;

# Joins Section
select d.employee_id, age, occupation from employee_demographics as d
join employee_salary as s
on s.employee_id = d.employee_id;

# Outer Joins
select * from employee_demographics as d
left join employee_salary as s
on s.employee_id = d.employee_id;

select * from employee_demographics as d
right join employee_salary as s
on s.employee_id = d.employee_id;

-- Self Join
select emp1.employee_id as emp_santa from employee_salary as emp1
join employee_salary as emp2
on emp1.employee_id + 1 = emp2.employee_id;

-- Joining multiple tables together
select * from employee_demographics as dem
join employee_salary as sal
	on dem.employee_id = sal.employee_id
join parks_departments as pd
	on pd.department_id = sal.dept_id;

-- Unions
select first_name, last_name from employee_demographics
Union distinct
select first_name, last_name
from employee_salary;

select first_name, last_name, 'Old Man' as Label from employee_demographics
where age > 40 and gender = 'male'
union
select first_name, last_name, 'Old Woman' as Label from employee_demographics
where age > 40 and gender = 'female'
union
select first_name, last_name, 'Highly Paid Employee' as Label
from employee_salary
where salary > 70000
order by first_name, last_name;

-- String Functions

#Length will give us the length of each value
SELECT LENGTH('sky');

#Now we can see the length of each name
SELECT first_name, LENGTH(first_name) as len_name
FROM employee_demographics
order by len_name;

select trim(first_name) from employee_demographics;

#Substring allows you to specify a starting point and how many characters you want so you can take characters from anywhere in the string. 
select birth_date, substring(birth_date,1,4) as birth_year,
substring(birth_date, 6, 2) as birth_month
from employee_demographics;

select first_name, locate('An', first_name)
from employee_demographics;

#Here we can combine the first and the last name columns together
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM employee_demographics;

# Case Statements
select first_name, last_name, age,
case 
	when age <= 30 then 'Young'
    when age between 31 and 50 then 'Middle'
    when age >= 50 then 'Old'
end as age_bracket
from employee_demographics;

-- Basically if they make less than 45k then they get a 5% raise - very generous
-- if they make more than 45k they get a 7% raise
-- they get a bonus of 10% if they work for the Finance Department
select first_name, last_name, salary, dept_id,
case
	when salary < 50000 then salary * 1.05
    when salary >= 50000 then salary * 1.07
    end as endyear_salary,
 case when dept_id = 6 then salary * .10
 end as bonus
from employee_salary;

-- Subqueries (a query within a query)
select * from employee_demographics
where employee_id in (
	select employee_id from employee_salary
    where dept_id = 1);
# an operand should only contain one column

select first_name, salary, 
(select avg(salary) 
	FROM employee_salary) as avg_salary from employee_salary;
    
SELECT gender, AVG(Min_age)
FROM (SELECT gender, MIN(age) Min_age, MAX(age) Max_age, COUNT(age) Count_age, AVG(age) Avg_age
FROM employee_demographics
GROUP BY gender) AS Agg_Table
GROUP BY gender;

-- Window Functions

-- windows functions are really powerful and are somewhat like a group by - except they don't roll everything up into 1 row when grouping. 
-- windows functions allow us to look at a partition or a group, but they each keep their own unique rows in the output
-- we will also look at things like Row Numbers, rank, and dense rank

# Join example
select gender, avg(salary) as avg_salary from employee_demographics dem
join employee_salary sal
	on dem.employee_id = sal.employee_id
group by gender;

# Window example
select dem.employee_id, dem.first_name, dem.last_name, gender, salary,
sum(salary) over(partition by gender order by dem.employee_id) as Rolling_Total,
row_number() over(partition by gender order by salary desc) as row_num,
rank() over(partition by gender order by salary desc) as rank_num,
dense_rank() over(partition by gender order by salary desc) as denserank_num
from employee_demographics dem
join employee_salary sal
	on dem.employee_id = sal.employee_id;
    
-- Using Common Table Expressions (CTE)
-- A CTE allows you to define a subquery block that can be referenced within the main query. 
-- It is particularly useful for recursive queries or queries that require referencing a higher level
-- this is something we will look at in the next lesson/

-- Let's take a look at the basics of writing a CTE:

-- First, CTEs start using a "With" Keyword. Now we get to name this CTE anything we want
-- Then we say as and within the parenthesis we build our subquery/table we want

WITH CTE_Example AS 
(
SELECT gender, SUM(salary), MIN(salary) as min_sale, MAX(salary) as max_sale,
COUNT(salary) as count_sal, AVG(salary) as avg_sal
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
-- directly after using it we can query the CTE
SELECT *
FROM CTE_Example;

-- we also have the ability to create multiple CTEs with just one With Expression
WITH CTE_Example AS 
(
SELECT employee_id, gender, birth_date
FROM employee_demographics dem
WHERE birth_date > '1985-01-01'
), -- just have to separate by using a comma
CTE_Example2 AS 
(
SELECT employee_id, salary
FROM parks_and_recreation.employee_salary
WHERE salary >= 50000
)
-- Now if we change this a bit, we can join these two CTEs together
SELECT *
FROM CTE_Example cte1
LEFT JOIN CTE_Example2 cte2
	ON cte1. employee_id = cte2. employee_id;
    
-- the last thing I wanted to show you is that we can actually make our life easier by renaming the columns in the CTE
-- let's take our very first CTE we made. We had to use tick marks because of the column names
-- we can rename them like this
WITH CTE_Example (gender, sum_salary, min_salary, max_salary, count_salary) AS 
(
SELECT gender, SUM(salary), MIN(salary), MAX(salary), COUNT(salary)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT *
FROM CTE_Example;

-- Using Temporary Tables
-- Temporary tables are tables that are only visible to the session that created them. 
-- They can be used to store intermediate results for complex queries or to manipulate data before inserting it into a permanent table.

-- There's 2 ways to create temp tables:
-- 1. This is the less commonly used way - which is to build it exactly like a real table and insert data into it
CREATE TEMPORARY TABLE temp_table
(first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
);
-- if we execute this it gets created and we can actually query it.
select * from temp_table;
-- notice that if we refresh out tables it isn't there. It isn't an actual table. It's just a table in memory.
-- now obviously it's balnk so we would need to insert data into it like this:
INSERT INTO temp_table
VALUES ('Alex','Freberg','Lord of the Rings: The Twin Towers');

select * from temp_table;
-- now when we run it and execute it again we have our data.

-- the second way is much faster and my preferred method
-- 2. Build it by inserting data into it - easier and faster

CREATE TEMPORARY TABLE salary_over_50k;
SELECT *
FROM employee_salary
WHERE salary >= 50000;

select * from salary_over_50k;

-- So let's look at how we can create a stored procedure
-- First let's just write a super simple query
SELECT *
FROM employee_salary
WHERE salary >= 50000;

-- Now let's put this into a stored procedure.
CREATE PROCEDURE large_salaries()
SELECT *
FROM employee_salary
WHERE salary >= 50000;
-- Now if we run this it will work and create the stored procedure
-- we can click refresh and see that it is there
-- notice it did not give us an output, that's because we 
-- If we want to call it and use it we can call it by saying:
CALL large_salaries();
-- as you can see it ran the query inside the stored procedure we created
-- Now how we have written is not actually best practice.alter
-- Usually when writing a stored procedure you don't have a simple query like that. It's usually more complex
-- if we tried to add another query to this stored procedure it wouldn't work. It's a separate query:
-- a delimiter separate queries from one another with a ;
-- or in the case of a procedure DELIMITER & BEGIN.
DELIMITER $$
CREATE PROCEDURE large_salaries2()
BEGIN
SELECT *
FROM employee_salary
WHERE salary >= 50000;
SELECT *
FROM employee_salary
WHERE salary >= 10000;
END $$
-- now we change the delimiter back after we use it to make it default again
DELIMITER ;

call large_salaries2();

DELIMITER $$
CREATE PROCEDURE large_salaries4(p_employee_id INT)
BEGIN
SELECT salary
FROM employee_salary
WHERE employee_id = p_employee_id
;
END $$
-- now we change the delimiter back after we use it to make it default again
DELIMITER ;

CALL large_salaries4(1);

-- Triggers:
-- a Trigger is a block of code that executes automatically executes when an event takes place in a table.
-- for example we have these 2 tables, invoice and payments - when a client makes a payment we want it to update the invoice field "total paid".
-- to reflect that the client has indeed paid their invoice.
DELIMITER $$
CREATE TRIGGER employee_insert
  -- we can also do BEFORE, but for this lesson we have to do after
	AFTER INSERT ON employee_salary
    -- now this means this trigger gets activated for each row that is inserted. Some sql databses like MSSQL have batch triggers or table level triggers that
    -- only trigger once, but MySQL doesn't have this functionality unfortunately
    FOR EACH ROW
    -- now we can write our block of code that we want to run when this is triggered
BEGIN
-- we want to update our client invoices table
-- and set the total paid = total_paid (if they had already made some payments) + NEW.amount_paid
-- NEW says only from the new rows that were inserted. There is also OLD which is rows that were deleted or updated, but for us we want NEW
    INSERT INTO employee_demographics (employee_id, first_name, last_name) 
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ; 

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES(13, 'Jean-Ralphio', 'Saperstein', 'Entertainment 720 CEO', 1000000, NULL);

SELECT * FROM employee_salary;

SELECT * FROM employee_demographics;

-- EVENTS
select * from employee_demographics;

-- we can drop or alter these events like this:
DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO BEGIN
	DELETE
	FROM parks_and_recreation.employee_demographics
    WHERE age >= 60;
END $$
DELIMITER ;

select * from employee_demographics;