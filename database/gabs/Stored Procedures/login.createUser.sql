
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@suggestedUsername	AS VARCHAR(100) = 'hulu'
--DECLARE	@tagline			AS VARCHAR(256) = ''
--DECLARE	@hash				AS CHAR(88) = '1'
--DECLARE	@salt				AS CHAR(8) = '2'
--DECLARE	@iterations			AS INT = 3
--DECLARE	@hashType			AS VARCHAR(10) = 'SHA512'
--DECLARE	@metricDistances	AS INT = 1
--DECLARE	@languageId			AS ForeignKey  = 1
--DECLARE	@authTypeId			AS ForeignKey = 1
--DECLARE	@email				AS VARCHAR(256) = NULL
--DECLARE	@mobileNumber		AS VARCHAR(50) = '9164022982'
--DECLARE	@userId				AS ForeignKey		
--DECLARE @username			AS VARCHAR(100) = ''
--DECLARE @error              AS VARCHAR(256)     = ''

CREATE PROCEDURE [login].[createUser]
	(
	@suggestedUsername	AS VARCHAR(100),
	@tagline			AS VARCHAR(256),
	@hash				AS CHAR(88),
	@salt				AS CHAR(8),
	@iterations			AS INT,
	@hashType			AS VARCHAR(10),
	@metricDistances	AS INT,
	@languageId			AS ForeignKey,
	@authTypeId			AS ForeignKey,
	@email				AS VARCHAR(256)     = NULL,
	@mobileNumber       AS VARCHAR(50)      = NULL,
	@userId				AS ForeignKey		        OUTPUT,
	@username			AS VARCHAR(100)		        OUTPUT,
	@error              AS VARCHAR(256)     = ''    OUTPUT
	)
AS

--###
--[login].[createUser]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DECLARE @hashTypeId INT

SELECT
	@hashTypeId				= hashType.hashTypeId

FROM	
	gabs.lookup.hashType	AS hashType
	WITH					( NOLOCK, INDEX( pk_hashType ) )

WHERE
	hashType.type			= @hashType
	
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


	
IF EXISTS
	(
	SELECT
		[user].userId			AS userId
		
	FROM
		Gabs.dbo.[user]			AS [user]
		WITH					( INDEX( pk_user ), NOLOCK )
		
	WHERE
		[user].username			= @suggestedUsername
	)
BEGIN

	
	
	SELECT @username = @suggestedUsername + LTRIM( STR( ROUND( RAND() * 10000, 0 ) + 1000 ) )



END
ELSE
BEGIN



	SELECT @username = @suggestedUsername



END



IF @email IS NOT NULL
BEGIN



    INSERT INTO
	    Gabs.dbo.[user]
	    (
	    [user].username,
	    [user].tagline,
	    [user].hash,
	    [user].salt,
	    [user].iterations,
	    [user].hashTypeId,
	    [user].metricDistances,
	    [user].languageId,
	    [user].authTypeId
	    )

    VALUES
	    (
	    @username,
	    @tagline,
	    @hash,
	    @salt,
	    @iterations,
	    @hashTypeId,
	    @metricDistances,
	    @languageId,
	    @authTypeId
	    )
    	


    SELECT @userId = SCOPE_IDENTITY()



    INSERT INTO
	    Gabs.dbo.[userEmail]
	    (
	    userId,
	    email
	    )

    VALUES
	    (
	    @userId,
	    @email
	    )



    INSERT INTO
	    Gabs.login.verifyEmail
	    (
	    userId,
	    email,
	    guid,
	    timestamp
	    )
    	
    VALUES
	    (
	    @userId,
	    @email,
	    NEWID(),
	    GETDATE()
	    )



    INSERT INTO
	    [Gabs].dbo.userInstructions
	    (
	    [userId]
	    )

    VALUES
	    (
	    @userId
	    )
    	
    	
    	
END



IF @mobileNumber IS NOT NULL
BEGIN



    IF NOT EXISTS(

        SELECT
            userPhone.userPhoneId       AS userPhoneId
            
        FROM
            Gabs.dbo.userPhone          AS userPhone
            WITH                        ( NOLOCK, INDEX( ix_userPhone ) )
            
        WHERE
                userPhone.number        = @mobileNumber
            OR  userPhone.number        = '1' + @mobileNumber
            OR  userPhone.number        = '+' + @mobileNumber
            OR  userPhone.number        = '+1' + @mobileNumber

    )
    BEGIN



        INSERT INTO
	        Gabs.dbo.[user]
	        (
	        [user].username,
	        [user].tagline,
	        [user].hash,
	        [user].salt,
	        [user].iterations,
	        [user].hashTypeId,
	        [user].metricDistances,
	        [user].languageId,
	        [user].authTypeId
	        )

        VALUES
	        (
	        @username,
	        @tagline,
	        @hash,
	        @salt,
	        @iterations,
	        @hashTypeId,
	        @metricDistances,
	        @languageId,
	        @authTypeId
	        )
        	


        SELECT @userId = SCOPE_IDENTITY()
    
    
    
        INSERT INTO
	        [Gabs].dbo.userPhone
	        (
	        [userId],
	        [number]
	        )

        VALUES
	        (
	        @userId,
	        @mobileNumber
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
	        @mobileNumber,
	        GETDATE()
	        )



        INSERT INTO
	        [Gabs].dbo.userInstructions
	        (
	        [userId]
	        )

        VALUES
	        (
	        @userId
	        )
    	
    	
    	
    END
    ELSE
    BEGIN
    
    

            SET @error = 'Mobile number is already in use.'



    END
    
END
	
	
	
--PRINT @userId
--PRINT @error

GO
