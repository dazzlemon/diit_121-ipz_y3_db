
-- ��� ������� ������� ������� ��� ��������� ��� ���� ��� ����� ���� ��������������� ���������� ��� ������� ������
-- (������ ���� � ����� TEXT -> VARCHAR)
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'student' AND COLUMN_NAME = 'firstname') BEGIN
    ALTER TABLE [student]
    ALTER COLUMN firstname VARCHAR(64)
END;
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'student' AND COLUMN_NAME = 'lastname') BEGIN
    ALTER TABLE [student]
    ALTER COLUMN lastname VARCHAR(64)
END;
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'teacher' AND COLUMN_NAME = 'firstname') BEGIN
    ALTER TABLE [teacher]
    ALTER COLUMN firstname VARCHAR(64)
END;
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'teacher' AND COLUMN_NAME = 'lastname') BEGIN
    ALTER TABLE [teacher]
    ALTER COLUMN lastname VARCHAR(64)
END;
GO

----------------------------
-- Window functions

-- 2.1.1 Ranking Window Functions. ROW_NUMBER
-- ���������, �������� ���� �������� ������ ���� ���� ����� �� ��������� ��������� �������� (�� Z->A, �� �->�) 
BEGIN
	DECLARE @teacherId INT = 1
	-- ������������� ���� �� �������, ���� �� �� ����� ��������� �
	SELECT ROW_NUMBER() OVER(ORDER BY lastname DESC,firstname DESC) AS RowNumber,
		   s.firstname,
		   s.lastName
	FROM student AS s
	JOIN [school].[group] AS g ON s.groupId = g.id
	WHERE g.curatorId = @teacherId
END 

-- 2.1.1 Ranking Window Functions. RANK
-- ���������, �������� ���� �������� ������ ����, �� ���������� ����� ����� ��� �������� ����� ������������ ����
BEGIN
	SELECT groupId,
		   RANK() OVER(ORDER BY groupId) AS Rank -- ������ ������������ �����
	FROM schedule
	GROUP BY groupId;
END

-- 2.1.1 Ranking Window Functions. DENSE_RANK
-- ����� �������� ���������� ��� ��� ��� ������ ������� ����������� ���������� �� ������������ ��, ���� ������� ������ �� ������� ����������� ���������, �� ������ �������
BEGIN
	SELECT t.lastname,
		   t.firstname,
		   DENSE_RANK() OVER(ORDER BY teacherId) AS Rank
	FROM schedule AS s
	JOIN teacher AS t ON s.teacherId = t.id
	GROUP BY s.teacherId, t.lastname, t.firstname;
END

-- 2.1.1 Ranking Window Functions. NTILE
-- ������� ���������� ���� �� 4 ����� �� �������� �������
BEGIN
	SELECT firstname,
		   lastname,
		   NTILE(4) OVER(ORDER BY lastname, firstname) AS [GroupNumber]
	FROM student
	ORDER BY [GroupNumber];
END

-- 2.1.2 Offset Window Functions. LAG
-- ������� �������� ��� ������� ���� ��'� ������� � ���������� ����
BEGIN
	WITH mycte AS (
		SELECT day, time, isOddWeek, classTypeId, classId, groupId, teacherId, roomId
		FROM schedule
		GROUP BY day, time, groupId, isOddWeek, classTypeId, classId, teacherId, roomId
		HAVING ISNULL(isOddWeek, 0) = 0
	)
	SELECT cte.*, LAG(CONCAT(t.lastname, ' ', t.firstname)) OVER(PARTITION BY cte.day, cte.groupId ORDER BY cte.time) AS teacherLastNameFromPreviuosPara
	FROM mycte AS cte
	JOIN teacher AS t ON cte.teacherId = t.id
	ORDER BY day, time 
END

