SELECT DISTINCT
	region.fromLatitude + ( ( region.toLatitude - region.fromLatitude ) / 2 )		AS latitude,
	region.fromLongitude + ( ( region.toLongitude - region.fromLongitude ) / 2 )	AS longitude

FROM
	Gabs.bot.[user]			AS [user]
	WITH					( NOLOCK, INDEX( pk_botUser ) )
	
	INNER JOIN
	Gabs.lookup.region		AS region
	WITH					( NOLOCK, INDEX( pk_region ) )
	ON	[user].regionId		= region.regionId
	
WHERE
	region.regionId = 2



DECLARE @regions	TABLE
	(
	rowNumber		INT,
	regionId		INT
	)

INSERT INTO
	@regions
	
SELECT
	ROW_NUMBER() OVER ( ORDER BY RAND( CAST( NEWID() AS VARBINARY ) ) )		AS rowNumber,
	regionId

FROM
	lookup.region

WHERE 
	regionId NOT IN ( -1, 0, 6 )



DECLARE @regionCount	INT

SELECT 
	@regionCount		= COUNT(*)
	
FROM
	@regions			AS regions



DECLARE @userRegions	TABLE
	(
	userId				INT,
	regionId			INT,
	newRegionId			INT
	)

INSERT INTO
	@userRegions
	
SELECT
	[user].userId,
	userRegion.regionId,
	ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( @regionCount - 1 ) ) + 1, 0 )	AS newRegionId

FROM
	Gabs.dbo.[user]			AS [user]
	WITH					( NOLOCK, INDEX( pk_user ) )
	
	INNER JOIN
	Gabs.dbo.userRegion		AS userRegion
	WITH					( NOLOCK, INDEX( pk_userRegion ) )
	ON	[user].userId		= userRegion.userId
	
WHERE
	userRegion.regionId		= 15 --monterey
	

SELECT * FROM dbo.[userRegion] WHERE regionId = 15
SELECT * FROM bot.[user] WHERE regionId = 15
--UPDATE dbo.[userRegion] SET regionId = 2 WHERE regionId = 15
--UPDATE bot.[user] SET regionId = 2 WHERE regionId = 15


DECLARE @randomRange		INT = 10000 -- ~2 miles
DECLARE @latitudePerFoot	DECIMAL(10,10) = 0.000002741
DECLARE @longitudePerFoot	DECIMAL(10,10) = 0.0000035736

UPDATE
	Gabs.bot.questionQueue
	
SET
	latitude = 
	37.757900000
	+	(	ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( @randomRange - 1 ) ) + 1, 0 )	-- distance
		*	CASE ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( 2 - 1 ) ) + 1, 0 ) WHEN 1 THEN 1 ELSE -1 END	-- negative
		*	@latitudePerFoot )
											,
	longitude = 
	-122.449450000
	+	(	ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( @randomRange - 1 ) ) + 1, 0 )	-- distance
		*	CASE ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( 2 - 1 ) ) + 1, 0 ) WHEN 1 THEN 1 ELSE -1 END	-- negative
		*	@longitudePerFoot )


FROM
	--Gabs.dbo.question						AS question
	Gabs.bot.questionQueue						AS question
	
	INNER JOIN
	@userRegions							AS userRegions
	ON question.userId						= userRegions.userId
	
WHERE
	question.userId							> 100000


	
	


