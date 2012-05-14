SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [login].deleteOldVerifyEmails

AS

--###
--[login].[deleteOldVerifyEmails]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



DELETE FROM
	Gabs.login.verifyEmail
	
WHERE
	verifyEmail.timestamp		< DATEADD( DAY, -7, GETDATE() ) --7 days old
GO
GRANT EXECUTE ON  [login].[deleteOldVerifyEmails] TO [verifyEmails]
GO
