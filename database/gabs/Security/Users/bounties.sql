IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'bounties')
CREATE LOGIN [bounties] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [bounties] FOR LOGIN [bounties] WITH DEFAULT_SCHEMA=[bounties]
GO
