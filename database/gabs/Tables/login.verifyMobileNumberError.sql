CREATE TABLE [login].[verifyMobileNumberError]
(
[verifyMobileNumberErrorId] [int] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[mobileNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [login].[verifyMobileNumberError] ADD CONSTRAINT [pk_verifyMobileNumberError] PRIMARY KEY NONCLUSTERED  ([verifyMobileNumberErrorId]) WITH (FILLFACTOR=97, PAD_INDEX=ON) ON [PRIMARY]
GO
