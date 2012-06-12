CREATE TABLE [lookup].[reputationAction]
(
[reputationActionId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reputation] [int] NOT NULL,
[object] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[procedure] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[enabled] [int] NOT NULL CONSTRAINT [DF_reputationAction_enabled] DEFAULT ((1))
) ON [PRIMARY]
GO
GRANT SELECT ON  [lookup].[reputationAction] TO [api]
GRANT SELECT ON  [lookup].[reputationAction] TO [processReputation]
GRANT SELECT ON  [lookup].[reputationAction] TO [processTopLists]
GO

ALTER TABLE [lookup].[reputationAction] ADD CONSTRAINT [pk_reputationAction] PRIMARY KEY CLUSTERED  ([reputationActionId]) ON [PRIMARY]
GO
