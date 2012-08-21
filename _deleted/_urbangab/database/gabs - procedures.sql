SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


--DECLARE @userId			AS PrimaryKey = 2

CREATE PROCEDURE [api].[loadAccount]
	(
	@userId			AS PrimaryKey
	)
AS

--###
--[api].[loadAccount]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	[user].userId							AS userId,
	[user].username							AS username,
	[user].displayName						AS displayName,
	[user].reputation						AS reputation,
	[user].metricDistances					AS metricDistances
	
FROM
	Gabs.dbo.[user]							AS [user]
	WITH									(NOLOCK, INDEX(pk_user))
	
WHERE
	[user].userId							= @userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT
	userLocation.userId						AS userId,
	userLocation.fromLatitude				AS fromLatitude,
	userLocation.fromLongitude				AS fromLongitude,
	userLocation.toLatitude					AS toLatitude,
	userLocation.toLongitude				AS toLongitude
	
FROM
	Gabs.dbo.userLocation					AS userLocation
	WITH									(NOLOCK, INDEX(ix_userLocation_userId))
	
WHERE
	userLocation.userId						= @userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)





GO


SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

--DECLARE @questionId			AS PrimaryKey = 1104484
--DECLARE @userId				AS ForeignKey = 1
--DECLARE	@expirationDays		AS INT = 2

CREATE PROCEDURE [api].[loadQuestion]
	(
	@questionId			AS PrimaryKey,
	@userId				AS ForeignKey,
	@expirationDays		AS INT
	)
AS

--###
--api.loadQuestion
--###
 
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
	bounty			INT
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
	latitude			DECIMAL(9,7),
	longitude			DECIMAL(10,7),
	distance			INT,
	reasonId			ForeignKey,
	timestamp			DATETIME2,
	selected			INT,
	votes				INT
	)



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
	question.bounty							AS bounty
	
FROM
	Gabs.dbo.question						AS question
	WITH									(NOLOCK, INDEX(pk_question))
	
	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									(NOLOCK, INDEX(pk_user))
	ON	question.userId						= [user].userId
	
WHERE
		question.questionId					= @questionId
		
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



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
	WHEN DATEDIFF( D, questions.timestamp, GETDATE() ) >= @expirationDays 
	AND questions.resolved = 0 --false
	THEN 1 --true
	ELSE 0 --false
	END										AS expired,
	questions.bounty						AS bounty,
	COUNT( answer.answerId )				AS answers
	
FROM
	@questions								AS questions
	
	LEFT JOIN
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_questionId))
	ON	questions.questionId				= answer.questionId
	
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
	questions.bounty

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



INSERT INTO	
	@answers
	
SELECT
	answer.answerId							AS answerId,
	answer.questionId						AS questionId,
	answer.userId							AS userId,
	[user].username							AS username,
	[user].reputation						AS reputation,
	answer.locationId						AS locationId,
	answer.location							AS location,
	answer.locationAddress					AS locationAddress,
	answer.latitude							AS latitude,
	answer.longitude						AS longitude,
	answer.distance							AS distance,
	answer.reasonId							AS reasonId,
	answer.timestamp						AS timestamp,
	answer.selected							AS selected,
	answer.votes							AS votes
	
FROM
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_questionId))

	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									(NOLOCK, INDEX(pk_user))
	ON	answer.userId						= [user].userId
	
WHERE
		answer.questionId					= @questionId 
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT
	answers.answerId						AS answerId,
	answers.questionId						AS questionId,
	answers.userId							AS userId,
	answers.username						AS username,
	answers.reputation						AS reputation,
	answers.locationId						AS locationId,
	answers.location						AS location,
	answers.locationAddress					AS locationAddress,
	answers.latitude						AS latitude,
	answers.longitude						AS longitude,
	answers.distance						AS distance,
	answers.reasonId						AS reasonId,
	answers.timestamp						AS timestamp,
	answers.selected						AS selected,
	CASE 
	WHEN COUNT(answerVote.answerVoteId) > 0
	THEN 1
	ELSE 0
	END										AS voted,
	answers.votes							AS votes
	
FROM
	@answers								AS answers

	LEFT JOIN
	Gabs.dbo.answerVote						AS answerVote
	WITH									(NOLOCK, INDEX(ix_answerVote_answerId))
	ON	answers.answerId					= answerVote.answerId
	AND answerVote.userId					= @userId

GROUP BY
	answers.answerId,
	answers.questionId,
	answers.userId,
	answers.username,
	answers.reputation,
	answers.locationId,
	answers.location,
	answers.locationAddress,
	answers.latitude,
	answers.longitude,
	answers.distance,
	answers.reasonId,
	answers.timestamp,
	answers.selected,
	answers.votes

ORDER BY
	answers.selected						DESC,
	answers.votes							DESC,
	answers.distance						ASC,
	answers.timestamp						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
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
	bounty			INT
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
	question.bounty										AS bounty
	
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
	


--no unresolve, try resolved

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
		question.bounty										AS bounty
		
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
	COUNT( answer.answerId )				AS answers
	
FROM
	@questions								AS questions
	
	LEFT JOIN
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_questionId))
	ON	questions.questionId				= answer.questionId
	
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
	questions.bounty

ORDER BY
	COUNT( answer.answerId )				ASC,
	questions.bounty						DESC,
	questions.timestamp						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
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
	bounty			INT
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
	question.bounty										AS bounty
	
FROM
	Gabs.dbo.[user]										AS [user]
	WITH												(NOLOCK, INDEX(pk_user))
	
	INNER JOIN
	Gabs.dbo.question									AS question
	WITH												(NOLOCK, INDEX(ix_question_userId))
	ON	[user].userId									= question.userId
	
WHERE
		[user].userId									= @userId
	AND	question.resolved								= 0 --false
	AND DATEDIFF( D, question.timestamp, GETDATE() )	< @expirationDays 
	
ORDER BY
	question.timestamp									DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



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
	COUNT( answer.answerId )							AS answers
	
FROM
	@questions											AS questions
	
	LEFT JOIN
	Gabs.dbo.answer										AS answer
	WITH												(NOLOCK, INDEX(ix_answer_questionId))
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
	questions.bounty

ORDER BY
	questions.timestamp									DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@userId				AS ForeignKey=1
--DECLARE	@count				AS INT=25
--DECLARE	@age				AS DATETIME2='11/20/2011'
--DECLARE	@expirationDays		AS INT = 5

CREATE PROCEDURE [api].[loadQuestionsByUserLocation]
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
	bounty					INT
	)



SELECT
	@fromLatitude						= userLocation.fromLatitude,
	@fromLongitude						= userLocation.fromLongitude,
	@toLatitude							= userLocation.toLatitude,
	@toLongitude						= userLocation.toLongitude
	
FROM
	Gabs.dbo.userLocation				userLocation
	WITH								(NOLOCK, INDEX(ix_userLocation_userId))

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
	question.bounty							AS bounty
	
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
	COUNT( answer.answerId )				AS answers
	
FROM
	@questions								AS questions
	
	LEFT JOIN
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_questionId))
	ON	questions.questionId				= answer.questionId
	
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
	questions.bounty

ORDER BY
	CASE 
	WHEN DATEDIFF( D, questions.timestamp, GETDATE() ) >= @expirationDays 
	AND questions.resolved = 0 --false
	THEN 1 --true
	ELSE 0 --false
	END										ASC,
	questions.resolved						ASC,
	COUNT( answer.answerId )				ASC,
	questions.timestamp						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	





GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [api].[loadReputationActions]

AS

--###
--[api].[loadReputationActions]
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	reputationAction.reputationActionId		AS id,
	reputationAction.name					AS name,
	reputationAction.reputation				AS reputation

