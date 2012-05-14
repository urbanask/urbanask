IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'messaging')
CREATE LOGIN [messaging] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [messaging] FOR LOGIN [messaging]
GO
