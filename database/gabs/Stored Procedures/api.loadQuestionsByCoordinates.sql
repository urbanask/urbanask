SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@currentUserId		AS PrimaryKey = 1  
--DECLARE	@fromLatitude		AS DECIMAL(9,7)=37.0000000
--DECLARE	@fromLongitude		AS DECIMAL(10,7)=-122.0000000
--DECLARE	@toLatitude			AS DECIMAL(9,7)=39.0000000
--DECLARE	@toLongitude		AS DECIMAL(10,7)=-120.0000000
--DECLARE	@age				AS DATETIME2='11/27/2011'
--DECLARE	@count				AS INT = 30
--DECLARE	@expirationDays		AS INT = 2

CREATE PROCEDURE [api].[loadQuestionsByCoordinates]
	(
	@currentUserId		AS ForeignKey,
	@fromLatitude		AS DECIMAL(9,7),
	@fromLongitude		AS DECIMAL(10,7),
	@toLatitude			AS DECIMAL(9,7),
	@toLongitude		AS DECIMAL(10,7),
	@age				AS DATETIME2,
	@count				AS INT,
	@expirationDays		AS INT
	)
AS

--###
--api.loadQuestionsByCoordinates
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @questions	TABLE
	(
	questionId		ForeignKey PRIMARY KEY,
	userId			ForeignKey,
	username		VARCHAR(100),
	reputation		INT,
	question		VARCHAR(50),
	link			VARCHAR(256),
	latitude		DECIMAL(9,7),
	longitude		DECIMAL(10,7),
	timestamp		DATETIME2,
	resolved		INT,
	bounty			INT,
	votes			INT
	)



INSERT INTO	
	@questions
	
SELECT
	question.questionId									AS questionId,
	question.userId										AS userId,
	[user].username										AS username,
	[user].reputation									AS reputation,
	question.question									AS question,
	question.link										AS link,
	question.latitude									AS latitude,
	question.longitude									AS longitude,
	question.timestamp									AS timestamp,
	0													AS resolved,
	question.bounty										AS bounty,
	question.votes										AS votes
	
FROM
	Gabs.dbo.question									AS question
	WITH												(NOLOCK, INDEX(ix_question_longitude_latitude))

	INNER JOIN
	Gabs.dbo.[user]										AS [user]
	WITH												(NOLOCK, INDEX(pk_user))
	ON	question.userId									= [user].userId
	
WHERE
		question.latitude								BETWEEN @fromLatitude 
														AND		@toLatitude 
	AND	question.longitude								BETWEEN @fromLongitude
														AND		@toLongitude
	AND	question.userId									<> @currentUserId
	AND	question.timestamp								> @age
	AND	question.resolved								= 0 --false
	AND DATEDIFF( D, question.timestamp, GETDATE() )	< @expirationDays 
	
ORDER BY
	question.timestamp									DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



--no unresolved, try resolved

IF NOT EXISTS
	(
	SELECT
		questions.questionId	AS questionId
		
	FROM
		@questions				AS questions
	)
BEGIN



	INSERT INTO	
		@questions
		
	SELECT
		question.questionId									AS questionId,
		question.userId										AS userId,
		[user].username										AS username,
		[user].reputation									AS reputation,
		question.question									AS question,
		question.link										AS link,
		question.latitude									AS latitude,
		question.longitude									AS longitude,
		question.timestamp									AS timestamp,
		1													AS resolved,
		question.bounty										AS bounty,
		question.votes										AS votes
		
	FROM
		Gabs.dbo.question									AS question
		WITH												(NOLOCK, INDEX(ix_question_longitude_latitude))

		INNER JOIN
		Gabs.dbo.[user]										AS [user]
		WITH												(NOLOCK, INDEX(pk_user))
		ON	question.userId									= [user].userId
		
	WHERE
			question.latitude								BETWEEN @fromLatitude 
															AND		@toLatitude 
		AND	question.longitude								BETWEEN @fromLongitude
															AND		@toLongitude
		AND question.userId									<> @currentUserId
		AND	question.timestamp								> @age
		AND	question.resolved								= 1 --true
		AND DATEDIFF( D, question.timestamp, GETDATE() )	< @expirationDays 
		
	ORDER BY
		question.timestamp									DESC

	OPTION
		  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



END


	
SELECT
	questions.questionId					AS questionId,
	questions.userId						AS userId,
	questions.username						AS username,
	questions.reputation					AS reputation,
	questions.question						AS question,
	questions.link							AS link,
	questions.latitude						AS latitude,
	questions.longitude						AS longitude,
	questions.timestamp						AS timestamp,
	questions.resolved						AS resolved,
	0										AS expired,
	questions.bounty						AS bounty,
	CASE 
	WHEN COUNT(questionVote.questionVoteId) > 0
	THEN 1
	ELSE 0
	END										AS voted,
	questions.votes							AS votes,
	COUNT( answer.answerId )				AS answers
	
FROM
	@questions								AS questions
	
	LEFT JOIN
	Gabs.dbo.answer							AS answer
	WITH									( NOLOCK, INDEX( ix_answer_questionId ) )
	ON	questions.questionId				= answer.questionId
	
	LEFT JOIN
	Gabs.dbo.questionVote					AS questionVote
	WITH									( NOLOCK, INDEX( ix_questionVote_questionId ) )
	ON	questions.questionId				= questionVote.questionId
	AND	questionVote.userId					= @currentUserId

GROUP BY
	questions.questionId,
	questions.userId,
	questions.username,
	questions.reputation,
	questions.question,
	questions.link,
	questions.latitude,
	questions.longitude,
	questions.timestamp,
	questions.resolved,
	questions.bounty,
	questions.votes

ORDER BY
	COUNT( answer.answerId )				ASC,
	questions.votes							DESC,
	questions.bounty						DESC,
	questions.timestamp						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	


GO
