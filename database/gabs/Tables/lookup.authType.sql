CREATE TABLE [lookup].[authType]
(
[authTypeId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[authType] ADD CONSTRAINT [pk_authType] PRIMARY KEY CLUSTERED  ([authTypeId]) ON [PRIMARY]
GO
