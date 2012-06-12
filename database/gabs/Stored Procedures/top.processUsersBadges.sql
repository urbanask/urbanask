
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



DECLARE @topTypeId  INT = 4 --badges
DECLARE @users		TABLE
	(
	userId			INT NOT NULL PRIMARY KEY,
	username		VARCHAR(100),
	reputation		INT,
	topScore		INT
	)



--###
--load question users
--###
 
INSERT INTO
	@users

SELECT	
	[user].userId								AS userId,
	[user].username								AS username,
	[user].reputation							AS reputation,
	COUNT( DISTINCT userBadge.userBadgeId )		AS topScore
	
FROM
	Gabs.dbo.question							AS question
	WITH										( NOLOCK, INDEX( ix_question_longitude_latitude ) )

	INNER JOIN
	Gabs.dbo.[user]								AS [user]
	WITH										( NOLOCK, INDEX( pk_user ) )
	ON	question.userId						    = [user].userId

	INNER JOIN
	Gabs.dbo.userBadge							AS userBadge
	WITH										( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	[user].userId							= userBadge.userId

WHERE
		question.regionId						= @regionId
	AND	userBadge.[timestamp]					BETWEEN @beginDate
												AND		@endDate	 
GROUP BY
	[user].userId,
	[user].username,
	[user].reputation
	
ORDER BY
	topScore									DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



--###
--load answer users
--###
 
INSERT INTO
	@users

SELECT	
	[user].userId								AS userId,
	[user].username								AS username,
	[user].reputation							AS reputation,
	COUNT( DISTINCT userBadge.userBadgeId )		AS topScore
	
FROM
	Gabs.dbo.question							AS question
	WITH										( NOLOCK, INDEX( ix_question_longitude_latitude ) )

	INNER JOIN
	Gabs.dbo.answer								AS answer
	WITH										( NOLOCK, INDEX( ix_answer_questionId ) )
	ON	question.questionId						= answer.questionId

    LEFT JOIN
    @users                                      AS users
    ON  answer.userId                           = users.userId
    
	INNER JOIN
	Gabs.dbo.[user]								AS [user]
	WITH										( NOLOCK, INDEX( pk_user ) )
	ON	answer.userId						    = [user].userId

	INNER JOIN
	Gabs.dbo.userBadge							AS userBadge
	WITH										( NOLOCK, INDEX( ix_userBadge_userId ) )
	ON	[user].userId							= userBadge.userId
    
WHERE
		question.regionId						= @regionId
	AND userBadge.[timestamp]					BETWEEN @beginDate
	                                            AND     @endDate
	AND users.userId					        IS NULL
	
GROUP BY
	[user].userId,
	[user].username,
	[user].reputation
	
ORDER BY
	topScore									DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	
	  

	  
DECLARE @topUsers		TABLE
	(
	regionId			INT,
	topTypeId			INT,
	intervalId			INT,
	userId				INT,
	username			VARCHAR(100),
	reputation			INT,
	totalQuestions		INT,
	totalAnswers		INT,
	totalBadges			INT,
	topScore			INT
	)

INSERT INTO
	@topUsers
	
SELECT	
	@regionId									AS regionId,
    @topTypeId									AS topTypeId, 
	@intervalId									AS intervalId,
	users.userId								AS userId,
	users.username								AS username,
	users.reputation							AS reputation,
	NULL                                		AS totalQuestions,
	NULL                            			AS totalAnswers,
	users.topScore              		        AS totalBadges,
	users.topScore								AS topScore
	
FROM
	@users										AS users

ORDER BY
	users.topScore								DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



UPDATE
	@topUsers
	
SET	
	totalQuestions                              = 
	(
	    SELECT
	        COUNT( question.userId )            AS totalQuestions

        FROM
	        Gabs.dbo.question					AS question
	        WITH								( NOLOCK, INDEX( ix_question_userId ) )
	    
	    WHERE
	        topUsers.userId						= question.userId
	)
	
FROM
	@topUsers									AS topUsers

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



UPDATE
	@topUsers
	
SET	
	totalAnswers                                = 
	(
	    SELECT
	        COUNT( answer.userId )              AS totalAnswers

        FROM
	        Gabs.dbo.answer					    AS answer
	        WITH								( NOLOCK, INDEX( ix_answer_userId ) )
	    
	    WHERE
	        topUsers.userId						= answer.userId
	)
	
FROM
	@topUsers									AS topUsers

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	



DELETE FROM
	Gabs.[top].topUser

WHERE
		topUser.regionId		= @regionId
	AND topUser.topTypeId		= @topTypeId
	AND topUser.intervalId		= @intervalId



INSERT INTO
	Gabs.[top].topUser

SELECT
	regionId,
	topTypeId,
	intervalId,
	userId,
	username,
	reputation,
	totalQuestions,
	totalAnswers,
	totalBadges,
	topScore

FROM
	@topUsers
GO


GRANT EXECUTE ON  [top].[processUsersBadges] TO [processTopLists]
GO
