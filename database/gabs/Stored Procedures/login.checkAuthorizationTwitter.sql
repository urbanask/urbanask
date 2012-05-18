SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@twitterId		AS VARCHAR(20) = '509992905'
--DECLARE	@userId			AS INT				
--DECLARE	@hash			AS CHAR(88)			
--DECLARE	@hashType		AS VARCHAR(10)		
--DECLARE	@salt			AS CHAR(8)			
--DECLARE	@iterations		AS INT		
--DECLARE	@enabled		AS INT
	

CREATE PROCEDURE [login].[checkAuthorizationTwitter]
	(
	@twitterId		AS VARCHAR(20),
	@userId			AS INT				OUTPUT,
	@hash			AS CHAR(88)			OUTPUT,
	@hashType		AS VARCHAR(10)		OUTPUT,
	@salt			AS CHAR(8)			OUTPUT,
	@iterations		AS INT				OUTPUT,
	@enabled		AS INT				OUTPUT
	)
AS

--###
--[login].[checkAuthorizationTwitter]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SET @userId = 0;
SET @enabled = 0;


SELECT
	@userId									= [user].userId,
	@hash									= [user].hash,
	@hashType								= hashtype.type,
	@salt									= [user].salt,
	@iterations								= [user].iterations,
	@enabled								= [user].enabled
	
FROM
	Gabs.dbo.userTwitter					AS userTwitter
	WITH									( NOLOCK, INDEX( ix_userTwitter_twitterId ) )

	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									( NOLOCK, INDEX( pk_user ) )
	ON	[user].userId						= userTwitter.userId

	INNER JOIN
	Gabs.lookup.hashType					AS hashType
	WITH									( NOLOCK, INDEX( pk_hashType ) )
	ON	[user].hashTypeId					= hashType.hashTypeID

WHERE
		userTwitter.twitterId				= @twitterId
	AND [user].authTypeId					= 3 --twitter

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



--PRINT @userId



GO
