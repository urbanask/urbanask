CREATE TABLE [lookup].[interval]
(
[intervalId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[interval] ADD CONSTRAINT [pk_interval] PRIMARY KEY CLUSTERED  ([intervalId]) ON [PRIMARY]
GO
GRANT SELECT ON  [lookup].[interval] TO [processTopLists]
GO
