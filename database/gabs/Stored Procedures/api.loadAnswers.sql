SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@questionId 		AS ForeignKey=1110495
--DECLARE	@locationAddress	AS VARCHAR(100) = '2508 J Street, Sacramento'
--DECLARE	@answerId	        AS ForeignKey

CREATE PROCEDURE [api].[loadAnswers]
	(
	@questionId		    AS ForeignKey,
	@locationAddress	AS VARCHAR(100),
	@answerId		    AS ForeignKey		OUTPUT
	)
AS

--###
--[api].[loadAnswers]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	@answerId                       = answer.answerId

FROM
	Gabs.dbo.answer					AS answer
	WITH							( NOLOCK, INDEX( ix_answer_questionId ) )

WHERE
		answer.questionId			= @questionId 
	AND answer.locationAddress      = @locationAddress
	
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


PRINT @answerId


GO
