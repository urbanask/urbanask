CREATE TABLE [lookup].[emailStatus]
(
[emailStatusId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[emailStatus] ADD CONSTRAINT [pk_emailStatus] PRIMARY KEY CLUSTERED  ([emailStatusId]) ON [PRIMARY]
GO
