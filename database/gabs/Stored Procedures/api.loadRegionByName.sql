SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE    @region     VARCHAR(100) = 'Sacramento, CA, USA'
--DECLARE    @regionId   [ForeignKey]    


CREATE PROCEDURE [api].[loadRegionByName]
(
    @region     VARCHAR(100),
    @regionId   [ForeignKey]    OUTPUT
)
AS

--###
--[api].[loadRegionByName]
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT @regionId = 0;



SELECT
	@regionId                       = regionName.regionId

FROM
	Gabs.lookup.regionName			AS regionName
	WITH							( INDEX( ix_regionName ), NOLOCK )

WHERE
	regionName.name				    = @region

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )
	


--PRINT @regionId

GO
