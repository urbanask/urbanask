CREATE TABLE [questions].[questionError]
(
[questionErrorId] [dbo].[primaryKey] NOT NULL,
[message] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [questions].[questionError] ADD CONSTRAINT [pk_questionError] PRIMARY KEY NONCLUSTERED  ([questionErrorId]) ON [PRIMARY]
GO
GRANT SELECT ON  [questions].[questionError] TO [processQuestions]
GRANT INSERT ON  [questions].[questionError] TO [processQuestions]
GO
