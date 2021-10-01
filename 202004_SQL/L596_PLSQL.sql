/*
| PRODUCT                              | VERSION    | STATUS           |
|--------------------------------------|------------|------------------|
| NLSRTL                               | 11.2.0.2.0 | Production       |
| Oracle Database 11g Express Edition  | 11.2.0.2.0 | 64bit Production |
| PL/SQL                               | 11.2.0.2.0 | Production       |
| TNS for Linux:                       | 11.2.0.2.0 | Production       |
*/

/* Write your PL/SQL query statement below */

SELECT 
    "CLASS"
FROM 
    "COURSES"
GROUP BY 
    "CLASS"
HAVING 
    COUNT(DISTINCT "STUDENT") >= 5 
;
