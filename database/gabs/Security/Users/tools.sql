IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'tools')
CREATE LOGIN [tools] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [tools] FOR LOGIN [tools] WITH DEFAULT_SCHEMA=[tools]
GO
