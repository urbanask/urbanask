SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FindText]
(
@text	AS VARCHAR(50)
)
AS

SELECT ROUTINE_NAME, ROUTINE_DEFINITION 
    FROM INFORMATION_SCHEMA.ROUTINES 
    WHERE ROUTINE_DEFINITION LIKE @text 
    AND ROUTINE_TYPE='PROCEDURE'
    
SELECT TABLES.TABLE_NAME, ''
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME LIKE @text 

SELECT COLUMNS.COLUMN_NAME, columns.TABLE_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME LIKE @text 

SELECT CHECK_CONSTRAINTS.CONSTRAINT_NAME, CHECK_CONSTRAINTS.CHECK_CLAUSE 
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CHECK_CLAUSE LIKE @text 

SELECT VIEWS.TABLE_NAME, VIEWS.VIEW_DEFINITION 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE VIEW_DEFINITION LIKE @text 

 

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [messaging].[insertAnswerMessage]
	(
	@message	AS VARCHAR(300),
	@processed	AS BIT			OUTPUT
	)
AS
BEGIN

--###
--messaging.insertAnswerMessage
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



	--###
	--default
	--###
	 
	SELECT @processed = 0;



	INSERT INTO
		Messaging.answers.answerQueue 	
		(
		[message]
		)
	    
	VALUES
		(
		@message
		)



	--###
	--success
	--###
 
	SELECT @processed = 1;
	


END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [messaging].[insertQuestionMessage]
	(
	@message	AS VARCHAR(150),
	@processed	AS BIT			OUTPUT
	)
AS
BEGIN

--###
--[messaging].[insertQuestionMessage]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



	--###
	--default
	--###
	 
	SELECT @processed = 0;



	INSERT INTO
		Messaging.questions.questionQueue	
		(
		[message]
		)
	    
	VALUES
		(
		@message
		)



	--###
	--success
	--###
 
	SELECT @processed = 1;
	


END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [processAnswers].[deleteFromWork]
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [processAnswers].[insertAnswer]
	(
	@answerId			AS PrimaryKey,
	@userId				AS ForeignKey,
	@questionId			AS ForeignKey,
	@locationId			AS VARCHAR(50),
	@location			AS VARCHAR(80),
	@locationAddress	AS VARCHAR(100),
	@latitude			AS DECIMAL(9,7),
	@longitude			AS DECIMAL(10,7),
	@distance			AS INT,
	@reasonId			AS ForeignKey,
	@timestamp			AS DATETIME2
	)
AS

--###
--processAnswers.insertAnswer
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Gabs.dbo.answer
	(
	answerId,
	userId,
	questionId,
	locationId,
	location,
	locationAddress,
	latitude,
	longitude,
	distance,
	reasonId,
	timestamp
	)

VALUES
	(
	@answerId,
	@userId,
	@questionId,
	@locationId,
	@location,
	@locationAddress,
	@latitude,
	@longitude,
	@distance,
	@reasonId,
	@timestamp
	)
	

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [processAnswers].[moveToError]
	(
	@answerId		AS PrimaryKey,
	@message		AS VARCHAR(300),
	@timestamp		AS DATETIME2
	)
AS

--###
--[processAnswers].[moveToError]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Messaging.answers.answerError
	(
	answerError.answerErrorId,
	answerError.[message],
	answerError.[timestamp]
	)

VALUES
	(
	@answerId,
	@message,
	@timestamp
	)
	

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [processAnswers].[moveToWork]
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [processQuestions].[deleteFromWork]
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

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [processQuestions].[insertQuestion]
	(
	@questionId		AS PrimaryKey,
	@userId			AS ForeignKey,
	@latitude		AS DECIMAL(9,7),
	@longitude		AS DECIMAL(10,7),
	@question		AS VARCHAR(50),
	@timestamp		AS DATETIME2
	)
AS

--###
--processQuestions.insertQuestion
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Gabs.dbo.question
	(
	questionId,
	userId,
	latitude,
	longitude,
	question,
	timestamp,
	resolved,
	bounty
	)

VALUES
	(
	@questionId,
	@userId,
	@latitude,
	@longitude,
	@question,
	@timestamp,
	0,
	0
	)
	



GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [processQuestions].[moveToError]
	(
	@questionId		AS PrimaryKey,
	@message		AS VARCHAR(150),
	@timestamp		AS DATETIME2
	)
AS

--###
--processQuestions.moveToError
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Messaging.questions.questionError
	(
	questionError.questionErrorId,
	questionError.[message],
	questionError.[timestamp]
	)

VALUES
	(
	@questionId,
	@message,
	@timestamp
	)
	

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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




