--Microsoft SQL Server 2019 (RTM-CU7) (KB4570012) - 15.0.4063.15 (X64) 
--    Aug 15 2020 10:48:11 
--    Copyright (C) 2019 Microsoft Corporation
--    Express Edition (64-bit) on Linux (Ubuntu 20.04.1 LTS) <X64>


/* Write your T-SQL query statement below */

SELECT 
    [class]
FROM 
    [courses]
GROUP BY 
    [class]
HAVING 
    COUNT(DISTINCT [student]) >= 5
;

