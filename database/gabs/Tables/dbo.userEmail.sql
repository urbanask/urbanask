CREATE TABLE [dbo].[userEmail]
(
[userEmailId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[email] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[emailStatusId] [dbo].[foreignKey] NOT NULL CONSTRAINT [DF_userEmail_verified] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userEmail] ADD CONSTRAINT [pk_userEmail] PRIMARY KEY NONCLUSTERED  ([userEmailId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_userEmail] ON [dbo].[userEmail] ([userId], [emailStatusId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userEmail] TO [api]
GRANT UPDATE ON  [dbo].[userEmail] TO [api]
GRANT INSERT ON  [dbo].[userEmail] TO [login]
GRANT SELECT ON  [dbo].[userEmail] TO [verifyEmails]
GRANT UPDATE ON  [dbo].[userEmail] TO [verifyEmails]
GO
