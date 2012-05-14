SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--DECLARE	@userId			AS ForeignKey = 1001
--DECLARE	@questionId		AS ForeignKey = 1104484
--DECLARE	@success		AS BIT

CREATE PROCEDURE [api].[saveQuestionUpvote]
	(
	@userId			AS ForeignKey,
	@questionId		AS ForeignKey,
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveQuestionUpvote]
--###

--###
--#1. can't vote on own question
--#2. if already voted on this question, subtract question.vote, delete questionVote
--#3. else add question.vote, insert questionVote
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

SET @success = 0 --false



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
	)
	BEGIN



		-- #2. if already voted on this question, subtract question.vote and questionVote

		UPDATE
			Gabs.dbo.question
			
		SET
			votes							= votes - questionVote.vote

		FROM
			Gabs.dbo.question				AS question
			WITH							( NOLOCK, INDEX( pk_question ) )

			INNER JOIN
			Gabs.dbo.questionVote			AS questionVote
			WITH							( NOLOCK, INDEX( ix_questionVote_questionId ) )
			ON	question.questionId			= questionVote.questionId

		WHERE
				question.questionId			= @questionId
			AND	questionVote.userId			= @userId



		DELETE
			Gabs.dbo.questionVote
			
		WHERE
				questionVote.questionId		= @questionId
			AND	questionVote.userId			= @userId



	END
	ELSE
	BEGIN



		-- #3. else add question.vote, insert questionVote
		
		UPDATE
			Gabs.dbo.question
			
		SET
			votes						= votes + 1

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
			1
			)
		
		

		DECLARE @questionUserId INT
		
		SELECT
			@questionUserId			= question.userId
			
		FROM
			Gabs.dbo.question		AS question
			WITH					( NOLOCK, INDEX( pk_question ) )
			
		WHERE
			question.questionId		= @questionId

		OPTION
			( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



		INSERT INTO
			Gabs.dbo.userNotification
			(
			userId,
			notificationId,
			objectTypeId,
			itemId,
			timestamp
			)
		VALUES
			(
			@questionUserId,
			2, --question upvoted
			1, --question
			@questionId,
			GETDATE()
			)



	END



	SET @success = 1; --true



END
GO
