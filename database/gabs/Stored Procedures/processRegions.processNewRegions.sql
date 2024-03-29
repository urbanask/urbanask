
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [processRegions].[processNewRegions]

AS

--###
--processRegions.processNewRegions
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DELETE
    Gabs.processRegions.regionNew
    
FROM
	Gabs.processRegions.regionNew       AS regionNew
	WITH                                ( NOLOCK, INDEX( ix_regionNew ) )

    INNER JOIN
	Gabs.[lookup].regionName            AS regionName
	WITH                                ( NOLOCK, INDEX( ix_regionName ) )
	ON  regionNew.region                = regionName.name
        
OPTION
      ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



IF EXISTS
(

	SELECT
		regionWork.regionWorkId             AS regionWorkId
		
	FROM
		Gabs.processRegions.regionWork	    AS regionWork
		WITH								( NOLOCK, INDEX( pk_regionWork ) )
			
)
BEGIN



	INSERT INTO
	    Gabs.processRegions.regionNew
	    
	SELECT
	    regionWork.region                   AS region,
	    question.latitude                   AS latitude,
	    question.longitude                  AS longitude
		
    FROM
        Gabs.processRegions.regionWork	    AS regionWork
        WITH                                ( NOLOCK, INDEX( ix_regionWork ) )
        
    	INNER JOIN
    	Gabs.dbo.question                   AS question
    	WITH                                ( NOLOCK, INDEX( pk_question ) )
    	ON  regionWork.questionId           = question.questionId
    	
    	LEFT JOIN
    	Gabs.[lookup].regionName            AS regionName
    	WITH                                ( NOLOCK, INDEX( ix_regionName ) )
    	ON  regionWork.region               = regionName.name
    	
    	LEFT JOIN
    	Gabs.processRegions.regionNew       AS regionNew
    	WITH                                ( NOLOCK, INDEX( ix_regionNew ) )
    	ON  regionWork.region               = regionNew.region
    	
    WHERE
            regionName.regionId             IS NULL
        AND regionNew.region                IS NULL
        
    OPTION
	      ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



END
GO
