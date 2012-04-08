SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [answers].[answerError](
	[answerErrorId] [dbo].[primaryKey] NOT NULL,
	[message] [varchar](300) NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_answerError] PRIMARY KEY NONCLUSTERED 
(
	[answerErrorId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [answers].[answerQueue](
	[answerQueueId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[message] [varchar](300) NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_answerQueue] PRIMARY KEY NONCLUSTERED 
(
	[answerQueueId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [answers].[answerQueue] ADD  CONSTRAINT [DF_Answer_Timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [answers].[answerWork](
	[answerWorkId] [dbo].[primaryKey] NOT NULL,
	[message] [varchar](300) NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_answerwork] PRIMARY KEY NONCLUSTERED 
(
	[answerWorkId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [questions].[questionError](
	[questionErrorId] [dbo].[primaryKey] NOT NULL,
	[message] [varchar](150) NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_questionError] PRIMARY KEY NONCLUSTERED 
(
	[questionErrorId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [questions].[questionQueue](
	[questionQueueId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[message] [varchar](150) NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_questionQueue] PRIMARY KEY NONCLUSTERED 
(
	[questionQueueId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [questions].[questionQueue] ADD  CONSTRAINT [DF_Message_Timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [questions].[questionWork](
	[questionWorkId] [dbo].[primaryKey] NOT NULL,
	[message] [varchar](150) NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_questionWork] PRIMARY KEY NONCLUSTERED 
(
	[questionWorkId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [questions].[questionWork] ADD  CONSTRAINT [DF_QuestionWork_Timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO


