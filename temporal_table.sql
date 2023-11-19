CREATE TABLE dbo.Users
(
    UserID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
    UserName NVARCHAR(50) NOT NULL
);

CREATE TABLE dbo.Projects
(
    ProjectID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Projects PRIMARY KEY,
    ProjectName NVARCHAR(50) NOT NULL
);

CREATE TABLE dbo.UserAssignment
(
    AssignmentID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_UserAssignment PRIMARY KEY,
    UserID INT NOT NULL CONSTRAINT FK_UserAssignment_Users_UserID FOREIGN KEY REFERENCES dbo.Users(UserID),
    ProjectID INT NOT NULL CONSTRAINT FK_UserAssignment_Projects_ProjectID FOREIGN KEY REFERENCES dbo.Projects(ProjectID),
    Amount DECIMAL(18,2) NOT NULL,
    ValidFromUTC DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    ValidToUTC DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFromUTC, ValidToUTC)
);

ALTER TABLE dbo.UserAssignment
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UserAssignmentHistory));

INSERT INTO dbo.Users (UserName)
VALUES ('Wyatt Earp'),
       ('Doc Holliday'),
       ('Ike Clanton'),
       ('Virgil Earp');

INSERT INTO dbo.Projects (ProjectName)
VALUES ('Project A'),
       ('Project B'),
       ('Project C');

INSERT INTO dbo.UserAssignment (UserID, ProjectID, Amount)
VALUES 
    (1, 1, 5000.00),
    (2, 2, 7500.00),
    (3, 2, 6500.00),
    (4, 1, 5500.00);

UPDATE dbo.UserAssignment
SET Amount = 6000.00
WHERE AssignmentID = 1;

UPDATE dbo.UserAssignment
SET Amount = 9000.00
WHERE AssignmentID = 2;

UPDATE dbo.UserAssignment
SET Amount = 6800.00
WHERE AssignmentID = 3;

INSERT INTO dbo.UserAssignment (UserID, ProjectID, Amount)
VALUES 
    (1, 3, 8000.00);

-- view the entire history of table
SELECT ua.AssignmentID, u.UserName, p.ProjectName, ua.Amount, ua.ValidFromUTC, ua.ValidToUTC
FROM dbo.UserAssignment FOR SYSTEM_TIME ALL ua
INNER JOIN dbo.Users u ON ua.UserID = u.UserID
INNER JOIN dbo.Projects p ON ua.ProjectID = p.ProjectID
ORDER BY AssignmentID, ValidFromUTC ASC;

-- view it for a set point in time 
SELECT ua.AssignmentID, u.UserName, p.ProjectName, ua.Amount, ua.ValidFromUTC, ua.ValidToUTC
FROM dbo.UserAssignment FOR SYSTEM_TIME AS OF '2023-01-19 05:20:11.2282792' ua -- other options include FOR SYSTEM_TIME BETWEEN '2023-01-01' AND '2023-02-01'
INNER JOIN dbo.Users u ON ua.UserID = u.UserID
INNER JOIN dbo.Projects p ON ua.ProjectID = p.ProjectID
ORDER BY AssignmentID, ValidFromUTC ASC;
