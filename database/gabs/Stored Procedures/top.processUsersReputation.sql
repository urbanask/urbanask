
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @regionId		AS INT = 1 --sacramento
--DECLARE	@intervalId		AS INT = 3 --month
--DECLARE	@beginDate		AS DATETIME2 = '5/1/2012 00:00:00'
--DECLARE	@endDate		AS DATETIME2 = GETDATE()
--DECLARE	@count			AS INT = 300

CREATE PROCEDURE [top].[processUsersReputation]
	(
	@regionId		AS ForeignKey,
	@intervalId		AS ForeignKey,
	@beginDate		AS DATETIME2,
	@endDate		AS DATETIME2,
	@count			AS INT
	)
AS

--###
--[top].[processUsersReputation]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @topTypeId  INT = 1 --reputation
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
	[union].userId								    AS userId,
	[user].username							        AS username,
	[user].reputation							    AS reputation,
	SUM( [union].topScore )				            AS topScore

FROM
(
    --###
    --question reputation
    --###
     
    SELECT	
	    question.userId								AS userId,
	    SUM( reputation.reputation )				AS topScore

    FROM
	    Gabs.dbo.question							AS question
	    WITH										( NOLOCK, INDEX( ix_question_longitude_latitude ) )

	    INNER JOIN
	    Gabs.dbo.reputation							AS reputation
	    WITH										( NOLOCK, INDEX( ix_reputation_userId ) )
	    ON	question.userId							= reputation.userId
        AND question.questionId                     = reputation.itemId
        
        INNER JOIN
        Gabs.[lookup].reputationAction              AS reputationAction
        WITH                                        ( NOLOCK, INDEX( pk_reputationAction ) )
        ON  reputation.reputationActionId           = reputationAction.reputationActionId
        
    WHERE
		    question.regionId						= @regionId
	    AND	reputation.[timestamp]					BETWEEN @beginDate AND @endDate
        AND reputationAction.[object]               = 'question'
    	 
    GROUP BY
	    question.userId

    UNION
    	
    --###
    --answer reputation
    --###
     
    SELECT
	    answer.userId								AS userId,
	    SUM( reputation.reputation )				AS topScore

    FROM
        Gabs.dbo.question							AS question
        WITH										( NOLOCK, INDEX( ix_question_longitude_latitude ) )

        INNER JOIN
        Gabs.dbo.answer								AS answer
        WITH										( NOLOCK, INDEX( ix_answer_questionId ) )
        ON	question.questionId						= answer.questionId

        INNER JOIN
        Gabs.dbo.reputation							AS reputation
        WITH										( NOLOCK, INDEX( ix_reputation_userId ) )
        ON	answer.userId							= reputation.userId
        AND answer.answerid                         = reputation.itemId
        
        INNER JOIN
        Gabs.[lookup].reputationAction              AS reputationAction
        WITH                                        ( NOLOCK, INDEX( pk_reputationAction ) )
        ON  reputation.reputationActionId           = reputationAction.reputationActionId
        
    WHERE
            question.regionId						= @regionId
        AND	reputation.[timestamp]					BETWEEN @beginDate AND @endDate
        AND reputationAction.[object]               = 'answer'

    GROUP BY
	    answer.userId

)                                                   AS [union]

    INNER JOIN
    Gabs.dbo.[user]								    AS [user]
    WITH										    ( NOLOCK, INDEX( pk_user ) )
    ON	[union].userId						        = [user].userId


GROUP BY
    [union].userId,
    [user].username,
    [user].reputation

HAVING
	SUM( [union].topScore ) 				        > 0
	
ORDER BY
	CASE 
	WHEN ( SUM( [union].topScore ) > [user].reputation )
	THEN [user].reputation
	ELSE SUM( [union].topScore )	
	END											    DESC
	
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )	



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
	NULL                                		AS totalBadges,
	CASE 
	WHEN (users.topScore > users.reputation)
	THEN users.reputation
	ELSE users.topScore	END						AS topScore
	
FROM
	@users										AS users

ORDER BY
	users.topScore								DESC

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )	



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


GRANT EXECUTE ON  [top].[processUsersReputation] TO [processTopLists]
GO
