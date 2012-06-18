
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



DECLARE @regions    TABLE
    (
    level           INT,
    regionId        INT
    )

INSERT INTO
    @regions
    
SELECT
    5                                               AS level,
	region5.regionId				                AS regionId

FROM
	Gabs.lookup.region				                AS region5
	WITH							                ( INDEX( pk_region ), NOLOCK )

    INNER JOIN
    Gabs.lookup.region                              AS region4
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region5.parentRegionId                      = region4.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region3
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region4.parentRegionId                      = region3.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region2
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region3.parentRegionId                      = region2.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region1
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region2.parentRegionId                      = region1.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region0
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region1.parentRegionId                      = region0.regionId
    
    LEFT JOIN
    @regions                                        AS regions
    ON  region5.regionId                            = regions.regionId

WHERE
    regions.regionId                                IS NULL
    
OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
    @regions
    
SELECT
    4                                               AS level,
	region4.regionId				                AS regionId

FROM
	Gabs.lookup.region				                AS region4
	WITH							                ( INDEX( pk_region ), NOLOCK )

    INNER JOIN
    Gabs.lookup.region                              AS region3
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region4.parentRegionId                      = region3.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region2
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region3.parentRegionId                      = region2.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region1
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region2.parentRegionId                      = region1.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region0
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region1.parentRegionId                      = region0.regionId
    
    LEFT JOIN
    @regions                                        AS regions
    ON  region4.regionId                            = regions.regionId

WHERE
    regions.regionId                                IS NULL
    
OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
    @regions
    
SELECT
    3                                               AS level,
	region3.regionId				                AS regionId

FROM
	Gabs.lookup.region				                AS region3
	WITH							                ( INDEX( pk_region ), NOLOCK )

    INNER JOIN
    Gabs.lookup.region                              AS region2
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region3.parentRegionId                      = region2.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region1
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region2.parentRegionId                      = region1.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region0
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region1.parentRegionId                      = region0.regionId
    
    LEFT JOIN
    @regions                                        AS regions
    ON  region3.regionId                            = regions.regionId

WHERE
    regions.regionId                                IS NULL

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
    @regions
    
SELECT
    2                                               AS level,
	region2.regionId				                AS regionId

FROM
	Gabs.lookup.region				                AS region2
	WITH							                ( INDEX( pk_region ), NOLOCK )

    INNER JOIN
    Gabs.lookup.region                              AS region1
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region2.parentRegionId                      = region1.regionId
    
    INNER JOIN
    Gabs.lookup.region                              AS region0
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region1.parentRegionId                      = region0.regionId
    
    LEFT JOIN
    @regions                                        AS regions
    ON  region2.regionId                            = regions.regionId

WHERE
    regions.regionId                                IS NULL
    
OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
    @regions
    
SELECT
    1                                               AS level,
	region1.regionId				                AS regionId

FROM
	Gabs.lookup.region				                AS region1
	WITH							                ( INDEX( pk_region ), NOLOCK )

    INNER JOIN
    Gabs.lookup.region                              AS region0
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region1.parentRegionId                      = region0.regionId
    
    LEFT JOIN
    @regions                                        AS regions
    ON  region1.regionId                            = regions.regionId

WHERE
    regions.regionId                                IS NULL
    
OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
    @regions
    
SELECT
    0                                               AS level,
	region0.regionId				                AS regionId

FROM
    Gabs.lookup.region                              AS region0
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    
    LEFT JOIN
    @regions                                        AS regions
    ON  region0.regionId                            = regions.regionId

WHERE
    regions.regionId                                IS NULL
    
OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



SELECT
    regions.regionId    AS regionId,
    regions.level       AS level

FROM
    @regions            AS regions

WHERE
	regions.regionId	>= 0

ORDER BY
    regions.level       DESC
    
GO

GRANT EXECUTE ON  [top].[lookupRegions] TO [processTopLists]
GO
