CREATE TABLE [dbo].[user]
(
[userId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[username] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[displayName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_user_displayName] DEFAULT (''),
[tagline] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reputation] [int] NOT NULL CONSTRAINT [DF_user_reputation] DEFAULT ((0)),
[hash] [char] (88) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[salt] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iterations] [int] NOT NULL,
[hashTypeId] [dbo].[foreignKey] NOT NULL,
[enabled] [bit] NOT NULL CONSTRAINT [DF_user_enabled] DEFAULT ((1)),
[metricDistances] [int] NOT NULL CONSTRAINT [DF_user_metricDistances] DEFAULT ((0)),
[languageId] [dbo].[foreignKey] NOT NULL CONSTRAINT [DF_user_languageId] DEFAULT ((1)),
[signupDate] [datetime2] NOT NULL CONSTRAINT [DF_user_signupDate] DEFAULT (getdate()),
[authTypeId] [dbo].[foreignKey] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user] ADD CONSTRAINT [pk_user] PRIMARY KEY NONCLUSTERED  ([userId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_user_username] ON [dbo].[user] ([username], [authTypeId], [enabled], [userId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[user] TO [api]
GRANT UPDATE ON  [dbo].[user] TO [api]
GRANT SELECT ON  [dbo].[user] TO [login]
GRANT INSERT ON  [dbo].[user] TO [login]
GRANT UPDATE ON  [dbo].[user] TO [login]
GRANT SELECT ON  [dbo].[user] TO [messaging]
GRANT SELECT ON  [dbo].[user] TO [processAnswers]
GRANT SELECT ON  [dbo].[user] TO [ProcessBadges]
GRANT SELECT ON  [dbo].[user] TO [processQuestions]
GRANT SELECT ON  [dbo].[user] TO [processReputation]
GRANT UPDATE ON  [dbo].[user] TO [processReputation]
GRANT SELECT ON  [dbo].[user] TO [processTopLists]
GO
