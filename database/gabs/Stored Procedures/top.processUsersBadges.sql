SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @regionId		AS INT = 1 --sacramento
--DECLARE	@intervalId		AS INT = 2 --week
--DECLARE	@beginDate		AS DATETIME2 = '1/16/2011 00:00:00'
--DECLARE	@endDate		AS DATETIME2 = GETDATE()
--DECLARE	@count			AS INT = 30

CREATE PROCEDURE [top].[processUsersBadges]
	(
	@regionId		AS ForeignKey,
	@intervalId		AS ForeignKey,
	@beginDate		AS DATETIME2,
	@endDate		AS DATETIME2,
	@count			AS INT
	)
AS

--###
--[top].[processUsersBadges]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



BEGIN TRAN



DECLARE @users		TABLE
	(
	userId			INT PRIMARY KEY,
	username		VARCHAR(100),
	reputation		INT,
	topScore		INT
	)

INSERT INTO
	@users

SELECT	
	[user].userId								AS userId,
	[user].username								AS username,
	[user].reputation							AS reputation,
	COUNT( DISTINCT userBadge.userBadgeId )		AS topScore
	
FROM
	Gabs.lookup.region							AS region
	WITH										(NOLOCK, INDEX(pk_region))

	INNER JOIN
	Gabs.dbo.userRegion							AS userRegion
	WITH										( NOLOCK, INDEX( pk_userRegion ) )
	ON	region.regionId							= userRegion.regionId

	INNER JOIN
	Gabs.dbo.[user]								AS [user]
	WITH										(NOLOCK, INDEX(pk_user))
	ON	userRegion.userId						= [user].userId

	INNER JOIN
	Gabs.dbo.userBadge							AS userBadge
	WITH										(NOLOCK, INDEX(ix_userBadge_userId))
	ON	[user].userId							= userBadge.userId

WHERE
		region.regionId							= @regionId
	AND	userBadge.timestamp						BETWEEN @beginDate
												AND		@endDate
	 
GROUP BY
	[user].userId,
	[user].username,
	[user].reputation
	
ORDER BY
	topScore									DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



DELETE FROM
	Gabs.[top].topUser

WHERE
		topUser.regionId		= @regionId
	AND topUser.topTypeId		= 4 --badges
	AND topUser.intervalId		= @intervalId



INSERT INTO
	Gabs.[top].topUser

SELECT	
	@regionId									AS regionId,
    4											AS topTypeId, --badges
	@intervalId									AS intervalId,
	users.userId								AS userId,
	users.username								AS username,
	users.reputation							AS reputation,
	COUNT( DISTINCT question.questionId )		AS totalQuestions,
	COUNT( DISTINCT answer.answerId )			AS totalAnswers,
	COUNT( DISTINCT userBadge.userBadgeId )		AS totalBadges,
	users.topScore								AS topScore
	
FROM
	@users										AS users

	LEFT JOIN
	Gabs.dbo.userBadge							AS userBadge
	WITH										(NOLOCK, INDEX(ix_userBadge_userId))
	ON	users.userId							= userBadge.userId

	LEFT JOIN
	Gabs.dbo.question							AS question
	WITH										(NOLOCK, INDEX(ix_question_userId))
	ON	users.userId							= question.userId

	LEFT JOIN
	Gabs.dbo.answer								AS answer
	WITH										(NOLOCK, INDEX(ix_answer_userId))
	ON	users.userId							= answer.userId

GROUP BY
	users.userId,
	users.username,
	users.reputation,
	users.topScore
	
ORDER BY
	users.topScore								DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



COMMIT TRAN
GO
GRANT EXECUTE ON  [top].[processUsersBadges] TO [processTopLists]
GO
