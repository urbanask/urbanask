
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--DECLARE	@phoneNumber    AS VARCHAR(50) = '+19164022982'
--DECLARE	@success		AS INT				

CREATE PROCEDURE [api].[verifyPhoneNumber]
	(
	@phoneNumber    AS VARCHAR(50),
	@success		AS INT	            OUTPUT
	)
AS

--###
--[api].[verifyPhoneNumber]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SET @success = 0 --false



IF EXISTS(

    SELECT
	    userPhone.userPhoneId       AS userPhoneId

    FROM
	    Gabs.dbo.userPhone		    AS userPhone
	    WITH					    ( NOLOCK, INDEX( ix_userPhone_number ) )

    WHERE
	        userPhone.number        = @phoneNumber
	    OR  '1' + userPhone.number  = @phoneNumber
	    OR  '+' + userPhone.number  = @phoneNumber
	    OR  '+1' + userPhone.number = @phoneNumber

)
BEGIN



    UPDATE
        Gabs.dbo.userPhone
        
    SET
        userPhone.verified          = 1 --true

    WHERE
	        userPhone.number        = @phoneNumber
	    OR  '1' + userPhone.number  = @phoneNumber
	    OR  '+' + userPhone.number  = @phoneNumber
	    OR  '+1' + userPhone.number = @phoneNumber



    SELECT @success = 1
    
    
    
END





--PRINT @success

GO
