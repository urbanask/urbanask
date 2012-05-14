CREATE TABLE [dbo].[userPictureDefault]
(
[userPictureDefaultId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[picture] [varbinary] (max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[userPictureDefault] ADD CONSTRAINT [pk_userPictureDefault] PRIMARY KEY NONCLUSTERED  ([userPictureDefaultId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userPictureDefault] TO [api]
GO
