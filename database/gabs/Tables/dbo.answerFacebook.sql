CREATE TABLE [dbo].[answerFacebook]
(
[answerFacebookId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[answerId] [dbo].[foreignKey] NOT NULL,
[openGraphId] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[answerFacebook] ADD CONSTRAINT [pk_answerFacebook] PRIMARY KEY NONCLUSTERED  ([answerFacebookId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_answerFacebook_answerId] ON [dbo].[answerFacebook] ([answerId], [openGraphId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[answerFacebook] TO [api]
GRANT INSERT ON  [dbo].[answerFacebook] TO [api]
GRANT UPDATE ON  [dbo].[answerFacebook] TO [api]
GO
