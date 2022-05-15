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

     SELECT ClassId
     FROM Schedule
UNION ALL
     SELECT Id
     FROM Class