IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'api')
CREATE LOGIN [api] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [api] FOR LOGIN [api]
GO
