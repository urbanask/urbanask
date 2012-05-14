CREATE TABLE [lookup].[hashType]
(
[hashTypeId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[hashType] ADD CONSTRAINT [pk_hashType] PRIMARY KEY CLUSTERED  ([hashTypeId]) ON [PRIMARY]
GO
GRANT SELECT ON  [lookup].[hashType] TO [login]
GO
