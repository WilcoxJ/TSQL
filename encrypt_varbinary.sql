-- Create master key pw (if you don't already have one)
-- CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<pw>'  

-- Create cert
CREATE CERTIFICATE testCert01
   WITH SUBJECT = 'Test',   
   EXPIRY_DATE = '20251031';  
GO  

-- Create key
CREATE SYMMETRIC KEY testKey01   
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE testCert01;  
GO      

-- Create Table
CREATE TABLE [dbo].[enc_test](
	[user_id] [int] NOT NULL,
	[name] [nvarchar](50) NULL,
	[encrypted_col] [varbinary](256) NULL
) ON [PRIMARY]
GO


-- Update table with encrypted value 
OPEN SYMMETRIC KEY testKey01  
   DECRYPTION BY CERTIFICATE testCert01;    

UPDATE [dbo].[enc_test]
SET encrypted_col  
    = EncryptByKey(Key_GUID('testKey01'), 'plain text test');  
GO      

-- View Encrypted Column
SELECT * FROM [dbo].[enc_test];     

-- View Decrypted Column
OPEN SYMMETRIC KEY testKey01  
  DECRYPTION BY CERTIFICATE testCert01; 

SELECT *, Convert(varchar, (DECRYPTBYKEY(encrypted_col))) 
FROM [dbo].[enc_test];


-- SQL Server supports the following ciphers

	-- Symmetrical Encryption 
	-- DES | Triple DES | RC2 | RC4 (deprecated) | 128-bit RC4 (deprecated) | DESX | 128-bit AES | 192-bit AES | 256-bit AES	

	-- Asymmetrical Encryption
	-- RSA_4096 | RSA_3072 | RSA_2048 | RSA_1024 | RSA_512
	
-- Documentations Links:
	--Create symmetric key
	-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-symmetric-key-transact-sql?view=sql-server-ver15

	-- KEY_GUID
	-- https://docs.microsoft.com/en-us/sql/t-sql/functions/key-guid-transact-sql?view=sql-server-ver15	

	-- EncryptByKey 
	-- https://docs.microsoft.com/en-us/sql/t-sql/functions/encryptbykey-transact-sql?view=sql-server-ver15

	-- DecryptByKey 
	-- https://docs.microsoft.com/en-us/sql/t-sql/functions/decryptbykey-transact-sql?view=sql-server-ver15	
