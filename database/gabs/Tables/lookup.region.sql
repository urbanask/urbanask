CREATE TABLE [lookup].[region]
(
[regionId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[parentRegionId] [dbo].[foreignKey] NULL,
[name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fromLatitude] [decimal] (9, 7) NULL,
[toLatitude] [decimal] (9, 7) NULL,
[fromLongitude] [decimal] (10, 7) NULL,
[toLongitude] [decimal] (10, 7) NULL
) ON [PRIMARY]
CREATE CLUSTERED INDEX [ix_region] ON [lookup].[region] ([fromLatitude], [toLatitude], [fromLongitude], [toLongitude], [regionId]) ON [PRIMARY]

ALTER TABLE [lookup].[region] ADD CONSTRAINT [pk_region] PRIMARY KEY NONCLUSTERED  ([regionId]) ON [PRIMARY]

GO
GRANT SELECT ON  [lookup].[region] TO [api]
GRANT SELECT ON  [lookup].[region] TO [bot]
GRANT SELECT ON  [lookup].[region] TO [login]
GRANT SELECT ON  [lookup].[region] TO [processTopLists]
GO