FROM
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(INDEX(pk_reputationAction), NOLOCK)

OPTION
	(FORCE ORDER, LOOP JOIN, MAXDOP 1)
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @regionId		AS INT = 1 --sacramento

CREATE PROCEDURE [api].[loadTopUsers]
	(
	@regionId		AS ForeignKey
	)
AS

--###
--[api].[loadTopUsers]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT	
	topUser.regionId						AS regionId,
	topUser.topTypeId						AS topTypeId,
	topUser.intervalId						AS intervalId,
	topUser.userId							AS userId,
	topUser.username						AS username,
	topUser.reputation						AS reputation,
	topUser.totalQuestions					AS totalQuestions,
	topUser.totalAnswers					AS totalAnswers,
	topUser.totalBadges						AS totalBadges,
	topUser.topScore						AS topScore
	
FROM
	Gabs.[top].topUser						AS topUser
	WITH									( NOLOCK, INDEX(ix_topUser_regionId) )

WHERE
		topUser.regionId					= @regionId

ORDER BY
	topUser.topTypeId						ASC,
	topUser.intervalId						ASC,
	topUser.topScore						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @userId			AS PrimaryKey = 1
--DECLARE @currentUserId	AS PrimaryKey = 43
--DECLARE	@count				AS INT = 10
--DECLARE	@expirationDays		AS INT = 2

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
	bounty			INT
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
	latitude			DECIMAL(9,7),
	longitude			DECIMAL(10,7),
	distance			INT,
	reasonId			ForeignKey,
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
	@totalQuestions						AS totalQuestions,
	@totalAnswers						AS totalAnswers,
	@totalBadges						AS totalBadges
	
FROM
	Gabs.dbo.[user]						AS [user]
	WITH								(NOLOCK, INDEX(pk_user))
	
WHERE
	[user].userId						= @userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



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
	question.bounty						AS bounty
	
FROM
	Gabs.dbo.[user]						AS [user]
	WITH								(NOLOCK, INDEX(pk_user))
	
	INNER JOIN
	Gabs.dbo.question					AS question
	WITH								(NOLOCK, INDEX(ix_question_userId))
	ON	[user].userId					= question.userId
	
WHERE
		[user].userId					= @userId
		
ORDER BY
	question.timestamp					DESC
		
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



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
	COUNT( answer.answerId )				AS answers
	
FROM
	@questions								AS questions
	
	LEFT JOIN
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_questionId))
	ON	questions.questionId				= answer.questionId
	
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
	questions.bounty

ORDER BY
	questions.timestamp						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



INSERT INTO	
	@answers
	
SELECT
	answer.answerId							AS answerId,
	answer.questionId						AS questionId,
	answer.userId							AS userId,
	[user].username							AS username,
	[user].reputation						AS reputation,
	answer.locationId						AS locationId,
	answer.location							AS location,
	answer.locationAddress					AS locationAddress,
	answer.latitude							AS latitude,
	answer.longitude						AS longitude,
	answer.distance							AS distance,
	answer.reasonId							AS reasonId,
	answer.timestamp						AS timestamp,
	answer.selected							AS selected,
	answer.votes							AS votes
	
FROM
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_userId))

	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									(NOLOCK, INDEX(pk_user))
	ON	answer.userId						= [user].userId
	
WHERE
		answer.userId						= @userId
	
ORDER BY
		answer.timestamp					DESC
		
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT
	answers.answerId						AS answerId,
	answers.questionId						AS questionId,
	answers.userId							AS userId,
	answers.username						AS username,
	answers.reputation						AS reputation,
	answers.locationId						AS locationId,
	answers.location						AS location,
	answers.locationAddress					AS locationAddress,
	answers.latitude						AS latitude,
	answers.longitude						AS longitude,
	answers.distance						AS distance,
	answers.reasonId						AS reasonId,
	answers.timestamp						AS timestamp,
	answers.selected						AS selected,
	CASE 
	WHEN COUNT(answerVote.answerVoteId) > 0
	THEN 1
	ELSE 0
	END										AS voted,
	answers.votes							AS votes
	
FROM
	@answers								AS answers

	LEFT JOIN
	Gabs.dbo.answerVote						AS answerVote
	WITH									(NOLOCK, INDEX(ix_answerVote_answerId))
	ON	answers.answerId					= answerVote.answerId
	AND answerVote.userId					= @currentUserId

GROUP BY
	answers.answerId,
	answers.questionId,
	answers.userId,
	answers.username,
	answers.reputation,
	answers.locationId,
	answers.location,
	answers.locationAddress,
	answers.latitude,
	answers.longitude,
	answers.distance,
	answers.reasonId,
	answers.timestamp,
	answers.selected,
	answers.votes

ORDER BY
		answers.timestamp					DESC
		
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT
	badge.badgeClassId			AS badgeClassId,
	badge.name					AS badge,
	badge.description			AS description,
	badge.unlimited				AS unlimited,
	COUNT(*)					AS badges

FROM
	Gabs.dbo.userBadge			AS userBadge
	WITH						(INDEX(ix_userBadge_userId), NOLOCK)

	INNER JOIN
	Gabs.lookup.badge			AS badge
	WITH						(INDEX(pk_badge), NOLOCK)
	ON	userBadge.badgeId		= badge.badgeId

WHERE
		userBadge.userId		= @userId

GROUP BY
	badge.badgeClassId,
	badge.name,
	badge.description,
	badge.unlimited

ORDER BY
	badge.badgeClassId		DESC,
	badge.name				ASC
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



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
		reputation.userId					= @userId
	
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

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

--DECLARE @userId			AS PrimaryKey = 1

CREATE PROCEDURE [api].[loadUserPicture] (

	@userId			AS PrimaryKey

)
AS

--###
--api.loadUserPicture
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



IF EXISTS( 

	SELECT
		[userPicture].userId			AS userId
		
	FROM
		Gabs.dbo.[userPicture]			AS [userPicture]
		WITH							(NOLOCK, INDEX(ix_userPicture_userId))
		
	WHERE
		[userPicture].userId			= @userId
		
)
BEGIN



	SELECT
		[userPicture].picture			AS picture
		
	FROM
		Gabs.dbo.[userPicture]			AS [userPicture]
		WITH							(NOLOCK, INDEX(ix_userPicture_userId))
		
	WHERE
		[userPicture].userId			= @userId



END
ELSE
BEGIN



	SELECT
		[userPictureDefault].picture	AS picture
		
	FROM
		Gabs.dbo.[userPictureDefault]	AS [userPictureDefault]
		WITH							(NOLOCK, INDEX(pk_userPictureDefault))
		


END

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--DECLARE	@latitude		AS DECIMAL(9,7)=38
--DECLARE	@longitude		AS DECIMAL(10,7)=-121	
--DECLARE	@count			AS INT=24

CREATE PROCEDURE [api].[loadUsersByCoordinates]
	(
	@latitude		AS DECIMAL(9,7),
	@longitude		AS DECIMAL(10,7),
	@count			AS INT
	)
AS

--###
--api.loadUsersByCoordinates
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @users			TABLE
	(
	userId				PrimaryKey PRIMARY KEY,
	username			VARCHAR(100),
	displayName			VARCHAR(100),
	reputation			INT,
	signupDate			DATETIME2
	)



INSERT INTO	
	@users
	
SELECT
	[user].userId							AS userId,
	[user].username							AS username,
	[user].displayName						AS displayName,
	[user].reputation						AS reputation,
	[user].signupDate						AS signupDate
	
FROM
	Gabs.dbo.userLocation					userLocation
	WITH									(NOLOCK, INDEX(ix_userLocation_bounds))
	
	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									(NOLOCK, INDEX(pk_user))
	ON	userLocation.userId					= [user].userId
		
