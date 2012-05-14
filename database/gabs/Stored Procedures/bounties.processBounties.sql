SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO

--DECLARE	@beginMinutes		INT = 360
--DECLARE	@endMinutes			INT = 1440
--DECLARE	@bounty				INT = 200
--DECLARE	@count				AS INT=1000


CREATE PROCEDURE [bounties].[processBounties]
	(
	@beginMinutes		INT,
	@endMinutes			INT,
	@bounty				INT,
	@count				INT
	)
AS

--###
--[bounties].[processBounties]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



DECLARE @questions	TABLE
	(
	questionId		INT PRIMARY KEY
	)



INSERT INTO
	@questions

SELECT
	question.questionId									AS questionId

FROM
	Gabs.dbo.question									AS question
	WITH												(NOLOCK, INDEX(ix_question_longitude_latitude))

	LEFT JOIN
	Gabs.dbo.answer										AS answer
	WITH												(NOLOCK, INDEX(ix_answer_questionId))
	ON	question.questionId								= answer.questionId
	
WHERE
	   	DATEDIFF( MI, question.timestamp, GETDATE() )	BETWEEN	@beginMinutes
														AND		@endMinutes

GROUP BY
	question.questionId

HAVING
	COUNT( answer.answerId )							= 0 --no answers

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



UPDATE
	Gabs.dbo.question
	
SET
	bounty							= @bounty

FROM
	@questions						AS questions

	INNER JOIN
	Gabs.dbo.question				AS question
	WITH							(NOLOCK, INDEX(pk_question))
	ON questions.questionId			= question.questionId
GO
GRANT EXECUTE ON  [bounties].[processBounties] TO [processBounties]
GO
