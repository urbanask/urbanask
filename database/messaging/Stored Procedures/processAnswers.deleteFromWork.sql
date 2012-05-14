SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE processAnswers.deleteFromWork
AS
BEGIN

--###
--processAnswers.deleteFromWork
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DELETE 
	Messaging.answers.answerWork 	
	
FROM
	Messaging.answers.answerWork		AS answerWork
	WITH								(NOLOCK, INDEX(pk_answerWork))

	INNER JOIN
	Gabs.dbo.answer						AS answer
	WITH								(NOLOCK, INDEX(pk_answer))
	ON	answerWork.answerWorkId			= answer.answerId
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



END
GO
