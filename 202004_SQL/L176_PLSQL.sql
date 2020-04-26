-- SELECT * FROM "V$VERSION"; 
-- Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production
-- PL/SQL Release 11.2.0.2.0 - Production
-- CORE    11.2.0.2.0    Production
-- TNS for Linux: Version 11.2.0.2.0 - Production
-- NLSRTL Version 11.2.0.2.0 - Production
 
/* Write your PL/SQL query statement below */

WITH
    "DIST" AS (
    SELECT DISTINCT
        "SALARY"
    FROM 
        "EMPLOYEE"
    -- Order in a simple query: 
    --   1. window function (select)
    --   2. distinct
    ),
    "RANKED" AS (
    SELECT
        "SALARY", 
        ROW_NUMBER() OVER(ORDER BY "SALARY" DESC) AS "RANK"
    FROM 
        "DIST"
    ),
    "RESULT" AS (
    SELECT 
        "SALARY"
    FROM 
        "RANKED"
    WHERE
        "RANK" = 2
    )
SELECT (SELECT "SALARY" FROM "RESULT") AS "SecondHighestSalary"
FROM "DUAL"
;
