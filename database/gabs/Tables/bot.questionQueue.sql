CREATE TABLE [bot].[questionQueue]
(
[questionQueueId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[order] [float] NOT NULL,
[userId] [dbo].[foreignKey] NOT NULL,
[question] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[latitude] [decimal] (9, 7) NOT NULL,
[longitude] [decimal] (10, 7) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [bot].[questionQueue] ADD CONSTRAINT [pk_botQuestionQueue] PRIMARY KEY NONCLUSTERED  ([questionQueueId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_questionQueue] ON [bot].[questionQueue] ([order], [userId], [question], [latitude], [longitude]) ON [PRIMARY]
GO
