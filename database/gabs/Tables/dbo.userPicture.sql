CREATE TABLE [dbo].[userPicture]
(
[userPictureId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[picture] [varbinary] (max) NOT NULL,
[icon] [varbinary] (max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userPicture] TO [api]
GRANT INSERT ON  [dbo].[userPicture] TO [login]
GRANT SELECT ON  [dbo].[userPicture] TO [tools]
GRANT INSERT ON  [dbo].[userPicture] TO [tools]
GO

ALTER TABLE [dbo].[userPicture] ADD CONSTRAINT [pk_userPicture] PRIMARY KEY NONCLUSTERED  ([userPictureId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_userPicture_userId] ON [dbo].[userPicture] ([userId]) ON [PRIMARY]
GO
