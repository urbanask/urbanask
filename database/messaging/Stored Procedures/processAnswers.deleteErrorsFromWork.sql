SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [processAnswers].[deleteErrorsFromWork]
AS

--###
--[processAnswers].[deleteErrorsFromWork]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DELETE 
	Messaging.answers.answerWork	
	
FROM
	Messaging.answers.answerWork		AS answerWork
	WITH								(NOLOCK, INDEX(pk_answerWork))

	INNER JOIN
	Messaging.answers.answerError		AS answerError
	WITH								(NOLOCK, INDEX(pk_answerError))
	ON	answerWork.answerWorkId			= answerError.answerErrorId
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



GO
