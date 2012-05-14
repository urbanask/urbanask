SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@username		AS VARCHAR(100) = 'ThinkingStiff'
--DECLARE	@exists			AS BIT		
		

CREATE PROCEDURE [login].[checkUsername]
	(
	@username		AS VARCHAR(100),
	@exists			AS BIT				OUTPUT
	)
AS

--###
--[login].[checkUsername]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SET @exists = 0;



IF EXISTS(

	SELECT
		[user].userId		AS userId
		
	FROM
		Gabs.dbo.[user]		AS [user]
		WITH				( NOLOCK, INDEX( ix_user_username ) )

	WHERE
		[user].username		= @username

)
BEGIN



	SET @exists = 1; --true



END


PRINT @exists



GO
