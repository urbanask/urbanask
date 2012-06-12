
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [bot].[loadQuestionQueue]

AS

--###
--bot.[loadQuestionQueue]
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



IF NOT EXISTS
	(
	SELECT
		questionQueue.questionQueueId	AS questionQueueId
		
	FROM
		Gabs.bot.questionQueue			AS questionQueue
		WITH							( NOLOCK, INDEX( ix_questionQueue ) )
	)
BEGIN



DECLARE @users		TABLE
	(
	number			INT,
	userId			INT,
	latitude		DECIMAL( 9, 7 ),
	longitude		DECIMAL( 10, 7 ),
	region			VARCHAR( 100 )
	)
	
INSERT INTO 
	@users 
	
SELECT
	ROW_NUMBER() OVER ( ORDER BY RAND( CAST( NEWID() AS VARBINARY ) ) )				AS number, 
	[user].userId																	AS userId,
	region.fromLatitude + ( ( region.toLatitude - region.fromLatitude ) / 2 )		AS latitude,
	region.fromLongitude + ( ( region.toLongitude - region.fromLongitude ) / 2 )	AS longitude,
	region.name																		AS region

FROM
	Gabs.bot.[user]			AS [user]
	WITH					( NOLOCK, INDEX( pk_botUser ) )
	
	INNER JOIN
	Gabs.lookup.region		AS region
	WITH					( NOLOCK, INDEX( pk_region ) )
	ON	[user].regionId		= region.regionId
	
ORDER BY
	number					ASC



DECLARE @userCount	INT

SELECT 
	@userCount		= COUNT(*)
	
FROM
	@users			AS users



DECLARE @questions	TABLE
	(
	question		VARCHAR(50),
	userNumber		INT
	)
	
INSERT INTO
	@questions

SELECT
	question.question						AS question,
	ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( @userCount - 1 ) ) + 1, 0 )	AS userNumber

FROM
	Gabs.bot.question						AS question



--lat: .000002741 = 1 ft
--lon: .0000035736 = 1 ft

DECLARE @randomRange		INT = 10000 -- ~2 miles
DECLARE @latitudePerFoot	DECIMAL(10,10) = 0.000002741
DECLARE @longitudePerFoot	DECIMAL(10,10) = 0.0000035736

INSERT INTO
	Gabs.bot.questionQueue
	
SELECT
	RAND( CAST( NEWID() AS VARBINARY ) )	AS [order],
	users.userId							AS userId,
	questions.question						AS question,
	users.latitude
	+	(	ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( @randomRange - 1 ) ) + 1, 0 )	-- distance
		*	CASE ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( 2 - 1 ) ) + 1, 0 ) WHEN 1 THEN 1 ELSE -1 END	-- negative
		*	@latitudePerFoot )
											AS randomLatitude,
	users.longitude
	+	(	ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( @randomRange - 1 ) ) + 1, 0 )	-- distance
		*	CASE ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( 2 - 1 ) ) + 1, 0 ) WHEN 1 THEN 1 ELSE -1 END	-- negative
		*	@longitudePerFoot )
											AS randomLongitude,
	users.region							AS region
	
FROM
	@questions								AS questions
	
	INNER JOIN
	@users									AS users
	ON	questions.userNumber				= users.number



END

GO
