
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--DECLARE @workCount INT = 10

CREATE PROCEDURE [bot].[moveToWork]
	(
	@workCount		INT
	)
AS

--###
--bot.moveToWork
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @workCount;



IF NOT EXISTS
(

	SELECT
		questionWork.questionWorkId 
		
	FROM
		Gabs.bot.questionWork			AS questionWork
		WITH							( NOLOCK, INDEX( pk_botQuestionWork ) )
			
)
BEGIN



	INSERT INTO
		Gabs.bot.questionWork 	
		(
		questionWork.userId,
		questionWork.question,
		questionWork.latitude,
		questionWork.longitude,
		questionWork.region
		)
	    
	SELECT
		questionQueue.userId			AS userId,
		questionQueue.question			AS question,
		questionQueue.latitude			AS latitude,
		questionQueue.longitude			AS longitude,
		questionQueue.region			AS region
		
	FROM
		Gabs.bot.questionQueue			AS questionQueue
		WITH							( NOLOCK, INDEX( ix_questionQueue ) )

	ORDER BY
		questionQueue.[order]			ASC
		
	OPTION
		  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



	DELETE 
		Gabs.bot.questionQueue
				
	FROM
		Gabs.bot.questionQueue				AS questionQueue
		WITH								( NOLOCK, INDEX( ix_questionQueue ) )

		INNER JOIN
		Gabs.bot.questionWork 				AS questionWork
		WITH								( NOLOCK, INDEX( ix_questionWork ) )
		ON	questionQueue.userId			= questionWork.userId
		AND	questionQueue.question			= questionQueue.question
		
	OPTION
		  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



END
GO
