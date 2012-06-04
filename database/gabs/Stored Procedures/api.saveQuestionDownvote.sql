SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--DECLARE	@userId			AS ForeignKey = 1001
--DECLARE	@questionId		AS ForeignKey = 1104484
--DECLARE	@success		AS BIT

CREATE PROCEDURE [api].[saveQuestionDownvote]
	(
	@userId			AS ForeignKey,
	@questionId		AS ForeignKey,
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveQuestionDownvote]
--###

--###
--#1. can't vote on own question
--#2. if already downvoted this question, +1 question.vote, delete questionVote
--#3. if already upvoted this question, -2 question.vote, update questionVote to -1
--#4. else update -1 question.vote, insert -1 questionVote
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

SET @success			= 0 --false



--#1. can't vote on own question

IF NOT EXISTS
(
	SELECT
		question.questionId				AS questionId

	FROM
		Gabs.dbo.question				AS question
		WITH							( NOLOCK, INDEX( pk_question ) )
		
	WHERE
			question.questionId			= @questionId
		AND	question.userId				= @userId
)
BEGIN
	

		
	--#2. if already downvoted this question, +1 question.vote, delete questionVote

	IF EXISTS
		(
		SELECT
			questionVote.questionId			AS questionId
		
		FROM
			Gabs.dbo.questionVote			AS questionVote
			WITH							( NOLOCK, INDEX( ix_questionVote_questionId ) )

		WHERE
				questionVote.questionId		= @questionId
			AND	questionVote.userId			= @userId
			AND questionVote.vote			= -1 --downvote
		)
	BEGIN



		UPDATE
			Gabs.dbo.question
			
		SET
			votes							= votes + 1

		WHERE
				question.questionId			= @questionId



		DELETE
			Gabs.dbo.questionVote
			
		WHERE
				questionVote.questionId		= @questionId
			AND	questionVote.userId			= @userId



	END
	
	--#3. if already upvoted this question, -2 question.vote, update questionVote to -1
	
	ELSE IF EXISTS
		(
		SELECT
			questionVote.questionId			AS questionId
		
		FROM
			Gabs.dbo.questionVote			AS questionVote
			WITH							( NOLOCK, INDEX( ix_questionVote_questionId ) )

		WHERE
				questionVote.questionId		= @questionId
			AND	questionVote.userId			= @userId
			AND questionVote.vote			= 1 --upvote
		)
	BEGIN



		UPDATE
			Gabs.dbo.question
			
		SET
			votes						= votes - 2

		WHERE
				question.questionId		= @questionId




		UPDATE
			Gabs.dbo.questionVote			
			
		SET
			questionVote.vote				= -1 --downvote

		WHERE
				questionVote.questionId		= @questionId
			AND	questionVote.userId			= @userId



	END
	
	--#4. else update -1 question.vote, insert -1 questionVote

	ELSE
	BEGIN
	

		UPDATE
			Gabs.dbo.question
			
		SET
			votes						= votes - 1

		WHERE
				question.questionId		= @questionId



		INSERT INTO
			Gabs.dbo.questionVote
			(
			questionId,
			userId,
			vote
			)
		VALUES
			(
			@questionId,
			@userId,
			-1 --downvote
			)
		
		
		
	END



	SET @success = 1; --true



END
GO
