SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@userId				AS ForeignKey=1
--DECLARE	@count				AS INT=25
--DECLARE	@age				AS DATETIME2='11/20/2011'
--DECLARE	@expirationDays		AS INT = 5

CREATE PROCEDURE [api].[_loadQuestionsByUserLocation]
	(
	@userId				AS ForeignKey,
	@age				AS DATETIME2,
	@count				AS INT,
	@expirationDays		AS INT
	)
AS

--###
--api.loadQuestionsByUserLocation
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE	@fromLatitude		AS DECIMAL(9,7) 
DECLARE	@fromLongitude		AS DECIMAL(10,7) 
DECLARE	@toLatitude			AS DECIMAL(9,7) 
DECLARE	@toLongitude		AS DECIMAL(10,7) 
DECLARE @questions			TABLE
	(
	questionId				ForeignKey PRIMARY KEY,
	userId					ForeignKey,
	username				VARCHAR(100),
	reputation				INT,
	question				VARCHAR(50),
	link					VARCHAR(256),
	latitude				DECIMAL(9,7),
	longitude				DECIMAL(10,7),
	timestamp				DATETIME2,
	resolved				INT,
	bounty					INT,
	votes					INT
	)



SELECT
	@fromLatitude						= userLocation.fromLatitude,
	@fromLongitude						= userLocation.fromLongitude,
	@toLatitude							= userLocation.toLatitude,
	@toLongitude						= userLocation.toLongitude
	
FROM
	Gabs.dbo.userLocation				userLocation
	WITH								( NOLOCK, INDEX( ix_userLocation_userId ) )

WHERE
		userLocation.userId				= @userId
		 
OPTION
	(FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO	
	@questions
	
SELECT
	question.questionId						AS questionId,
	question.userId							AS userId,
	[user].username							AS username,
	[user].reputation						AS reputation,
	question.question						AS question,
	question.link							AS link,
	question.latitude						AS latitude,
	question.longitude						AS longitude,
	question.timestamp						AS timestamp,
	question.resolved						AS resolved,
	question.bounty							AS bounty,
	question.votes							AS votes
	
FROM
	Gabs.dbo.question						AS question
	WITH									(NOLOCK, INDEX(ix_question_longitude_latitude))

	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									(NOLOCK, INDEX(pk_user))
	ON	question.userId						= [user].userId
	
WHERE
		question.latitude					BETWEEN @fromLatitude 
											AND		@toLatitude 
	AND	question.longitude					BETWEEN @fromLongitude
											AND		@toLongitude
	AND	question.timestamp					> @age

ORDER BY
	question.resolved						ASC,
	question.timestamp						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT
	questions.questionId					AS questionId,
	questions.userId						AS userId,
	questions.username						AS username,
	questions.question						AS question,
	questions.reputation					AS reputation,
	questions.link							AS link,
	questions.latitude						AS latitude,
	questions.longitude						AS longitude,
	questions.timestamp						AS timestamp,
	questions.resolved						AS resolved,
	CASE 
	WHEN DATEDIFF( D, questions.timestamp, GETDATE() ) >= @expirationDays 
	AND questions.resolved = 0 --false
	THEN 1 --true
	ELSE 0 --false
	END										AS expired,
	questions.bounty						AS bounty,
	CASE 
	WHEN COUNT( questionVote.questionVoteId ) > 0
	THEN 1
	ELSE 0
	END										AS voted,
	questions.votes							AS votes,
	COUNT( answer.answerId )				AS answers
	
FROM
	@questions								AS questions
	
	LEFT JOIN
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_questionId))
	ON	questions.questionId				= answer.questionId
	
	LEFT JOIN
	Gabs.dbo.questionVote					AS questionVote
	WITH									( NOLOCK, INDEX( ix_questionVote_questionId ) )
	ON	questions.questionId				= questionVote.questionId
	AND	questionVote.userId					= @userId

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
