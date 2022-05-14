USE School

-- WHERE, IN, BETWEEN, LIKE
-- ORDER BY, ASC
-- CASE … WHEN … THEN … ELSE …
-- ROW_NUMBER, OVER, PARTITION BY

-- Shows all classes on any day between monday and friday that is lecture
-- or laboratory
SELECT ROW_NUMBER() OVER( PARTITION BY [Day]
                          ORDER BY [Time] ASC
                        ) AS "row" 
     ,"Day" = CASE [Day] WHEN 0 THEN 'Monday'
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

-- GROUP BY, COUNT, AS
-- HAVING
-- Shows all groups that have exactly 2 students
SELECT GroupId, COUNT(*) AS StudentCount
FROM Student
GROUP BY GroupId
HAVING COUNT(*) = 2

-- TODO: SUM, AVG, MIN, MAX
-- TODO: DISTINCT
-- TODO: DESC
-- TODO: TOP, PERCENT, WITH TIES
-- TODO: OFFSET, FETCH, FIRST, ROWS
-- TODO: COALESCE()