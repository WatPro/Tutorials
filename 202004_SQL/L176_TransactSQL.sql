-- SELECT @@version; 
-- Microsoft SQL Server 2017 (RTM-CU19) (KB4535007) - 14.0.3281.6 (X64) 
--     Jan 23 2020 21:00:04 
--     Copyright (C) 2017 Microsoft Corporation
--     Express Edition (64-bit) on Linux (Ubuntu 16.04.6 LTS)

/* Write your T-SQL query statement below */

WITH
    [dist] AS (
    SELECT DISTINCT
        [Salary]
    FROM 
        [Employee]
    -- Order in a simple query: 
    --   1. window function (select)
    --   2. distinct
    ),
    [ranked] AS (
    SELECT
        [Salary], 
        ROW_NUMBER() OVER(ORDER BY [Salary] DESC) AS [RowNumber]
    FROM 
        [dist]
    ),
    [result] AS (
    SELECT 
        [Salary] 
    FROM 
        [ranked]
    WHERE
        [RowNumber] = 2
    )
SELECT (SELECT [Salary] FROM [result]) AS [SecondHighestSalary]
;
