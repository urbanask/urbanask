
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
--DECLARE	@count			AS INT = 300

CREATE PROCEDURE [top].[processUsersQuestions]
	(
	@regionId		AS ForeignKey,
	@intervalId		AS ForeignKey,
	@beginDate		AS DATETIME2,
	@endDate		AS DATETIME2,
	@count			AS INT
	)
AS

--###
--[top].[processUsersQuestions]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @topTypeId  INT = 2 --questions
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
	COUNT( question.questionId )		        AS topScore
	
FROM
	Gabs.dbo.question							AS question
	WITH										( NOLOCK, INDEX( ix_question_regionId ) )

	INNER JOIN
	Gabs.dbo.[user]								AS [user]
	WITH										( NOLOCK, INDEX( pk_user ) )
	ON	question.userId						    = [user].userId

WHERE
		question.regionId						= @regionId
	AND	question.[timestamp]					BETWEEN @beginDate
												AND		@endDate	 
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
	COUNT( question.questionId )                AS totalQuestions,
	NULL   		                                AS totalAnswers,
	NULL                            			AS totalBadges,
	users.topScore								AS topScore
	
FROM
	@users										AS users

	INNER JOIN
	Gabs.dbo.question							AS question
	WITH										( NOLOCK, INDEX( ix_question_userId ) )
	ON	users.userId							= question.userId

GROUP BY
	users.userId,
	users.username,
	users.reputation,
	users.topScore
	
ORDER BY
	users.topScore								DESC

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



UPDATE
	@topUsers
	
SET	
	totalBadges                                = 
	(
	    SELECT
	        COUNT( userBadge.userId )           AS totalBadges

        FROM
	        Gabs.dbo.userBadge					AS userBadge
	        WITH								( NOLOCK, INDEX( ix_userBadge_userId ) )
	    
	    WHERE
	        topUsers.userId						= userBadge.userId
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




GRANT EXECUTE ON  [top].[processUsersQuestions] TO [processTopLists]
GO
