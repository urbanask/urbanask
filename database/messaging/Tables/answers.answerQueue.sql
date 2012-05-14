CREATE TABLE [answers].[answerQueue]
(
[answerQueueId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[message] [varchar] (600) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [datetime2] NOT NULL CONSTRAINT [DF_Answer_Timestamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [answers].[answerQueue] ADD CONSTRAINT [pk_answerQueue] PRIMARY KEY NONCLUSTERED  ([answerQueueId]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [ix_answerQueue] ON [answers].[answerQueue] ([timestamp], [answerQueueId]) ON [PRIMARY]
GO
GRANT INSERT ON  [answers].[answerQueue] TO [messaging]
GRANT SELECT ON  [answers].[answerQueue] TO [processAnswers]
GRANT DELETE ON  [answers].[answerQueue] TO [processAnswers]
GO
