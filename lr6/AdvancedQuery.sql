
-- Для початку зробимо альтери над таблицями для того щоб можна було використовувати сортування над певними полями
-- (Змінимо поля з типом TEXT -> VARCHAR)
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
-- Наприклад, викладач хоче створити список учнів його групи за зворотним алфавітним порядком (від Z->A, від Я->А) 
BEGIN
	DECLARE @teacherId INT = 1
	-- Використовуємо каст до варчару, тому що не можна сортувати ы
	SELECT ROW_NUMBER() OVER(ORDER BY lastname DESC,firstname DESC) AS RowNumber,
		   s.firstname,
		   s.lastName
	FROM student AS s
	JOIN [school].[group] AS g ON s.groupId = g.id
	WHERE g.curatorId = @teacherId
END 

-- 2.1.1 Ranking Window Functions. RANK
-- Наприклад, ректорат хоче створити список груп, які навчаються більше інших для побудови схеми загруженності учнів
BEGIN
	SELECT groupId,
		   RANK() OVER(ORDER BY groupId) AS Rank -- ступінь загруженності групи
	FROM schedule
	GROUP BY groupId;
END

-- 2.1.1 Ranking Window Functions. DENSE_RANK
-- Тепер ректорат замислився над тим щоб знайти найбільш працелюбних викладачів та винагородити їх, тому створит список від найбільш загруженого викладача, до самого лінивого
BEGIN
	SELECT t.lastname,
		   t.firstname,
		   DENSE_RANK() OVER(ORDER BY teacherId) AS Rank
	FROM schedule AS s
	JOIN teacher AS t ON s.teacherId = t.id
	GROUP BY s.teacherId, t.lastname, t.firstname;
END

-- 2.1.1 Ranking Window Functions. NTILE
-- Давайте розподілимо учнів на 4 групи за алфвітним списком
BEGIN
	SELECT firstname,
		   lastname,
		   NTILE(4) OVER(ORDER BY lastname, firstname) AS [GroupNumber]
	FROM student
	ORDER BY [GroupNumber];
END

-- 2.1.2 Offset Window Functions. LAG
-- Давайте виведемо біля поточної пари ім'я вчителя з попередньої пари
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
-- Давайте виведемо біля пари час наступної пари щоб можна було одразу зрозуміти чи буде час щоб перекусити
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
-- Давайте виведемо прізвище першого учня в кожній групі
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
-- Тепер давайте виведемо прізвище останнього учня в кожній групі
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
-- Виведемо кіл-ть студентів в кожній групі
BEGIN
	SELECT groupId,
		COUNT(1) AS count -- кіл-ть студентів в кожній групі   
	FROM student
	GROUP BY groupId
END

-- 2.1.3 Aggregate  Window Functions. AVG
-- Виведемо середню кіл-ть студентів в кожній групі
BEGIN
	SELECT AVG(count) AS averageStudentsCountPerGroup
	FROM (
		SELECT COUNT(1) AS count -- кіл-ть студентів в кожній групі
		FROM student
		GROUP BY groupId
	) AS counts
END

-- 2.1.3 Aggregate  Window Functions. MAX
-- Виведемо час останньої пари на першому тижні
BEGIN
	SELECT TOP 1 MAX(time) AS lastParaTime
	FROM schedule
	GROUP BY time, isOddWeek
	HAVING ISNULL(isOddWeek, 0) = 0
	ORDER BY lastParaTime DESC
END

-- 2.1.3 Aggregate  Window Functions. MIN
-- Виведемо час першої пари на другому тижні
BEGIN
	SELECT TOP 1 MIN(time) AS firstParaTime
	FROM schedule
	GROUP BY time, isOddWeek
	HAVING ISNULL(isOddWeek, 1) = 1
	ORDER BY firstParaTime ASC
END

-- 2.1.3 Aggregate  Window Functions. SUM
-- Виведемо загальну кіл-ть студентів і викладачів
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
-- Виведемо групу та кіл-ть пар в кожний з днів тижня
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
-- Візьмемо таблицю з попереднього запиту і перетворимо її на структуру: groupId, day
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
-- Виведемо кіл-ть студентів в кожній групі використовуючи GROUPING SETS
BEGIN
	SELECT groupId,
		   COUNT(1) AS studentsPerGroup
	FROM student
	GROUP BY GROUPING SETS (groupId)
	ORDER BY groupId
