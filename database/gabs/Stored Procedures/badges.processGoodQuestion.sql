SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 9 --good question
--DECLARE	@unlimited		AS INT = 1 --false
--DECLARE	@days			AS INT = 30
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processGoodQuestion]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processGoodQuestion]
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
	WITH								( NOLOCK, INDEX( ix_question_longitude_latitude ) )

	LEFT JOIN
	Gabs.dbo.userBadge					AS userBadge
	WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	question.userId					= userBadge.userId
	AND userBadge.badgeId				= @badgeId

WHERE
		question.timestamp				> DATEADD( d, -@days, GETDATE() )
	AND	question.votes					>= 25 --good question
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
GRANT EXECUTE ON  [badges].[processGoodQuestion] TO [ProcessBadges]
GO
