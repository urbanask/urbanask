
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@username		AS VARCHAR(100) = 'thinkingstiff'
--DECLARE	@userId			AS INT				
--DECLARE	@hash			AS CHAR(88)			
--DECLARE	@hashType		AS VARCHAR(10)		
--DECLARE	@salt			AS CHAR(8)			
--DECLARE	@iterations		AS INT		
		

CREATE PROCEDURE [login].[checkAuthorization]
	(
	@username		AS VARCHAR(100),
	@userId			AS INT				OUTPUT,
	@hash			AS CHAR(88)			OUTPUT,
	@hashType		AS VARCHAR(10)		OUTPUT,
	@salt			AS CHAR(8)			OUTPUT,
	@iterations		AS INT				OUTPUT,
	@enabled		AS INT				OUTPUT
	)
AS

--###
--login.checkAuthorization
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT @userId = 0;
SELECT @enabled = 0;



SELECT
	@userId									= [user].userId,
	@hash									= [user].hash,
	@hashType								= hashtype.type,
	@salt									= [user].salt,
	@iterations								= [user].iterations,
	@enabled								= [user].enabled
	
FROM
	Gabs.dbo.[user]							AS [user]
	WITH									( NOLOCK, INDEX( ix_user_username ) )

	INNER JOIN
	Gabs.lookup.hashType					AS hashType
	WITH									( NOLOCK, INDEX( pk_hashType ) )
	ON	[user].hashTypeId					= hashType.hashTypeID

WHERE
		[user].username						= @username
	AND [user].authTypeId					IN ( 1, 4 ) --normal, mobile

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )
	  

--PRINT @userId



GO
