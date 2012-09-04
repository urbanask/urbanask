SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [login].[viewVerifyPhoneNumbers]
	(
	@workCount		INT
	)
AS

--###
--[login].[viewVerifyPhoneNumbers]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @workCount;



SELECT
	verifyMobileNumber.userId		    AS userId,
	verifyMobileNumber.mobileNumber     AS mobileNumber
	
FROM
	Gabs.login.verifyMobileNumber	    AS verifyMobileNumber
	WITH							    ( NOLOCK, INDEX( ix_verifyMobileNumber ) )

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



GO
GRANT EXECUTE ON  [login].[viewVerifyPhoneNumbers] TO [verifyPhoneNumbers]
GO