END

-- 2.5 CUBE
-- Тепер виведемо не тільки кіл-ть студентів в кожній групі, а ще й загальну суму студентів
BEGIN
	SELECT groupId,
		   COUNT(1) AS studentsPerGroup
	FROM student
	GROUP BY CUBE(groupId)
	ORDER BY groupId
END

-- 2.6 ROLLUP
-- Тепер виведемо не тільки кіл-ть студентів в кожній групі, а ще й загальну суму студентів
-- ROLLUP майже такий самий як і CUBE, але CUBE згенерує ще під-тотал для всіх комбінацій груп
BEGIN
	SELECT ISNULL(groupId, 0) AS groupId,
		   COUNT(1) AS studentsPerGroup
	FROM student
	GROUP BY ROLLUP(groupId)
	ORDER BY groupId
END

-- 2.7 GROUPING()
-- Покажемо який рядок є згрупованим серед усіх
BEGIN
	SELECT groupId,
		   COUNT(1) AS studentsPerGroup,
		   GROUPING(groupId) AS 'Grouping'
	FROM student
	GROUP BY ROLLUP(groupId)
END

-- 2.8 GROUPING_ID()
-- GROUPING_ID() такий самий як і GROUPING, різниця лиш в тому що GROUPING_ID() може працювати з декількома полями одночасно
BEGIN
	SELECT groupId, firstname,
		   COUNT(1) AS studentsPerGroup,
		   GROUPING_ID(groupId, firstname) AS 'Grouping'
	FROM student
	GROUP BY ROLLUP(groupId, firstname)
END

-- 2.9.1 INSERT VALUES
-- Спробуємо додати декілька нових студентів
BEGIN
	INSERT INTO student (firstname, lastname, groupId)
	VALUES ('Patrick', 'Bateman', 936),
		   ('Homer', 'Simpson', 936);
END

-- 2.9.2 INSERT SELECT
-- Спробуємо додати хайзенберга до списку викладачів хімфаку
BEGIN
	INSERT INTO teacher
	SELECT 'Walter', 'White'
END

-- 2.9.3 INSERT EXEC
-- Додамо ще одного викладача
BEGIN
	DECLARE @q nvarchar(64) = ' SELECT ''Tony'', ''Soprano'' '
	INSERT INTO teacher (firstname, lastname)
	EXEC(@q)
END

-- 2.9.4 SELECT INTO
-- SELECT INTO створює нову таблицю в звичайній файлгрупі і додає дані саме туди, тому давайте спробуємо додати дані в тимчасову табличку
BEGIN
	IF OBJECT_ID('tempdb..#tmpTable') IS NOT NULL DROP TABLE #tmpTable
	GO

	SELECT firstName, lastname, groupId
	INTO #tmpTable
	FROM student
END

-- 2.9.5 BULK INSERT
-- Додамо нового студента з файлу 'new_students.csv'
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
-- Повертає нам стовпчик з таблиці, який має тип IDENTITY
BEGIN
	DECLARE @tableVariable TABLE (myidentity INT IDENTITY(1,1) PRIMARY KEY, ch CHAR(1))
	INSERT INTO @tableVariable (ch) VALUES ('s'), ('i'), ('g'), ('m'), ('a')

	SELECT $identity
	FROM @tableVariable
END

-- 2.10.2 @@identity
-- Повертає нам номер останньо доданого рядка. Обмежена поточним сеансом
BEGIN
	SELECT MAX(id)
	FROM student;

	INSERT INTO student (firstName, lastName, groupId)
	VALUES ('Bruce', 'Wayne', 949)

	SELECT @@IDENTITY
END

-- 2.10.3 SCOPE_IDENTITY()
-- Обмежена поточним сеансом та областю дії
BEGIN
	SELECT MAX(id)
	FROM class;

	INSERT INTO class (name) VALUES ('math')

	SELECT SCOPE_IDENTITY()
END

