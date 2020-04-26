-- SELECT @@version; 
-- Microsoft SQL Server 2017 (RTM-CU19) (KB4535007) - 14.0.3281.6 (X64) 
--     Jan 23 2020 21:00:04 
--     Copyright (C) 2017 Microsoft Corporation
--     Express Edition (64-bit) on Linux (Ubuntu 16.04.6 LTS)

/* Write your T-SQL query statement below */

WITH
    [UnbannedUsers] AS (
    SELECT 
        [Users_Id] AS [Id]
    FROM
        [Users]
    WHERE
        [Banned] = 'No'
    ),
    [CleanTrips] AS ( 
    SELECT 
        [Trips].[Id],
        CASE 
            WHEN [Trips].[Status] 
                IN ('cancelled_by_client','cancelled_by_driver')
               THEN 1.0
            ELSE 0.0
        END AS [Cancelled],
        [Trips].[Request_at]
    FROM
        [Trips] 
        INNER JOIN 
        [UnbannedUsers] [Client]
            ON [Trips].[Client_Id] = [Client].[Id] 
        INNER JOIN 
        [UnbannedUsers] [Driver]
            ON [Trips].[Driver_Id] = [Driver].[Id]
    ), 
    [Summary] AS (
    SELECT 
        [Request_at]     AS [Day],
        SUM([Cancelled]) AS [Cancelled],
        COUNT(1)         AS [Total]
    FROM
        [CleanTrips]
    GROUP BY 
        [Request_at]
    HAVING 
        [Request_at] BETWEEN '2013-10-01' AND '2013-10-03'
    ) 
SELECT 
    [Day],
    CAST([Cancelled]/[Total] AS [decimal](19,2)) 
        AS [Cancellation Rate]
FROM 
    [Summary]
ORDER BY
    [Day] ASC
;
