SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [processAnswers].[insertAnswer]
	(
	@answerId			AS PrimaryKey,
	@userId				AS ForeignKey,
	@questionId			AS ForeignKey,
	@locationId			AS VARCHAR(50),
	@reference			AS VARCHAR(300),
	@location			AS VARCHAR(80),
	@locationAddress	AS VARCHAR(100),
	@note				AS VARCHAR(40),
	@link				AS VARCHAR(256),
	@phone				AS VARCHAR(50),
	@latitude			AS DECIMAL(9,7),
	@longitude			AS DECIMAL(10,7),
	@distance			AS INT,
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
	reference,
	location,
	locationAddress,
	note,
	link,
	phone,
	latitude,
	longitude,
	distance,
	timestamp
	)

VALUES
	(
	@answerId,
	@userId,
	@questionId,
	@locationId,
	@reference,
	@location,
	@locationAddress,
	@note,
	@link,
	@phone,
	@latitude,
	@longitude,
	@distance,
	@timestamp
	)
	


DECLARE @questionUserId INT

SELECT
	@questionUserId			= question.userId
	
FROM
	Gabs.dbo.question		AS question
	WITH					( NOLOCK, INDEX( pk_question ) )
	
WHERE
	question.questionId		= @questionId

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	Gabs.dbo.userNotification
	(
	userId,
	notificationId,
	objectTypeId,
	itemId,
	timestamp
	)
VALUES
	(
	@questionUserId,
	1, --new answer
	1, --question
	@questionId,
	@timestamp
	)
GO