-- 2.10.4 IDENT_CURRENT('table name')
-- Необмежена областю дії та сеансом, але обмежена вказанням таблиці
BEGIN
	SELECT MAX(id)
	FROM class;

	INSERT INTO class (name) VALUES ('machine learning')

	SELECT IDENT_CURRENT('class')
END

-- 2.10.5 IDENT_INSERT
-- Дозволяє додавати явно змінні в identity поле
BEGIN
	DECLARE @id INT = 5
	DECLARE @name VARCHAR(64)

	-- Запам'ятовуємо значення по айдішнику
	SELECT @name = name
	FROM class
	WHERE id = @id

	-- Робимо простір між значеннями identity
	DELETE class
	WHERE id = @id

	SET IDENTITY_INSERT class ON;
	INSERT INTO class (id, name) VALUES (@id, @name); -- Якби не було виставлено значення IDENTITY_INSERT ON, в нас би виникла тут помилка
	SET IDENTITY_INSERT class OFF;
END

-- 2.11 CREATE SEQUENCE
BEGIN
	IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[students_seq]') AND type = 'SO') DROP SEQUENCE students_seq;
	GO

	CREATE SEQUENCE students_seq
	AS BIGINT
	START WITH 1     -- Початкове значення послідовності
	INCREMENT BY 1   -- На яке значення збільшувати значення
	MINVALUE 1       -- Мінімальне значення в послідовності
	MAXVALUE 99999   -- Максимальне значення в послідовності
	NO CYCLE	     -- Не скидати послідовність після того як дійшло до макс.значення
	CACHE 10;        -- Запам'ятовувати кожні витягнуті 10 значень з послідовності

	SELECT NEXT VALUE FOR students_seq; -- Дістаємо наступне значення з послідовності
	SELECT NEXT VALUE FOR students_seq; -- Дістаємо наступне значення з послідовності
END

-- 2.12.1 sys.sequences view
BEGIN
	-- Якщо хочемо побачити які є послідовності на цій бд - виконаємо такий запит 
	SELECT * FROM sys.sequences
END

-- 2.12.2 sp_sequence_get_range
BEGIN
	-- Дістанемо наступні 10 значень з послідовності, яку створили в пункті 2.11
	DECLARE @range_first_value_output sql_variant;
	DECLARE @range_size INT = 10
	EXEC sp_sequence_get_range @sequence_name = 'students_seq', @range_size = @range_size, @range_first_value = @range_first_value_output OUTPUT;

	SELECT @range_first_value_output
END

-- 2.13 DELETE
-- Видалимо студента Гомера Сімпсона з бази даних, через те що він погано вчився
BEGIN
	-- Краще було б видалити через поле id, але для того щоб показати що можна видаляти і за декількома полями використаємо такий синтаксис
	DELETE FROM student
	WHERE firstName = 'Homer' AND lastName = 'Simpson' AND groupId = 936;
END

-- 2.14 TRUNCATE
-- TRUNCATE використовується для того, щоб видалити всі записи з таблиці. Але він залишає поля, індекси та обмеження. (identity поле скидається на замовчуване або 1)
BEGIN
	-- TRUNCATE схожий на DELETE без WHERE, але він швидший і використовує менше ресурсів
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
-- Адмін був неуважний і неправильно написав ім'я останнього учня що додав до бази даних, тому одразу написав такий запит щоб відредагувати ім'я на правильне
BEGIN
	UPDATE student
	SET firstname = 'Bobby'
	WHERE id = (SELECT MAX(id) FROM student)
END

-- 2.16.1 MERGE. WHEN MATCHED THEN. WHEN NOT MATCHED THEN
-- Уявімо ситуація що нам треба оновити дані про викладача, а якщо його ще не додано до таблиці - створити новий рядок
BEGIN
	-- Створимо для цього невеличку процедуру
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
		WHEN MATCHED THEN -- Якщо умова вище виконана, то виконається операція UPDATE
			UPDATE SET firstName = source.firstName
		WHEN NOT MATCHED THEN -- Якщо не виконана - операція INSERT
			INSERT (firstName, lastName)
			VALUES (source.firstName, source.lastName);
	END
	GO
	
	-- Протестуємо процедуру
	DECLARE @lastName VARCHAR(64) = 'Pennyworth'
	EXEC InsertTeacher @firstName = 'Alfred', @lastName = @lastName
	EXEC InsertTeacher @firstName = 'Saxon', @lastName = @lastName
	
	SELECT firstname, lastname 
	FROM teacher
	WHERE lastname = @lastname
