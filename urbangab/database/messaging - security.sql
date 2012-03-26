CREATE USER [answers] FOR LOGIN [answers] WITH DEFAULT_SCHEMA=[dbo]
GO


CREATE USER [messaging] FOR LOGIN [messaging] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [processAnswers] FOR LOGIN [processAnswers] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [processQuestions] FOR LOGIN [processQuestions] WITH DEFAULT_SCHEMA=[ProcessQuestions]
GO

CREATE USER [questions] FOR LOGIN [questions] WITH DEFAULT_SCHEMA=[Questions]
GO

CREATE SCHEMA [answers] AUTHORIZATION [answers]
GO

CREATE SCHEMA [messaging] AUTHORIZATION [messaging]
GO

CREATE SCHEMA [processAnswers] AUTHORIZATION [processAnswers]
GO

CREATE SCHEMA [processQuestions] AUTHORIZATION [processQuestions]
GO

CREATE SCHEMA [questions] AUTHORIZATION [questions]
GO

