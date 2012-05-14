SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 17 --first downvote
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 30
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processFirstDownvote]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processFirstDownvote]
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
	WITH								( NOLOCK, INDEX( ix_answerVote_timestamp ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	answerVote.userId				= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		answerVote.timestamp			> DATEADD( d, -@days, GETDATE() )
	AND answerVote.vote					= -1
	AND	userBadge.userBadgeId			IS NULL	

GROUP BY
	answerVote.userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.userBadge

SELECT
	badges.userId				AS userId,
	@badgeId					AS badgeId,
	badges.timestamp			AS timestamp

FROM
	@badges						AS badges

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
	badges.userId			AS userId,
	5						AS notificationId, --earned badge
	2						AS objectTypeId, --badge
	@badgeId				AS badgeId,
	badges.timestamp		AS timestamp

FROM
	@badges					AS badges

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)


GO
GRANT EXECUTE ON  [badges].[processFirstDownvote] TO [ProcessBadges]
GO
