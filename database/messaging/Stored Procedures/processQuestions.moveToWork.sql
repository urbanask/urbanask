SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [processQuestions].[moveToWork]
	(
	@workCount		INT
	)
AS
BEGIN

--###
--processQuestions.moveToWork
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @workCount;



IF NOT EXISTS
(

	SELECT
		questionWork.questionWorkId
		
	FROM
		Messaging.questions.questionWork	AS questionWork
		WITH								(NOLOCK, INDEX(pk_questionWork))
			
)
BEGIN



	INSERT INTO
		Messaging.questions.questionWork	
		(
		questionWork.questionWorkId,
		questionWork.[message],
		questionWork.[timestamp]
		)
	    
	SELECT
		questionQueue.questionQueueID		AS questionWorkId,
		questionQueue.[message]				AS [message],
		questionQueue.[timestamp]			AS [timestamp]
		
	FROM
		Messaging.questions.questionQueue	AS questionQueue
		WITH								(NOLOCK, INDEX(ix_questionQueue))

	ORDER BY
		questionQueue.[timestamp]			ASC
		
	OPTION
		  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



	DELETE 
		Messaging.questions.questionQueue	
		
	FROM
		Messaging.questions.questionQueue	AS questionQueue
		WITH								(NOLOCK, INDEX(pk_questionQueue))

		INNER JOIN
		Messaging.questions.questionWork	AS questionWork
		WITH								(NOLOCK, INDEX(pk_questionWork))
		ON	questionQueue.questionQueueId	= questionWork.questionWorkId
		
	OPTION
		  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



END



END
GO
