SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@userId			AS INT		= 1	
--DECLARE	@hash			AS CHAR(88)	= 'AAADzYl7TdCABAIeBswsSiZCWaPar85QbX8D7Xx2hB70KxZBLi9d8A6Tq7ZCgd17cwTdUBWsLklOqQLgoSeZAmFRZB440pJizlgKFTzBb5ZAQZDZD'		
		

CREATE PROCEDURE [login].[updateFacebookHash]
	(
	@userId			AS [ForeignKey],
	@hash			AS VARCHAR(88),
	@accessToken	AS VARCHAR(255)
	)
AS

--###
--[login].[updateFacebookHash]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



UPDATE
	Gabs.dbo.[user]

SET
	hash						= @hash

WHERE
		[user].userId			= @userId



UPDATE
	Gabs.dbo.[userFacebook]

SET
	accessToken					= @accessToken

WHERE
		[userFacebook].userId	= @userId

GO
