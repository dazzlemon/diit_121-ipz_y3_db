-- Create

-- USE master;
-- DROP DATABASE School;

CREATE DATABASE School;
USE School;

CREATE TABLE Room( Id INT

                  , CONSTRAINT PK_Room PRIMARY KEY (Id)
                  )


CREATE TABLE Teacher( Id        INT IDENTITY(1, 1)
                    , FirstName TEXT NOT NULL
                    , LastName  TEXT NOT NULL
                    
                    , CONSTRAINT PK_Teacher PRIMARY KEY (Id)
                    )

CREATE TABLE [Group]( Id        INT
                    -- NVARCHAR(450) instead of TEXT because it won't work with UNIQUE otherwise
                    , [Name]    NVARCHAR(450) NOT NULL UNIQUE
                    , CuratorId INT NOT NULL

                    , CONSTRAINT FK_CuratorId FOREIGN KEY (CuratorId) REFERENCES Teacher (Id)
                    , CONSTRAINT PK_Group     PRIMARY KEY (Id)
                    )


CREATE TABLE ClassType( Id   INT IDENTITY(1, 1)
                      -- NVARCHAR(450) instead of TEXT because it won't work with UNIQUE otherwise
                      , Name NVARCHAR(450) NOT NULL UNIQUE

                      , CONSTRAINT PK_ClassType PRIMARY KEY (Id)
                      )

CREATE TABLE Class( Id            INT IDENTITY(1, 1)
                  -- NVARCHAR(450) instead of TEXT because it won't work with UNIQUE otherwise
                  , [Name]        NVARCHAR(450) NOT NULL UNIQUE                  

                  , CONSTRAINT PK_Class PRIMARY KEY (Id)
                  )

CREATE TABLE Schedule( [Day]       SMALLINT NOT NULL
                     , [Time]      TIME     NOT NULL
                     , IsOddWeek   BIT DEFAULT NULL -- if NULL same for both weeks
                     , ClassTypeId INT      NOT NULL
                     , ClassId     INT      NOT NULL
                     , GroupId     INT      NOT NULL
                     , Subgroup    INT      NOT NULL DEFAULT 0 -- 0 means whole group together
                     , TeacherId   INT      NOT NULL
                     , RoomId      INT      NOT NULL

                     , CONSTRAINT FK_Schedule_RoomId      FOREIGN KEY (RoomId)      REFERENCES Room      (Id)
                     , CONSTRAINT FK_Schedule_TeacherId   FOREIGN KEY (TeacherId)   REFERENCES Teacher   (Id)
                     , CONSTRAINT FK_Schedule_ClassTypeId FOREIGN KEY (ClassTypeId) REFERENCES ClassType (Id)
                     , CONSTRAINT FK_Schedule_ClassId     FOREIGN KEY (ClassId)     REFERENCES Class     (Id)
                     , CONSTRAINT FK_Schedule_GroupId     FOREIGN KEY (GroupId)     REFERENCES [Group]   (Id)
                     , CONSTRAINT CHK_Schedule CHECK ([Day] BETWEEN 0 AND 6) -- 0 is monday
                     )


CREATE TABLE Student( Id                INT  IDENTITY(1, 1)
                    , FirstName         TEXT NOT NULL
                    , LastName          TEXT NOT NULL
                    , GroupId           INT  NOT NULL
                    
                    , CONSTRAINT PK_Student         PRIMARY KEY (Id)
                    , CONSTRAINT FK_Student_GroupId FOREIGN KEY (GroupId) REFERENCES [Group] (Id)
                    )

-- Populate
-- source for random names: https://perchance.org/first-and-last-name
--                 numbers: https://www.randomlists.com/random-numbers

INSERT INTO Room (Id)
          VALUES (202) --  1
               , (303) --  2
               , (404) --  3
               , (504) --  4
               , (323) --  5
               , (220) --  6
               , (1234) -- 7
               , (1) --    8
               , (419) --  9
               , (123) -- 10
               ;

INSERT INTO Teacher (FirstName, LastName  )
             VALUES ('John',    'Nash'    ) --  1
                  , ('Terence', 'Tao'     ) --  2
                  , ('fname1',  'fname2'  ) --  3
                  , ('another', 'cool guy') --  4
                  , ('and one', 'more'    ) --  5
                  , ('aboba',   'abobovich') -- 6
                  , ('Alexander',  'Ivanov') -- 7
                  , ('Valeriy', 'Jmishenko') -- 8
                  , ('Ryleigh', 'Smith') --     9
                  , ('Alex', 'Gonzales') --    10
                  , ('Elijah', 'Ashley') --    11
                  , ('Zara', 'Kora') --        12
                  , ('Lila', 'Gonzales') --    13
                  , ('Amir', 'Scott') --       14
                  ;

INSERT INTO [Group] (Id, [Name], CuratorId)
             VALUES (911, '911', 1)
                  , (912, '912', 2)
                  , (931, '931', 3)
                  , (940, '940', 4)
                  , (927, '927', 5)
                  , (964, '964', 6)
                  , (951, '951', 7)
                  , (915, '915', 8)
                  , (920, '920', 9)
                  , (936, '936', 10)
                  , (928, '928', 11)
                  , (949, '949', 12)
                  ;

-- Less than 10 because there is no other types I know
INSERT INTO ClassType ([Name])
               VALUES ('Lecture')
                    , ('Laboratory')
                    , ('Practice')
                    ;

INSERT INTO Class (Name)
           VALUES ('Game Theory')        -- 1
                , ('Probability Theory') -- 2
                , ('One more subject')   -- 3
                , ('Databases') -- 4
                , ('Translators') -- 5
                , ('Computer Graphics') -- 6
                , ('Operating Systems') -- 7
                , ('Object Oriented Programming') -- 8
                , ('User Experience') -- 9
                , ('Mobile development') -- 10
                ;

-- Only 4 because its just combinations of other tables
INSERT INTO Schedule ([Day], [Time], IsOddWeek, ClassTypeId, ClassId, GroupId, Subgroup, TeacherId, RoomId)
               VALUES (0,    '9:30',  0,        1,           1,       911,     0,        1,         202)
                    , (0,    '9:30',  1,        1,           2,       911,     0,        2,         123)
                    , (0,    '11:00', NULL,     2,           3,       911,     1,        6,         1)
                    , (1,    '9:30',  NULL,     2,           1,       940,     2,        1,         1234)
                    ;

INSERT INTO Student (FirstName,  LastName,     GroupId)
             VALUES ('Daniel',    'Safonov',   911) -- 1
                  , ('John',      'Wick',      911) -- 2
                  , ('Valeria',   'Poverly',   931) -- 3
                  , ('Raelynn',   'Bandini',   940) -- 4
                  , ('Kai',       'McKenna',   927) -- 5
                  , ('Ryker',     'Kade',      964) -- 6
                  , ('Jesse',     'Carter',    951) -- 7
                  , ('Barrett',   'Rivera',    915) -- 8
                  , ('Charlotte', 'Solace',    920) -- 9
                  , ('Bennett',   'Hernandez', 936) -- 10
                  , ('Nyla',      'Hansley',   928) -- 11
                  , ('Ruth',      'Kora',      949) -- 12
                  ;