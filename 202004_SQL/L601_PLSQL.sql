-- SELECT * FROM "V$VERSION"; 
-- Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production
-- PL/SQL Release 11.2.0.2.0 - Production
-- CORE    11.2.0.2.0    Production
-- TNS for Linux: Version 11.2.0.2.0 - Production
-- NLSRTL Version 11.2.0.2.0 - Production
 
/* Write your PL/SQL query statement below */

SELECT 
    "ID", 
    TO_CHAR("VISIT_DATE") AS "VISIT_DATE",
    "PEOPLE"
FROM 
    "STADIUM"
WHERE
    EXISTS (
    SELECT 
        1 
    FROM 
        "STADIUM" "FRONT"
    WHERE 
        100 <= ALL (
        SELECT "PEOPLE" 
        FROM "STADIUM" "PERIOD"
        WHERE "PERIOD"."ID" 
            BETWEEN "FRONT"."ID" AND ("FRONT"."ID"+2)
        )
        AND 
        EXISTS (
        SELECT 1 
        FROM "STADIUM" "PERIOD" 
        WHERE "PERIOD"."ID" = ("FRONT"."ID"+2)
        )
        AND
        "STADIUM"."ID" BETWEEN "FRONT"."ID" AND ("FRONT"."ID"+2)
    ) 
ORDER BY
    "ID"
;
