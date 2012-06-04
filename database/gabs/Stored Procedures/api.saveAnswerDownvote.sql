
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--DECLARE	@userId			AS ForeignKey = 1
--DECLARE	@answerId		AS ForeignKey = 4248908
--DECLARE	@success		AS BIT

CREATE PROCEDURE [api].[saveAnswerDownvote]
	(
	@userId			AS ForeignKey,
	@answerId		AS ForeignKey,
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveAnswerDownvote]
--###

--###
--1. can't vote on own answer
--2. if already voted on another answer, delete other answer.vote and answerVote, update answer.vote, insert new answerVote
--3. else if already voted on this answer, delete answer.vote and answerVote
--4. else update answer.vote, insert answerVote
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

DECLARE @alreadyAnswered	BIT	= 0 --false
DECLARE @questionId			ForeignKey
SET @success = 0 --false

SELECT
	@questionId				= answer.questionId

FROM
	Gabs.dbo.answer			AS answer
	WITH					( NOLOCK, INDEX( pk_answer ) )

WHERE
	answer.answerId			= @answerId

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



--#1 can't vote on own answer

IF NOT EXISTS
(
	SELECT
		answer.answerId				AS answerId

	FROM
		Gabs.dbo.answer				AS answer
		WITH						( NOLOCK, INDEX( pk_answer ) )

	WHERE
			answer.answerId			= @answerId
		AND answer.userId			= @userId 
)
BEGIN
	


	-- #3 else if already voted on this answer, delete answer.vote and answerVote
	
	IF EXISTS
	(
		SELECT
			answer.answerId					AS answerId
		
		FROM
			Gabs.dbo.answer					AS answer
			WITH							( NOLOCK, INDEX( pk_answer ) )

			INNER JOIN
			Gabs.dbo.answerVote				AS answerVote
			WITH							( NOLOCK, INDEX( ix_answerVote_answerId ) )
			ON	answer.answerId				= answerVote.answerId

		WHERE
				answer.answerId				= @answerId
			AND	answerVote.userId			= @userId
			AND answerVote.vote				= -1 --downvote
	)
	BEGIN

		SET @alreadyAnswered = 1 --true
		SET @success = 1 --true

	END
	
	
	
	-- #2 if already voted on another answer, delete other answer.vote and answerVote, update answer.vote, insert new answerVote
	-- #3 else if already voted on this answer, delete answer.vote and answerVote
	
	IF EXISTS
	(
		SELECT
			answer.answerId					AS answerId
			
		FROM
			Gabs.dbo.answer					AS answer
			WITH							( NOLOCK, INDEX( ix_answer_questionId ) )

			INNER JOIN
			Gabs.dbo.answerVote				AS answerVote
			WITH							( NOLOCK, INDEX( ix_answerVote_answerId ) )
			ON	answer.answerId				= answerVote.answerId

		WHERE
				answer.questionId			= @questionId
			AND	answerVote.userId			= @userId
	)
	BEGIN
	

	
		UPDATE
			Gabs.dbo.answer
			
		SET
			votes						= votes - answerVote.vote

		FROM
			Gabs.dbo.answer				AS answer
			WITH						( NOLOCK, INDEX( ix_answer_questionId ) )

			INNER JOIN
			Gabs.dbo.answerVote			AS answerVote
			WITH						( NOLOCK, INDEX( ix_answerVote_answerId ) )
			ON	answer.answerId			= answerVote.answerId

		WHERE
				answer.questionId		= @questionId
			AND	answerVote.userId		= @userId



		DELETE
			Gabs.dbo.answerVote
			
		FROM
			Gabs.dbo.answer					AS answer
			WITH							( NOLOCK, INDEX( ix_answer_questionId ) )

			INNER JOIN
			Gabs.dbo.answerVote				AS answerVote
			WITH							( NOLOCK, INDEX( ix_answerVote_answerId ) )
			ON	answer.answerId				= answerVote.answerId

		WHERE
				answer.questionId			= @questionId
			AND	answerVote.userId			= @userId



	END
	
	
	
	-- #4 else update answer.vote, insert answerVote
	
	IF @alreadyAnswered = 0 --false
	BEGIN
	

	
		UPDATE
			Gabs.dbo.answer
			
		SET
			votes				= votes - 1 --downvote

		WHERE
				answerId		= @answerId



		INSERT INTO
			Gabs.dbo.answerVote
			(
			answerId,
			userId,
			vote
			)
		VALUES
			(
			@answerId,
			@userId,
			-1 --downvote
			)
		

		
		SET @success = 1; --true



	END



END


--PRINT @success

GO
