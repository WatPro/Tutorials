-- SELECT * FROM "V$VERSION"; 
-- Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production
-- PL/SQL Release 11.2.0.2.0 - Production
-- CORE    11.2.0.2.0    Production
-- TNS for Linux: Version 11.2.0.2.0 - Production
-- NLSRTL Version 11.2.0.2.0 - Production
 
/* Write your PL/SQL query statement below */

WITH
    "UNBANNEDUSERS" AS (
    SELECT 
        "USERS_ID" AS "ID"
    FROM
        "USERS"
    WHERE
        "BANNED" = 'No'
    ),
    "CLEANTRIPS" AS ( 
    SELECT 
        "TRIPS"."ID",
        CASE 
            WHEN "TRIPS"."STATUS" 
                IN ('cancelled_by_client','cancelled_by_driver')
               THEN 1
            ELSE 0
        END AS "CANCEL",
        "TRIPS"."REQUEST_AT"
    FROM
        "TRIPS"
        INNER JOIN 
        "UNBANNEDUSERS" "CLIENT"
            ON "TRIPS"."CLIENT_ID" = "CLIENT"."ID" 
        INNER JOIN 
        "UNBANNEDUSERS" "DRIVER"
            ON "TRIPS"."DRIVER_ID" = "DRIVER"."ID"
    ), 
    "SUMMARY" AS (
    SELECT 
        "REQUEST_AT"  AS "Day",
        SUM("CANCEL") AS "CANCEL",
        COUNT(1)      AS "TOTAL"
    FROM
        "CLEANTRIPS"
    GROUP BY 
        "REQUEST_AT"
    HAVING 
        "REQUEST_AT" BETWEEN '2013-10-01' AND '2013-10-03'
    ) 
SELECT 
    "Day",
    CAST("CANCEL"/"TOTAL" AS NUMBER(38,2)) 
        AS "Cancellation Rate" 
FROM 
    "SUMMARY"
ORDER BY
    "Day" ASC
;
