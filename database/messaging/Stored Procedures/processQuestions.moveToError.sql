SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
