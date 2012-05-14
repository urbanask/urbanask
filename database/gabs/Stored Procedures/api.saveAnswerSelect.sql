SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--DECLARE	@userId			AS ForeignKey = 1
--DECLARE	@answerId		AS ForeignKey = 4248167
--DECLARE @questionId		AS ForeignKey = 1104484
--DECLARE @success			AS BIT	


CREATE PROCEDURE [api].[saveAnswerSelect]
	(
	@userId			AS ForeignKey,
	@questionId		AS ForeignKey,
	@answerId		AS ForeignKey,
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveAnswerSelect]
--###

--###
--1. can't select if not @userId's question
--2. if question already resolved, unselect old answer
--3. if answer already selected, unselect & unresolve question
--4. update question.resolved, answer.selected
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

SET @success = 0; --false, default



--#1. can't select if not @userId's question

IF EXISTS
(
	SELECT
		question.questionId				AS questionId

	FROM
		Gabs.dbo.question				AS question
		WITH							(NOLOCK, INDEX(pk_question))
		
		INNER JOIN
		Gabs.dbo.answer					AS answer
		WITH							(NOLOCK, INDEX(ix_answer_questionId))
		ON	question.questionId			= answer.questionId
		
	WHERE
			question.questionId			= @questionId
		AND	question.userId				= @userId
		AND answer.answerId				= @answerId
)
BEGIN



	-- variables
	
	DECLARE @selected	BIT = 1
	DECLARE @resolved	BIT = 1



	-- #3. if answer already selected, unselect & unresolve question
	
	IF EXISTS
	(
		SELECT
			answer.answerId			AS answerId

		FROM
			Gabs.dbo.answer			AS answer
			WITH					( NOLOCK, INDEX( pk_answer ) )
			
		WHERE
				answer.answerId		= @answerId
			AND	answer.selected		= 1	--true
	)
	BEGIN



		SET @selected = 0 --false
		SET @resolved = 0 --false



	END



	--#2. if question already resolved, unselect old answer
	
	UPDATE
		Gabs.dbo.answer
		
	SET
		answer.selected			= 0 --false
		
	WHERE
			answer.questionId	= @questionId
		AND	answer.selected		= 1	--true



	--#4. update question.resolved, answer.selected
	
	UPDATE
		Gabs.dbo.question
		
	SET
		question.resolved			= @resolved
		
	WHERE
			question.questionId		= @questionId



	UPDATE
		Gabs.dbo.answer
		
	SET
		selected			= @selected
		
	WHERE
			answerId		= @answerId
			
			
			
	IF @selected = 1
	BEGIN
	
	
	
		DECLARE @answerUserId INT
		
		SELECT
			@answerUserId			= answer.userId
			
		FROM
			Gabs.dbo.answer			AS answer
			WITH					( NOLOCK, INDEX( pk_answer ) )
			
		WHERE
			answer.answerId			= @answerId

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
			@answerUserId,
			3, --answer selected
			1, --question
			@questionId,
			GETDATE()
			)
	
	
	
	END
	
	
	
	SET @success = 1; --true
		
		
		
END
			
GO
