CREATE TABLE [lookup].[notification]
(
[notificationId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[notification] ADD CONSTRAINT [pk_notification] PRIMARY KEY CLUSTERED  ([notificationId]) ON [PRIMARY]
GO
GRANT SELECT ON  [lookup].[notification] TO [api]
GO
