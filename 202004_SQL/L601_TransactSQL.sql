-- SELECT @@version; 
-- Microsoft SQL Server 2017 (RTM-CU19) (KB4535007) - 14.0.3281.6 (X64) \n\tJan 23 2020 21:00:04 
--     Copyright (C) 2017 Microsoft Corporation
--     Express Edition (64-bit) on Linux (Ubuntu 16.04.6 LTS)

/* Write your T-SQL query statement below */

DECLARE @consec [int] = 3; 
WITH 
    [front] AS (
    SELECT [id] 
    FROM [stadium] [front]
    WHERE 
        100 <= ALL (
        SELECT [people] 
        FROM [stadium] [period]
        WHERE [period].[id] 
            BETWEEN [front].[id] AND ([front].[id]+(@consec-1))
        )
        AND 
        EXISTS (
        SELECT 1 
        FROM [stadium] [period]
        WHERE [period].[id] = ([front].[id]+(@consec-1))
        )
    )
SELECT 
    [id], 
    [visit_date],
    [people]
FROM 
    [stadium]
WHERE
    EXISTS (
    SELECT 1 
    FROM [front]
    WHERE [stadium].[id] 
        BETWEEN [front].[id] AND ([front].[id]+(@consec-1))
    ) 
-- ORDER BY
--     [id]
;
