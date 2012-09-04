SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@userId					AS ForeignKey = 1
--DECLARE	@emailStatusId			AS ForeignKey = 2 --unverified

CREATE PROCEDURE [login].[deleteVerifyPhoneNumbers]
	(
	@userId				AS ForeignKey
	)
AS

--###
--[login].[deleteVerifyPhoneNumbers]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



DELETE FROM
	Gabs.login.verifyMobileNumber
	
WHERE
	verifyMobileNumber.userId		= @userId

GO
GRANT EXECUTE ON  [login].[deleteVerifyPhoneNumbers] TO [verifyPhoneNumbers]
GO
