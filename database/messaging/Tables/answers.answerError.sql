CREATE TABLE [answers].[answerError]
(
[answerErrorId] [dbo].[primaryKey] NOT NULL,
[message] [varchar] (600) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [answers].[answerError] ADD CONSTRAINT [pk_answerError] PRIMARY KEY NONCLUSTERED  ([answerErrorId]) ON [PRIMARY]
GO
GRANT SELECT ON  [answers].[answerError] TO [processAnswers]
GRANT INSERT ON  [answers].[answerError] TO [processAnswers]
GO
