IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'reputation')
CREATE LOGIN [reputation] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [reputation] FOR LOGIN [reputation] WITH DEFAULT_SCHEMA=[reputation]
GO