WHERE
		@longitude							BETWEEN userLocation.fromLongitude 
											AND		userLocation.toLongitude
	AND	@latitude							BETWEEN userLocation.fromLatitude 
											AND		userLocation.toLatitude 

ORDER BY
	[user].reputation						DESC
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT	
	users.userId							AS userId,
	users.username							AS username,
	users.displayName						AS displayName,
	users.reputation						AS reputation,
	users.signupDate						AS signupDate,
	COUNT( DISTINCT question.questionId )	AS totalQuestions,
	COUNT( DISTINCT answer.answerId )		AS totalAnswers,
	COUNT( DISTINCT userBadge.userBadgeId )	AS totalBadges
	
FROM
	@users									AS users
	
	LEFT JOIN
	Gabs.dbo.question						AS question
	WITH									(NOLOCK, INDEX(ix_question_userId))
	ON	users.userId						= question.userId

	LEFT JOIN
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_userId))
	ON	users.userId						= answer.userId

	LEFT JOIN
	Gabs.dbo.userBadge						AS userBadge
	WITH									(NOLOCK, INDEX(ix_userBadge_userId))
	ON	users.userId						= userBadge.userId

GROUP BY
	users.userId,
	users.username,
	users.displayName,
	users.reputation,
	users.signupDate
	
ORDER BY
	[users].reputation						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

--DECLARE	@userId			AS ForeignKey = 1
--DECLARE	@answerId		AS ForeignKey = 4248167
--DECLARE @questionId		AS ForeignKey = 1104484
--DECLARE @success		AS BIT	


CREATE PROCEDURE [api].[saveAnswerSelect]
	(
	@userId			AS ForeignKey,
	@questionId		AS ForeignKey,
	@answerId		AS ForeignKey,
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveAnswerSelect]
--###

--###
--1. can't select if not @userId's question
--2. if question already resolved, delete old selection
--3. if answer already selected, unselect & unresolve question
--4. update question.resolved
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

SET @success = 0; --false, default



--#1

IF EXISTS
(
	SELECT
		question.questionId				AS questionId

	FROM
		Gabs.dbo.question				AS question
		WITH							(NOLOCK, INDEX(pk_question))
		
		INNER JOIN
		Gabs.dbo.answer					AS answer
		WITH							(NOLOCK, INDEX(ix_answer_questionId))
		ON	question.questionId			= answer.questionId
		
	WHERE
			question.questionId			= @questionId
		AND	question.userId				= @userId
		AND answer.answerId				= @answerId
)
BEGIN



	-- variables
	
	DECLARE @selected	BIT = 1
	DECLARE @resolved	BIT = 1



	-- #3
	
	IF EXISTS
	(
		SELECT
			answer.answerId			AS answerId

		FROM
			Gabs.dbo.answer			AS answer
			WITH					( NOLOCK, INDEX( pk_answer ) )
			
		WHERE
				answer.answerId		= @answerId
			AND	answer.selected		= 1	--true
	)
	BEGIN



		SET @selected = 0 --false
		SET @resolved = 0 --false



	END



	--#2
	
	UPDATE
		Gabs.dbo.answer
		
	SET
		answer.selected			= 0 --false
		
	WHERE
			answer.questionId	= @questionId
		AND	answer.selected		= 1	--true



	--#4
	
	UPDATE
		Gabs.dbo.question
		
	SET
		question.resolved			= @resolved
		
	WHERE
			question.questionId		= @questionId



	UPDATE
		Gabs.dbo.answer
		
	SET
		selected			= @selected
		
	WHERE
			answerId		= @answerId
			
			
			
	SET @success = 1; --true
		
		
		
END
			

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

--DECLARE	@userId			AS ForeignKey = 1001
--DECLARE	@questionId		AS ForeignKey = 1104484
--DECLARE	@answerId		AS ForeignKey = 4248167
--DECLARE	@success		AS BIT

CREATE PROCEDURE [api].[saveAnswerVote]
	(
	@userId			AS ForeignKey,
	@questionId		AS ForeignKey,
	@answerId		AS ForeignKey,
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveAnswerVote]
--###

--###
--1. can't vote on own question
--2. can't vote on own answer
--3. if aleady voted on another answer on this question, delete other vote and answerVote
--4. if aleady voted on this answer on this question, delete vote and answerVote
--5. else update answer.vote, insert answerVote
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

DECLARE @alreadyAnswered	BIT	= 0 --false
SET @success					= 0 --false



--#1

IF NOT EXISTS
(
	SELECT
		question.questionId				AS questionId

	FROM
		Gabs.dbo.question				AS question
		WITH							(NOLOCK, INDEX(pk_question))
		
	WHERE
			question.questionId			= @questionId
		AND	question.userId				= @userId
)
BEGIN
	


	--#2
	
	IF NOT EXISTS
	(
		SELECT
			answer.answerId				AS answerId

		FROM
			Gabs.dbo.answer				AS answer
			WITH						( NOLOCK, INDEX( pk_answer ) )

		WHERE
				answer.answerId			= @answerId
			AND answer.userId			= @userId 
	)
	BEGIN
		


		-- #4
		
		IF EXISTS
		(
			SELECT
				answer.answerId					AS answerId
			
			FROM
				Gabs.dbo.answer					AS answer
				WITH							(NOLOCK, INDEX(pk_answer))

				INNER JOIN
				Gabs.dbo.answerVote				AS answerVote
				WITH							(NOLOCK, INDEX(ix_answerVote_answerId))
				ON	answer.answerId				= answerVote.answerId

			WHERE
					answer.answerId				= @answerId
				AND	answerVote.userId			= @userId
		)
		BEGIN

			SET @alreadyAnswered = 1 --true
			SET @success = 1 --true

		END
		
		
		
		-- #3, #4
		
		IF EXISTS
		(
			SELECT
				answer.answerId					AS answerId
				
			FROM
				Gabs.dbo.answer					AS answer
				WITH							(NOLOCK, INDEX(ix_answer_questionId))

				INNER JOIN
				Gabs.dbo.answerVote				AS answerVote
				WITH							(NOLOCK, INDEX(ix_answerVote_answerId))
				ON	answer.answerId				= answerVote.answerId

			WHERE
					answer.questionId			= @questionId
				AND	answerVote.userId			= @userId
		)
		BEGIN
		

		
			UPDATE
				Gabs.dbo.answer
				
			SET
				votes						= CASE WHEN votes = 0 THEN 0 ELSE votes - 1 END

			FROM
				Gabs.dbo.answer				AS answer
				WITH						(NOLOCK, INDEX(ix_answer_questionId))

				INNER JOIN
				Gabs.dbo.answerVote			AS answerVote
				WITH						(NOLOCK, INDEX(ix_answerVote_answerId))
				ON	answer.answerId			= answerVote.answerId

			WHERE
					answer.questionId		= @questionId
				AND	answerVote.userId		= @userId



			DELETE
				Gabs.dbo.answerVote
				
			FROM
				Gabs.dbo.answer					AS answer
				WITH							(NOLOCK, INDEX(ix_answer_questionId))

				INNER JOIN
				Gabs.dbo.answerVote				AS answerVote
				WITH							(NOLOCK, INDEX(ix_answerVote_answerId))
				ON	answer.answerId				= answerVote.answerId

			WHERE
					answer.questionId			= @questionId
				AND	answerVote.userId			= @userId



		END
		
		
		
		-- #5
		
		IF @alreadyAnswered = 0 --false
		BEGIN
		

		
			UPDATE
				Gabs.dbo.answer
				
			SET
				votes				= votes + 1

			WHERE
					answerId		= @answerId



			INSERT INTO
				Gabs.dbo.answerVote
				(
				answerId,
				userId,
				vote
				)
			VALUES
				(
				@answerId,
				@userId,
				1
				)
			

			
			SET @success = 1; --true



		END



	END
			
			
			
