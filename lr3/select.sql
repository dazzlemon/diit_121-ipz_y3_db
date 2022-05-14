USE School

-- WHERE, BETWEEN, IN, LIKE
-- Shows all classes on any day between monday and friday that is not lecture
-- or laboratory (so only practice)
SELECT *
FROM Schedule
WHERE [Day] BETWEEN 0 AND 4 -- between monday and friday (inclusive)
AND ClassTypeId NOT IN ( SELECT Id
                         FROM ClassType
                         WHERE [Name] LIKE 'L%' -- 'Lecture' or 'Laboratory'
                       )

-- TODO: GROUP BY, COUNT, SUM, AVG, MIN, MAX, AS

-- TODO: HAVING

-- TODO: DISTINCT

-- TODO: ORDER BY, ASC, DESC

-- TODO: TOP, PERCENT, WITH TIES

-- TODO: OFFSET, FETCH, FIRST, ROWS

-- TODO: ROW_NUMBER(), OVER, PARTITION BY

-- TODO: CASE … WHEN … THEN … ELSE …

-- TODO: COALESCE()
