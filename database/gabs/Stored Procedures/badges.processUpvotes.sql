SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 1 --10 upvotes
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 3
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processUpvotes]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processUpvotes]
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
	answerVote.timestamp				AS timestamp
	
FROM
	Gabs.dbo.answerVote					AS answerVote
	WITH								( NOLOCK, INDEX( ix_answerVote_timestamp ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	answerVote.userId				= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		userBadge.userBadgeId			IS NULL	

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	@badges

SELECT
	questionVote.userId					AS userId,
	questionVote.timestamp				AS timestamp
	
FROM
	Gabs.dbo.questionVote				AS questionVote
	WITH								( NOLOCK, INDEX( ix_questionVote_timestamp ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	questionVote.userId				= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		userBadge.userBadgeId			IS NULL	

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



INSERT INTO
	Gabs.dbo.userBadge

SELECT
	badges.userId				AS userId,
	@badgeId					AS badgeId,
	MAX( badges.timestamp )		AS timestamp

FROM
	@badges						AS badges

GROUP BY
	badges.userId

HAVING
	COUNT( badges.timestamp )	>= 10

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.userNotification
	(
	userId,
	notificationId,
	objectTypeId,
	itemId,
	timestamp
	)

SELECT
	badges.userId				AS userId,
	5							AS notificationId, --earned badge
	2							AS objectTypeId, --badge
	@badgeId					AS badgeId,
	MAX( badges.timestamp )		AS timestamp

FROM
	@badges						AS badges

GROUP BY
	badges.userId

HAVING
	COUNT( badges.timestamp )	>= 10

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

GO
GRANT EXECUTE ON  [badges].[processUpvotes] TO [ProcessBadges]
GO
