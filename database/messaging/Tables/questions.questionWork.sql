CREATE TABLE [questions].[questionWork]
(
[questionWorkId] [dbo].[primaryKey] NOT NULL,
[message] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [datetime2] NOT NULL CONSTRAINT [DF_QuestionWork_Timestamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [questions].[questionWork] ADD CONSTRAINT [pk_questionWork] PRIMARY KEY NONCLUSTERED  ([questionWorkId]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [ix_questionWork] ON [questions].[questionWork] ([timestamp], [questionWorkId], [message]) ON [PRIMARY]
GO
GRANT SELECT ON  [questions].[questionWork] TO [processQuestions]
GRANT INSERT ON  [questions].[questionWork] TO [processQuestions]
GRANT DELETE ON  [questions].[questionWork] TO [processQuestions]
GO
