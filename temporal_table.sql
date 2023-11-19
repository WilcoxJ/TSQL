CREATE TABLE dbo.UserAssignment
(
    AssignmentID INT IDENTITY NOT NULL,
    UserID INT NOT NULL,
    ProjectID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    ValidFromUTC DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidToUTC DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFromUTC, ValidToUTC)
);

-- Enable system versioning on the table
ALTER TABLE dbo.UserAssignment
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UserAssignmentHistory));

-- Insert some initial data
INSERT INTO dbo.UserAssignment (UserID, ProjectID, Amount)
VALUES 
    (101, 1, 5000.00),
    (102, 2, 7500.00),
    (103, 2, 6500.00),
    (104, 1, 5500.00);

-- Update an assignment amount
UPDATE dbo.UserAssignment
SET Amount = 6000.00
WHERE UserID = 101 AND ProjectID = 1;

UPDATE dbo.UserAssignment
SET Amount = 6800.00
WHERE UserID = 103 AND ProjectID = 2;

INSERT INTO dbo.UserAssignment (UserID, ProjectID, Amount)
VALUES 
    (105, 3, 8000.00),

-- Query the current state of the table
SELECT AssignmentID, UserID, ProjectID, Amount, ValidFromUTC, ValidToUTC
FROM dbo.UserAssignment;

-- Query the history of changes for all records
SELECT AssignmentID, UserID, ProjectID, Amount, ValidFromUTC, ValidToUTC
FROM dbo.UserAssignment
FOR SYSTEM_TIME ALL;
-- other options: FOR SYSTEM_TIME AS OF '2023-01-15', SYSTEM_TIME BETWEEN '2023-01-01' AND '2023-02-01'
