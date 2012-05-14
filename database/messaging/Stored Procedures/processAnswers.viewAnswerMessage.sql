SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [processAnswers].[viewAnswerMessage]
AS
BEGIN

--###
--processAnswers.viewAnswerMessage
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	answerWork.answerWorkId					AS answerId,
	answerWork.[message]					AS [message],
	answerWork.timestamp					AS timestamp
	
FROM
	Messaging.answers.answerWork			AS answerWork
	WITH									(NOLOCK, INDEX(ix_answerWork))

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



END
GO
