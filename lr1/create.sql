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
                    
                    , CONSTRAINT PK_Teacher PRIMARY KEY (Id));


CREATE TABLE [Group]( Id        INT
                    , [Name]    TEXT NOT NULL
                    , CuratorId INT NOT NULL

                    , CONSTRAINT FK_CuratorId FOREIGN KEY (CuratorId) REFERENCES Teacher (Id)
                    , CONSTRAINT PK_Group     PRIMARY KEY (Id)
                    )


CREATE TABLE ClassType( Id   INT IDENTITY(1, 1)
                      , Name TEXT NOT NULL

                      , CONSTRAINT PK_ClassType PRIMARY KEY (Id)
                      )

CREATE TABLE Class( Id            INT IDENTITY(1, 1)
                  , [Name]        TEXT NOT NULL
                  
                  , CONSTRAINT PK_Class PRIMARY KEY (Id)
                  )

CREATE TABLE Schedule( [Day]       SMALLINT NOT NULL
                     , [Time]      TIME     NOT NULL
                     , IsOddWeek   BIT -- if NULL same for both weeks
                     , ClassTypeId INT      NOT NULL
                     , ClassId     INT      NOT NULL
                     , GroupId     INT      NOT NULL
                     , Subgroup    INT      NOT NULL
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
                    );
