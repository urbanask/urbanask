IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'verifyEmails')
CREATE LOGIN [verifyEmails] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [verifyEmails] FOR LOGIN [verifyEmails] WITH DEFAULT_SCHEMA=[verifyEmails]
GO
