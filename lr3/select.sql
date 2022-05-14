USE School

-- WHERE, BETWEEN, IN, LIKE
-- Shows all classes on any day between monday and friday that is lecture
-- or laboratory
SELECT *
FROM Schedule
WHERE [Day] BETWEEN 0 AND 4 -- between monday and friday (inclusive)
AND ClassTypeId IN ( SELECT Id
                     FROM ClassType
                     WHERE [Name] LIKE 'L%' -- 'Lecture' or 'Laboratory'
                   )

-- GROUP BY, COUNT, AS
-- TODO: SUM, AVG, MIN, MAX 
SELECT GroupId, COUNT(*) AS StudentCount
FROM Student
GROUP BY GroupId

-- TODO: HAVING

-- TODO: DISTINCT

-- TODO: ORDER BY, ASC, DESC

-- TODO: TOP, PERCENT, WITH TIES

-- TODO: OFFSET, FETCH, FIRST, ROWS

-- TODO: ROW_NUMBER(), OVER, PARTITION BY

-- TODO: CASE … WHEN … THEN … ELSE …

-- TODO: COALESCE()
