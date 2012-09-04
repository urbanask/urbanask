IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'verifyPhoneNumbers')
CREATE LOGIN [verifyPhoneNumbers] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [verifyPhoneNumbers] FOR LOGIN [verifyPhoneNumbers]
GO
