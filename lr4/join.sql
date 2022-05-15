USE School

-- cartesian product
SELECT *
-- FROM Schedule, Class -- Same
FROM Schedule CROSS JOIN Class

-- intersect
     SELECT ClassId
     FROM Schedule
INTERSECT
     SELECT Id
     FROM Class
