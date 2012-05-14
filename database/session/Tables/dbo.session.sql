CREATE TABLE [dbo].[session]
(
[sessionId] [uniqueidentifier] NOT NULL CONSTRAINT [df_session_sessionId] DEFAULT (newid()),
[sessionKey] [uniqueidentifier] NOT NULL CONSTRAINT [DF_session_sessionKey] DEFAULT (newid()),
[userId] [dbo].[foreignKey] NOT NULL,
[timestamp] [datetime2] NOT NULL CONSTRAINT [df_session_timestamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[session] ADD CONSTRAINT [pk_session] PRIMARY KEY CLUSTERED  ([sessionId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[session] TO [login]
GRANT INSERT ON  [dbo].[session] TO [login]
GO
