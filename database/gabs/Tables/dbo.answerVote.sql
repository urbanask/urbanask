CREATE TABLE [dbo].[answerVote]
(
[answerVoteId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[answerId] [dbo].[foreignKey] NOT NULL,
[userId] [dbo].[foreignKey] NOT NULL,
[vote] [int] NOT NULL,
[timestamp] [datetime2] NOT NULL CONSTRAINT [DF_answerVote_timestamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[answerVote] ADD CONSTRAINT [pk_answerVote] PRIMARY KEY NONCLUSTERED  ([answerVoteId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_answerVote_answerId] ON [dbo].[answerVote] ([answerId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_answerVote_timestamp] ON [dbo].[answerVote] ([timestamp], [answerVoteId]) INCLUDE ([answerId], [userId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[answerVote] TO [api]
GRANT INSERT ON  [dbo].[answerVote] TO [api]
GRANT DELETE ON  [dbo].[answerVote] TO [api]
GRANT SELECT ON  [dbo].[answerVote] TO [ProcessBadges]
GRANT SELECT ON  [dbo].[answerVote] TO [processReputation]
GO
