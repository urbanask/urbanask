SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 18 --beta
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 200
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processBeta]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processBeta]
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
		[user].signupDate				< '4/1/2012'
	AND	[user].reputation				> 200 --at least 200 reputation
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
GRANT EXECUTE ON  [badges].[processBeta] TO [ProcessBadges]
GO
