SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [processQuestions].[deleteErrorsFromWork]
AS

--###
--[processQuestions].[deleteErrorsFromWork]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DELETE 
	Messaging.questions.questionWork	
	
FROM
	Messaging.questions.questionWork	AS questionWork
	WITH								(NOLOCK, INDEX(pk_questionWork))

	INNER JOIN
	Messaging.questions.questionError	AS questionError
	WITH								(NOLOCK, INDEX(pk_questionError))
	ON	questionWork.questionWorkId		= questionError.questionErrorId
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



GO
