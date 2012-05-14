SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@userId			AS ForeignKey = 1
--DECLARE	@answerId		AS ForeignKey = 4248908
--DECLARE	@success		AS BIT				

CREATE PROCEDURE [api].[saveAnswerFlag]
	(
	@userId			AS ForeignKey,
	@answerId		AS ForeignKey,
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveAnswerFlag]
--###

--###
--1. can't flag own answer
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
		answer.answerId					AS answerId

	FROM
		Gabs.dbo.answer					AS answer
		WITH							( NOLOCK, INDEX( pk_answer ) )
		
	WHERE
			answer.answerId				= @answerId
		AND	answer.userId				= @userId
)
BEGIN



	-- #2
	
	IF EXISTS
	(
		SELECT
			answerFlag.answerId				AS answerId
			
		FROM
			Gabs.dbo.answerFlag				AS answerFlag
			WITH							( NOLOCK, INDEX( ix_answerFlag_answerId ) )

		WHERE
				answerFlag.answerId			= @answerId
			AND	answerFlag.userId			= @userId
	)
	BEGIN



		SET @success = 1;

	

	END
	ELSE
	BEGIN



		INSERT INTO
			Gabs.dbo.answerFlag
			(
			answerId,
			userId
			)
		VALUES
			(
			@answerId,
			@userId
			)



		SET @success = 1;



	END



END


--PRINT @success

GO
