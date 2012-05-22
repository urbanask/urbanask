CREATE TABLE [lookup].[region]
(
[regionId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fromLatitude] [decimal] (9, 7) NOT NULL,
[toLatitude] [decimal] (9, 7) NOT NULL,
[fromLongitude] [decimal] (10, 7) NOT NULL,
[toLongitude] [decimal] (10, 7) NOT NULL
) ON [PRIMARY]
GO
GRANT SELECT ON  [lookup].[region] TO [api]
GRANT SELECT ON  [lookup].[region] TO [bot]
GRANT SELECT ON  [lookup].[region] TO [login]
GRANT SELECT ON  [lookup].[region] TO [processTopLists]
GO

ALTER TABLE [lookup].[region] ADD CONSTRAINT [pk_region] PRIMARY KEY CLUSTERED  ([regionId], [fromLatitude], [toLatitude], [fromLongitude], [toLongitude]) ON [PRIMARY]
GO
