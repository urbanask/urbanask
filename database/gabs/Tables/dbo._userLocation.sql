CREATE TABLE [dbo].[_userLocation]
(
[userLocationId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[fromLatitude] [decimal] (9, 7) NOT NULL,
[fromLongitude] [decimal] (10, 7) NOT NULL,
[toLatitude] [decimal] (9, 7) NOT NULL,
[toLongitude] [decimal] (10, 7) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_userLocation] ADD CONSTRAINT [pk_userLocation] PRIMARY KEY NONCLUSTERED  ([userLocationId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_userLocation_bounds] ON [dbo].[_userLocation] ([fromLongitude], [toLongitude], [fromLatitude], [toLatitude], [userId], [userLocationId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_userLocation_userId] ON [dbo].[_userLocation] ([userId], [fromLatitude], [fromLongitude], [toLatitude], [toLongitude]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[_userLocation] TO [api]
GRANT INSERT ON  [dbo].[_userLocation] TO [login]
GRANT SELECT ON  [dbo].[_userLocation] TO [processTopLists]
GO