END
			


PRINT @success
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [badges].[lookupBadges]

AS

--###
--[badges].[lookupBadges]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	badge.badgeId			AS badgeId,
	badge.unlimited			AS unlimited,
	badge.[procedure]		AS [procedure]

FROM
	Gabs.lookup.badge		AS badge
	WITH					( NOLOCK, INDEX( pk_badge ) )

WHERE
	badge.enabled			= 1 --true

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



GO
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 6 --alpha
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 5
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processAlpha]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processAlpha]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @badges TABLE
	(
	userId		INT,
	timestamp	DATETIME2
	)

INSERT INTO
	@badges

SELECT
	[user].userId						AS userId,
	[user].signupDate					AS timestamp
	
FROM
	Gabs.dbo.[user]						AS [user]
	WITH								( NOLOCK, INDEX( ix_user_username ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	[user].userId					= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		[user].signupDate				< '3/1/2012'
	AND	userBadge.userBadgeId			IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.userBadge

SELECT
	badges.userId			AS userId,
	@badgeId				AS badgeId,
	badges.timestamp		AS timestamp

FROM
	@badges					AS badges

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 4 --first question
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 30
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processFirstQuestion]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processFirstQuestione]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @badges TABLE
	(
	userId		INT,
	timestamp	DATETIME2
	)

INSERT INTO
	@badges

SELECT
	question.userId						AS userId,
	MIN( question.timestamp )			AS timestamp
	
FROM
	Gabs.dbo.question					AS question
	WITH								(NOLOCK, INDEX(ix_question_longitude_latitude))

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								(NOLOCK, INDEX(ix_userBadge_userId))
	ON	question.userId					= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		question.timestamp				> DATEADD( d, -@days, GETDATE() )
	AND	question.resolved				= 1 --true
	AND	userBadge.userBadgeId			IS NULL	

GROUP BY
	question.userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.userBadge

SELECT
	badges.userId			AS userId,
	@badgeId				AS badgeId,
	badges.timestamp		AS timestamp

FROM
	@badges					AS badges

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 5 --first selected
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 30
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processFirstSelected]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processFirstSelected]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @badges TABLE
	(
	userId		INT,
	timestamp	DATETIME2
	)

INSERT INTO
	@badges

SELECT
	answer.userId						AS userId,
	MIN( answer.timestamp )				AS timestamp
	
FROM
	Gabs.dbo.answer						AS answer
	WITH								( NOLOCK, INDEX( ix_answer_timestamp ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	answer.userId					= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		answer.timestamp				> DATEADD( d, -@days, GETDATE() )
	AND	answer.selected					= 1 --true
	AND	userBadge.userBadgeId			IS NULL	

GROUP BY
	answer.userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.userBadge

SELECT
	badges.userId			AS userId,
	@badgeId				AS badgeId,
	badges.timestamp		AS timestamp

FROM
	@badges					AS badges

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 1 --first upvote
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 30
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processFirstUpvote]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processFirstUpvote]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @badges TABLE
	(
	userId		INT,
	timestamp	DATETIME2
	)

INSERT INTO
	@badges

SELECT
	answerVote.userId					AS userId,
	MIN( answerVote.timestamp )			AS timestamp
	
FROM
	Gabs.dbo.answerVote					AS answerVote
	WITH								(NOLOCK, INDEX(ix_answerVote_timestamp))

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								(NOLOCK, INDEX(ix_userBadge_userId))
	ON	answerVote.userId				= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		answerVote.timestamp			> DATEADD( d, -@days, GETDATE() )
	AND	userBadge.userBadgeId			IS NULL	

GROUP BY
	answerVote.userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.userBadge

SELECT
	badges.userId			AS userId,
	@badgeId				AS badgeId,
	badges.timestamp		AS timestamp

FROM
	@badges					AS badges

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 2 --pirate
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 5
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processPirate]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processPirate]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @badges TABLE
	(
	userId		INT,
	timestamp	DATETIME2
	)

INSERT INTO
	@badges

SELECT
	reputation.userId					AS userId,
	MIN( reputation.timestamp )			AS timestamp
	
FROM
	Gabs.dbo.reputation					AS reputation
	WITH								( NOLOCK, INDEX( ix_reputation_itemId ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	reputation.userId				= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		reputation.timestamp			> DATEADD( d, -@days, GETDATE() )
	AND	reputation.reputationActionId	= 9 --bounty
	AND	userBadge.userBadgeId			IS NULL	

GROUP BY
	reputation.userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.userBadge

SELECT
	badges.userId			AS userId,
	@badgeId				AS badgeId,
	badges.timestamp		AS timestamp

FROM
	@badges					AS badges

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

GO
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [bounties].[lookupBounties]

AS

--###
--[bounties].[lookupBounties]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	bounty.beginMinutes		AS beginMinutes,
	bounty.endMinutes		AS endMinutes,
	bounty.amount			AS amount

FROM
	Gabs.lookup.bounty		AS bounty

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO

--DECLARE	@beginMinutes		INT = 360
--DECLARE	@endMinutes			INT = 1440
--DECLARE	@bounty				INT = 200
--DECLARE	@count				AS INT=1000


CREATE PROCEDURE [bounties].[processBounties]
	(
	@beginMinutes		INT,
	@endMinutes			INT,
	@bounty				INT,
	@count				INT
	)
AS

--###
--[bounties].[processBounties]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @questions	TABLE
	(
	questionId		INT PRIMARY KEY
	)



INSERT INTO
	@questions

SELECT
	question.questionId									AS questionId

FROM
	Gabs.dbo.question									AS question
	WITH												(NOLOCK, INDEX(ix_question_longitude_latitude))

	LEFT JOIN
	Gabs.dbo.answer										AS answer
	WITH												(NOLOCK, INDEX(ix_answer_questionId))
	ON	question.questionId								= answer.questionId
	
WHERE
	   	DATEDIFF( MI, question.timestamp, GETDATE() )	BETWEEN	@beginMinutes
														AND		@endMinutes

GROUP BY
	question.questionId

HAVING
	COUNT( answer.answerId )							= 0 --no answers

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



UPDATE
	Gabs.dbo.question
	
SET
	bounty							= @bounty

FROM
	@questions						AS questions

	INNER JOIN
	Gabs.dbo.question				AS question
	WITH							(NOLOCK, INDEX(pk_question))
	ON questions.questionId			= question.questionId

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[findText]
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

--DECLARE	@username		AS VARCHAR(100) = 'thinkingstiff'
--DECLARE	@userId			AS INT				
--DECLARE	@hash			AS CHAR(88)			
--DECLARE	@hashType		AS VARCHAR(10)		
--DECLARE	@salt			AS CHAR(8)			
--DECLARE	@iterations		AS INT		
		

CREATE PROCEDURE [login].[checkAuthorization]
	(
	@username		AS VARCHAR(100),
	@userId			AS INT				OUTPUT,
	@hash			AS CHAR(88)			OUTPUT,
	@hashType		AS VARCHAR(10)		OUTPUT,
	@salt			AS CHAR(8)			OUTPUT,
	@iterations		AS INT				OUTPUT
	)
AS

--###
--login.checkAuthorization
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT @userId = 0;



SELECT
	@userId									= [user].userId,
	@hash									= [user].hash,
	@hashType								= hashtype.type,
	@salt									= [user].salt,
	@iterations								= [user].iterations
	
FROM
	Gabs.dbo.[user]							AS [user]
	WITH									(NOLOCK, INDEX(ix_user_username))

	INNER JOIN
	Gabs.lookup.hashType					AS hashType
	WITH									(NOLOCK, INDEX(pk_hashType))
	ON	[user].hashTypeId					= hashType.hashTypeID

WHERE
		[user].username						= @username
	AND	[user].[enabled]					= 1 --true

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)
	  




GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [login].[createUser]
	(
	@username		AS VARCHAR(100),
	@displayName	AS VARCHAR(100),
	@hash			AS CHAR(44),
	@salt			AS CHAR(8),
	@iterations		AS INT,
	@hashTypeId		ForeignKey
	)
AS

--###
--[login].[createUser]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Gabs.dbo.[user]
	(
	[user].username,
	[user].displayName,
	[user].hash,
	[user].salt,
	[user].iterations,
	[user].hashTypeId
	)

VALUES
	(
	@username,
	@displayName,
	@hash,
	@salt,
	@iterations,
	@hashTypeId
	)
	

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--DECLARE	@days				AS INT=3
--DECLARE	@count				AS INT=1000

CREATE PROCEDURE [reputation].[processAnswerAccepted]
	(
	@days		INT,
	@count		INT
	)
AS

--###
--[reputation].[processAnswerAccepted]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



-- variables

DECLARE @reputation					TABLE
	(
	userId							ForeignKey,
	itemId							ForeignKey,
	timestamp						DATETIME2
	)
DECLARE @answerAcceptedReputation	INT



-- set variables

SELECT
	@answerAcceptedReputation				= reputationAction.reputation

FROM
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(NOLOCK, INDEX(pk_reputationAction))
	
WHERE
	reputationAction.reputationActionId		= 5 -- answer accepted
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	@reputation

SELECT
	answer.userId						AS userId,
	answer.answerId						AS itemId,
	answer.timestamp					AS timestamp
	
FROM
	Gabs.dbo.answer						AS answer
	WITH								(NOLOCK, INDEX(ix_answer_timestamp))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	answer.answerId					= reputation.itemId
	AND	reputation.reputationActionId	= 5 --answer accepted
	AND	reputation.timestamp			> DATEADD( d, -@days, GETDATE() )

WHERE
		answer.timestamp				> DATEADD( d, -@days, GETDATE() )
	AND	answer.selected					= 1 --true
	AND	reputation.reputationId			IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId			AS userId,
	5							AS reputationActionId, --answer accepted
	reputation.itemId			AS itemId,
	@answerAcceptedReputation	AS reputation,
	reputation.timestamp		AS timestamp

FROM
	@reputation					AS reputation
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



UPDATE
	Gabs.dbo.[user]
	
SET
	reputation				= reputation + @answerAcceptedReputation

FROM
	@reputation				AS reputation

	INNER JOIN
	Gabs.dbo.[user]			AS [user]
	WITH					(NOLOCK, INDEX(pk_user))
	ON	reputation.userId	= [user].userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)


GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@days				AS INT=2
--DECLARE	@count				AS INT=1000

CREATE PROCEDURE [reputation].[processAnswers]
	(
	@days		INT,
	@count		INT
	)
AS

--###
--[reputation].[processAnswers]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



-- variables

DECLARE @reputation					TABLE
	(
	userId							ForeignKey,
	itemId							ForeignKey,
	timestamp						DATETIME2
	)
DECLARE @answerQuestionReputation	INT



-- set variables

SELECT
	@answerQuestionReputation				= reputationAction.reputation

FROM
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(NOLOCK, INDEX(pk_reputationAction))
	
WHERE
	reputationAction.reputationActionId		= 2 -- answer question
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

	
	
-- answer question

INSERT INTO
	@reputation

SELECT
	answer.userId						AS userId,
	answer.answerId						AS itemId,
	answer.timestamp					AS timestamp
	
FROM
	Gabs.dbo.answer						AS answer
	WITH								(NOLOCK, INDEX(ix_answer_timestamp))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	answer.answerId					= reputation.itemId
	AND	reputation.reputationActionId	= 2 --answer question
	AND	reputation.timestamp			> DATEADD( d, -@days, GETDATE() )
	
WHERE
		answer.timestamp				> DATEADD( d, -@days, GETDATE() )
	AND	reputation.reputationId			IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId			AS userId,
	2							AS reputationActionId, --answer question
	reputation.itemId			AS itemId,
	@answerQuestionReputation	AS reputation,
	reputation.timestamp		AS timestamp

FROM
	@reputation					AS reputation
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



UPDATE
	Gabs.dbo.[user]
	
SET
	reputation				= reputation + @answerQuestionReputation

FROM
	@reputation				AS reputation

	INNER JOIN
	Gabs.dbo.[user]			AS [user]
	WITH					(NOLOCK, INDEX(pk_user))
	ON	reputation.userId	= [user].userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--DECLARE	@days				AS INT=3
--DECLARE	@count				AS INT=1000

CREATE PROCEDURE [reputation].[processAnswerVotes]
	(
	@days		INT,
	@count		INT
	)
AS

--###
--[reputation].[processAnswerVotes]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



-- variables

DECLARE @reputation					TABLE
	(
	userId							ForeignKey,
    reputationActionId				ForeignKey,
	itemId							ForeignKey,
	reputation						INT,
	timestamp						DATETIME2
	)
DECLARE @upvoteAnswerReputation		INT
DECLARE @answerUpvotedReputation	INT



-- set variables

SELECT
	@upvoteAnswerReputation					= reputationAction.reputation

FROM
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(NOLOCK, INDEX(pk_reputationAction))
	
WHERE
	reputationAction.reputationActionId		= 3 -- upvote answer 
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)


	
SELECT
	@answerUpvotedReputation				= reputationAction.reputation

FROM
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(NOLOCK, INDEX(pk_reputationAction))
	
WHERE
	reputationAction.reputationActionId		= 7 --answer upvoted
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)


	
INSERT INTO
	@reputation

SELECT
	answerVote.userId					AS userId,
	3									AS reputationActionId, --upvote answer
	answerVote.answerId					AS itemId,
	@upvoteAnswerReputation				AS reputation,
	answerVote.timestamp				AS timestamp
	
FROM
	Gabs.dbo.answerVote					AS answerVote
	WITH								(NOLOCK, INDEX(ix_answerVote_timestamp))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	answerVote.answerId				= reputation.itemId
	AND	reputation.reputationActionId	= 3 --upvote answer
	AND	reputation.timestamp			> DATEADD( d, -@days, GETDATE() )

WHERE
		answerVote.timestamp			> DATEADD( d, -@days, GETDATE() )
	AND	reputation.reputationId			IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	@reputation

SELECT
	answer.userId				AS userId,
	7							AS reputationActionId, --answer upvoted
	answer.answerId				AS itemId,
	@answerUpvotedReputation	AS reputation,
	reputation.timestamp		AS timestamp

FROM
	@reputation					AS reputation

	INNER JOIN
	Gabs.dbo.answer				AS answer
	WITH						(NOLOCK, INDEX(pk_answer))
	ON reputation.itemId		= answer.answerId



INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId				AS userId,
	reputation.reputationActionId	AS reputationActionId,
	reputation.itemId				AS itemId,
	reputation.reputation			AS reputation,
	reputation.timestamp			AS timestamp

FROM
	@reputation						AS reputation
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



UPDATE
	Gabs.dbo.[user]
	
SET
	[user].reputation		= [user].reputation + reputation.reputation

FROM
	@reputation				AS reputation

	INNER JOIN
	Gabs.dbo.[user]			AS [user]
	WITH					(NOLOCK, INDEX(pk_user))
	ON	reputation.userId	= [user].userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)


GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO

--DECLARE	@days				AS INT=3
--DECLARE	@expirationDays		AS INT=1
--DECLARE	@count				AS INT=1000

