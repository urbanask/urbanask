SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @userId				AS PrimaryKey = 1
--DECLARE @currentUserId		AS PrimaryKey = 1
--DECLARE @count				AS INT = 10
--DECLARE @expirationDays		AS INT = 2

CREATE PROCEDURE [api].[loadUser]
	(
	@currentUserId		AS PrimaryKey,
	@userId				AS PrimaryKey,
	@count				AS INT,
	@expirationDays		AS INT
	)
AS

--###
--api.loadUser
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



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
DECLARE @answers		TABLE
	(
	answerId			ForeignKey PRIMARY KEY,
	questionId			ForeignKey,
	userId				ForeignKey,
	username			VARCHAR(100),
	reputation			INT,
	locationId			VARCHAR(50),
	location			VARCHAR(80),
	locationAddress		VARCHAR(100),
	note				VARCHAR(40),
	link				VARCHAR(256),
	phone				VARCHAR(50),
	latitude			DECIMAL(9,7),
	longitude			DECIMAL(10,7),
	distance			INT,
	timestamp			DATETIME2,
	selected			INT,
	votes				INT
	)
DECLARE @reputation		TABLE
	(
	reputationId		PrimaryKey PRIMARY KEY,
	reputationAction	VARCHAR(50),
	questionId			ForeignKey,
	question			VARCHAR(50),
	reputation			INT,
	timestamp			DATETIME2
	)
DECLARE @notifications	TABLE
	(
	notification		VARCHAR(50),
	objectType			VARCHAR(50),
	itemId				ForeignKey,
	objectDescription	VARCHAR(50),
	viewed				INT,
	timestamp			DATETIME2
	)
DECLARE @totalQuestions	INT
DECLARE @totalAnswers	INT
DECLARE @totalBadges	INT



SELECT
	@totalQuestions			= COUNT(*)

FROM
	Gabs.dbo.question		AS question

WHERE
	question.userId			= @userId
	
	
	
SELECT
	@totalAnswers			= COUNT(*)

FROM
	Gabs.dbo.answer			AS answer

WHERE
	answer.userId			= @userId
	
	
	
SELECT
	@totalBadges			= COUNT(*)

FROM
	Gabs.dbo.userBadge		AS userBadge

WHERE
	userBadge.userId		= @userId
	
	
	
SELECT
	[user].userId						AS userId,
	[user].username						AS username,
	[user].displayName					AS displayName,
	[user].reputation					AS reputation,
	[user].signupDate					AS signupDate,
	[user].tagline						AS tagline,
	@totalQuestions						AS totalQuestions,
	@totalAnswers						AS totalAnswers,
	@totalBadges						AS totalBadges
	
FROM
	Gabs.dbo.[user]						AS [user]
	WITH								( NOLOCK, INDEX( pk_user ) )
	
WHERE
	[user].userId						= @userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT
	badge.badgeClassId				AS badgeClassId,
	badge.name						AS badge,
	badge.description				AS description,
	badge.unlimited					AS unlimited,
	COUNT( userBadge.userBadgeId )	AS badges

FROM
	Gabs.lookup.badge				AS badge
	WITH							( INDEX( pk_badge ), NOLOCK )

	INNER JOIN
	Gabs.lookup.badgeClass			AS badgeClass
	WITH							( INDEX( pk_badgeClass ), NOLOCK )
	ON	badge.badgeClassId			= badgeClass.badgeClassId

	LEFT JOIN
	Gabs.dbo.userBadge				AS userBadge
	WITH							( INDEX( ix_userBadge_userId ), NOLOCK )
	ON	badge.badgeId				= userBadge.badgeId
	AND	userBadge.userId			= @userId

GROUP BY
	badge.badgeClassId,
	badge.name,
	badge.description,
	badge.unlimited,
	badgeClass.[order]

ORDER BY
	badgeClass.[order]				DESC,
	badge.name						ASC
	
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



SET ROWCOUNT @count;



INSERT INTO	
	@questions
	
SELECT
	question.questionId					AS questionId,
	question.userId						AS userId,
	[user].username						AS username,
	[user].reputation					AS reputation,
	question.question					AS question,
	question.link						AS link,
	question.latitude					AS latitude,
	question.longitude					AS longitude,
	question.timestamp					AS timestamp,
	question.resolved					AS resolved,
	question.bounty						AS bounty,
	question.votes						AS votes
	
FROM
	Gabs.dbo.[user]						AS [user]
	WITH								( NOLOCK, INDEX( pk_user ) )
	
	INNER JOIN
	Gabs.dbo.question					AS question
	WITH								( NOLOCK, INDEX( ix_question_userId ) )
	ON	[user].userId					= question.userId
	
WHERE
		[user].userId					= @userId
		
ORDER BY
	question.timestamp					DESC
		
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SET ROWCOUNT 0;



/* my unresolved questions */

