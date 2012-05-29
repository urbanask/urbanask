
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@suggestedUsername	AS VARCHAR(100) = 'mattwalton'
--DECLARE	@tagline			AS VARCHAR(256) = ''
--DECLARE	@hash				AS CHAR(88) = '1'
--DECLARE	@salt				AS CHAR(8) = '2'
--DECLARE	@iterations			AS INT = 3
--DECLARE	@hashType			AS VARCHAR(10) = 'SHA512'
--DECLARE	@metricDistances	AS INT = 1
--DECLARE	@languageId			AS ForeignKey  = 1
--DECLARE	@authTypeId			AS ForeignKey = 3
--DECLARE	@twitterId			AS VARCHAR(20) = '509992905'
--DECLARE	@screenName			AS VARCHAR(200) = 'mattwalton'
--DECLARE	@token				AS VARCHAR(256) = '509992905-0lfNtgoF6ElDyBADP5bcNxeLSlSMzYyAIJH5MxAK'
--DECLARE	@tokenSecret		AS VARCHAR(256) = 'VPtt67zvKpCIjkoTQO9WgruoPZQ1urPEBNsZXna28'
--DECLARE	@location			AS VARCHAR(200) = 'Sacramento, CA'
--DECLARE	@defaultRegionId	AS ForeignKey = 2
--DECLARE	@latitude			AS DECIMAL(9,7)		= NULL
--DECLARE	@longitude			AS DECIMAL(10,7)	= NULL
--DECLARE	@userId				AS ForeignKey		
--DECLARE	@username			AS VARCHAR(100)		


CREATE PROCEDURE [login].[createTwitterUser]
	(
	@suggestedUsername	AS VARCHAR(100),
	@tagline			AS VARCHAR(256),
	@hash				AS CHAR(88),
	@salt				AS CHAR(8),
	@iterations			AS INT,
	@hashType			AS VARCHAR(10),
	@metricDistances	AS INT,
	@languageId			AS ForeignKey,
	@authTypeId			AS ForeignKey,
	@twitterId			AS VARCHAR(20),
	@screenName			AS VARCHAR(200),
	@token				AS VARCHAR(256),
	@tokenSecret		AS VARCHAR(256),
	@location			AS VARCHAR(200),
	@defaultRegionId	AS ForeignKey,
	@latitude			AS DECIMAL(9,7)		= NULL,
	@longitude			AS DECIMAL(10,7)	= NULL,
	@userId				AS ForeignKey		OUTPUT,
	@username			AS VARCHAR(100)		OUTPUT
	)
AS

--###
--[login].[createTwitterUser]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DECLARE @hashTypeId INT

SELECT
	@hashTypeId				= hashType.hashTypeId

FROM	
	gabs.lookup.hashType	AS hashType
	WITH					( NOLOCK, INDEX( pk_hashType ) )

WHERE
	hashType.type			= @hashType
	
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


	
IF EXISTS
	(
	SELECT
		[user].userId			AS userId
		
	FROM
		Gabs.dbo.[user]			AS [user]
		WITH					( INDEX( pk_user ), NOLOCK )
		
	WHERE
		[user].username			= @suggestedUsername
	)
BEGIN

	
	
	SELECT @username = @suggestedUsername + LTRIM( STR( ROUND( RAND() * 10000, 0 ) + 1000 ) )



END
ELSE
BEGIN



	SELECT @username = @suggestedUsername



END



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
	Gabs.dbo.[userTwitter]
	(
	userId,
	twitterId,
	screenName,
	token,
	tokenSecret,
	location
	)

VALUES
	(
	@userId,
	@twitterId,
	@screenName,
	@token,
	@tokenSecret,
	@location
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



INSERT INTO
	[Gabs].dbo.userInstructions
	(
	[userId]
	)

VALUES
	(
	@userId
	)
	
	
	
--PRINT @userId
--PRINT @username

GO
