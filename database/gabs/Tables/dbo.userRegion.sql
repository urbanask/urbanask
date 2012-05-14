CREATE TABLE [dbo].[userRegion]
(
[userRegionId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[regionId] [dbo].[foreignKey] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userRegion] ADD CONSTRAINT [pk_userRegion] PRIMARY KEY NONCLUSTERED  ([userRegionId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_userRegion_userId] ON [dbo].[userRegion] ([userRegionId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userRegion] TO [api]
GRANT UPDATE ON  [dbo].[userRegion] TO [api]
GRANT INSERT ON  [dbo].[userRegion] TO [login]
GRANT SELECT ON  [dbo].[userRegion] TO [processTopLists]
GO
