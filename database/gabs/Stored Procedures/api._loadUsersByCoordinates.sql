SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@latitude		AS DECIMAL(9,7)=38
--DECLARE	@longitude		AS DECIMAL(10,7)=-121	
--DECLARE	@count			AS INT=24

CREATE PROCEDURE [api].[_loadUsersByCoordinates]
	(
	@latitude		AS DECIMAL(9,7),
	@longitude		AS DECIMAL(10,7),
	@count			AS INT
	)
AS

--###
--api.loadUsersByCoordinates
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @users			TABLE
	(
	userId				PrimaryKey PRIMARY KEY,
	username			VARCHAR(100),
	displayName			VARCHAR(100),
	reputation			INT,
	signupDate			DATETIME2,
	tagline				VARCHAR(256)
	)



INSERT INTO	
	@users
	
SELECT
	[user].userId							AS userId,
	[user].username							AS username,
	[user].displayName						AS displayName,
	[user].reputation						AS reputation,
	[user].signupDate						AS signupDate,
	[user].tagline							AS tagline
	
FROM
	Gabs.dbo.userLocation					userLocation
	WITH									(NOLOCK, INDEX(ix_userLocation_bounds))
	
	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									(NOLOCK, INDEX(pk_user))
	ON	userLocation.userId					= [user].userId
		
WHERE
		@longitude							BETWEEN userLocation.fromLongitude 
											AND		userLocation.toLongitude
	AND	@latitude							BETWEEN userLocation.fromLatitude 
											AND		userLocation.toLatitude 

ORDER BY
	[user].reputation						DESC
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT	
	users.userId							AS userId,
	users.username							AS username,
	users.displayName						AS displayName,
	users.reputation						AS reputation,
	users.signupDate						AS signupDate,
	users.tagline							AS tagline,
	COUNT( DISTINCT question.questionId )	AS totalQuestions,
	COUNT( DISTINCT answer.answerId )		AS totalAnswers,
	COUNT( DISTINCT userBadge.userBadgeId )	AS totalBadges
	
FROM
	@users									AS users
	
	LEFT JOIN
	Gabs.dbo.question						AS question
	WITH									(NOLOCK, INDEX(ix_question_userId))
	ON	users.userId						= question.userId

	LEFT JOIN
	Gabs.dbo.answer							AS answer
	WITH									(NOLOCK, INDEX(ix_answer_userId))
	ON	users.userId						= answer.userId

	LEFT JOIN
	Gabs.dbo.userBadge						AS userBadge
	WITH									(NOLOCK, INDEX(ix_userBadge_userId))
	ON	users.userId						= userBadge.userId

GROUP BY
	users.userId,
	users.username,
	users.displayName,
	users.reputation,
	users.signupDate,
	users.tagline
	
ORDER BY
	[users].reputation						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	
GO