-- 2.1.2 Offset Window Functions. LEAD
-- ������� �������� ��� ���� ��� �������� ���� ��� ����� ���� ������ �������� �� ���� ��� ��� ����������
BEGIN
	WITH mycte AS (
		SELECT day, time, isOddWeek, classTypeId, classId, groupId, teacherId, roomId
		FROM schedule
		GROUP BY day, time, groupId, isOddWeek, classTypeId, classId, teacherId, roomId
		HAVING ISNULL(isOddWeek, 0) = 0
	)
	SELECT *, LEAD(time) OVER(PARTITION BY day, groupId ORDER BY time) AS nextParaTime
	FROM mycte
	ORDER BY day, time 
END

-- 2.1.2 Offset Window Functions. FIRST_VALUE
-- ������� �������� ������� ������� ���� � ����� ����
BEGIN
	WITH mycte AS (
		SELECT RANK() OVER(PARTITION BY s.groupId ORDER BY s.lastname) as rankId,
	           FIRST_VALUE(s.lastname) OVER (PARTITION BY s.groupId ORDER BY s.lastname ROWS UNBOUNDED PRECEDING) AS lastName,
		       s.groupId
		FROM student AS s
	)
	SELECT lastName,
		   groupId
	FROM mycte 
	WHERE rankId = 1
END

-- 2.1.2 Offset Window Functions. LAST_VALUE
-- ����� ������� �������� ������� ���������� ���� � ����� ����
BEGIN
	WITH mycte AS (
		SELECT RANK() OVER(PARTITION BY s.groupId ORDER BY s.lastname DESC) as rankId,
	           LAST_VALUE(s.lastname) OVER (PARTITION BY s.groupId ORDER BY s.lastname DESC) AS lastName,
		       s.groupId
		FROM student AS s
	)
	SELECT lastName,
		   groupId
	FROM mycte 
	WHERE rankId = 1
END

-- 2.1.3 Aggregate  Window Functions. COUNT
-- �������� ��-�� �������� � ����� ����
BEGIN
	SELECT groupId,
		COUNT(1) AS count -- ��-�� �������� � ����� ����   
	FROM student
	GROUP BY groupId
END

-- 2.1.3 Aggregate  Window Functions. AVG
-- �������� ������� ��-�� �������� � ����� ����
BEGIN
	SELECT AVG(count) AS averageStudentsCountPerGroup
	FROM (
		SELECT COUNT(1) AS count -- ��-�� �������� � ����� ����
		FROM student
		GROUP BY groupId
	) AS counts
END

-- 2.1.3 Aggregate  Window Functions. MAX
-- �������� ��� �������� ���� �� ������� ����
BEGIN
	SELECT TOP 1 MAX(time) AS lastParaTime
	FROM schedule
	GROUP BY time, isOddWeek
	HAVING ISNULL(isOddWeek, 0) = 0
	ORDER BY lastParaTime DESC
END

-- 2.1.3 Aggregate  Window Functions. MIN
-- �������� ��� ����� ���� �� ������� ����
BEGIN
	SELECT TOP 1 MIN(time) AS firstParaTime
	FROM schedule
	GROUP BY time, isOddWeek
	HAVING ISNULL(isOddWeek, 1) = 1
	ORDER BY firstParaTime ASC
END

-- 2.1.3 Aggregate  Window Functions. SUM
-- �������� �������� ��-�� �������� � ����������
BEGIN
	DECLARE @studentsCount INT
	DECLARE @teachersCount INT
	
	SELECT @studentsCount = COUNT(1)
	FROM student
	
	SELECT @teachersCount = COUNT(1)
	FROM teacher

	SELECT SUM(@studentsCount + @teachersCount)
END

-- 2.2 PIVOT
-- �������� ����� �� ��-�� ��� � ������ � ��� �����
BEGIN
	SELECT groupId,
	       [0] AS Monday,
		   [1] AS Tuesday,
		   [2] AS Wednesday,
		   [3] AS Thursday,
		   [4] AS Friday,
		   [5] AS Saturday,
		   [6] AS Sunday
	FROM 
	(SELECT groupId, day FROM schedule) AS sc
	PIVOT
	(
	COUNT(day) FOR [day] IN ([0], [1], [2], [3], [4], [5], [6])
	) AS pivotTable;
END

