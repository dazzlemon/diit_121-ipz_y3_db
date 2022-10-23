-- Multi valued self contained suqbuery
-- IN
--   Shows all classes on any day between monday and friday that is lecture
--   or laboratory
--   Days are mapped to text
--   also row_number added
SELECT DENSE_RANK() OVER( PARTITION BY [Day]
                          ORDER BY [Time] ASC
                        ) AS "row" 
     , "Day" = CASE [Day] WHEN 0 THEN 'Monday'
                          WHEN 1 THEN 'Tuesday'
                          WHEN 2 THEN 'Wednesday'
                          WHEN 3 THEN 'Thursday'
                          WHEN 4 THEN 'Friday'
                          WHEN 5 THEN 'Saturday'
                          WHEN 6 THEN 'Sunday'
                          ELSE 'IMPOSSIBRU'
                          END
     , [Time]
     , IsOddWeek
     , ClassTypeId
     , ClassId
     , GroupId
     , Subgroup
     , TeacherId
     , RoomId
FROM Schedule
WHERE [Day] BETWEEN 0 AND 4 -- between monday and friday (inclusive)
AND ClassTypeId IN ( SELECT Id
                     FROM ClassType
                     WHERE [Name] LIKE 'L%' -- 'Lecture' or 'Laboratory'
                   )

-- Single valued corellated subquery
-- EXISTS
--   Shows all students that have a class that starts at 9:30 on tuesday
SELECT *
FROM Student
WHERE EXISTS ( SELECT *
               FROM Schedule
               WHERE GroupId = Student.GroupId
                 AND [Day] = 1
                 AND [Time] = '09:30:00'
             )

-- Multi valued corellated subquery
-- SOME
--   Shows all students that have a class that starts at 9:30 on tuesday
SELECT *
FROM Student
WHERE '09:30:00' = SOME( SELECT [Time]
                         FROM Schedule
                         WHERE GroupId = Student.GroupId
                           AND [Day] = 1
                       )

-- Multi valued corellated subquery
-- IN
--   Shows all students that have a class that starts at 9:30 on tuesday
SELECT *
FROM Student
WHERE '09:30:00' IN ( SELECT [Time]
                      FROM Schedule
                      WHERE GroupId = Student.GroupId
                        AND [Day] = 1
                    )

-- Multi valued corellated subquery
-- ALL, EXISTS
--   Shows all students that only have a class that starts at 9:30 on tuesday
SELECT *
FROM Student
WHERE '09:30:00' = ALL( SELECT [Time]
                        FROM Schedule
                        WHERE GroupId = Student.GroupId
                          AND [Day] = 1
                      )
  -- if none exist it will still return true
  AND EXISTS ( SELECT [Time]
               FROM Schedule
               WHERE GroupId = Student.GroupId
                 AND [Day] = 1
             )

-- Multi valued self contained subquery
-- SOME
--   Shows all students that have a class that starts at 9:30 on tuesday
SELECT *
FROM Student
WHERE GroupId = SOME( SELECT GroupId
                      FROM Schedule
                      WHERE [Day] = 1
                        AND [Time] = '09:30:00'
                    )

-- Multi valued self contained subquery
--   ALL
-- Single valued self contained subquery
--   If there a group that is the only one
--   to have a class that starts at 9:30 on tuesday
--     select all students in that group
SELECT *
FROM Student
WHERE GroupId = ALL( SELECT GroupId
                     FROM Schedule
                     WHERE [Day] = 1
                       AND [Time] = '09:30:00'
                   )
  AND 1 = ( SELECT COUNT(*)
            FROM Schedule
            WHERE [Day] = 1
              AND [Time] = '09:30:00'
          )


-- Nested derived tables
--   Select all groups (with week) that have just a single lecture that week
SELECT GroupId, IsOddWeek
FROM ( SELECT IsOddWeek
            , GroupId
            , "Class Type"
            , COUNT("Class Type") AS "Count"
       FROM ( SELECT IsOddWeek
                   , GroupId
                   , ClassType.Name AS "Class type"
              FROM Schedule
              JOIN Class ON Class.Id = ClassId
              JOIN ClassType ON ClassType.Id = ClassTypeId
            ) AS DerivedSchedule
       GROUP BY IsOddWeek
              , GroupId
              , "Class Type"
     ) AS DerivedTypeCount
WHERE "Class Type" = 'Lecture'
  AND "Count" = 1