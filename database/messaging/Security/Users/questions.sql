IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'questions')
CREATE LOGIN [questions] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [questions] FOR LOGIN [questions] WITH DEFAULT_SCHEMA=[Questions]
GO
