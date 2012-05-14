IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'processQuestions')
CREATE LOGIN [processQuestions] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [processQuestions] FOR LOGIN [processQuestions] WITH DEFAULT_SCHEMA=[ProcessQuestions]
GO
