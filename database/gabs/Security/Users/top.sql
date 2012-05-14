IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'top')
CREATE LOGIN [top] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [top] FOR LOGIN [top] WITH DEFAULT_SCHEMA=[top]
GO
