-- This is an example of how to create a stored procedure that accepts the cert level pw as a parameter.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[testSproc]
    @pw NVARCHAR(MAX)
AS
BEGIN
    DECLARE @SQL AS NVARCHAR(MAX);
    SET NOCOUNT ON;
    SET @SQL = 'OPEN SYMMETRIC KEY key_name DECRYPTION BY CERTIFICATE cert_name WITH PASSWORD = '''+@pw+'''';

    EXEC (@SQL)
    -- Now that the key is open you can encrypt and decrypt as needed in the sproc 

    SELECT *, Convert(varchar, (DECRYPTBYKEY(encryptedCol))) 
        FROM [dbo].[enc_test];
    
END
