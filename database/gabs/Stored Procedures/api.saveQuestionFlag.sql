SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@userId			AS ForeignKey = 1
--DECLARE	@questionId		AS ForeignKey = 4248908
--DECLARE	@success		AS BIT				

CREATE PROCEDURE [api].[saveQuestionFlag]
	(
	@userId			AS ForeignKey,
	@questionId		AS ForeignKey,
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveQuestionFlag]
--###

--###
--1. can't flag own question
--2. if already flagged, ignore
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

SET @success = 0 --false



--#1 

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



	-- #2
	
	IF EXISTS
	(
		SELECT
			questionFlag.questionId			AS questionId
			
		FROM
			Gabs.dbo.questionFlag			AS questionFlag
			WITH							( NOLOCK, INDEX( ix_questionFlag_questionId ) )

		WHERE
				questionFlag.questionId		= @questionId
			AND	questionFlag.userId			= @userId
	)
	BEGIN



		SET @success = 1;

	

	END
	ELSE
	BEGIN



		INSERT INTO
			Gabs.dbo.questionFlag
			(
			questionId,
			userId
			)
		VALUES
			(
			@questionId,
			@userId
			)



		SET @success = 1;



	END



END


--PRINT @success

GO
