CREATE TABLE [dbo].[userBadge]
(
[userBadgeId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[badgeId] [dbo].[foreignKey] NOT NULL,
[timestamp] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userBadge] ADD CONSTRAINT [pk_userBadge] PRIMARY KEY NONCLUSTERED  ([userBadgeId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_userBadge_userId] ON [dbo].[userBadge] ([userId], [userBadgeId], [badgeId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userBadge] TO [api]
GRANT SELECT ON  [dbo].[userBadge] TO [ProcessBadges]
GRANT INSERT ON  [dbo].[userBadge] TO [ProcessBadges]
GRANT SELECT ON  [dbo].[userBadge] TO [processTopLists]
GO
