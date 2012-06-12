CREATE TABLE [bot].[questionWork]
(
[questionWorkId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[question] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[latitude] [decimal] (9, 7) NOT NULL,
[longitude] [decimal] (10, 7) NOT NULL,
[region] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
CREATE CLUSTERED INDEX [ix_questionWork] ON [bot].[questionWork] ([userId], [question], [latitude], [longitude], [region]) ON [PRIMARY]

GO
ALTER TABLE [bot].[questionWork] ADD CONSTRAINT [pk_botQuestionWork] PRIMARY KEY NONCLUSTERED  ([questionWorkId]) ON [PRIMARY]
GO
