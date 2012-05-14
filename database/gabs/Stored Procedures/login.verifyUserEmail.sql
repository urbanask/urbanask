SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@userId					AS ForeignKey = 1
--DECLARE	@emailStatusId			AS ForeignKey = 2 --unverified

CREATE PROCEDURE [login].[verifyUserEmail]
	(
	@guid					AS CHAR(36)
	)
AS

--###
--[login].[verifyUserEmail]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



DECLARE @userId				AS ForeignKey

SELECT
	@userId					= verifyEmail.userId

FROM
	Gabs.login.verifyEmail	AS verifyEmail
	WITH					( INDEX( ix_verifyEmail ), NOLOCK )
	
WHERE
	verifyEmail.guid		= @guid



UPDATE
	Gabs.dbo.userEmail
	
SET
	userEmail.emailStatusId			= 4 -- verified
	
WHERE
		userEmail.userId			= @userId 



DELETE FROM
	Gabs.login.verifyEmail
	
WHERE
	verifyEmail.userId				= @userId
GO
GRANT EXECUTE ON  [login].[verifyUserEmail] TO [api]
GO
