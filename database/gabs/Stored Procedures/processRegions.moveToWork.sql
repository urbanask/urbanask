
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--DECLARE @workCount INT = 20

CREATE PROCEDURE [processRegions].[moveToWork]
	(
	@workCount		INT
	)
AS

--###
--processRegions.moveToWork
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @workCount;



IF NOT EXISTS
(

	SELECT
		regionWork.regionWorkId             AS regionWorkId
		
	FROM
		Gabs.processRegions.regionWork	    AS regionWork
		WITH								( NOLOCK, INDEX( pk_regionWork ) )
			
)
BEGIN



	INSERT INTO
		Gabs.processRegions.regionWork
		(
		regionWork.region,
		regionWork.questionId
		)
	    
	SELECT
		question.region				AS region,
		question.questionId			AS questionId
		
    FROM
        Gabs.dbo.question           AS question
        WITH                        ( NOLOCK, INDEX( ix_question_longitude_latitude ) )
        
    WHERE
		    question.timestamp		> DATEADD( WEEK, -2, GETDATE() ) -- last two weeks
        AND question.regionId       IS NULL
        AND question.region         <> ''
        
    ORDER BY
	    question.[timestamp]		DESC
    	
    OPTION
	      ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



END
GO
