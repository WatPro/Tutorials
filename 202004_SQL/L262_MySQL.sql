## SHOW GLOBAL VARIABLES LIKE 'version'; 
## version: 5.7.29-0ubuntu0.16.04.1

# Write your MySQL query statement below

SELECT 
    `Day`, 
    ROUND(`Cancel`/`Total`,2) AS `Cancellation Rate`
FROM 
    (
    SELECT 
        `Request_at` AS `Day`,
        COUNT(`Id`)  AS `Total`, 
        SUM(
            CASE 
                WHEN `Status` IN 
                    ('cancelled_by_driver', 'cancelled_by_client') 
                    THEN 1
                ELSE 0 
            END
        ) AS `Cancel`
    FROM 
        `Trips`
    WHERE 
        `Client_Id` IN 
        (
        SELECT `Users_Id` 
        FROM `Users` 
        WHERE `Role`="client" AND `Banned`="No"
        ) 
        AND 
        `Driver_Id` IN 
        (
        SELECT `Users_Id` 
        FROM `Users` 
        WHERE `Role`="driver" AND `Banned`="No"
        )
    GROUP BY 
        `Request_at`
    ) `TB`
WHERE
    `Day` BETWEEN '2013-10-01' AND '2013-10-03'
; 
