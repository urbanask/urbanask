SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [tools].[viewUsers]

AS

--###
--[tools].[viewUsers]
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	botUser.userId			AS userId,
	[user].username			AS username,
	userPicture.picture		AS picture
	
FROM
	Gabs.bot.[user]			AS botUser
	WITH					( NOLOCK, INDEX( pk_botUser ) )
	
	INNER JOIN
	Gabs.dbo.[user]			AS [user]
	WITH					( NOLOCK, INDEX( pk_user ) )
	ON	botUser.userId		= [user].userId
	
	INNER JOIN
	Gabs.dbo.userPicture	AS userPicture
	WITH					( NOLOCK, INDEX( ix_userPicture_userId ) )
	ON	botUser.userId		= userPicture.userId
	
GO
