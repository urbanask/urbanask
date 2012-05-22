SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE tools.getNextUser
	(
	@userId		INT	OUTPUT
	)
AS

--###
--tools.getNextUser
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT TOP 1
	@userId							= [user].userId
	
FROM
	Gabs.dbo.[user]					AS [user]
	
	LEFT JOIN
	Gabs.dbo.userPicture			AS userPicture
	ON [user].userId				= userPicture.userId
	
WHERE
		[user].userId				> 100000
	AND	userPicture.userPictureId	IS NULL
	
	
GO
