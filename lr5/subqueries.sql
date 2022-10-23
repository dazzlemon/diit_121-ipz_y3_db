USE School

-- Schedule with ClassId replaced with actual ClassName
-- cartesian product
SELECT Day, Time, IsOddWeek, ClassTypeId, Name AS ClassName, GroupId, Subgroup
     , TeacherId, RoomId
-- FROM Schedule, Class -- Same
FROM Schedule CROSS JOIN Class
WHERE Class.Id = ClassId

-- Show all active classes
-- intersect
     SELECT ClassId
     FROM Schedule
INTERSECT
     SELECT Id
     FROM Class

-- Show all inactive classes
-- except
     SELECT ClassId
     FROM Schedule
EXCEPT
     SELECT Id
     FROM Class

-- Idk real world example
     SELECT ClassId
     FROM Schedule
UNION
     SELECT Id
     FROM Class

SELECT DISTINCT COALESCE(ClassId, Class.Id) AS "Class ID"
FROM Schedule FULL JOIN Class
ON ClassId = Class.Id

SELECT COALESCE(ClassId, Class.Id) AS "Class ID"
FROM Schedule FULL JOIN Class
ON ClassId = Class.Id

SELECT ClassId, Class.Id
FROM Schedule FULL JOIN Class
ON ClassId = Class.Id


-- Idk real world example
     SELECT ClassId
     FROM Schedule
UNION ALL
     SELECT Id
     FROM Class

-- inner join
SELECT Day, Time, IsOddWeek, ClassTypeId, Name AS ClassName, GroupId, Subgroup
     , TeacherId, RoomId
-- FROM Schedule, Class -- Same
FROM Schedule JOIN Class
ON Class.Id = ClassId

-- Idk real world example
SELECT *
FROM Schedule
JOIN Room
ON RoomId >= Room.Id

-- multi join
SELECT Day, Time, IsOddWeek, ClassType.Name AS "Class type"
     , Class.Name AS ClassName, GroupId, Subgroup, TeacherId, RoomId
-- FROM Schedule, Class -- Same
FROM Schedule
JOIN Class ON Class.Id = ClassId
JOIN ClassType ON ClassType.Id = ClassTypeId

SELECT Class.Id
FROM Class
LEFT JOIN Schedule ON ClassId = Class.Id

SELECT Class.Id
FROM Class
RIGHT JOIN Schedule ON ClassId = Class.Id

SELECT Class.Id
FROM Class
FULL JOIN Schedule ON ClassId = Class.Id