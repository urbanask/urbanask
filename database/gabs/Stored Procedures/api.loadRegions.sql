SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [api].[loadRegions]

AS

--###
--[api].[loadRegions]
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	region.regionId					AS id,
	region.name						AS name

FROM
	Gabs.lookup.region				AS region
	WITH							( INDEX( pk_region ), NOLOCK )

WHERE
	region.regionId					> 0

ORDER BY
	region.name						ASC

OPTION
	(FORCE ORDER, LOOP JOIN, MAXDOP 1)
GO
