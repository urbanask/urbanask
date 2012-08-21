CREATE USER [api] FOR LOGIN [api] WITH DEFAULT_SCHEMA=[dbo]
GO


CREATE USER [badges] FOR LOGIN [badges] WITH DEFAULT_SCHEMA=[badges]
GO

CREATE USER [bounties] FOR LOGIN [bounties] WITH DEFAULT_SCHEMA=[bounties]
GO

CREATE USER [login] FOR LOGIN [login] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [messaging] FOR LOGIN [messaging] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [processAnswers] FOR LOGIN [processAnswers] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [ProcessBadges] FOR LOGIN [ProcessBadges] WITH DEFAULT_SCHEMA=[ProcessBadges]
GO

CREATE USER [processBounties] FOR LOGIN [processBounties] WITH DEFAULT_SCHEMA=[processBounties]
GO

CREATE USER [processQuestions] FOR LOGIN [processQuestions] WITH DEFAULT_SCHEMA=[ProcessQuestions]
GO

CREATE USER [processReputation] FOR LOGIN [processReputation] WITH DEFAULT_SCHEMA=[processReputation]
GO

CREATE USER [processTopLists] FOR LOGIN [processTopLists] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [reputation] FOR LOGIN [reputation] WITH DEFAULT_SCHEMA=[reputation]
GO
CREATE USER [top] FOR LOGIN [top] WITH DEFAULT_SCHEMA=[top]
GO

CREATE SCHEMA [api] AUTHORIZATION [api]
GO

CREATE SCHEMA [badges] AUTHORIZATION [badges]
GO
CREATE SCHEMA [bounties] AUTHORIZATION [bounties]
GO

CREATE SCHEMA [login] AUTHORIZATION [login]
GO

CREATE SCHEMA [lookup] AUTHORIZATION [dbo]
GO

CREATE SCHEMA [messaging] AUTHORIZATION [messaging]
GO

CREATE SCHEMA [processAnswers] AUTHORIZATION [processAnswers]
GO
CREATE SCHEMA [ProcessBadges] AUTHORIZATION [ProcessBadges]
GO

CREATE SCHEMA [processBounties] AUTHORIZATION [processBounties]
GO

CREATE SCHEMA [processQuestions] AUTHORIZATION [processQuestions]
GO

CREATE SCHEMA [processReputation] AUTHORIZATION [processReputation]
GO

CREATE SCHEMA [reputation] AUTHORIZATION [reputation]
GO

CREATE SCHEMA [top] AUTHORIZATION [top]
GO

CREATE SCHEMA [utility] AUTHORIZATION [dbo]
GO




