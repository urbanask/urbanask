CREATE TABLE [lookup].[topType]
(
[topTypeId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[topType] ADD CONSTRAINT [pk_topType] PRIMARY KEY CLUSTERED  ([topTypeId]) ON [PRIMARY]
GO
