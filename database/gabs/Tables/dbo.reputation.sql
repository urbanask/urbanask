CREATE TABLE [dbo].[reputation]
(
[reputationId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[reputationActionId] [dbo].[foreignKey] NOT NULL,
[itemId] [dbo].[foreignKey] NOT NULL,
[reputation] [int] NOT NULL,
[timestamp] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[reputation] ADD CONSTRAINT [pk_reputation] PRIMARY KEY NONCLUSTERED  ([reputationId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_reputation_itemId] ON [dbo].[reputation] ([reputationActionId], [itemId], [timestamp], [reputationId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_reputation_userId] ON [dbo].[reputation] ([userId], [timestamp]) INCLUDE ([reputation], [reputationId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[reputation] TO [api]
GRANT SELECT ON  [dbo].[reputation] TO [ProcessBadges]
GRANT SELECT ON  [dbo].[reputation] TO [processReputation]
GRANT INSERT ON  [dbo].[reputation] TO [processReputation]
GRANT SELECT ON  [dbo].[reputation] TO [processTopLists]
GO
