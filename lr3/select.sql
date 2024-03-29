USE School

-- WHERE, IN, BETWEEN, LIKE
-- ORDER BY, ASC
-- CASE … WHEN … THEN … ELSE …
-- ROW_NUMBER, OVER, PARTITION BY -- DENSE_RANK instead of ROW_NUMBER

-- Shows all classes on any day between monday and friday that is lecture
-- or laboratory
-- Days are mapped to text
-- also row_number added
SELECT DENSE_RANK() OVER( PARTITION BY [Day]
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

-- SELECT top 10% students with highest marks
SELECT TOP 1 WITH TIES *
FROM Student
ORDER By GroupId -- imagine that they are ordered by theirs marks or something

-- OFFSET, FETCH, FIRST, ROWS
-- COALESCE
-- No real world example with this database
SELECT COALESCE(IsOddWeek, ClassTypeId) AS FirstNotNull
     , *
FROM Schedule
ORDER BY [Day]
OFFSET 1 ROWS FETCH FIRST 2 ROWS ONLY

-- DISTINCT
-- Select all rooms in use 
SELECT DISTINCT RoomId
FROM Schedule
ORDER BY RoomId DESC

-- earliest class
SELECT MIN([Time])
FROM Schedule

-- latest class
SELECT MAX([Time])
FROM Schedule