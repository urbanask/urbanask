IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'login')
CREATE LOGIN [login] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [login] FOR LOGIN [login]
GO
