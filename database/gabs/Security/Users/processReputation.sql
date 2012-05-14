IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'processReputation')
CREATE LOGIN [processReputation] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [processReputation] FOR LOGIN [processReputation] WITH DEFAULT_SCHEMA=[processReputation]
GO
