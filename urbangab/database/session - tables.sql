SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[session](
	[sessionId] [uniqueidentifier] NOT NULL,
	[sessionKey] [uniqueidentifier] NOT NULL,
	[userId] [dbo].[foreignKey] NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_session] PRIMARY KEY CLUSTERED 
(
	[sessionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[session] ADD  CONSTRAINT [df_session_sessionId]  DEFAULT (newid()) FOR [sessionId]
GO

ALTER TABLE [dbo].[session] ADD  CONSTRAINT [DF_session_sessionKey]  DEFAULT (newid()) FOR [sessionKey]
GO

ALTER TABLE [dbo].[session] ADD  CONSTRAINT [df_session_timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO


