CREATE TABLE [dbo].[userFacebook]
(
[userFacebookId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[facebookId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[accessToken] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postQuestions] [int] NOT NULL CONSTRAINT [DF_userFacebook_postQuestions] DEFAULT ((1)),
[postAnswers] [int] NOT NULL CONSTRAINT [DF_userFacebook_postAnswers] DEFAULT ((1)),
[postBadges] [int] NOT NULL CONSTRAINT [DF_userFacebook_postBadges] DEFAULT ((1))
) ON [PRIMARY]
CREATE CLUSTERED INDEX [ix_userFacebook_userId] ON [dbo].[userFacebook] ([userId], [facebookId]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ix_userFacebook_facebookId] ON [dbo].[userFacebook] ([facebookId], [userId]) ON [PRIMARY]

GO
GRANT SELECT ON  [dbo].[userFacebook] TO [api]
GRANT SELECT ON  [dbo].[userFacebook] TO [login]
GRANT INSERT ON  [dbo].[userFacebook] TO [login]
GRANT UPDATE ON  [dbo].[userFacebook] TO [login]
GO

ALTER TABLE [dbo].[userFacebook] ADD CONSTRAINT [pk_userFacebook] PRIMARY KEY NONCLUSTERED  ([userFacebookId]) ON [PRIMARY]
GO
