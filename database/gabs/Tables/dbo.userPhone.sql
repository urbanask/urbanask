CREATE TABLE [dbo].[userPhone]
(
[userPhoneId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[notifications] [int] NOT NULL CONSTRAINT [DF_userPhone_notifications] DEFAULT ((1)),
[verified] [int] NOT NULL CONSTRAINT [DF_userPhone_verified] DEFAULT ((0)),
[stop] [int] NOT NULL CONSTRAINT [DF_userPhone_stop] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userPhone] ADD CONSTRAINT [pk_userPhone] PRIMARY KEY NONCLUSTERED  ([userPhoneId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_userPhone_number] ON [dbo].[userPhone] ([number], [userPhoneId]) INCLUDE ([stop], [userId], [verified]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_userPhone] ON [dbo].[userPhone] ([userId], [number], [notifications], [verified]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userPhone] TO [api]
GRANT INSERT ON  [dbo].[userPhone] TO [api]
GRANT UPDATE ON  [dbo].[userPhone] TO [api]
GO
