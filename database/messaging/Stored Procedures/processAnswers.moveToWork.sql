SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE processAnswers.moveToWork
	(
	@workCount		INT
	)
AS
BEGIN

--###
--processAnswers.moveToWork
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @workCount;



IF NOT EXISTS
(

	SELECT
		answerWork.answerWorkId 
		
	FROM
		Messaging.answers.answerWork	AS answerWork
		WITH							(NOLOCK, INDEX(pk_answerWork))
			
)
BEGIN



	INSERT INTO
		Messaging.answers.answerWork 	
		(
		answerWork.answerWorkId,
		answerWork.[message],
		answerWork.[timestamp]
		)
	    
	SELECT
		answerQueue.answerQueueId			AS answerWorkId,
		answerQueue.[message]				AS [message],
		answerQueue.[timestamp]				AS [timestamp]
		
	FROM
		Messaging.answers.answerQueue		AS answerQueue
		WITH								(NOLOCK, INDEX(ix_answerQueue))

	ORDER BY
		answerQueue.[timestamp]				ASC
		
	OPTION
		  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



	DELETE 
		Messaging.answers.answerQueue	
		
	FROM
		Messaging.answers.answerQueue		AS answerQueue
		WITH								(NOLOCK, INDEX(pk_answerQueue))

		INNER JOIN
		Messaging.answers.answerWork		AS answerWork
		WITH								(NOLOCK, INDEX(pk_answerWork))
		ON	answerQueue.answerQueueId		= answerWork.answerWorkId
		
	OPTION
		  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



END



END
GO
