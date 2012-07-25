SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@userId			AS ForeignKey = 24
--DECLARE	@answerId		AS ForeignKey = 1110459
--DECLARE	@openGrapId		AS VARCHAR(40) = 'xxxx11'
--DECLARE	@success		AS BIT				

CREATE PROCEDURE [api].[saveAnswerOpenGraphPost]
	(
	@userId			AS [ForeignKey],
	@answerId		AS [ForeignKey],
	@openGraphId	AS VARCHAR(40),
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveAnswerOpenGraphPost]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

SET @success = 0 --false



IF EXISTS
(
	SELECT
		answerFacebook.answerId		        AS answerId

	FROM
		Gabs.dbo.answerFacebook		        AS answerFacebook
		WITH							    ( NOLOCK, INDEX( ix_answerFacebook_answerId ) )
		
	WHERE
			answerFacebook.answerId         = @answerId
)
BEGIN



    UPDATE
		Gabs.dbo.answerFacebook

    SET
        openGraphId                         = @openGraphId
        
	WHERE
			answerFacebook.answerId         = @answerId


        
END 
ELSE
BEGIN



	INSERT INTO
		Gabs.dbo.answerFacebook
		(
		answerId,
		openGraphId
		)
	VALUES
		(
		@answerId,
		@openGraphId
		)



END



SET @success = 1 --true

--PRINT @success

GO
