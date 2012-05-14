CREATE TABLE [lookup].[objectType]
(
[objectTypeId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[objectType] ADD CONSTRAINT [pk_objectType] PRIMARY KEY CLUSTERED  ([objectTypeId]) ON [PRIMARY]
GO
GRANT SELECT ON  [lookup].[objectType] TO [api]
GO
