CREATE TABLE [dbo].[userNotification]
(
[userNotificationId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[notificationId] [dbo].[foreignKey] NOT NULL,
[objectTypeId] [dbo].[foreignKey] NOT NULL,
[itemId] [dbo].[foreignKey] NOT NULL,
[timestamp] [datetime2] NOT NULL,
[viewed] [int] NOT NULL CONSTRAINT [DF_userNotification_viewed] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userNotification] ADD CONSTRAINT [pk_userNotification] PRIMARY KEY NONCLUSTERED  ([userNotificationId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userNotification] TO [api]
GRANT INSERT ON  [dbo].[userNotification] TO [api]
GRANT UPDATE ON  [dbo].[userNotification] TO [api]
GRANT INSERT ON  [dbo].[userNotification] TO [processAnswers]
GRANT INSERT ON  [dbo].[userNotification] TO [ProcessBadges]
GO
