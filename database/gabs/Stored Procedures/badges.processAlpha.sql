SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@badgeId		AS INT = 6 --alpha
--DECLARE	@unlimited		AS INT = 0 --false
--DECLARE	@days			AS INT = 5
--DECLARE	@count			AS INT = 100

CREATE PROCEDURE [badges].[processAlpha]
	(
	@badgeId		AS ForeignKey,
	@unlimited		AS INT,
	@days			AS INT,
	@count			AS INT
	)
AS

--###
--[badges].[processAlpha]
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
		[user].signupDate				< '3/1/2012'
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

GO
GRANT EXECUTE ON  [badges].[processAlpha] TO [ProcessBadges]
GO