-- 2.3 UNPIVOT
-- ³������ ������� � ������������ ������ � ����������� �� �� ���������: groupId, day
BEGIN
	DECLARE @pivotTable TABLE (groupId INT, monday int, tuesday int, wednesday int, thursday int, friday int, saturday int, sunday int)
	INSERT INTO @pivotTable
	SELECT groupId,
	       [0] AS Monday,
		   [1] AS Tuesday,
		   [2] AS Wednesday,
		   [3] AS Thursday,
		   [4] AS Friday,
		   [5] AS Saturday,
		   [6] AS Sunday
	FROM 
	(SELECT groupId, day FROM schedule) AS sc
	PIVOT
	(
	COUNT(day) FOR [day] IN ([0], [1], [2], [3], [4], [5], [6])
	) AS pivotTable;

	SELECT groupId, day
	FROM 
	(SELECT groupId, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday FROM @pivotTable) AS pt
	UNPIVOT
	(
		unp FOR day IN (Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
	) AS pivotTable;
END

-- 2.4 GROUPING SETS
-- �������� ��-�� �������� � ����� ���� �������������� GROUPING SETS
BEGIN
	SELECT groupId,
		   COUNT(1) AS studentsPerGroup
	FROM student
	GROUP BY GROUPING SETS (groupId)
	ORDER BY groupId
END

-- 2.5 CUBE
-- ����� �������� �� ����� ��-�� �������� � ����� ����, � �� � �������� ���� ��������
BEGIN
	SELECT groupId,
		   COUNT(1) AS studentsPerGroup
	FROM student
	GROUP BY CUBE(groupId)
	ORDER BY groupId
END

-- 2.6 ROLLUP
-- ����� �������� �� ����� ��-�� �������� � ����� ����, � �� � �������� ���� ��������
-- ROLLUP ����� ����� ����� �� � CUBE, ��� CUBE ������� �� ��-����� ��� ��� ��������� ����
BEGIN
	SELECT ISNULL(groupId, 0) AS groupId,
		   COUNT(1) AS studentsPerGroup
	FROM student
	GROUP BY ROLLUP(groupId)
	ORDER BY groupId
END

-- 2.7 GROUPING()
-- �������� ���� ����� � ����������� ����� ���
BEGIN
	SELECT groupId,
		   COUNT(1) AS studentsPerGroup,
		   GROUPING(groupId) AS 'Grouping'
	FROM student
	GROUP BY ROLLUP(groupId)
END

-- 2.8 GROUPING_ID()
-- GROUPING_ID() ����� ����� �� � GROUPING, ������ ��� � ���� �� GROUPING_ID() ���� ��������� � ��������� ������ ���������
BEGIN
	SELECT groupId, firstname,
		   COUNT(1) AS studentsPerGroup,
		   GROUPING_ID(groupId, firstname) AS 'Grouping'
	FROM student
	GROUP BY ROLLUP(groupId, firstname)
END

-- 2.9.1 INSERT VALUES
-- �������� ������ ������� ����� ��������
BEGIN
	INSERT INTO student (firstname, lastname, groupId)
	VALUES ('Patrick', 'Bateman', 936),
		   ('Homer', 'Simpson', 936);
END

-- 2.9.2 INSERT SELECT
-- �������� ������ ����������� �� ������ ���������� �������
BEGIN
	INSERT INTO teacher
	SELECT 'Walter', 'White'
END

-- 2.9.3 INSERT EXEC
-- ������ �� ������ ���������
BEGIN
	DECLARE @q nvarchar(64) = ' SELECT ''Tony'', ''Soprano'' '
	INSERT INTO teacher (firstname, lastname)
	EXEC(@q)
END

-- 2.9.4 SELECT INTO
-- SELECT INTO ������� ���� ������� � �������� �������� � ���� ��� ���� ����, ���� ������� �������� ������ ��� � ��������� ��������
BEGIN
	IF OBJECT_ID('tempdb..#tmpTable') IS NOT NULL DROP TABLE #tmpTable
	GO

	SELECT firstName, lastname, groupId
	INTO #tmpTable
	FROM student
END

-- 2.9.5 BULK INSERT
-- ������ ������ �������� � ����� 'new_students.csv'
BEGIN
	BULK INSERT student
	FROM '~/new_students.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n'
	)
