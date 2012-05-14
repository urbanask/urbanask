CREATE TABLE [lookup].[reason]
(
[reasonId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[reason] ADD CONSTRAINT [pk_reason] PRIMARY KEY CLUSTERED  ([reasonId]) ON [PRIMARY]
GO