CREATE PROCEDURE [reputation].[processBounties]
	(
	@days				INT,
	@count				INT,
	@expirationDays		INT
	)
AS

--###
--[reputation].[processBounties]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



-- variables

DECLARE @reputation			TABLE
	(
	userId					ForeignKey,
	itemId					ForeignKey,
	reputation				INT,
	timestamp				DATETIME2
	)
DECLARE @questions			TABLE
	(
	questionId				ForeignKey PRIMARY KEY,
	reputation				INT,
	timestamp				DATETIME2
	)



-- resolved questions, bounty to selected

INSERT INTO
	@reputation

SELECT
	answer.userId							AS userId,
	answer.answerId							AS itemId,
	question.bounty							AS reputation,
	answer.timestamp						AS timestamp

FROM
	Gabs.dbo.question						AS question
	WITH									(NOLOCK, INDEX(ix_question_longitude_latitude))
	
	INNER JOIN
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_questionId))
	ON	question.questionId					= answer.questionId
	AND	answer.selected						= 1 --true

	LEFT JOIN
	Gabs.dbo.reputation						AS reputation
	WITH									(NOLOCK, INDEX(ix_reputation_itemId))
	ON	answer.answerId						= reputation.itemId
	AND	reputation.reputationActionId		= 9 --bounty
	AND	reputation.timestamp				> DATEADD( d, -@days, GETDATE() )

WHERE
		question.timestamp					> DATEADD( d, -@days, GETDATE() )
	AND	question.resolved					= 1 --true
	AND	question.bounty						> 0 --has bounty
	AND	reputation.reputationId				IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



-- expired questions, bounty to first

INSERT INTO
	@questions

SELECT
	question.questionId									AS questionId,
	question.bounty										AS reputation,
	MIN( answer.timestamp )								AS timestamp

FROM
	Gabs.dbo.question									AS question
	WITH												(NOLOCK, INDEX(ix_question_longitude_latitude))
	
	INNER JOIN
	Gabs.dbo.answer										AS answer
	WITH												(NOLOCK, INDEX(ix_answer_questionId))
	ON	question.questionId								= answer.questionId

	LEFT JOIN
	Gabs.dbo.reputation									AS reputation
	WITH												(NOLOCK, INDEX(ix_reputation_itemId))
	ON	answer.answerId									= reputation.itemId
	AND	reputation.reputationActionId					= 9 --bounty
	AND	reputation.timestamp							> DATEADD( d, -@days, GETDATE() )

WHERE
		question.timestamp								> DATEADD( d, -@days, GETDATE() )
	AND	question.resolved								= 0 --false
	AND	DATEDIFF( D, question.timestamp, GETDATE() )	> @expirationDays --expired
	AND	question.bounty									> 0 --has bounty
	AND	reputation.reputationId							IS NULL	

GROUP BY
	question.questionId,
	question.bounty
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	@reputation

SELECT
	answer.userId							AS userId,
	answer.answerId							AS itemId,
	questions.reputation					AS reputation,
	questions.timestamp						AS timestamp

FROM
	@questions								AS questions

	INNER JOIN
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_questionId))
	ON	questions.questionId				= answer.questionId
	AND	questions.timestamp					= answer.timestamp

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId			AS userId,
	9							AS reputationActionId, --bounty
	reputation.itemId			AS itemId,
	reputation.reputation		AS reputation,
	reputation.timestamp		AS timestamp

FROM
	@reputation					AS reputation
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



UPDATE
	Gabs.dbo.[user]
	
SET
	reputation				= [user].reputation + reputation.reputation

FROM
	@reputation				AS reputation

	INNER JOIN
	Gabs.dbo.[user]			AS [user]
	WITH					(NOLOCK, INDEX(pk_user))
	ON	reputation.userId	= [user].userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@days				AS INT=2
--DECLARE	@count				AS INT=1000

CREATE PROCEDURE [reputation].[processQuestions]
	(
	@days		INT,
	@count		INT
	)
AS

--###
--[reputation].[processQuestions]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



-- variables

DECLARE @reputation				TABLE
	(
	userId						ForeignKey,
	itemId						ForeignKey,
	timestamp					DATETIME2
	)
DECLARE @askQuestionReputation	INT



-- set variables

SELECT
	@askQuestionReputation					= reputationAction.reputation

FROM
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(NOLOCK, INDEX(pk_reputationAction))
	
WHERE
	reputationAction.reputationActionId		= 1 -- ask question
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

	
	
-- ask question

INSERT INTO
	@reputation

SELECT
	question.userId						AS userId,
	question.questionId					AS itemId,
	question.timestamp					AS timestamp
	
FROM
	Gabs.dbo.question					AS question
	WITH								(NOLOCK, INDEX(ix_question_longitude_latitude))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	question.questionId				= reputation.itemId
	AND	reputation.reputationActionId	= 1 --ask question
	AND	reputation.timestamp			> DATEADD( d, -@days, GETDATE() )
	
WHERE
		question.timestamp				> DATEADD( d, -@days, GETDATE() )
	AND	reputation.reputationId			IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId			AS userId,
	1							AS reputationActionId, --ask question
	reputation.itemId			AS itemId,
	@askQuestionReputation		AS reputation,
	reputation.timestamp		AS timestamp

FROM
	@reputation					AS reputation
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



UPDATE
	Gabs.dbo.[user]
	
SET
	reputation				= reputation + @askQuestionReputation

FROM
	@reputation				AS reputation

	INNER JOIN
	Gabs.dbo.[user]			AS [user]
	WITH					(NOLOCK, INDEX(pk_user))
	ON	reputation.userId	= [user].userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)


GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--DECLARE	@days				AS INT=3
--DECLARE	@count				AS INT=600000

CREATE PROCEDURE [reputation].[processResolveQuestion]
	(
	@days		INT,
	@count		INT
	)
AS

--###
--[reputation].[processResolveQuestion]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



-- variables

DECLARE @reputation					TABLE
	(
	userId							ForeignKey,
	itemId							ForeignKey,
	timestamp						DATETIME2
	)
DECLARE @resolveQuestionReputation	INT



-- set variables

SELECT
	@resolveQuestionReputation				= reputationAction.reputation

FROM
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(NOLOCK, INDEX(pk_reputationAction))
	
WHERE
	reputationAction.reputationActionId		= 4 -- resolve question
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)


	
INSERT INTO
	@reputation

SELECT
	question.userId						AS userId,
	question.questionId					AS itemId,
	question.timestamp					AS timestamp
	
FROM
	Gabs.dbo.question					AS question
	WITH								(NOLOCK, INDEX(ix_question_longitude_latitude))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	question.questionId				= reputation.itemId
	AND	reputation.reputationActionId	= 4 --resolve question
	AND	reputation.timestamp			> DATEADD( d, -@days, GETDATE() )

WHERE
		question.timestamp				> DATEADD( d, -@days, GETDATE() )
	AND	question.resolved				= 1 --true
	AND	reputation.reputationId			IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId			AS userId,
	4							AS reputationActionId, --resolve question
	reputation.itemId			AS itemId,
	@resolveQuestionReputation	AS reputation,
	reputation.timestamp		AS timestamp

FROM
	@reputation					AS reputation
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



UPDATE
	Gabs.dbo.[user]
	
SET
	reputation				= reputation + @resolveQuestionReputation

FROM
	@reputation				AS reputation

	INNER JOIN
	Gabs.dbo.[user]			AS [user]
	WITH					(NOLOCK, INDEX(pk_user))
	ON	reputation.userId	= [user].userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)


GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [top].[lookupIntervals]

AS

