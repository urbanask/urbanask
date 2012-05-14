IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'processBounties')
CREATE LOGIN [processBounties] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [processBounties] FOR LOGIN [processBounties] WITH DEFAULT_SCHEMA=[processBounties]
GO
