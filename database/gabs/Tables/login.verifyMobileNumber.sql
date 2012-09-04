CREATE TABLE [login].[verifyMobileNumber]
(
[verifyMobileNumberId] [int] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[mobileNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [login].[verifyMobileNumber] ADD CONSTRAINT [pk_verifyMobileNumber] PRIMARY KEY NONCLUSTERED  ([verifyMobileNumberId]) WITH (FILLFACTOR=97, PAD_INDEX=ON) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_verifyMobileNumber] ON [login].[verifyMobileNumber] ([timestamp], [userId], [mobileNumber]) ON [PRIMARY]
GO
GRANT INSERT ON  [login].[verifyMobileNumber] TO [api]
GO
