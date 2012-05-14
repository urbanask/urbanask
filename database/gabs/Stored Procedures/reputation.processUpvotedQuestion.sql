SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@reputationActionId		INT = 10
--DECLARE	@reputation				INT = 1
--DECLARE	@days					INT = 10
--DECLARE	@count					INT = 1000
--DECLARE	@expirationDays			INT = 2

CREATE PROCEDURE [reputation].[processUpvotedQuestion]
	(
	@reputationActionId		INT,
	@reputation				INT,
	@days					INT,
	@count					INT,
	@expirationDays			INT
	)
AS

--###
--[reputation].[processUpvotedQuestion]
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
	questionVote.userId					AS userId,
	questionVote.questionId				AS itemId,
	questionVote.timestamp				AS timestamp
	
FROM
	Gabs.dbo.questionVote				AS questionVote
	WITH								( NOLOCK, INDEX( ix_questionVote_timestamp ) )
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								( NOLOCK, INDEX( ix_reputation_itemId ) )
	ON	questionVote.questionId			= reputation.itemId
	AND	questionVote.userId				= reputation.userId
	AND	reputation.reputationActionId	= @reputationActionId
	AND	questionVote.timestamp			= reputation.timestamp

WHERE
		questionVote.timestamp			> DATEADD( d, -@days, GETDATE() )
	AND	reputation.reputationId			IS NULL	

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId				AS userId,
	@reputationActionId				AS reputationActionId, 
	reputation.itemId				AS itemId,
	@reputation						AS reputation,
	reputation.timestamp			AS timestamp

FROM
	@reputations					AS reputation
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



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
GRANT EXECUTE ON  [reputation].[processUpvotedQuestion] TO [processReputation]
GO
