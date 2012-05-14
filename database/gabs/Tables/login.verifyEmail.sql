CREATE TABLE [login].[verifyEmail]
(
[verifyEmailId] [int] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[email] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[guid] [char] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [datetime2] NOT NULL,
[sent] [int] NOT NULL CONSTRAINT [DF_verifyEmail_sent] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [login].[verifyEmail] ADD CONSTRAINT [pk_verifyEmail] PRIMARY KEY NONCLUSTERED  ([verifyEmailId]) WITH (FILLFACTOR=97, PAD_INDEX=ON) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_verifyEmail] ON [login].[verifyEmail] ([timestamp], [sent], [userId], [email], [guid]) ON [PRIMARY]
GO