END

-- 2.16.2 MERGE. WHEN MATCHED AND ... THEN. WHEN NOT MATCHED BY TARGET THEN
-- Тепер давайте побудуємо схожу процедуру і для студентів
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
		WHEN MATCHED AND source.groupId IS NOT NULL THEN -- Якщо умова вище виконана і передана група буде непорожня, то оновимо групу в якій навчається студент
			UPDATE SET groupId = source.groupId
		WHEN NOT MATCHED BY TARGET THEN -- Якщо такого студента ще немає - додамо його
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
-- Збережемо айді доданого рядка
BEGIN
	DECLARE @tableVariable TABLE (id INT)

	INSERT INTO class (name)
	OUTPUT INSERTED.ID INTO @tableVariable(ID)
	VALUES ('geoinformation theory')

	-- Перевіряємо що в нас дійсно той самий айді новоствореного рядка
	SELECT c.id, c.name
	FROM @tableVariable AS t
	JOIN class AS c ON c.id = t.id
END

-- 2.18  DELETE ... OUTPUT
-- Збережемо айді видаленого рядка
BEGIN
	DECLARE @tableVariable TABLE (id INT)
	DECLARE @name VARCHAR(32) = 'mobile development'
	DECLARE @deletedId INT
	SELECT @deletedId = id FROM class WHERE name = @name -- Запам'ятовуємо айдішник 

	DELETE FROM class
	OUTPUT DELETED.ID INTO @tableVariable(ID)
	WHERE name = @name

	-- Перевіряємо що в нас зберігся видалений айдішник
	SELECT CASE WHEN id = @deletedId THEN 'Айді співпадають'
		       ELSE 'Айді не співпадають. Кернел панік'
		   END
	FROM @tableVariable
END

-- 2.19  UPDATE ... OUTPUT
-- Збережемо айді зміненого рядка
BEGIN
	DECLARE @tableVariable TABLE (id INT)
	DECLARE @firstname VARCHAR(32) = 'Frank'
	DECLARE @groupId INT = 964
	DECLARE @updatedId INT
	SELECT @updatedId = id FROM student WHERE firstname = @firstname AND groupId = @groupId -- Запам'ятовуємо айдішник 

	UPDATE student SET lastname = 'Sinatra'
	OUTPUT INSERTED.ID INTO @tableVariable(ID)
	WHERE firstname = @firstname AND groupId = @groupId

	-- Перевіряємо що в нас зберігся айдішник рядка який ми міняли
	SELECT CASE WHEN id = @updatedId THEN 'Айді співпадають'
		       ELSE 'Айді не співпадають. Кернел панік'
		   END
	FROM @tableVariable
END

-- 2.20  MERGE ... OUTPUT
-- Візьмемо за основу процедуру з пункта 2.16.1 і будемо повертати дію яка виконалась над таблицею 
BEGIN
	DECLARE @firstName VARCHAR(32) = 'Cruso'
	DECLARE @lastName VARCHAR(32) = 'Robbinzon'
	DECLARE @groupId INT = 936

	MERGE student AS target
	USING (SELECT @firstName, @lastName, @groupId) AS source (firstName, lastName, groupId)
	ON (target.lastName = source.lastName AND target.firstName = source.firstName)
	WHEN MATCHED AND source.groupId IS NOT NULL THEN -- Якщо умова вище виконана і передана група буде непорожня, то оновимо групу в якійнавчається студент
		UPDATE SET groupId = source.groupId
	WHEN NOT MATCHED BY TARGET THEN -- Якщо такого студента ще немає - додамо його
		INSERT (firstName, lastName, groupId)
		VALUES (source.firstName, source.lastName, source.groupId)
	OUTPUT $action AS performedAction; -- Повертаємо або UPDATE або INSERT в нашому випадку
END