CREATE DATABASE data_analysis;

-- connect to the database
\c data_analysis;

-- create schema
CREATE SCHEMA Parks_and_Recreation;

-- set the schema
SET search_path TO Parks_and_Recreation;



CREATE TABLE employee_demographics
(
    employee_id INT NOT NULL,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    age         INT,
    gender      VARCHAR(10),
    birth_date  DATE,
    PRIMARY KEY (employee_id)
);

CREATE TABLE employee_salary
(
    employee_id INT         NOT NULL,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    occupation  VARCHAR(50),
    salary      INT,
    dept_id     INT
);


INSERT INTO employee_demographics (employee_id, first_name, last_name, age, gender, birth_date)
VALUES (1, 'Leslie', 'Knope', 44, 'Female', '1979-09-25'),
       (3, 'Tom', 'Haverford', 36, 'Male', '1987-03-04'),
       (4, 'April', 'Ludgate', 29, 'Female', '1994-03-27'),
       (5, 'Jerry', 'Gergich', 61, 'Male', '1962-08-28'),
       (6, 'Donna', 'Meagle', 46, 'Female', '1977-07-30'),
       (7, 'Ann', 'Perkins', 35, 'Female', '1988-12-01'),
       (8, 'Chris', 'Traeger', 43, 'Male', '1980-11-11'),
       (9, 'Ben', 'Wyatt', 38, 'Male', '1985-07-26'),
       (10, 'Andy', 'Dwyer', 34, 'Male', '1989-03-25'),
       (11, 'Mark', 'Brendanawicz', 40, 'Male', '1983-06-14'),
       (12, 'Craig', 'Middlebrooks', 37, 'Male', '1986-07-27');


INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (1, 'Leslie', 'Knope', 'Deputy Director of Parks and Recreation', 75000, 1),
       (2, 'Ron', 'Swanson', 'Director of Parks and Recreation', 70000, 1),
       (3, 'Tom', 'Haverford', 'Entrepreneur', 50000, 1),
       (4, 'April', 'Ludgate', 'Assistant to the Director of Parks and Recreation', 25000, 1),
       (5, 'Jerry', 'Gergich', 'Office Manager', 50000, 1),
       (6, 'Donna', 'Meagle', 'Office Manager', 60000, 1),
       (7, 'Ann', 'Perkins', 'Nurse', 55000, 4),
       (8, 'Chris', 'Traeger', 'City Manager', 90000, 3),
       (9, 'Ben', 'Wyatt', 'State Auditor', 70000, 6),
       (10, 'Andy', 'Dwyer', 'Shoe Shiner and Musician', 20000, NULL),
       (11, 'Mark', 'Brendanawicz', 'City Planner', 57000, 3),
       (12, 'Craig', 'Middlebrooks', 'Parks Director', 65000, 1);



CREATE TABLE parks_departments
(
    department_id   SERIAL      NOT NULL,
    department_name varchar(50) NOT NULL,
    PRIMARY KEY (department_id)
);

INSERT INTO parks_departments (department_name)
VALUES ('Parks and Recreation'),
       ('Animal Control'),
       ('Public Works'),
       ('Healthcare'),
       ('Library'),
       ('Finance');


-- Execution

SELECT DISTINCT dept_id
from employee_salary;


SELECT salary + 10 as salary_plus_10
from employee_salary;

SELECT *
FROM employee_demographics
WHERE (first_name = 'Leslie' AND age = 44)
   OR age > 55;

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'A%';

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'A__';

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'A__%';

-- Joins

SELECT gender, COUNT(*), AVG(age), MIN(birth_date)
FROM employee_demographics
GROUP BY gender;

SELECT *
FROM employee_demographics
ORDER BY gender ASC, age DESC;

SELECT occupation, AVG(salary)
FROM employee_salary
WHERE first_name LIKE '%r%'
GROUP BY occupation
HAVING AVG(salary) > 50000;

SELECT first_name, salary
FROM employee_salary
ORDER BY salary DESC
LIMIT 3;

SELECT gender, AVG(age) as avg_age
FROM employee_demographics
GROUP BY gender
HAVING AVG(age) > 40;

-- Joins

SELECT *
FROM employee_demographics AS de
         JOIN employee_salary AS sa
              ON de.employee_id = sa.employee_id;

SELECT *
FROM employee_salary AS sa
         LEFT JOIN employee_demographics AS de
                   ON de.employee_id = sa.employee_id;

SELECT *
FROM employee_salary AS sa
         FULL OUTER JOIN employee_demographics AS de
                         ON de.employee_id = sa.employee_id;

SELECT COUNT(*)
FROM employee_demographics
         CROSS JOIN employee_salary;

-- Self join
SELECT e1.first_name as name1, e2.first_name as name2
FROM employee_salary as e1
         JOIN employee_salary as e2
              ON e1.employee_id + 1 = e2.employee_id;

