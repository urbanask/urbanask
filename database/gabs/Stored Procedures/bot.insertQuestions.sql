
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [bot].[insertQuestions]

AS

--###
--bot.insertQuestions
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Messaging.questions.questionQueue	
	(
	[message]
	)
    
SELECT
	CAST( questionWork.userId AS VARCHAR )
	+ '~' + CAST( questionWork.latitude AS VARCHAR )
	+ '~' + CAST( questionWork.longitude AS VARCHAR )
	+ '~' + questionWork.region							
	+ '~' + questionWork.question						AS message
	
FROM
	Gabs.bot.questionWork								AS questionWork
	WITH												( NOLOCK, INDEX( ix_questionWork ) )
	
	

DELETE FROM
	Gabs.bot.questionWork	

GO
