CREATE TABLE [lookup].[badge]
(
[badgeId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[enabled] [int] NOT NULL,
[badgeClassId] [dbo].[foreignKey] NOT NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unlimited] [int] NOT NULL,
[procedure] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[badge] ADD CONSTRAINT [pk_badge] PRIMARY KEY CLUSTERED  ([badgeId]) ON [PRIMARY]
GO
GRANT SELECT ON  [lookup].[badge] TO [api]
GRANT SELECT ON  [lookup].[badge] TO [ProcessBadges]
GO