--###
--[top].[lookupIntervals]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	interval.intervalId		AS intervalId,
	interval.name			AS name

FROM
	Gabs.lookup.interval	AS interval
	WITH					( NOLOCK, INDEX( pk_interval ) )

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [top].[lookupRegions]

AS

--###
--[top].[lookupRegions]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	region.regionId			AS regionId,
	region.fromLatitude		AS fromLatitude,
	region.toLatitude		AS toLatitude,
	region.fromLongitude	AS fromLongitude,
	region.toLongitude		AS toLongitude

FROM
	Gabs.lookup.region		AS region
	WITH					( NOLOCK, INDEX( pk_region ) )

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



GO
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @regionId		AS INT = 1 --sacramento
--DECLARE	@intervalId		AS INT = 2 --week
--DECLARE	@beginDate		AS DATETIME2 = '1/16/2011 00:00:00'
--DECLARE	@endDate		AS DATETIME2 = GETDATE()
--DECLARE	@count			AS INT = 30

CREATE PROCEDURE [top].[processUsersAnswers]
	(
	@regionId		AS ForeignKey,
	@intervalId		AS ForeignKey,
	@beginDate		AS DATETIME2,
	@endDate		AS DATETIME2,
	@count			AS INT
	)
AS

--###
--[top].[processUsersAnswers]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



BEGIN TRAN



DELETE FROM
	Gabs.[top].topUser

WHERE
		topUser.regionId		= @regionId
	AND topUser.topTypeId		= 3 --answers
	AND topUser.intervalId		= @intervalId



DECLARE @users		TABLE
	(
	userId			INT PRIMARY KEY,
	username		VARCHAR(100),
	reputation		INT,
	topScore		INT
	)

INSERT INTO
	@users

SELECT	
	[user].userId								AS userId,
	[user].username								AS username,
	[user].reputation							AS reputation,
	COUNT( DISTINCT answer.answerId )			AS topScore
	
FROM
	Gabs.lookup.region							AS region
	WITH										(NOLOCK, INDEX(pk_region))

	INNER JOIN
	Gabs.dbo.userLocation						AS userLocation
	WITH										(NOLOCK, INDEX(ix_userLocation_bounds))
	ON	region.fromLatitude						< userLocation.toLatitude 
	AND region.toLatitude						> userLocation.fromLatitude 
	AND	region.fromLongitude					< userLocation.toLongitude
	AND region.toLongitude						> userLocation.fromLongitude

	INNER JOIN
	Gabs.dbo.[user]								AS [user]
	WITH										(NOLOCK, INDEX(pk_user))
	ON	userLocation.userId						= [user].userId

	INNER JOIN
	Gabs.dbo.answer								AS answer
	WITH										(NOLOCK, INDEX(ix_answer_userId))
	ON	[user].userId							= answer.userId

WHERE
		region.regionId							= @regionId
	AND	answer.timestamp						BETWEEN @beginDate
												AND		@endDate
	 
GROUP BY
	[user].userId,
	[user].username,
	[user].reputation
	
ORDER BY
	topScore									DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



INSERT INTO
	Gabs.[top].topUser

SELECT	
	@regionId									AS regionId,
    3											AS topTypeId, --answers
	@intervalId									AS intervalId,
	users.userId								AS userId,
	users.username								AS username,
	users.reputation							AS reputation,
	COUNT( DISTINCT question.questionId )		AS totalQuestions,
	COUNT( DISTINCT answer.answerId )			AS totalAnswers,
	COUNT( DISTINCT userBadge.userBadgeId )		AS totalBadges,
	users.topScore								AS topScore
	
FROM
	@users										AS users

	LEFT JOIN
	Gabs.dbo.userBadge							AS userBadge
	WITH										(NOLOCK, INDEX(ix_userBadge_userId))
	ON	users.userId							= userBadge.userId

	LEFT JOIN
	Gabs.dbo.question							AS question
	WITH										(NOLOCK, INDEX(ix_question_userId))
	ON	users.userId							= question.userId

	LEFT JOIN
	Gabs.dbo.answer								AS answer
	WITH										(NOLOCK, INDEX(ix_answer_userId))
	ON	users.userId							= answer.userId

GROUP BY
	users.userId,
	users.username,
	users.reputation,
	users.topScore
	
ORDER BY
	users.topScore								DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



COMMIT TRAN

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @regionId		AS INT = 1 --sacramento
--DECLARE	@intervalId		AS INT = 2 --week
--DECLARE	@beginDate		AS DATETIME2 = '1/16/2011 00:00:00'
--DECLARE	@endDate		AS DATETIME2 = GETDATE()
--DECLARE	@count			AS INT = 30

CREATE PROCEDURE [top].[processUsersBadges]
	(
	@regionId		AS ForeignKey,
	@intervalId		AS ForeignKey,
	@beginDate		AS DATETIME2,
	@endDate		AS DATETIME2,
	@count			AS INT
	)
AS

--###
--[top].[processUsersBadges]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



BEGIN TRAN



DELETE FROM
	Gabs.[top].topUser

WHERE
		topUser.regionId		= @regionId
	AND topUser.topTypeId		= 4 --badges
	AND topUser.intervalId		= @intervalId



DECLARE @users		TABLE
	(
	userId			INT PRIMARY KEY,
	username		VARCHAR(100),
	reputation		INT,
	topScore		INT
	)

INSERT INTO
	@users

SELECT	
	[user].userId								AS userId,
	[user].username								AS username,
	[user].reputation							AS reputation,
	COUNT( DISTINCT userBadge.userBadgeId )		AS topScore
	
FROM
	Gabs.lookup.region							AS region
	WITH										(NOLOCK, INDEX(pk_region))

	INNER JOIN
	Gabs.dbo.userLocation						AS userLocation
	WITH										(NOLOCK, INDEX(ix_userLocation_bounds))
	ON	region.fromLatitude						< userLocation.toLatitude 
	AND region.toLatitude						> userLocation.fromLatitude 
	AND	region.fromLongitude					< userLocation.toLongitude
	AND region.toLongitude						> userLocation.fromLongitude

	INNER JOIN
	Gabs.dbo.[user]								AS [user]
	WITH										(NOLOCK, INDEX(pk_user))
	ON	userLocation.userId						= [user].userId

	INNER JOIN
	Gabs.dbo.userBadge							AS userBadge
	WITH										(NOLOCK, INDEX(ix_userBadge_userId))
	ON	[user].userId							= userBadge.userId

WHERE
		region.regionId							= @regionId
	AND	userBadge.timestamp						BETWEEN @beginDate
												AND		@endDate
	 
GROUP BY
	[user].userId,
	[user].username,
	[user].reputation
	
ORDER BY
	topScore									DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



INSERT INTO
	Gabs.[top].topUser

SELECT	
	@regionId									AS regionId,
    4											AS topTypeId, --badges
	@intervalId									AS intervalId,
	users.userId								AS userId,
	users.username								AS username,
	users.reputation							AS reputation,
	COUNT( DISTINCT question.questionId )		AS totalQuestions,
	COUNT( DISTINCT answer.answerId )			AS totalAnswers,
	COUNT( DISTINCT userBadge.userBadgeId )		AS totalBadges,
	users.topScore								AS topScore
	
FROM
	@users										AS users

	LEFT JOIN
	Gabs.dbo.userBadge							AS userBadge
	WITH										(NOLOCK, INDEX(ix_userBadge_userId))
	ON	users.userId							= userBadge.userId

	LEFT JOIN
	Gabs.dbo.question							AS question
	WITH										(NOLOCK, INDEX(ix_question_userId))
	ON	users.userId							= question.userId

	LEFT JOIN
	Gabs.dbo.answer								AS answer
	WITH										(NOLOCK, INDEX(ix_answer_userId))
	ON	users.userId							= answer.userId

