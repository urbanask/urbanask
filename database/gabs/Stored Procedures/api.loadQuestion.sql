
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE @questionId			AS PrimaryKey = 1106064
--DECLARE @userId				AS ForeignKey = 128
--DECLARE @expirationDays		AS INT = 2

CREATE PROCEDURE [api].[loadQuestion]
	(
	@questionId			AS PrimaryKey,
	@userId				AS ForeignKey,
	@expirationDays		AS INT
	)
AS

--###
--api.loadQuestion
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DECLARE @questions	TABLE
	(
	questionId		ForeignKey PRIMARY KEY,
	userId			ForeignKey,
	username		VARCHAR(100),
	reputation		INT,
	question		VARCHAR(50),
	link			VARCHAR(256),
	latitude		DECIMAL(9,7),
	longitude		DECIMAL(10,7),
	timestamp		DATETIME2,
	resolved		INT,
	bounty			INT,
	votes			INT,
	region          VARCHAR(100)
	)



INSERT INTO	
	@questions
	
SELECT
	question.questionId						AS questionId,
	question.userId							AS userId,
	[user].username							AS username,
	[user].reputation						AS reputation,
	question.question						AS question,
	question.link							AS link,
	question.latitude						AS latitude,
	question.longitude						AS longitude,
	question.timestamp						AS timestamp,
	question.resolved						AS resolved,
	question.bounty							AS bounty,
	question.votes							AS votes,
	question.region                         AS region
	
FROM
	Gabs.dbo.question						AS question
	WITH									( NOLOCK, INDEX( pk_question ) )
	
	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									( NOLOCK, INDEX( pk_user ) )
	ON	question.userId						= [user].userId
	
WHERE
		question.questionId					= @questionId
		
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



SELECT
	questions.questionId					AS questionId,
	questions.userId						AS userId,
	questions.username						AS username,
	questions.reputation					AS reputation,
	questions.question						AS question,
	questions.link							AS link,
	questions.latitude						AS latitude,
	questions.longitude						AS longitude,
	questions.timestamp						AS timestamp,
	questions.resolved						AS resolved,
	CASE 
	WHEN DATEDIFF( D, questions.timestamp, GETDATE() ) >= @expirationDays 
	AND questions.resolved = 0 --false
	THEN 1 --true
	ELSE 0 --false
	END										AS expired,
	questions.bounty						AS bounty,
	ISNULL( questionVote.vote, 0 )			AS voted,
	questions.votes							AS votes,
	questions.region                        AS region,
	COUNT( answer.answerId )				AS answers
	
FROM
	@questions								AS questions
	
	LEFT JOIN
	Gabs.dbo.answer							AS answer
	WITH									( NOLOCK, INDEX( ix_answer_questionId ) )
	ON	questions.questionId				= answer.questionId
	
	LEFT JOIN
	Gabs.dbo.questionVote					AS questionVote
	WITH									( NOLOCK, INDEX( ix_questionVote_questionId ) )
	ON	questions.questionId				= questionVote.questionId
	AND	questionVote.userId					= @userId

GROUP BY
	questions.questionId,
	questions.userId,
	questions.username,
	questions.reputation,
	questions.question,
	questions.link,
	questions.latitude,
	questions.longitude,
	questions.timestamp,
	questions.resolved,
	questions.bounty,
	ISNULL( questionVote.vote, 0 ),
	questions.votes,
	questions.region

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )	



SELECT
	answer.answerId							AS answerId,
	answer.questionId						AS questionId,
	answer.userId							AS userId,
	[user].username							AS username,
	[user].reputation						AS reputation,
	answer.locationId						AS locationId,
	answer.location							AS location,
	answer.locationAddress					AS locationAddress,
	answer.note								AS note,
	answer.link								AS link,
	answer.phone							AS phone,
	answer.latitude							AS latitude,
	answer.longitude						AS longitude,
	answer.distance							AS distance,
	answer.timestamp						AS timestamp,
	answer.selected							AS selected,
	ISNULL( answerVote.vote, 0 )			AS voted,
	answer.votes							AS votes,
	answerFacebook.openGraphId              AS openGraphId

FROM
	Gabs.dbo.answer							AS answer
	WITH									( NOLOCK, INDEX( ix_answer_questionId ) )

	INNER JOIN
	Gabs.dbo.[user]							AS [user]
	WITH									( NOLOCK, INDEX( pk_user ) )
	ON	answer.userId						= [user].userId
	
	LEFT JOIN
	Gabs.dbo.answerVote						AS answerVote
	WITH									( NOLOCK, INDEX( ix_answerVote_answerId ) )
	ON	answer.answerId						= answerVote.answerId
	AND answerVote.userId					= @userId

    LEFT JOIN
	Gabs.dbo.answerFacebook				    AS answerFacebook
	WITH									( NOLOCK, INDEX( ix_answerFacebook_answerId ) )
    ON  answer.answerId                     = answerFacebook.answerId

WHERE
		answer.questionId					= @questionId 
	
ORDER BY
	answer.selected							DESC,
	answer.votes							DESC,
	answer.distance							ASC,
	answer.timestamp						DESC

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



SELECT
    userFacebook.facebookId                 AS facebookId,
	questionFacebook.openGraphId			AS openGraphId,
	questionFacebook.resolvedOpenGraphId	AS resolvedOpenGraphId

FROM
    Gabs.dbo.question                       AS question
    WITH                                    ( NOLOCK, INDEX( pk_question ) )
    
    LEFT JOIN
	Gabs.dbo.questionFacebook				AS questionFacebook
	WITH									( NOLOCK, INDEX( ix_questionFacebook_questionId ) )
    ON  question.questionId                 = questionFacebook.questionId
    
    LEFT JOIN
    Gabs.dbo.userFacebook                   AS userFacebook
    WITH                                    ( NOLOCK, INDEX( ix_userFacebook_userId ) )
    ON  question.userId                     = userFacebook.userId
    
WHERE
		question.questionId			        = @questionId 
	  
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )





GO
