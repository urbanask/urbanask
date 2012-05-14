SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@facbookId		AS VARCHAR(20) = '724347036'
--DECLARE	@userId			AS INT				
--DECLARE	@hash			AS CHAR(88)			
--DECLARE	@hashType		AS VARCHAR(10)		
--DECLARE	@salt			AS CHAR(8)			
--DECLARE	@iterations		AS INT		
		

CREATE PROCEDURE [login].[checkAuthorizationFacebook]
	(
	@facebookId		AS VARCHAR(20),
	@userId			AS INT				OUTPUT,
	@hash			AS CHAR(88)			OUTPUT,
	@hashType		AS VARCHAR(10)		OUTPUT,
	@salt			AS CHAR(8)			OUTPUT,
	@iterations		AS INT				OUTPUT,
	@enabled		AS INT				OUTPUT
	)
AS

--###
--[login].[checkAuthorizationFacebook]
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
	Gabs.dbo.userFacebook					AS userFacebook
	WITH									( NOLOCK, INDEX( ix_userFacebook_facebookId ) )

	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									( NOLOCK, INDEX( pk_user ) )
	ON	[user].userId						= userFacebook.userId

	INNER JOIN
	Gabs.lookup.hashType					AS hashType
	WITH									( NOLOCK, INDEX( pk_hashType ) )
	ON	[user].hashTypeId					= hashType.hashTypeID

WHERE
		userFacebook.facebookId				= @facebookId
	AND [user].authTypeId					= 2 --facebook

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )
	  

--PRINT @userId



GO
