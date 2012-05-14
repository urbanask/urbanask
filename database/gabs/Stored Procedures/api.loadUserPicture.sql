SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
--DECLARE @userId			AS PrimaryKey = 1

CREATE PROCEDURE [api].[loadUserPicture] (

	@userId			AS PrimaryKey

)
AS

--###
--api.loadUserPicture
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



IF EXISTS( 

	SELECT
		[userPicture].userId			AS userId
		
	FROM
		Gabs.dbo.[userPicture]			AS [userPicture]
		WITH							(NOLOCK, INDEX(ix_userPicture_userId))
		
	WHERE
		[userPicture].userId			= @userId
		
)
BEGIN



	SELECT
		[userPicture].picture			AS picture
		
	FROM
		Gabs.dbo.[userPicture]			AS [userPicture]
		WITH							(NOLOCK, INDEX(ix_userPicture_userId))
		
	WHERE
		[userPicture].userId			= @userId



END
ELSE
BEGIN



	SELECT
		[userPictureDefault].picture	AS picture
		
	FROM
		Gabs.dbo.[userPictureDefault]	AS [userPictureDefault]
		WITH							(NOLOCK, INDEX(pk_userPictureDefault))
		


END
GO
