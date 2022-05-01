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