IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'answers')
CREATE LOGIN [answers] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [answers] FOR LOGIN [answers]
GO
