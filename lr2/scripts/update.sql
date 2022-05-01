-- TODO
USE School

DROP TABLE IF EXISTS Student

CREATE TABLE Student( Id                INT  IDENTITY(1, 1)
                    , FirstName         TEXT NOT NULL
                    , LastName          TEXT NOT NULL
                    , GroupId           INT  NOT NULL
                    
                    , CONSTRAINT PK_Student         PRIMARY KEY (Id)
                    , CONSTRAINT FK_Student_GroupId FOREIGN KEY (GroupId) REFERENCES School.[Group] (Id)
                    )

ALTER TABLE Student ADD NewColumn INT NULL

-- ALTER TABLE Student SP_RENAME COLUMN FirstName TO FirstNameRenamed -- DOESNT WORK IN T-SQL
EXEC sp_rename 'Student.FirstName', 'FirstNameRenamed', 'COLUMN'

ALTER TABLE Student
    ALTER COLUMN FirstNameRenamed NVARCHAR(6)

ALTER TABLE Student
    ADD CONSTRAINT DF_Student_FirstNameRenamed DEFAULT 'aboba' FOR FirstNameRenamed

ALTER TABLE Student DROP DF_Student_FirstNameRenamed

UPDATE Teacher
    SET FirstName = 'baobab'
    WHERE CONVERT(VARCHAR(MAX), FirstName) = 'aboba'

UPDATE Teacher
    SET FirstName = 'Avatar'
    Where CONVERT(VARCHAR(MAX), FirstName) = 'Zara'

INSERT INTO Student (FirstNameRenamed,  LastName,     GroupId)
             VALUES ('Daniel', 'Safonov',   911) -- 1
                  , ('John',   'Wick',      911) -- 2
                  , ('Valery', 'Poverly',   931) -- 3
                  , ('Raelyn', 'Bandini',   940) -- 4
                  , ('Kai',    'McKenna',   927) -- 5
                  , ('Ryker',  'Kade',      964) -- 6
                  , ('Jesse',  'Carter',    951) -- 7
                  , ('Baret',  'Rivera',    915) -- 8
                  , ('4arlot', 'Solace',    920) -- 9
                  , ('Bennet', 'Hernandez', 936) -- 10
                  , ('Nyla',   'Hansley',   928) -- 11
                  , ('Ruth',   'Kora',      949) -- 12
                  ;

UPDATE Student
    SET FirstNameRenamed = 'Avatar'
    Where CONVERT(VARCHAR(MAX), FirstNameRenamed) = 'Ruth'