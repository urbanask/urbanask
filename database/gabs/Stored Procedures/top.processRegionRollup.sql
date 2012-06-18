SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO

--DECLARE @regionId		AS INT = 22 --california
--DECLARE	@topTypeId		AS INT = 2 --questions
--DECLARE	@intervalId		AS INT = 0 --all
--DECLARE	@count			AS INT = 30

CREATE PROCEDURE [top].processRegionRollup
	(
	@regionId		AS ForeignKey,
	@topTypeId		AS ForeignKey,
	@intervalId		AS ForeignKey,
	@count			AS INT
	)
AS

--###
--[top].processRegionRollup
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @users      TABLE
    (
    regionId        INT,
    topTypeId       INT,
    intervalId      INT,
    userId          INT,
    username        VARCHAR(100),
    reputation      INT,
    totalQuestions  INT,
    totalAnswers    INT,
    totalBadges     INT,
    topScore        INT    
    )
    
INSERT INTO
    @users
     
SELECT
    @regionId                   AS regionId,
    topUser.topTypeId           AS topTypeId,
    topUser.intervalId          AS intervalId,
    topUser.userId              AS userId,
    topUser.username            AS username,
    topUser.reputation          AS reputation,
    topUser.totalQuestions      AS totalQuestions,
    topUser.totalAnswers        AS totalAnswers,
    topUser.totalBadges         AS totalBadges,
    SUM( topUser.topScore )     AS topScore
    
FROM
    Gabs.[top].topUser          AS topUser
    WITH                        ( NOLOCK, INDEX( ix_topUser_regionId ) )
    
    INNER JOIN
    Gabs.lookup.region          AS region
    WITH                        ( NOLOCK, INDEX( pk_region ) )
    ON  topUser.regionId        = region.regionId
    
WHERE
        region.parentRegionId   = @regionId
    AND topUser.topTypeId       = @topTypeId
    AND topUser.intervalId      = @intervalId

GROUP BY
    topUser.topTypeId,
    topUser.intervalId,
    topUser.userId,
    topUser.username,
    topUser.reputation,
    topUser.totalQuestions,
    topUser.totalAnswers,
    topUser.totalBadges
    
ORDER BY
    topScore                    DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



IF EXISTS(

    SELECT
        topUser.topUserId           AS topUserId

    FROM
        Gabs.[top].topUser          AS topUser
        WITH                        ( NOLOCK, INDEX( pk_topUser ) )

    WHERE
		    topUser.regionId		= @regionId
	    AND topUser.topTypeId		= @topTypeId
	    AND topUser.intervalId		= @intervalId

)
BEGIN



    UPDATE
	    Gabs.[top].topUser

    SET
        topUser.topScore        = topUser.topScore + users.topScore
        
    FROM
        @users                  AS users
        
        INNER JOIN
        Gabs.[top].topUser      AS topUser
		ON  users.regionId	    = topUser.regionId
	    AND users.topTypeId	    = topUser.topTypeId
	    AND users.intervalId	= topUser.intervalId
	    AND users.userId        = topUser.userId



END
ELSE
BEGIN



    INSERT INTO
	    Gabs.[top].topUser

    SELECT
	    regionId,
	    topTypeId,
	    intervalId,
	    userId,
	    username,
	    reputation,
	    totalQuestions,
	    totalAnswers,
	    totalBadges,
	    topScore

    FROM
	    @users



END


    
    
GO
GRANT EXECUTE ON  [top].[processRegionRollup] TO [processTopLists]
GO
