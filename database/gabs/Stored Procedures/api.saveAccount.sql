
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@userId			    AS ForeignKey = 24
--DECLARE	@username			AS VARCHAR(100) = 'Emil Sinclair'
--DECLARE	@tagline			AS VARCHAR(256) = 'something'
--DECLARE	@phoneNumber		AS VARCHAR(50) = '+19164022982'
--DECLARE	@regionId			AS ForeignKey = 1
--DECLARE		@error          AS VARCHAR(256) = '' 

CREATE PROCEDURE [api].[saveAccount]
	(
	@userId			AS ForeignKey,
	@username		AS VARCHAR(100),
	@tagline		AS VARCHAR(256),
	@phoneNumber 	AS VARCHAR(50),
	@regionId		AS ForeignKey,
	@error          AS VARCHAR(256) = '' OUTPUT
	)
AS

--###
--[api].[saveAccount]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;


UPDATE
	Gabs.dbo.[user]

SET 
	[user].username		= @username,
	[user].tagline		= @tagline

WHERE
	[user].userId		= @userId



DELETE FROM
    Gabs.dbo.userRegion

WHERE
        userRegion.userId		= @userId



IF @regionId > -1
BEGIN



    INSERT INTO
        Gabs.dbo.userRegion
        (
        userId,
        regionId
        )
       
    VALUES
        (
        @userId,
        @regionId
        )
    


END



IF EXISTS(

    SELECT
        userPhone.userPhoneId       AS userPhoneId
        
    FROM
        Gabs.dbo.userPhone          AS userPhone
        WITH                        ( NOLOCK, INDEX( ix_userPhone ) )
        
    WHERE
        userPhone.userId            = @userId

)
BEGIN



    IF NOT EXISTS(

        SELECT
            userPhone.userPhoneId       AS userPhoneId
            
        FROM
            Gabs.dbo.userPhone          AS userPhone
            WITH                        ( NOLOCK, INDEX( ix_userPhone ) )
            
        WHERE
                userPhone.userId        = @userId
            AND userPhone.number        = @phoneNumber

    )
    BEGIN
    
    
    
        IF NOT EXISTS(

            SELECT
                userPhone.userPhoneId       AS userPhoneId
                
            FROM
                Gabs.dbo.userPhone          AS userPhone
                WITH                        ( NOLOCK, INDEX( ix_userPhone ) )
                
            WHERE
                    userPhone.userId        <> @userId
                AND userPhone.number        = @phoneNumber

        )
        BEGIN
    
    
    
            UPDATE
                Gabs.dbo.userPhone
            
            SET
                number                  = @phoneNumber,
                verified                = 0 --false
                
            WHERE
                userPhone.userId        = @userId
        
    
    
            INSERT INTO
	            Gabs.login.verifyMobileNumber
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
	            
	            
	            
	    END
        ELSE
        BEGIN
        
        
        
            SET @error = 'Mobile number is already in use.'
            
        
        
        END



    END



END
ELSE
BEGIN



    INSERT INTO
        Gabs.dbo.userPhone
        (
        userId,
        number,
        verified
        )
        
    VALUES
        (
        @userId,
        @phoneNumber,
        0 --false
        )
    
    
    
    INSERT INTO
	    Gabs.login.verifyMobileNumber
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



END


GO
