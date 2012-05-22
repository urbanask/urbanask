IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'bot')
CREATE LOGIN [bot] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [bot] FOR LOGIN [bot]
GO
