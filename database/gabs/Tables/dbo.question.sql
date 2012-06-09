CREATE TABLE [dbo].[question]
(
[questionId] [dbo].[primaryKey] NOT NULL,
[userId] [dbo].[foreignKey] NOT NULL,
[question] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[link] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[latitude] [decimal] (9, 7) NOT NULL,
[longitude] [decimal] (10, 7) NOT NULL,
[region] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[regionId] [dbo].[foreignKey] NULL,
[timestamp] [datetime2] NOT NULL,
[resolved] [int] NOT NULL CONSTRAINT [DF_question_resolved] DEFAULT ((0)),
[bounty] [int] NOT NULL,
[votes] [int] NOT NULL CONSTRAINT [DF_question_votes] DEFAULT ((0))
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[question] TO [api]
GRANT UPDATE ON  [dbo].[question] TO [api]
GRANT SELECT ON  [dbo].[question] TO [bot]
GRANT UPDATE ON  [dbo].[question] TO [bot]
GRANT SELECT ON  [dbo].[question] TO [processAnswers]
GRANT SELECT ON  [dbo].[question] TO [ProcessBadges]
GRANT SELECT ON  [dbo].[question] TO [processBounties]
GRANT UPDATE ON  [dbo].[question] TO [processBounties]
GRANT SELECT ON  [dbo].[question] TO [processQuestions]
GRANT INSERT ON  [dbo].[question] TO [processQuestions]
GRANT SELECT ON  [dbo].[question] TO [processReputation]
GRANT SELECT ON  [dbo].[question] TO [processTopLists]
GO

ALTER TABLE [dbo].[question] ADD CONSTRAINT [pk_question] PRIMARY KEY NONCLUSTERED  ([questionId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_question_longitude_latitude] ON [dbo].[question] ([timestamp] DESC, [longitude], [latitude], [resolved], [bounty], [questionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_question_userId] ON [dbo].[question] ([userId], [timestamp], [questionId]) ON [PRIMARY]
GO
