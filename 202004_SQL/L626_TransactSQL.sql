-- SELECT @@version; 
-- Microsoft SQL Server 2017 (RTM-CU19) (KB4535007) - 14.0.3281.6 (X64) 
--     Jan 23 2020 21:00:04 
--     Copyright (C) 2017 Microsoft Corporation
--     Express Edition (64-bit) on Linux (Ubuntu 16.04.6 LTS)

/* Write your T-SQL query statement below */

DECLARE @ct [bigint] = (SELECT COUNT(1) FROM [seat]);
SELECT 
    CASE 
        WHEN [id] % 2 = 0
            THEN [id] - 1
        WHEN [id] = @ct 
            THEN [id]
        ELSE [id] + 1
    END AS [id], 
    [student]
FROM 
    [seat]
ORDER BY
    [id] ASC
;
