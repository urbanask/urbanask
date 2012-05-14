SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE @userId			AS PrimaryKey = 1

CREATE PROCEDURE [api].[loadUserIcon] (

	@userId			AS PrimaryKey

)
AS

--###
--[api].[loadUserIcon]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



IF EXISTS
( 
	SELECT
		[userPicture].userId			AS userId
		
	FROM
		Gabs.dbo.[userPicture]			AS [userPicture]
		WITH							( NOLOCK, INDEX( ix_userPicture_userId ) )
		
	WHERE
			[userPicture].userId		= @userId
		AND	[userPicture].icon			IS NOT NULL
)
BEGIN



	SELECT
		[userPicture].icon				AS icon
		
	FROM
		Gabs.dbo.[userPicture]			AS [userPicture]
		WITH							( NOLOCK, INDEX( ix_userPicture_userId ) )
		
	WHERE
		[userPicture].userId			= @userId



END
ELSE
BEGIN



	SELECT
		[userPictureDefault].picture	AS picture
		
	FROM
		Gabs.dbo.[userPictureDefault]	AS [userPictureDefault]
		WITH							( NOLOCK, INDEX( pk_userPictureDefault ) )



END
GO
