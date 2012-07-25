CREATE TABLE [dbo].[questionFacebook]
(
[questionFacebookId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[questionId] [dbo].[foreignKey] NOT NULL,
[openGraphId] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[resolvedOpenGraphId] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[questionFacebook] ADD CONSTRAINT [pk_questionFacebook] PRIMARY KEY NONCLUSTERED  ([questionFacebookId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_questionFacebook_questionId] ON [dbo].[questionFacebook] ([questionId], [openGraphId], [resolvedOpenGraphId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[questionFacebook] TO [api]
GRANT INSERT ON  [dbo].[questionFacebook] TO [api]
GRANT UPDATE ON  [dbo].[questionFacebook] TO [api]
GO