END

-- 2.10.1 $identity
-- ������� ��� �������� � �������, ���� �� ��� IDENTITY
BEGIN
	DECLARE @tableVariable TABLE (myidentity INT IDENTITY(1,1) PRIMARY KEY, ch CHAR(1))
	INSERT INTO @tableVariable (ch) VALUES ('s'), ('i'), ('g'), ('m'), ('a')

	SELECT $identity
	FROM @tableVariable
END

-- 2.10.2 @@identity
-- ������� ��� ����� �������� �������� �����. �������� �������� �������
BEGIN
	SELECT MAX(id)
	FROM student;

	INSERT INTO student (firstName, lastName, groupId)
	VALUES ('Bruce', 'Wayne', 949)

	SELECT @@IDENTITY
END

-- 2.10.3 SCOPE_IDENTITY()
-- �������� �������� ������� �� ������� 䳿
BEGIN
	SELECT MAX(id)
	FROM class;

	INSERT INTO class (name) VALUES ('math')

	SELECT SCOPE_IDENTITY()
END

-- 2.10.4 IDENT_CURRENT('table name')
-- ���������� ������� 䳿 �� �������, ��� �������� ��������� �������
BEGIN
	SELECT MAX(id)
	FROM class;

	INSERT INTO class (name) VALUES ('machine learning')

	SELECT IDENT_CURRENT('class')
END

-- 2.10.5 IDENT_INSERT
-- �������� �������� ���� ���� � identity ����
BEGIN
	DECLARE @id INT = 5
	DECLARE @name VARCHAR(64)

	-- �����'������� �������� �� ��������
	SELECT @name = name
	FROM class
	WHERE id = @id

	-- ������ ������ �� ���������� identity
	DELETE class
	WHERE id = @id

	SET IDENTITY_INSERT class ON;
	INSERT INTO class (id, name) VALUES (@id, @name); -- ���� �� ���� ���������� �������� IDENTITY_INSERT ON, � ��� �� ������� ��� �������
	SET IDENTITY_INSERT class OFF;
END

-- 2.11 CREATE SEQUENCE
BEGIN
	IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[students_seq]') AND type = 'SO') DROP SEQUENCE students_seq;
	GO

	CREATE SEQUENCE students_seq
	AS BIGINT
	START WITH 1     -- ��������� �������� �����������
	INCREMENT BY 1   -- �� ��� �������� ���������� ��������
	MINVALUE 1       -- ̳������� �������� � �����������
	MAXVALUE 99999   -- ����������� �������� � �����������
	NO CYCLE	     -- �� ������� ����������� ���� ���� �� ����� �� ����.��������
	CACHE 10;        -- �����'��������� ���� �������� 10 ������� � �����������

	SELECT NEXT VALUE FOR students_seq; -- ĳ����� �������� �������� � �����������
	SELECT NEXT VALUE FOR students_seq; -- ĳ����� �������� �������� � �����������
END

-- 2.12.1 sys.sequences view
BEGIN
	-- ���� ������ �������� �� � ����������� �� ��� �� - �������� ����� ����� 
	SELECT * FROM sys.sequences
END

-- 2.12.2 sp_sequence_get_range
BEGIN
	-- ĳ������� ������� 10 ������� � �����������, ��� �������� � ����� 2.11
	DECLARE @range_first_value_output sql_variant;
	DECLARE @range_size INT = 10
	EXEC sp_sequence_get_range @sequence_name = 'students_seq', @range_size = @range_size, @range_first_value = @range_first_value_output OUTPUT;

	SELECT @range_first_value_output
END

-- 2.13 DELETE
-- �������� �������� ������ ѳ������ � ���� �����, ����� �� �� �� ������ ������
BEGIN
	-- ����� ���� � �������� ����� ���� id, ��� ��� ���� ��� �������� �� ����� �������� � �� ��������� ������ ����������� ����� ���������
	DELETE FROM student
	WHERE firstName = 'Homer' AND lastName = 'Simpson' AND groupId = 936;
