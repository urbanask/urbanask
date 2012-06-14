
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@userId			AS ForeignKey = 1
--DECLARE	@answerId		AS ForeignKey = 4248908
--DECLARE	@success		AS BIT				

CREATE PROCEDURE [api].[saveAccount]
	(
	@userId			AS ForeignKey,
	@username		AS VARCHAR(100),
	@tagline		AS VARCHAR(256),
	@regionId		AS ForeignKey
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
GO
