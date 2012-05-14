SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [login].[createFacebookUser]
	(
	@username			AS VARCHAR(100),
	@tagline			AS VARCHAR(256),
	@hash				AS CHAR(88),
	@salt				AS CHAR(8),
	@iterations			AS INT,
	@hashType			AS VARCHAR(10),
	@metricDistances	AS INT,
	@languageId			AS ForeignKey,
	@authTypeId			AS ForeignKey,
	@facebookId			AS VARCHAR(20),
	@location			AS VARCHAR(200),
	@email				AS VARCHAR(256),
	@accessToken		AS VARCHAR(256),
	@defaultRegionId	AS ForeignKey,
	@latitude			AS DECIMAL(9,7)		= NULL,
	@longitude			AS DECIMAL(10,7)	= NULL,
	@userId				AS ForeignKey		OUTPUT
	)
AS

--###
--[login].[createFacebookUser]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DECLARE @hashTypeId INT

SELECT
	@hashTypeId				= hashType.hashTypeId

FROM	
	gabs.lookup.hashType	AS hashType
	WITH					( NOLOCK, INDEX( pk_hashType ) )

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	Gabs.dbo.[user]
	(
	[user].username,
	[user].tagline,
	[user].hash,
	[user].salt,
	[user].iterations,
	[user].hashTypeId,
	[user].metricDistances,
	[user].languageId,
	[user].authTypeId
	)

VALUES
	(
	@username,
	@tagline,
	@hash,
	@salt,
	@iterations,
	@hashTypeId,
	@metricDistances,
	@languageId,
	@authTypeId
	)
	


SELECT @userId = SCOPE_IDENTITY()



INSERT INTO
	Gabs.dbo.[userFacebook]
	(
	userId,
	facebookId,
	location,
	email,
	accessToken
	)

VALUES
	(
	@userId,
	@facebookId,
	@location,
	@email,
	@accessToken
	)



DECLARE @regionId	INT
SET @regionId = @defaultRegionId



IF @latitude IS NOT NULL
BEGIN


	IF EXISTS(
		SELECT
			region.regionId			AS regionId
			
		FROM
			Gabs.lookup.region		AS region
			WITH					( INDEX( pk_region ), NOLOCK )
			
		WHERE
				@latitude			BETWEEN region.fromLatitude
									AND		region.toLatitude
			AND	@longitude			BETWEEN region.fromLongitude
									AND		region.toLongitude
	)
	BEGIN



		SELECT
			@regionId				= region.regionId
			
		FROM
			Gabs.lookup.region		AS region
			WITH					( INDEX( pk_region ), NOLOCK )
			
		WHERE
				@latitude			BETWEEN region.fromLatitude
									AND		region.toLatitude
			AND	@longitude			BETWEEN region.fromLongitude
									AND		region.toLongitude
			AND	region.regionId		> 0 -- all
			
		OPTION
			( FORCE ORDER, LOOP JOIN, MAXDOP 1 )
			
			

	END



END



INSERT INTO
	[Gabs].[dbo].[userRegion]
    (
	[userId],
    [regionId]
	)

VALUES
    (
	@userId,
    @regionId
	)



GO
