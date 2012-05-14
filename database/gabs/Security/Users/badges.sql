IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'badges')
CREATE LOGIN [badges] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [badges] FOR LOGIN [badges] WITH DEFAULT_SCHEMA=[badges]
GO
