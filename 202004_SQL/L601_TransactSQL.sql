-- SELECT @@version; 
-- Microsoft SQL Server 2017 (RTM-CU19) (KB4535007) - 14.0.3281.6 (X64) \n\tJan 23 2020 21:00:04 
--     Copyright (C) 2017 Microsoft Corporation
--     Express Edition (64-bit) on Linux (Ubuntu 16.04.6 LTS)

/* Write your T-SQL query statement below */

WITH 
    [ranked] AS (
    SELECT 
        ROW_NUMBER() OVER(ORDER BY [visit_date] ASC) AS [row], 
              -- visit_date is unique
        [id], -- id and visit_date is in the same order
        [visit_date],
        [people]
    FROM 
        [stadium]
    ), 
    [single_day] AS (
    SELECT
        [row],
        [id], 
        [visit_date],
        [people]
    FROM 
        [ranked]
    WHERE
        [people] >= 100
    ),
    [interior_row] AS ( -- rows inside (i.e. not at the boundary)
    SELECT 
        [row]
    FROM 
        [single_day] 
    WHERE -- minimum neighbourhood
        ([row] - 1) 
            IN (SELECT [row] FROM [single_day])
        AND
        ([row] + 1) 
            IN (SELECT [row] FROM [single_day])
    )
SELECT 
    [id], 
    [visit_date],
    [people]
FROM
    [single_day]
WHERE
    EXISTS (
    SELECT 1 
    FROM [interior_row]
    WHERE 
        [single_day].[row] 
        BETWEEN 
            ( [interior_row].[row] - 1 ) 
        AND 
            ( [interior_row].[row] + 1 )
    )
;
