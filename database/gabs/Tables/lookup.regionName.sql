CREATE TABLE [lookup].[regionName]
(
[regionNameId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[regionId] [dbo].[foreignKey] NOT NULL,
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[regionName] ADD CONSTRAINT [pk_regionName] PRIMARY KEY NONCLUSTERED  ([regionNameId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_regionName] ON [lookup].[regionName] ([name], [regionId]) ON [PRIMARY]
GO
