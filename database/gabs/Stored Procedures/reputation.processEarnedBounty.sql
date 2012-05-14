SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@reputationActionId		INT = 9
--DECLARE	@reputation				INT = 0
--DECLARE	@days					INT = 1000
--DECLARE	@count					INT = 1000
--DECLARE	@expirationDays			INT = 2

CREATE PROCEDURE [reputation].[processEarnedBounty]
	(
	@reputationActionId		INT,
	@reputation				INT,
	@days					INT,
	@count					INT,
	@expirationDays			INT
	)
AS

--###
--[reputation].[processEarnedBounty]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



-- variables

DECLARE @reputations		TABLE
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
DECLARE @users				TABLE
	(
	userId					ForeignKey,
	reputation				INT
	)



-- resolved questions, bounty to selected

INSERT INTO
	@reputations

SELECT
	answer.userId							AS userId,
	answer.answerId							AS itemId,
	question.bounty							AS reputation,
	answer.timestamp						AS timestamp

FROM
	Gabs.dbo.question						AS question
	WITH									( NOLOCK, INDEX( ix_question_longitude_latitude ) )
	
	INNER JOIN
	Gabs.dbo.answer							AS answer
	WITH									( NOLOCK, INDEX( ix_answer_questionId ) )
	ON	question.questionId					= answer.questionId
	AND	answer.selected						= 1 --true

	LEFT JOIN
	Gabs.dbo.reputation						AS reputation
	WITH									( NOLOCK, INDEX( ix_reputation_itemId ) )
	ON	answer.answerId						= reputation.itemId
	AND	answer.userId						= reputation.userId
	AND	reputation.reputationActionId		= @reputationActionId
	AND answer.timestamp					= reputation.timestamp

WHERE
		question.resolved					= 1 --true
	AND	question.bounty						> 0 --has bounty
	AND	reputation.reputationId				IS NULL	

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



-- expired questions, bounty to first answer with 3+ upvotes

INSERT INTO
	@questions

SELECT
	question.questionId									AS questionId,
	question.bounty										AS reputation,
	answer.timestamp									AS timestamp

FROM
	Gabs.dbo.question									AS question
	WITH												( NOLOCK, INDEX( ix_question_longitude_latitude ) )
	
	INNER JOIN
	Gabs.dbo.answer										AS answer
	WITH												( NOLOCK, INDEX( ix_answer_questionId ) )
	ON	question.questionId								= answer.questionId

	LEFT JOIN
	Gabs.dbo.reputation									AS reputation
	WITH												( NOLOCK, INDEX( ix_reputation_itemId ) )
	ON	answer.answerId									= reputation.itemId
	AND	answer.userId									= reputation.userId
	AND	reputation.reputationActionId					= @reputationActionId
	AND answer.timestamp								= reputation.timestamp

WHERE
		question.resolved								= 0 --false
	AND	DATEDIFF( D, question.timestamp, GETDATE() )	> @expirationDays --expired
	AND	question.bounty									> 0 --has bounty
	AND answer.votes									>= 3 --has 3+ votes
	AND	reputation.reputationId							IS NULL	

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	@reputations

SELECT
	answer.userId							AS userId,
	answer.answerId							AS itemId,
	questions.reputation					AS reputation,
	questions.timestamp						AS timestamp

FROM
	@questions								AS questions

	INNER JOIN
	Gabs.dbo.answer							AS answer
	WITH									( NOLOCK, INDEX( ix_answer_questionId ) )
	ON	questions.questionId				= answer.questionId
	AND	questions.timestamp					= answer.timestamp

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId			AS userId,
	@reputationActionId			AS reputationActionId, 
	reputation.itemId			AS itemId,
	reputation.reputation		AS reputation,
	reputation.timestamp		AS timestamp

FROM
	@reputations				AS reputation
	
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	@users

SELECT
	reputation.userId				AS userId,
	SUM( reputation.reputation )	AS reputation

FROM
	@reputations					AS reputation

GROUP BY
	reputation.userId

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



UPDATE
	Gabs.dbo.[user]
	
SET
	[user].reputation			= [user].reputation + users.reputation

FROM
	@users						AS users

	INNER JOIN
	Gabs.dbo.[user]				AS [user]
	WITH						( NOLOCK, INDEX( pk_user ) )
	ON	users.userId			= [user].userId


GO
GRANT EXECUTE ON  [reputation].[processEarnedBounty] TO [processReputation]
GO
