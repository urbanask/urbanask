IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'processAnswers')
CREATE LOGIN [processAnswers] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [processAnswers] FOR LOGIN [processAnswers]
GO
