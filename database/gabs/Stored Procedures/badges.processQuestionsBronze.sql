SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 33 --inquisitive - questions - bronze
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 300
--DECLARE	@count			AS INT = 1000

CREATE PROCEDURE [badges].[processQuestionsBronze]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processQuestionsBronze]
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
	question.timestamp					AS timestamp
	
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
	AND	userBadge.userBadgeId			IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



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

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)

GO
GRANT EXECUTE ON  [badges].[processQuestionsBronze] TO [ProcessBadges]
GO
