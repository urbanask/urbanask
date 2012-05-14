CREATE TABLE [dbo].[questionFlag]
(
[questionFlagId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[questionId] [dbo].[foreignKey] NOT NULL,
[userId] [dbo].[foreignKey] NOT NULL,
[timestamp] [datetime2] NOT NULL CONSTRAINT [DF_questionFlag_timestamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[questionFlag] ADD CONSTRAINT [pk_questionFlag] PRIMARY KEY NONCLUSTERED  ([questionFlagId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_questionFlag_questionId] ON [dbo].[questionFlag] ([questionId], [questionFlagId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_questionFlag_timestamp] ON [dbo].[questionFlag] ([timestamp], [questionId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[questionFlag] TO [api]
GRANT INSERT ON  [dbo].[questionFlag] TO [api]
GRANT SELECT ON  [dbo].[questionFlag] TO [ProcessBadges]
GO
