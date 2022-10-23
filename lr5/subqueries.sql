-- Inline TVF
--  Select Schedule.Time by GroupId and Day
CREATE FUNCTION ScheduleTimeByGroupIdDay ( @GroupId INT
                                         , @Day INT
                                         )
RETURNS TABLE
AS RETURN ( SELECT [Time]
            FROM Schedule
            WHERE GroupId = @GroupId
              AND [Day] = @Day
          )
GO

-- Inline TVF usage
--   Shows all students that only have a class that starts at 9:30 on tuesday
SELECT *
FROM Student
WHERE '09:30:00' = ALL( SELECT *
                        FROM ScheduleTimeByGroupIdDay(Student.GroupId, 1)
                      )
  -- if none exist it will still return true
  AND EXISTS ( SELECT *
               FROM ScheduleTimeByGroupIdDay(Student.GroupId, 1)
             )

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
-- Multiple references to the derived table (implicit)
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

-- Multiple CTEs
--   Map day, class type and class name to text
WITH scheduleDayText AS ( SELECT DISTINCT "DayText" = CASE [Day] 
                                             WHEN 0 THEN 'Monday'
                                             WHEN 1 THEN 'Tuesday'
                                             WHEN 2 THEN 'Wednesday'
                                             WHEN 3 THEN 'Thursday'
                                             WHEN 4 THEN 'Friday'
                                             WHEN 5 THEN 'Saturday'
                                             WHEN 6 THEN 'Sunday'
                                             ELSE 'IMPOSSIBRU'
                                             END
                                        , [Day]
                          FROM Schedule
                         ),
     scheduleClassType AS ( SELECT DISTINCT ClassType.Name AS "Class type"
                                          , ClassTypeId
                            FROM Schedule, ClassType
                            WHERE ClassType.Id = ClassTypeId
                          ),
     scheduleClassName AS ( SELECT DISTINCT Class.Name AS "Class name"
                                          , ClassId
                            FROM Schedule, Class
                            WHERE Class.Id = ClassId
                          )
SELECT scheduleDayText.DayText
     , Schedule.Time
     , Schedule.IsOddWeek
     , scheduleClassName.[Class name]
     , scheduleClassType.[Class type]
     , Schedule.GroupId
     , Schedule.Subgroup
     , Schedule.TeacherId
     , Schedule.RoomId
FROM Schedule
   , scheduleDayText
   , scheduleClassName
   , scheduleClassType
WHERE Schedule.Day = scheduleDayText.Day
  AND Schedule.ClassTypeId = scheduleClassType.ClassTypeId
  AND Schedule.ClassId = scheduleClassName.ClassId

-- Recursive CTE
WITH fibonacci ( n_
               , n
               )
AS ( SELECT 0
          , 1
     UNION ALL SELECT n
                    , n_ + n
               FROM fibonacci
               WHERE n < 1000000000
   )
SELECT n_ as fibonacci
FROM fibonacci;

-- Multiple references to the same CTE
--   Shows all students that only have a class that starts at 9:30 on tuesday
WITH tuesdaySchedule ( [Time]
                     , GroupId
                     )
AS ( SELECT [Time]
          , GroupId
     FROM Schedule
     WHERE [Day] = 1
   )
SELECT *
FROM Student
WHERE '09:30:00' = ALL( SELECT [Time]
                        FROM tuesdaySchedule
                        WHERE GroupId = Student.GroupId
                      )
  -- if none exist it will still return true
  AND EXISTS ( SELECT [Time]
               FROM tuesdaySchedule
               WHERE GroupId = Student.GroupId
             )

-- View
--   Map Day, Class type and Class Name to text
GO

CREATE VIEW ScheduleTextView
WITH ENCRYPTION
   , SCHEMABINDING
AS
SELECT "Day" = CASE [Day] WHEN 0 THEN 'Monday'
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
     , ClassType.Name AS [Class type]
     , Class.Name AS [Class name]
     , GroupId
     , Subgroup
     , TeacherId
     , RoomId
FROM dbo.Schedule
JOIN dbo.ClassType ON ClassTypeId = ClassType.Id
JOIN dbo.Class ON ClassId = Class.Id
WITH CHECK OPTION
GO

SELECT * FROM ScheduleTextView