SELECT es.employee_id, pd.department_name, ed.age
FROM employee_salary as es
         JOIN parks_departments as pd
              ON es.dept_id = pd.department_id
         JOIN employee_demographics as ed
              ON es.employee_id = ed.employee_id;

-- Set
SELECT first_name, last_name
FROM employee_demographics
UNION
SELECT first_name, last_name
FROM employee_salary;


SELECT first_name, last_name
FROM employee_demographics
UNION ALL
SELECT first_name, last_name
FROM employee_salary;

SELECT first_name, last_name, 'Old man' as label
FROM employee_demographics
WHERE age > 40
  AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old lady' as label
FROM employee_demographics
WHERE age > 40
  AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Higly paid' as label
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name;

-- String

SELECT UPPER(first_name),
       LOWER(last_name),
       LENGTH(first_name)                 as length,
       EXTRACT(MONTH from birth_date)     as month,
       SUBSTRING(last_name, 2, 2)         as sub_last,
       REPLACE(first_name, 'a', '4')      as name_mod,
       POSITION('a' in first_name)        as pos_a,
       CONCAT(first_name, ' ', last_name) as full_name
FROM employee_demographics
ORDER BY length;

SELECT TRIM('   skyfall   ');
SELECT LTRIM('   skyfall   ');
SELECT RTRIM('   skyfall   ');

-- Case

SELECT t1.first_name,
       CASE
           WHEN t1.age >= 40 THEN 'Old'
           WHEN t1.age BETWEEN 30 AND 40 THEN 'Middle'
           ELSE 'Young'
       END AS age_group,
       t1.age
FROM employee_demographics AS t1;


SELECT CONCAT(t1.first_name, ' ', t1.last_name) as full_name,
       CASE
           WHEN t1.salary > 50000 THEN t1.salary * 1.05
           WHEN t1.salary <= 50000 THEN t1.salary * 1.05
           ELSE t1.salary
       END AS new_salary,
       CASE
           WHEN t2.department_name = 'Finance' THEN salary * 0.1
           ELSE 0
       END AS bonus
FROM employee_salary as t1
JOIN parks_departments as t2
    ON t1.dept_id = t2.department_id;

SELECT t1.first_name, t1.salary, 'High' as salary_level
FROM employee_salary as t1
WHERE t1.salary > (
    SELECT AVG(salary)
    FROM employee_salary
    )
UNION
SELECT t1.first_name, t1.salary, 'Low' as salary_level
FROM employee_salary as t1
WHERE t1.salary <= (
    SELECT AVG(salary)
    FROM employee_salary
);

-- Select the average age of maximum ages by gender
SELECT AVG(t1.max_age)
FROM (
    SELECT gender, MAX(age) AS max_age
    FROM employee_demographics
    GROUP BY gender
     ) AS t1;


-- Window functions
SELECT t1.first_name,
       SUM(t2.salary) OVER (PARTITION BY t1.gender ORDER BY t1.employee_id
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as avg_salary
FROM employee_demographics as t1
JOIN employee_salary as t2
    ON t1.employee_id = t2.employee_id;

SELECT t1.first_name,
       ROW_NUMBER() OVER (PARTITION BY t1.gender) as number
FROM employee_demographics as t1
JOIN employee_salary as t2
  ON t1.employee_id = t2.employee_id;

SELECT t1.first_name, t2.salary,
       ROW_NUMBER() OVER(PARTITION BY t1.gender ORDER BY t2.salary DESC) as row_num,
       RANK() OVER(PARTITION BY t1.gender ORDER BY t2.salary DESC) as rank,
       DENSE_RANK() OVER(PARTITION BY t1.gender ORDER BY t2.salary DESC) AS dense_rank,
       PERCENT_RANK() OVER(PARTITION BY t1.gender ORDER BY t2.salary DESC) AS pct_rank,
       NTILE(3) OVER(PARTITION BY t1.gender ORDER BY t2.salary DESC) AS ntile,
       CUME_DIST() OVER(PARTITION BY t1.gender ORDER BY t2.salary DESC) AS cume_dist
FROM employee_demographics AS t1
JOIN employee_salary AS t2
    ON t1.employee_id = t2.employee_id;

SELECT t1.first_name, t1.salary,
       FIRST_VALUE(t1.salary) OVER(
           ORDER BY t1.salary DESC
           ROWS BETWEEN
              UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS highest_salary
FROM employee_salary as t1;

SELECT t1.year, t1.age,
       LAG(t1.age, 1) OVER(ORDER BY t1.year) as prev_age,
       LEAD(t1.age, 1) OVER(ORDER BY t1.year) as next_age
FROM (
         SELECT EXTRACT(YEAR FROM t2.birth_date) as year, t2.age
         FROM employee_demographics as t2
     ) as t1;
