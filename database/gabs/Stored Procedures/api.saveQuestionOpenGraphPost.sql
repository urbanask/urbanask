SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@userId			AS ForeignKey = 24
--DECLARE	@questionId		AS ForeignKey = 1110459
--DECLARE	@openGrapId		AS VARCHAR(40) = 'xxxx11'
--DECLARE	@success		AS BIT				

CREATE PROCEDURE [api].[saveQuestionOpenGraphPost]
	(
	@userId			AS ForeignKey,
	@questionId		AS ForeignKey,
	@openGraphId	AS VARCHAR(40),
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveQuestionOpenGraphPost]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

SET @success = 0 --false



IF EXISTS
(
	SELECT
		questionFacebook.questionId		    AS questionId

	FROM
		Gabs.dbo.questionFacebook		    AS questionFacebook
		WITH							    ( NOLOCK, INDEX( ix_questionFacebook_questionId ) )
		
	WHERE
			questionFacebook.questionId     = @questionId
)
BEGIN



    UPDATE
		Gabs.dbo.questionFacebook

    SET
        openGraphId                         = @openGraphId
        
	WHERE
			questionFacebook.questionId     = @questionId


        
END 
ELSE
BEGIN



	INSERT INTO
		Gabs.dbo.questionFacebook
		(
		questionId,
		openGraphId
		)
	VALUES
		(
		@questionId,
		@openGraphId
		)



END



SET @success = 1 --true

--PRINT @success

GO
