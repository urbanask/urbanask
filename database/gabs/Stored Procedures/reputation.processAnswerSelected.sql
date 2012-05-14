SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@reputationActionId		INT = 5
--DECLARE	@reputation				INT = 20
--DECLARE	@days					INT = 100
--DECLARE	@count					INT = 1000
--DECLARE	@expirationDays			INT = 2

CREATE PROCEDURE [reputation].[processAnswerSelected]
	(
	@reputationActionId		INT,
	@reputation				INT,
	@days					INT,
	@count					INT,
	@expirationDays			INT
	)
AS

--###
--[reputation].[processAnswerSelected]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



-- variables

DECLARE @reputations			TABLE
	(
	userId						ForeignKey,
	itemId						ForeignKey,
	timestamp					DATETIME2
	)
DECLARE @users					TABLE
	(
	userId						ForeignKey,
	reputation					INT
	)



INSERT INTO
	@reputations

SELECT
	answer.userId						AS userId,
	answer.answerId						AS itemId,
	answer.timestamp					AS timestamp
	
FROM
	Gabs.dbo.answer						AS answer
	WITH								( NOLOCK, INDEX( ix_answer_timestamp ) )
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								( NOLOCK, INDEX( ix_reputation_itemId ) )
	ON	answer.answerId					= reputation.itemId
	AND	answer.userId					= reputation.userId
	AND	reputation.reputationActionId	= @reputationActionId
	AND answer.timestamp				= reputation.timestamp

WHERE
		answer.selected					= 1 --true
	AND	reputation.reputationId			IS NULL	

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId			AS userId,
	@reputationActionId			AS reputationActionId, 
	reputation.itemId			AS itemId,
	@reputation					AS reputation,
	reputation.timestamp		AS timestamp

FROM
	@reputations				AS reputation
	
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	@users

SELECT
	reputation.userId			AS userId,
	SUM( @reputation )			AS reputation

FROM
	@reputations				AS reputation

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
GRANT EXECUTE ON  [reputation].[processAnswerSelected] TO [processReputation]
GO
