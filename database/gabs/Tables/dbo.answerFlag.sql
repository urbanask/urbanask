CREATE TABLE [dbo].[answerFlag]
(
[answerFlagId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[answerId] [dbo].[foreignKey] NOT NULL,
[userId] [dbo].[foreignKey] NOT NULL,
[timestamp] [datetime2] NOT NULL CONSTRAINT [DF_answerFlag_timestamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[answerFlag] ADD CONSTRAINT [pk_answerFlag] PRIMARY KEY NONCLUSTERED  ([answerFlagId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_answerFlag_answerId] ON [dbo].[answerFlag] ([answerId], [answerFlagId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_answerFlag_timestamp] ON [dbo].[answerFlag] ([timestamp], [answerId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[answerFlag] TO [api]
GRANT INSERT ON  [dbo].[answerFlag] TO [api]
GRANT SELECT ON  [dbo].[answerFlag] TO [ProcessBadges]
GO
