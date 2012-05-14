CREATE TABLE [dbo].[answer]
(
[answerId] [dbo].[primaryKey] NOT NULL,
[questionId] [dbo].[foreignKey] NOT NULL,
[userId] [dbo].[foreignKey] NOT NULL,
[locationId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[locationAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[latitude] [decimal] (9, 7) NOT NULL,
[longitude] [decimal] (10, 7) NOT NULL,
[distance] [int] NOT NULL,
[timestamp] [datetime2] NOT NULL,
[selected] [int] NOT NULL CONSTRAINT [DF_answer_selected] DEFAULT ((0)),
[votes] [int] NOT NULL CONSTRAINT [DF_answer_votes] DEFAULT ((0)),
[reference] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[note] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[link] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[answer] ADD CONSTRAINT [pk_answer] PRIMARY KEY NONCLUSTERED  ([answerId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_answer_questionId] ON [dbo].[answer] ([questionId], [timestamp], [answerId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_answer_timestamp] ON [dbo].[answer] ([timestamp]) INCLUDE ([answerId], [selected], [userId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_answer_userId] ON [dbo].[answer] ([userId], [timestamp], [answerId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[answer] TO [api]
GRANT UPDATE ON  [dbo].[answer] TO [api]
GRANT SELECT ON  [dbo].[answer] TO [processAnswers]
GRANT INSERT ON  [dbo].[answer] TO [processAnswers]
GRANT SELECT ON  [dbo].[answer] TO [ProcessBadges]
GRANT SELECT ON  [dbo].[answer] TO [processBounties]
GRANT SELECT ON  [dbo].[answer] TO [processReputation]
GRANT SELECT ON  [dbo].[answer] TO [processTopLists]
GO
