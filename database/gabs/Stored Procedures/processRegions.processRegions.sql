SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE processRegions.processRegions

AS

--###
--processRegions.processRegions
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



IF EXISTS
(

	SELECT
		regionWork.regionWorkId             AS regionWorkId
		
	FROM
		Gabs.processRegions.regionWork	    AS regionWork
		WITH								( NOLOCK, INDEX( pk_regionWork ) )
			
)
BEGIN



	UPDATE
	    Gabs.dbo.question  
	    
	SET
	    question.regionId                   = regionName.regionId
		
    FROM
        Gabs.processRegions.regionWork	    AS regionWork
        WITH                                ( NOLOCK, INDEX( ix_regionWork ) )
        
    	INNER JOIN
    	Gabs.lookup.regionName              AS regionName
    	WITH                                ( NOLOCK, INDEX( ix_regionName ) )
    	ON  regionWork.region               = regionName.name
    	
    	INNER JOIN
    	Gabs.dbo.question                   AS question
    	WITH                                ( NOLOCK, INDEX( pk_question ) )
    	ON  regionWork.questionId           = question.questionId
    	
    OPTION
	      ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



END
GO
