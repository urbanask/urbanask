SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@userId					AS ForeignKey = 1
--DECLARE	@emailStatusId			AS ForeignKey = 2 --unverified

CREATE PROCEDURE [login].[updateUserEmail]
	(
	@userId				AS ForeignKey,
	@emailStatusId		AS ForeignKey
	)
AS

--###
--[login].[updateUserEmail]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



UPDATE
	Gabs.dbo.userEmail
	
SET
	userEmail.emailStatusId			= @emailStatusId
	
WHERE
		userEmail.userId			= @userId 
	



UPDATE
	Gabs.login.verifyEmail
	
SET
	verifyEmail.sent				= 1 -- true
	
WHERE
		verifyEmail.userId			= @userId 
	



IF @emailStatusId = 4 -- invalid
BEGIN



	DELETE FROM
		Gabs.login.verifyEmail
		
	WHERE
		verifyEmail.userId			= @userId



END
GO
GRANT EXECUTE ON  [login].[updateUserEmail] TO [verifyEmails]
GO
