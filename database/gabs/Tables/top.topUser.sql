CREATE TABLE [top].[topUser]
(
[topUserId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[regionId] [dbo].[foreignKey] NOT NULL,
[topTypeId] [dbo].[foreignKey] NOT NULL,
[intervalId] [dbo].[foreignKey] NOT NULL,
[userId] [dbo].[foreignKey] NOT NULL,
[username] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reputation] [int] NOT NULL,
[totalQuestions] [int] NOT NULL,
[totalAnswers] [int] NOT NULL,
[totalBadges] [int] NOT NULL,
[topScore] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [top].[topUser] ADD CONSTRAINT [pk_topUser] PRIMARY KEY NONCLUSTERED  ([topUserId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_topUser_regionId] ON [top].[topUser] ([regionId], [topTypeId], [intervalId], [topScore]) ON [PRIMARY]
GO
GRANT SELECT ON  [top].[topUser] TO [api]
GO
