IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ProcessBadges')
CREATE LOGIN [ProcessBadges] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [ProcessBadges] FOR LOGIN [ProcessBadges] WITH DEFAULT_SCHEMA=[ProcessBadges]
GO