GROUP BY
	users.userId,
	users.username,
	users.reputation,
	users.topScore
	
ORDER BY
	users.topScore								DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



COMMIT TRAN

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @regionId		AS INT = 1 --sacramento
--DECLARE	@intervalId		AS INT = 2 --week
--DECLARE	@beginDate		AS DATETIME2 = '1/16/2011 00:00:00'
--DECLARE	@endDate		AS DATETIME2 = GETDATE()
--DECLARE	@count			AS INT = 300

CREATE PROCEDURE [top].[processUsersQuestions]
	(
	@regionId		AS ForeignKey,
	@intervalId		AS ForeignKey,
	@beginDate		AS DATETIME2,
	@endDate		AS DATETIME2,
	@count			AS INT
	)
AS

--###
--[top].[processUsersQuestions]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



BEGIN TRAN



DELETE FROM
	Gabs.[top].topUser

WHERE
		topUser.regionId		= @regionId
	AND topUser.topTypeId		= 2 --questions
	AND topUser.intervalId		= @intervalId



DECLARE @users		TABLE
	(
	userId			INT PRIMARY KEY,
	username		VARCHAR(100),
	reputation		INT,
	topScore		INT
	)

INSERT INTO
	@users

SELECT	
	[user].userId								AS userId,
	[user].username								AS username,
	[user].reputation							AS reputation,
	COUNT( DISTINCT question.questionId )		AS topScore
	
FROM
	Gabs.lookup.region							AS region
	WITH										(NOLOCK, INDEX(pk_region))

	INNER JOIN
	Gabs.dbo.userLocation						AS userLocation
	WITH										(NOLOCK, INDEX(ix_userLocation_bounds))
	ON	region.fromLatitude						< userLocation.toLatitude 
	AND region.toLatitude						> userLocation.fromLatitude 
	AND	region.fromLongitude					< userLocation.toLongitude
	AND region.toLongitude						> userLocation.fromLongitude

	INNER JOIN
	Gabs.dbo.[user]								AS [user]
	WITH										(NOLOCK, INDEX(pk_user))
	ON	userLocation.userId						= [user].userId

	INNER JOIN
	Gabs.dbo.question							AS question
	WITH										(NOLOCK, INDEX(ix_question_userId))
	ON	[user].userId							= question.userId

WHERE
		region.regionId							= @regionId
	AND	question.timestamp						BETWEEN @beginDate
												AND		@endDate
	 
GROUP BY
	[user].userId,
	[user].username,
	[user].reputation
	
ORDER BY
	topScore									DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



INSERT INTO
	Gabs.[top].topUser

SELECT	
	@regionId									AS regionId,
    2											AS topTypeId, --questions
	@intervalId									AS intervalId,
	users.userId								AS userId,
	users.username								AS username,
	users.reputation							AS reputation,
	COUNT( DISTINCT question.questionId )		AS totalQuestions,
	COUNT( DISTINCT answer.answerId )			AS totalAnswers,
	COUNT( DISTINCT userBadge.userBadgeId )		AS totalBadges,
	users.topScore								AS topScore
	
FROM
	@users										AS users

	LEFT JOIN
	Gabs.dbo.userBadge							AS userBadge
	WITH										(NOLOCK, INDEX(ix_userBadge_userId))
	ON	users.userId							= userBadge.userId

	LEFT JOIN
	Gabs.dbo.question							AS question
	WITH										(NOLOCK, INDEX(ix_question_userId))
	ON	users.userId							= question.userId

	LEFT JOIN
	Gabs.dbo.answer								AS answer
	WITH										(NOLOCK, INDEX(ix_answer_userId))
	ON	users.userId							= answer.userId

GROUP BY
	users.userId,
	users.username,
	users.reputation,
	users.topScore
	
ORDER BY
	users.topScore								DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



COMMIT TRAN

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @regionId		AS INT = 1 --sacramento
--DECLARE	@intervalId		AS INT = 4 --year
--DECLARE	@beginDate		AS DATETIME2 = '1/1/2012 00:00:00'
--DECLARE	@endDate		AS DATETIME2 = GETDATE()
--DECLARE	@count			AS INT = 300

CREATE PROCEDURE [top].[processUsersReputation]
	(
	@regionId		AS ForeignKey,
	@intervalId		AS ForeignKey,
	@beginDate		AS DATETIME2,
	@endDate		AS DATETIME2,
	@count			AS INT
	)
AS

--###
--[top].[processUsersReputation]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



BEGIN TRAN



DELETE FROM
	Gabs.[top].topUser

WHERE
		topUser.regionId		= @regionId
	AND topUser.topTypeId		= 1 --reputation
	AND topUser.intervalId		= @intervalId



DECLARE @users		TABLE
	(
	userId			INT PRIMARY KEY,
	username		VARCHAR(100),
	reputation		INT,
	topScore		INT
	)

INSERT INTO
	@users

SELECT	
	[user].userId								AS userId,
	[user].username								AS username,
	[user].reputation							AS reputation,
	SUM( reputation.reputation )				AS topScore

FROM
	Gabs.lookup.region							AS region
	WITH										(NOLOCK, INDEX(pk_region))

	INNER JOIN
	Gabs.dbo.userLocation						AS userLocation
	WITH										(NOLOCK, INDEX(ix_userLocation_bounds))
	ON	region.fromLatitude						< userLocation.toLatitude 
	AND region.toLatitude						> userLocation.fromLatitude 
	AND	region.fromLongitude					< userLocation.toLongitude
	AND region.toLongitude						> userLocation.fromLongitude

	INNER JOIN
	Gabs.dbo.[user]								AS [user]
	WITH										(NOLOCK, INDEX(pk_user))
	ON	userLocation.userId						= [user].userId

	INNER JOIN
	Gabs.dbo.reputation							AS reputation
	WITH										( NOLOCK, INDEX( ix_reputation_userId ) )
	ON	[user].userId							= reputation.userId

WHERE
		region.regionId							= @regionId
	AND	reputation.timestamp					BETWEEN @beginDate AND @endDate
	 
GROUP BY
	[user].userId,
	[user].username,
	[user].reputation
	
ORDER BY
	CASE WHEN @intervalId = 0 --all
	THEN [USER].reputation
	ELSE SUM( reputation.reputation )	
	END											DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



INSERT INTO
	Gabs.[top].topUser

SELECT	
	@regionId									AS regionId,
    1											AS topTypeId,  --reputation
	@intervalId									AS intervalId,
	users.userId								AS userId,
	users.username								AS username,
	users.reputation							AS reputation,
	COUNT( DISTINCT question.questionId )		AS totalQuestions,
	COUNT( DISTINCT answer.answerId )			AS totalAnswers,
	COUNT( DISTINCT userBadge.userBadgeId )		AS totalBadges,
	CASE WHEN @intervalId = 0 --all
	THEN users.reputation
	ELSE users.topScore	END						AS topScore
	
FROM
	@users										AS users

	LEFT JOIN
	Gabs.dbo.userBadge							AS userBadge
	WITH										(NOLOCK, INDEX(ix_userBadge_userId))
	ON	users.userId							= userBadge.userId

	LEFT JOIN
	Gabs.dbo.question							AS question
	WITH										(NOLOCK, INDEX(ix_question_userId))
	ON	users.userId							= question.userId

	LEFT JOIN
	Gabs.dbo.answer								AS answer
	WITH										(NOLOCK, INDEX(ix_answer_userId))
	ON	users.userId							= answer.userId

GROUP BY
	users.userId,
	users.username,
	users.reputation,
	users.topScore
	
ORDER BY
	users.topScore								DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	




COMMIT TRAN

GO




