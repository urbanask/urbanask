USE Gabs

SELECT * FROM [Gabs].[dbo].[user] WHERE userId < 20
SELECT TOP 20 * FROM [Gabs].[dbo].[userLocation] ORDER BY userId
SELECT * FROM userBadge ORDER BY timestamp

SET IDENTITY_INSERT Gabs.dbo.[user] ON
INSERT INTO [Gabs].[dbo].[user]
	(
	--[userId],
	[username]
	,[displayName]
	,[reputation]
	,[hash]
	,[salt]
	,[iterations]
	,[hashTypeId]
	,[enabled]
	,[metricDistances]
	,[languageId]
	,[signupDate]
	)
VALUES
	(
	--6,
	'kristin',
	'kristin',
	0,
	'NJki1k1yQesfx9UZt//jfI1fEFJFOPjVU/UcU3yRHAQwz/Qsftt/tnL6WM9tKb4pe2zr8i8aLmHq+7eZ0N3lGA==',
	'98z0dQ==',
	5,
	2,
	1,
	0,
	1,
	GETDATE()
	)
GO


INSERT INTO userLocation SELECT 15, fromLatitude, fromLongitude, toLatitude, toLongitude FROM userLocation WHERE userId = 1
INSERT INTO userBadge VALUES ( 15, 6, GETDATE() )


DECLARE @image VARBINARY(MAX);
SELECT @image = BulkColumn FROM OPENROWSET(BULK N'C:\kristin.png', SINGLE_BLOB) AS picture

INSERT INTO [dbo].[userPicture] ( userId, picture ) VALUES ( 15, @image )

