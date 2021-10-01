# Tested on MySQL Community Server - GPL, 8.0.21

SELECT 
    `class`
FROM 
    `courses`
GROUP BY 
    `class`
HAVING
    COUNT(DISTINCT `student`) >= 5
;

