-- SELECT * FROM "V$VERSION"; 
-- Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production
-- PL/SQL Release 11.2.0.2.0 - Production
-- CORE    11.2.0.2.0    Production
-- TNS for Linux: Version 11.2.0.2.0 - Production
-- NLSRTL Version 11.2.0.2.0 - Production
 
/* Write your PL/SQL query statement below */

WITH
    "CT" AS (
    SELECT COUNT(1) AS "CT" FROM "SEAT"
    )
SELECT 
    CASE MOD("ID",2)
        WHEN 0
            THEN "ID" - 1
        ELSE 
            LEAST(("ID" + 1),(SELECT "CT" FROM "CT"))
    END AS "ID", 
    "STUDENT"
FROM 
    "SEAT"
ORDER BY
    "ID" ASC
;
