SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@userId					AS ForeignKey = 1
--DECLARE	@emailStatusId			AS ForeignKey = 2 --unverified

CREATE PROCEDURE [login].[saveVerifyPhoneNumberErrors]
	(
	@userId				AS ForeignKey,
	@phoneNumber		AS ForeignKey
	)
AS

--###
--[login].[saveVerifyPhoneNumberErrors]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Gabs.login.verifyMobileNumberError
    (
    userId,
    mobileNumber,
    timestamp
    )

VALUES
    (
    @userId,
    @phoneNumber,
    GETDATE()
    )	

GO
GRANT EXECUTE ON  [login].[saveVerifyPhoneNumberErrors] TO [verifyPhoneNumbers]
GO