END

-- 2.14 TRUNCATE
-- TRUNCATE ��������������� ��� ����, ��� �������� �� ������ � �������. ��� �� ������ ����, ������� �� ���������. (identity ���� ��������� �� ����������� ��� 1)
BEGIN
	-- TRUNCATE ������ �� DELETE ��� WHERE, ��� �� ������� � ����������� ����� �������
	IF OBJECT_ID('tempdb..#tmpTable2') IS NOT NULL DROP TABLE #tmpTable2
	GO

	CREATE TABLE #tmpTable2 (id INT PRIMARY KEY IDENTITY(1,1), ch CHAR(1))
	INSERT INTO #tmpTable2 (ch) VALUES ('s'), ('i'), ('g'), ('m'), ('a')
	
	SELECT MAX(id) FROM #tmpTable2;

	TRUNCATE TABLE #tmpTable2;

	SELECT id, ch FROM #tmpTable2;

	INSERT INTO #tmpTable2 (ch) VALUES ('q');
	SELECT id, ch FROM #tmpTable2;
END

-- 2.15 UPDATE
-- ���� ��� ��������� � ����������� ������� ��'� ���������� ���� �� ����� �� ���� �����, ���� ������ ������� ����� ����� ��� ������������ ��'� �� ���������
BEGIN
	UPDATE student
	SET firstname = 'Bobby'
	WHERE id = (SELECT MAX(id) FROM student)
END

-- 2.16.1 MERGE. WHEN MATCHED THEN. WHEN NOT MATCHED THEN
-- ����� �������� �� ��� ����� ������� ��� ��� ���������, � ���� ���� �� �� ������ �� ������� - �������� ����� �����
BEGIN
	-- �������� ��� ����� ��������� ���������
	IF OBJECT_ID(N'[dbo].[InsertTeacher]', N'P') IS NULL
		EXEC('CREATE PROCEDURE [dbo].[InsertTeacher] AS SET NOCOUNT ON;')
	GO
	ALTER PROCEDURE dbo.InsertTeacher
		@firstName VARCHAR(64),  
		@lastName VARCHAR(64)  
	AS
	BEGIN
		SET NOCOUNT ON;  
		MERGE teacher AS target
		USING (SELECT @firstName, @lastName) AS source (firstName, lastName)
		ON (target.lastName = source.lastName)
		WHEN MATCHED THEN -- ���� ����� ���� ��������, �� ���������� �������� UPDATE
			UPDATE SET firstName = source.firstName
		WHEN NOT MATCHED THEN -- ���� �� �������� - �������� INSERT
			INSERT (firstName, lastName)
			VALUES (source.firstName, source.lastName);
	END
	GO
	
	-- ���������� ���������
	DECLARE @lastName VARCHAR(64) = 'Pennyworth'
	EXEC InsertTeacher @firstName = 'Alfred', @lastName = @lastName
	EXEC InsertTeacher @firstName = 'Saxon', @lastName = @lastName
	
	SELECT firstname, lastname 
	FROM teacher
	WHERE lastname = @lastname
END

-- 2.16.2 MERGE. WHEN MATCHED AND ... THEN. WHEN NOT MATCHED BY TARGET THEN
-- ����� ������� �������� ����� ��������� � ��� ��������
BEGIN
	IF OBJECT_ID(N'[dbo].[InsertStudent]', N'P') IS NULL
		EXEC('CREATE PROCEDURE [dbo].[InsertStudent] AS SET NOCOUNT ON;')
	GO
	ALTER PROCEDURE dbo.InsertStudent
		@firstName VARCHAR(64),  
		@lastName VARCHAR(64),
		@groupId INT
	AS
	BEGIN
		SET NOCOUNT ON;  
		MERGE student AS target
		USING (SELECT @firstName, @lastName, @groupId) AS source (firstName, lastName, groupId)
		ON (target.lastName = source.lastName AND target.firstName = source.firstName)
		WHEN MATCHED AND source.groupId IS NOT NULL THEN -- ���� ����� ���� �������� � �������� ����� ���� ���������, �� ������� ����� � ��� ��������� �������
			UPDATE SET groupId = source.groupId
		WHEN NOT MATCHED BY TARGET THEN -- ���� ������ �������� �� ���� - ������ ����
			INSERT (firstName, lastName, groupId)
			VALUES (source.firstName, source.lastName, source.groupId);	
	END
	GO

	EXEC InsertStudent @firstName = 'Volodymyr', @lastName = 'Zelenskyi', @groupId = 949

	SELECT firstname, lastname, groupId 
	FROM student
	WHERE lastname = 'Zelenskyi'

	EXEC InsertStudent @firstName = 'Volodymyr', @lastName = 'Zelenskyi', @groupId = 940

	SELECT firstname, lastname, groupId 
	FROM student
	WHERE lastname = 'Zelenskyi'
