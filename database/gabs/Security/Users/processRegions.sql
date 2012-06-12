IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'processRegions')
CREATE LOGIN [processRegions] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [processRegions] FOR LOGIN [processRegions] WITH DEFAULT_SCHEMA=[processRegions]
GO
