-- Create master key pw
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '3aog57q15d4Ldsase445wsd4f'  

-- add varbinary field to table
ALTER TABLE [dbo].[enc_test]
    ADD encryptedCol varbinary(128);
    GO  

-- Create PW protected cert
CREATE CERTIFICATE testCert01
    ENCRYPTION BY PASSWORD = 'pGFD4bb925DGvbd2439587y'
   WITH SUBJECT = 'Test',   
   EXPIRY_DATE = '20251031';  
GO  

-- Create KEY
CREATE SYMMETRIC KEY testKey01   
WITH ALGORITHM = AES_256  -- I'm using AES256, but you can use whichever algorithm you prefer. Link to docs: https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/data-encryption-in-sql-server#:~:text=SQL%20Server%20supports%20several%20symmetric,using%20the%20Windows%20Crypto%20API.
ENCRYPTION BY CERTIFICATE testCert01;  
GO      

-- Update table with encrypted value 
OPEN SYMMETRIC KEY testKey01  
   DECRYPTION BY CERTIFICATE testCert01 WITH PASSWORD = 'pGFD4bb925DGvbd2439587y';  

UPDATE [dbo].[enc_test]
SET encryptedCol  
    = EncryptByKey(Key_GUID('testKey01'), 'plain text test');  
GO      

-- view Encrypted Column
SELECT * FROM [dbo].[enc_test];     

-- View Decrypted Column
OPEN SYMMETRIC KEY testKey01  
  DECRYPTION BY CERTIFICATE testCert01 WITH PASSWORD = 'pGFD4bb925DGvbd2439587y';   

SELECT *, Convert(varchar, (DECRYPTBYKEY(encryptedCol))) 
FROM [dbo].[enc_test];