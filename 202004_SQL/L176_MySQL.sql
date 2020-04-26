## SHOW GLOBAL VARIABLES LIKE 'version'; 
## version: 5.7.29-0ubuntu0.16.04.1

# Write your MySQL query statement below

SELECT 
    MAX(`Salary`) AS `SecondHighestSalary`
FROM
    `Employee`
WHERE
    `Salary` <> (SELECT MAX(`Salary`) FROM `Employee`)
;
