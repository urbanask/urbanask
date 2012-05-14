SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
