CREATE TABLE [bot].[question]
(
[questionId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[question] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [bot].[question] ADD CONSTRAINT [pk_botQuestion] PRIMARY KEY NONCLUSTERED  ([questionId]) ON [PRIMARY]
GO
