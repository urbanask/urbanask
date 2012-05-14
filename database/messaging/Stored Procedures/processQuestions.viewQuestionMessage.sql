SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [processQuestions].[viewQuestionMessage]
AS
BEGIN

--###
--processQuestions.viewQuestionMessage
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	questionWork.questionWorkId				AS questionId,
	questionWork.[message]					AS [message],
	questionWork.timestamp					AS timestamp
	
FROM
	Messaging.questions.questionWork		AS questionWork
	WITH									(NOLOCK, INDEX(ix_questionWork))

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



END
GO