IF @currentUserId = @userId
BEGIN



	INSERT INTO	
		@questions
		
	SELECT DISTINCT
		question.questionId					AS questionId,
		question.userId						AS userId,
		[user].username						AS username,
		[user].reputation					AS reputation,
		question.question					AS question,
		question.link						AS link,
		question.latitude					AS latitude,
		question.longitude					AS longitude,
		question.timestamp					AS timestamp,
		question.resolved					AS resolved,
		question.bounty						AS bounty,
		question.votes						AS votes
		
	FROM
		Gabs.dbo.[user]						AS [user]
		WITH								( NOLOCK, INDEX( pk_user ) )
		
		INNER JOIN
		Gabs.dbo.question					AS question
		WITH								( NOLOCK, INDEX( ix_question_userId ) )
		ON	[user].userId					= question.userId
		
		INNER JOIN
		Gabs.dbo.answer						AS answer
		WITH								( NOLOCK, INDEX( ix_answer_questionId ) )
		ON	question.questionId				= answer.questionId
		
		LEFT JOIN
		@questions							AS questions
		ON	question.questionId				= questions.questionId

	WHERE
			[user].userId					= @userId
		AND question.resolved				= 0 --false
		AND	questions.questionId			IS NULL --not already there

	ORDER BY
		question.timestamp					DESC
			
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
	CASE 
	WHEN DATEDIFF( D, questions.timestamp, GETDATE() ) 
		>= @expirationDays 
	THEN 1 
	ELSE 0 
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
	questions.timestamp						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



SET ROWCOUNT @count;



SELECT
	answer.answerId							AS answerId,
	answer.questionId						AS questionId,
	answer.userId							AS userId,
	[user].username							AS username,
	[user].reputation						AS reputation,
	answer.locationId						AS locationId,
	answer.location							AS location,
	answer.locationAddress					AS locationAddress,
	answer.note								AS note,
	answer.link								AS link,
	answer.phone							AS phone,
	answer.latitude							AS latitude,
	answer.longitude						AS longitude,
	answer.distance							AS distance,
	answer.timestamp						AS timestamp,
	answer.selected							AS selected,
	ISNULL( answerVote.vote, 0 )			AS voted,
	answer.votes							AS votes
	
FROM
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_userId))

	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									(NOLOCK, INDEX(pk_user))
	ON	answer.userId						= [user].userId
	
	LEFT JOIN
	Gabs.dbo.answerVote						AS answerVote
	WITH									(NOLOCK, INDEX(ix_answerVote_answerId))
	ON	answer.answerId						= answerVote.answerId
	AND answerVote.userId					= @currentUserId

WHERE
		answer.userId						= @userId
	
ORDER BY
		answer.timestamp					DESC
		
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



/* question reputation */

INSERT INTO
	@reputation

SELECT
	reputation.reputationId					AS reputationId,
	reputationAction.name					AS reputationAction,
	reputation.itemId						AS questionId,
	question.question						AS question,
	reputation.reputation					AS reputation,
	reputation.timestamp					AS timestamp

FROM
	Gabs.dbo.reputation						AS reputation
	WITH									(INDEX(ix_reputation_userId), NOLOCK)

	INNER JOIN
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(INDEX(pk_reputationAction), NOLOCK)
	ON	reputation.reputationActionId		= reputationAction.reputationActionId
	AND	reputationAction.object				= 'question'

	INNER JOIN
	Gabs.dbo.question						AS question
	WITH									(INDEX(pk_question), NOLOCK)
	ON	reputation.itemId					= question.questionId

WHERE
		reputation.userId					= @userId

ORDER BY
		reputation.timestamp				DESC
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



/* answer reputation */

INSERT INTO
	@reputation

SELECT
	reputation.reputationId					AS reputationId,
	reputationAction.name					AS reputationAction,
	answer.questionId						AS questionId,
	question.question						AS question,
	reputation.reputation					AS reputation,
	reputation.timestamp					AS timestamp

FROM
	Gabs.dbo.reputation						AS reputation
	WITH									(INDEX(ix_reputation_userId), NOLOCK)

	INNER JOIN
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(INDEX(pk_reputationAction), NOLOCK)
	ON	reputation.reputationActionId		= reputationAction.reputationActionId
	AND	reputationAction.object				= 'answer'

	INNER JOIN
	Gabs.dbo.answer							AS answer
	WITH									(INDEX(pk_answer), NOLOCK)
	ON	reputation.itemId					= answer.answerId

	INNER JOIN
	Gabs.dbo.question						AS question
	WITH									(INDEX(pk_question), NOLOCK)
	ON	answer.questionId					= question.questionId

WHERE
		reputation.userId					=	@userId
	AND reputation.reputationActionId		<>  CASE WHEN @userId = @currentUserId THEN 0 ELSE 12 END -- downvoted answer
		
ORDER BY
		reputation.timestamp				DESC
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT
	reputation.reputationId			AS reputationId,
	reputation.reputationAction		AS reputationAction,
	reputation.questionId			AS questionId,
	reputation.question				AS question,
	reputation.reputation			AS reputation,
	reputation.timestamp			AS timestamp

FROM
	@reputation						AS reputation

ORDER BY
		reputation.timestamp		DESC
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SET ROWCOUNT 0



GO
