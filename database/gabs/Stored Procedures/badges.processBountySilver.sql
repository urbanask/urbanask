SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 2 --bounty silver
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 3
--DECLARE	@count			AS INT = 1000

CREATE PROCEDURE [badges].[processBountySilver]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processBountySilver]
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
	MAX( reputation.timestamp )			AS timestamp
	
FROM
	Gabs.dbo.reputation					AS reputation
	WITH								( NOLOCK, INDEX( ix_reputation_itemId ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	reputation.userId				= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		reputation.reputationActionId	= 9 --bounty
	AND	userBadge.userBadgeId			IS NULL	

GROUP BY
	reputation.userId

HAVING
	COUNT( reputation.reputationId )	>= 25

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
GRANT EXECUTE ON  [badges].[processBountySilver] TO [ProcessBadges]
GO
