CREATE TABLE [answers].[answerWork]
(
[answerWorkId] [dbo].[primaryKey] NOT NULL,
[message] [varchar] (600) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [answers].[answerWork] ADD CONSTRAINT [pk_answerwork] PRIMARY KEY NONCLUSTERED  ([answerWorkId]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [ix_answerWork] ON [answers].[answerWork] ([timestamp], [answerWorkId], [message]) ON [PRIMARY]
GO
GRANT SELECT ON  [answers].[answerWork] TO [processAnswers]
GRANT INSERT ON  [answers].[answerWork] TO [processAnswers]
GRANT DELETE ON  [answers].[answerWork] TO [processAnswers]
GO
