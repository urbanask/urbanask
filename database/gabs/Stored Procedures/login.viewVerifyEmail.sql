SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [login].[viewVerifyEmail]
	(
	@workCount		INT
	)
AS

--###
--[login].[viewVerifyEmail]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @workCount;



SELECT
	verifyEmail.userId				AS userId,
	verifyEmail.email				AS email,
	verifyEmail.guid				AS guid
	
FROM
	Gabs.login.verifyEmail			AS verifyEmail
	WITH							( NOLOCK, INDEX( ix_verifyEmail ) )

WHERE
	verifyEmail.sent				= 0 --false
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



GO
GRANT EXECUTE ON  [login].[viewVerifyEmail] TO [verifyEmails]
GO