END

-- 2.17 INSERT ... OUTPUT
-- ��������� ��� �������� �����
BEGIN
	DECLARE @tableVariable TABLE (id INT)

	INSERT INTO class (name)
	OUTPUT INSERTED.ID INTO @tableVariable(ID)
	VALUES ('geoinformation theory')

	-- ���������� �� � ��� ����� ��� ����� ��� �������������� �����
	SELECT c.id, c.name
	FROM @tableVariable AS t
	JOIN class AS c ON c.id = t.id
END

-- 2.18  DELETE ... OUTPUT
-- ��������� ��� ���������� �����
BEGIN
	DECLARE @tableVariable TABLE (id INT)
	DECLARE @name VARCHAR(32) = 'mobile development'
	DECLARE @deletedId INT
	SELECT @deletedId = id FROM class WHERE name = @name -- �����'������� ������� 

	DELETE FROM class
	OUTPUT DELETED.ID INTO @tableVariable(ID)
	WHERE name = @name

	-- ���������� �� � ��� ������� ��������� �������
	SELECT CASE WHEN id = @deletedId THEN '��� ����������'
		       ELSE '��� �� ����������. ������ ����'
		   END
	FROM @tableVariable
END

-- 2.19  UPDATE ... OUTPUT
-- ��������� ��� �������� �����
BEGIN
	DECLARE @tableVariable TABLE (id INT)
	DECLARE @firstname VARCHAR(32) = 'Frank'
	DECLARE @groupId INT = 964
	DECLARE @updatedId INT
	SELECT @updatedId = id FROM student WHERE firstname = @firstname AND groupId = @groupId -- �����'������� ������� 

	UPDATE student SET lastname = 'Sinatra'
	OUTPUT INSERTED.ID INTO @tableVariable(ID)
	WHERE firstname = @firstname AND groupId = @groupId

	-- ���������� �� � ��� ������� ������� ����� ���� �� �����
	SELECT CASE WHEN id = @updatedId THEN '��� ����������'
		       ELSE '��� �� ����������. ������ ����'
		   END
	FROM @tableVariable
END

-- 2.20  MERGE ... OUTPUT
-- ³������ �� ������ ��������� � ������ 2.16.1 � ������ ��������� �� ��� ���������� ��� �������� 
BEGIN
	DECLARE @firstName VARCHAR(32) = 'Cruso'
	DECLARE @lastName VARCHAR(32) = 'Robbinzon'
	DECLARE @groupId INT = 936

	MERGE student AS target
	USING (SELECT @firstName, @lastName, @groupId) AS source (firstName, lastName, groupId)
	ON (target.lastName = source.lastName AND target.firstName = source.firstName)
	WHEN MATCHED AND source.groupId IS NOT NULL THEN -- ���� ����� ���� �������� � �������� ����� ���� ���������, �� ������� ����� � ������������ �������
		UPDATE SET groupId = source.groupId
	WHEN NOT MATCHED BY TARGET THEN -- ���� ������ �������� �� ���� - ������ ����
		INSERT (firstName, lastName, groupId)
		VALUES (source.firstName, source.lastName, source.groupId)
	OUTPUT $action AS performedAction; -- ��������� ��� UPDATE ��� INSERT � ������ �������
END