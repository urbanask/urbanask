CREATE TABLE [dbo].[questionVote]
(
[questionVoteId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[questionId] [dbo].[foreignKey] NOT NULL,
[userId] [dbo].[foreignKey] NOT NULL,
[vote] [int] NOT NULL,
[timestamp] [datetime2] NOT NULL CONSTRAINT [DF_questionVote_timestamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[questionVote] ADD CONSTRAINT [pk_questionVote] PRIMARY KEY NONCLUSTERED  ([questionVoteId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_questionVote_questionId] ON [dbo].[questionVote] ([questionId], [questionVoteId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_questionVote_timestamp] ON [dbo].[questionVote] ([timestamp], [questionId]) INCLUDE ([userId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[questionVote] TO [api]
GRANT INSERT ON  [dbo].[questionVote] TO [api]
GRANT DELETE ON  [dbo].[questionVote] TO [api]
GRANT SELECT ON  [dbo].[questionVote] TO [ProcessBadges]
GRANT SELECT ON  [dbo].[questionVote] TO [processReputation]
GO
