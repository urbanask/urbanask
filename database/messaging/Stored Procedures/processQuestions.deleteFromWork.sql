SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE processQuestions.deleteFromWork
AS
BEGIN

--###
--processQuestions.deleteFromWork
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DELETE 
	Messaging.questions.questionWork	
	
FROM
	Messaging.questions.questionWork	AS questionWork
	WITH								(NOLOCK, INDEX(pk_questionWork))

	INNER JOIN
	Gabs.dbo.question					AS question
	WITH								(NOLOCK, INDEX(pk_question))
	ON	questionWork.questionWorkId		= question.questionId
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



END
GO
