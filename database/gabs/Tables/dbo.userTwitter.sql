CREATE TABLE [dbo].[userTwitter]
(
[userTwitterId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[twitterId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[screenName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[token] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tokenSecret] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postQuestions] [int] NOT NULL CONSTRAINT [DF_userTwitter_postQuestions] DEFAULT ((1)),
[postAnswers] [int] NOT NULL CONSTRAINT [DF_userTwitter_postAnswers] DEFAULT ((1)),
[postBadges] [int] NOT NULL CONSTRAINT [DF_userTwitter_postBadges] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userTwitter] ADD CONSTRAINT [pk_userTwitter] PRIMARY KEY NONCLUSTERED  ([userTwitterId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_userTwitter_twitterId] ON [dbo].[userTwitter] ([twitterId], [userId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userTwitter] TO [login]
GRANT INSERT ON  [dbo].[userTwitter] TO [login]
GO
