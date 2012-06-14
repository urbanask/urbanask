
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



DECLARE @regions    TABLE
    (
    level           INT,
    level1          INT,
    level2          INT,
    level3          INT,
    level4          INT,
    level5          INT,
    id              INT,
    name            VARCHAR(100)
    )

INSERT INTO
    @regions
    
SELECT
    5                                               AS level,
    DENSE_RANK() OVER( ORDER BY region1.name ASC )  AS level1,
    DENSE_RANK() OVER( ORDER BY region2.name ASC )  AS level2,
    DENSE_RANK() OVER( ORDER BY region3.name ASC )  AS level3,
    DENSE_RANK() OVER( ORDER BY region4.name ASC )  AS level4,
    DENSE_RANK() OVER( ORDER BY region5.name ASC )  AS level5,
	region5.regionId				                AS id,
	region5.name					                AS name

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
    ON  region5.regionId                            = regions.id

WHERE
    regions.id                                      IS NULL
    
OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
    @regions
    
SELECT
    4                                               AS level,
    DENSE_RANK() OVER( ORDER BY region1.name ASC )  AS level1,
    DENSE_RANK() OVER( ORDER BY region2.name ASC )  AS level2,
    DENSE_RANK() OVER( ORDER BY region3.name ASC )  AS level3,
    DENSE_RANK() OVER( ORDER BY region4.name ASC )  AS level4,
    0                                               AS level5,
	region4.regionId				                AS id,
	region4.name					                AS name

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
    ON  region4.regionId                            = regions.id

WHERE
    regions.id                                      IS NULL
    
OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
    @regions
    
SELECT
    3                                               AS level,
    DENSE_RANK() OVER( ORDER BY region1.name ASC )  AS level1,
    DENSE_RANK() OVER( ORDER BY region2.name ASC )  AS level2,
    DENSE_RANK() OVER( ORDER BY region3.name ASC )  AS level3,
    0                                               AS level4,
    0                                               AS level5,
	region3.regionId				                AS id,
	region3.name					                AS name

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
    ON  region3.regionId                            = regions.id

WHERE
    regions.id                                      IS NULL

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
    @regions
    
SELECT
    2                                               AS level,
    DENSE_RANK() OVER( ORDER BY region1.name ASC )  AS level1,
    DENSE_RANK() OVER( ORDER BY region2.name ASC )  AS level2,
    0                                               AS level3,
    0                                               AS level4,
    0                                               AS level5,
	region2.regionId				                AS id,
	region2.name					                AS name

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
    ON  region2.regionId                            = regions.id

WHERE
    regions.id                                      IS NULL
    
OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
    @regions
    
SELECT
    1                                               AS level,
    DENSE_RANK() OVER( ORDER BY region1.name ASC )  AS level1,
    0                                               AS level2,
    0                                               AS level3,
    0                                               AS level4,
    0                                               AS level5,
	region1.regionId				                AS id,
	region1.name					                AS name

FROM
	Gabs.lookup.region				                AS region1
	WITH							                ( INDEX( pk_region ), NOLOCK )

    INNER JOIN
    Gabs.lookup.region                              AS region0
    WITH                                            ( INDEX( pk_region ), NOLOCK )
    ON  region1.parentRegionId                      = region0.regionId
    
    LEFT JOIN
    @regions                                        AS regions
    ON  region1.regionId                            = regions.id

WHERE
    regions.id                                      IS NULL
    
OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



SELECT
    regions.id          AS id,
    regions.name        AS name,
    regions.level       AS level

FROM
    @regions            AS regions

WHERE
    regions.id          > 0

ORDER BY
    regions.level1      ASC,
    regions.level2      ASC,
    regions.level3      ASC,
    regions.level4      ASC,
    regions.level5      ASC
    
GO
