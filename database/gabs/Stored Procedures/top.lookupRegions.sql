SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [top].[lookupRegions]

AS

--###
--[top].[lookupRegions]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	region.regionId			AS regionId,
	region.fromLatitude		AS fromLatitude,
	region.toLatitude		AS toLatitude,
	region.fromLongitude	AS fromLongitude,
	region.toLongitude		AS toLongitude

FROM
	Gabs.lookup.region		AS region
	WITH					( NOLOCK, INDEX( pk_region ) )

WHERE
	region.regionId			>= 0

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


GO
GRANT EXECUTE ON  [top].[lookupRegions] TO [processTopLists]
GO
