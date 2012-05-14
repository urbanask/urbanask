SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@userId				AS ForeignKey=1
--DECLARE	@count				AS INT=25
--DECLARE	@expirationDays		AS INT = 1

CREATE PROCEDURE [api].[loadQuestionsByUser]
	(
	@userId				AS PrimaryKey,
	@count				AS INT,
	@expirationDays		AS INT
	)
AS

--###
--api.loadQuestionsByUser
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @questions	TABLE
	(
	questionId		ForeignKey PRIMARY KEY,
	username		VARCHAR(100),
	reputation		INT,
	question		VARCHAR(50),
	link			VARCHAR(256),
	latitude		DECIMAL(9,7),
	longitude		DECIMAL(10,7),
	timestamp		DATETIME2,
	bounty			INT,
	votes			INT
	)



INSERT INTO	
	@questions
	
SELECT
	question.questionId									AS questionId,
	[user].username										AS username,
	[user].reputation									AS reputation,
	question.question									AS question,
	question.link										AS link,
	question.latitude									AS latitude,
	question.longitude									AS longitude,
	question.timestamp									AS timestamp,
	question.bounty										AS bounty,
	question.votes										AS votes
	
FROM
	Gabs.dbo.[user]										AS [user]
	WITH												( NOLOCK, INDEX( pk_user ) )
	
	INNER JOIN
	Gabs.dbo.question									AS question
	WITH												( NOLOCK, INDEX( ix_question_userId ) )
	ON	[user].userId									= question.userId
	
WHERE
		[user].userId									= @userId
	AND	question.resolved								= 0 --false
	AND DATEDIFF( D, question.timestamp, GETDATE() )	< @expirationDays 
	
ORDER BY
	question.timestamp									DESC

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



SELECT
	questions.questionId								AS questionId,
	@userId												AS userId,
	questions.username									AS username,
	questions.reputation								AS reputation,
	questions.question									AS question,
	questions.link										AS link,
	questions.latitude									AS latitude,
	questions.longitude									AS longitude,
	questions.timestamp									AS timestamp,
	0													AS resolved,
	0													AS expired,
	questions.bounty									AS bounty,
	0													AS voted,
	questions.votes										AS votes,
	COUNT( answer.answerId )							AS answers
	
FROM
	@questions											AS questions
	
	LEFT JOIN
	Gabs.dbo.answer										AS answer
	WITH												( NOLOCK, INDEX( ix_answer_questionId ) )
	ON	questions.questionId							= answer.questionId
	
GROUP BY
	questions.questionId,
	questions.username,
	questions.reputation,
	questions.question,
	questions.link,
	questions.latitude,
	questions.longitude,
	questions.timestamp,
	questions.bounty,
	questions.votes

ORDER BY
	questions.timestamp									DESC

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )	
GO
