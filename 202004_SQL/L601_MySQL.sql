## SHOW GLOBAL VARIABLES LIKE 'version'; 
## version: 5.7.29-0ubuntu0.16.04.1

# Write your MySQL query statement below

SELECT 
    `id`, 
    `visit_date`,
    `people`
FROM 
    `stadium`
WHERE
    EXISTS (
    SELECT 
        1 
    FROM 
        `stadium` `front`
    WHERE 
        100 <= ALL (
        SELECT `people` 
        FROM `stadium` `period`
        WHERE `period`.`id` 
            BETWEEN `front`.`id` AND (`front`.`id`+2)
        )
        AND 
        3 = (
        SELECT COUNT(1) 
        FROM `stadium` `period`
        WHERE `period`.`id` 
            BETWEEN `front`.`id` AND (`front`.`id`+2)
        )
        AND
        `stadium`.`id` BETWEEN `front`.`id` AND (`front`.`id`+2)
    ) 
;
