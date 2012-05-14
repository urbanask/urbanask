CREATE TABLE [lookup].[badgeClass]
(
[badgeClassId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[order] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[badgeClass] ADD CONSTRAINT [pk_badgeClass] PRIMARY KEY CLUSTERED  ([badgeClassId]) ON [PRIMARY]
GO
GRANT SELECT ON  [lookup].[badgeClass] TO [api]
GO
