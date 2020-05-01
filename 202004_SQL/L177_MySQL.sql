## SHOW GLOBAL VARIABLES LIKE 'version'; 
## version: 5.7.29-0ubuntu0.16.04.1

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
      # Write your MySQL query statement below.
      IF( N > (
              SELECT COUNT(DISTINCT `Salary`)
              FROM `Employee`
              )
          ,
          NULL
          ,
          (
              SELECT `Salary`
              FROM 
                  (
                  SELECT DISTINCT `Salary`
                  FROM `Employee`
                  ORDER BY `Salary` DESC
                  LIMIT N
                  ) `T`
              ORDER BY `Salary` ASC
              LIMIT 1
          )
      )
  );
END
