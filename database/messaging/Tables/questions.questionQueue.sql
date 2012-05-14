CREATE TABLE [questions].[questionQueue]
(
[questionQueueId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[message] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [datetime2] NOT NULL CONSTRAINT [DF_Message_Timestamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [questions].[questionQueue] ADD CONSTRAINT [pk_questionQueue] PRIMARY KEY NONCLUSTERED  ([questionQueueId]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [ix_questionQueue] ON [questions].[questionQueue] ([timestamp], [questionQueueId]) ON [PRIMARY]
GO
GRANT INSERT ON  [questions].[questionQueue] TO [messaging]
GRANT SELECT ON  [questions].[questionQueue] TO [processQuestions]
GRANT DELETE ON  [questions].[questionQueue] TO [processQuestions]
GO
