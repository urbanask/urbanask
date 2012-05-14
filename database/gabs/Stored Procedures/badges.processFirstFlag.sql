SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 19 --first flag
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 30
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processFirstFlag]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processFirstFlag]
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
	questionFlag.userId					AS userId,
	MIN( questionFlag.timestamp )		AS timestamp
	
FROM
	Gabs.dbo.questionFlag				AS questionFlag
	WITH								( NOLOCK, INDEX( ix_questionFlag_timestamp ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	questionFlag.userId				= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		questionFlag.timestamp			> DATEADD( d, -@days, GETDATE() )
	AND	userBadge.userBadgeId			IS NULL	

GROUP BY
	questionFlag.userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	@badges

SELECT
	answerFlag.userId					AS userId,
	MIN( answerFlag.timestamp )			AS timestamp
	
FROM
	Gabs.dbo.answerFlag					AS answerFlag
	WITH								( NOLOCK, INDEX( ix_answerFlag_timestamp ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	answerFlag.userId				= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		answerFlag.timestamp			> DATEADD( d, -@days, GETDATE() )
	AND	userBadge.userBadgeId			IS NULL	

GROUP BY
	answerFlag.userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



INSERT INTO
	Gabs.dbo.userBadge

SELECT
	badges.userId				AS userId,
	@badgeId					AS badgeId,
	MIN( badges.timestamp )		AS timestamp

FROM
	@badges						AS badges

GROUP BY
	badges.userId

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
	MIN( badges.timestamp )		AS timestamp

FROM
	@badges						AS badges

GROUP BY
	badges.userId

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

GO
GRANT EXECUTE ON  [badges].[processFirstFlag] TO [ProcessBadges]
GO
