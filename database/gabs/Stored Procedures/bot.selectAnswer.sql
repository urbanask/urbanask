
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [bot].[selectAnswer]

AS

--###
--bot.selectAnswer
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DECLARE @chance		INT = 2 -- 2%
DECLARE @daysOld	INT = 4 -- 4 days


DECLARE @questions	TABLE
	(
	questionId		INT,
	chance			INT
	)

INSERT INTO
	@questions
	
SELECT DISTINCT
	question.questionId			AS questionId,
	ROUND( ( RAND( CAST( NEWID() AS VARBINARY ) ) * ( 100 - 1 ) ) + 1, 0 )	AS chance

FROM
	Gabs.bot.[user]				AS [user]
	WITH						( NOLOCK, INDEX( pk_botUser ) )
	
	INNER JOIN
	Gabs.dbo.question			AS question
	WITH						( NOLOCK, INDEX( ix_question_userId ) )
	ON	[USER].userId			= question.userId
	
	INNER JOIN
	Gabs.dbo.answer				AS answer
	WITH						( NOLOCK, INDEX( ix_answer_questionId ) )
	ON	question.questionId		= answer.questionId
	
WHERE
		question.resolved		= 0 -- false
	AND	question.timestamp		< DATEADD( DAY, -@daysOld, GETDATE() ) 

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



IF EXISTS(
	SELECT
		questions.questionId	AS questionId
		
	FROM
		@questions				AS questions
		
	WHERE
		questions.chance		<= @chance
)
BEGIN



	UPDATE
		Gabs.dbo.question
		
	SET
		resolved					= 1 --true
		
	FROM
		@questions					AS questions
		
		INNER JOIN
		Gabs.dbo.question			AS question
		WITH						( NOLOCK, INDEX( pk_question ) )
		ON	questions.questionId	= question.questionId
		
	WHERE
		questions.chance			<= @chance

	OPTION
		  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



	DECLARE @answers	TABLE
		(
		row				INT,
		answerId		INT
		)

	INSERT INTO
		@answers
		
	SELECT
		ROW_NUMBER() OVER ( 
			PARTITION BY
				answer.questionId
			ORDER BY
				answer.votes		DESC,
				answer.distance		ASC,
				answer.timestamp	DESC
		)									AS number, 
		answer.answerId						AS answerId
		
	FROM
		@questions							AS questions
		
		INNER JOIN
		Gabs.dbo.answer						AS answer
		WITH								( NOLOCK, INDEX( ix_answer_questionId ) )
		ON	questions.questionId			= answer.questionId
	
	WHERE
			questions.chance				<= @chance

	OPTION
		  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



	UPDATE
		Gabs.dbo.answer
	
	SET
		selected				= 1 --true
		
	FROM
		@answers				AS answers
		
		INNER JOIN
		Gabs.dbo.answer			AS answer
		WITH					( NOLOCK, INDEX( pk_answer ) )
		ON answers.answerId		= answer.answerId
		
	WHERE
		answers.row				= 1 -- first row

	OPTION
		  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



END


GO
