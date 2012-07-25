SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--DECLARE	@userId			AS ForeignKey = 24
--DECLARE	@questionId		AS ForeignKey = 1110459
--DECLARE	@openGrapId		AS VARCHAR(40) = 'xxxx11'
--DECLARE	@success		AS BIT				

CREATE PROCEDURE [api].[saveQuestionOpenGraphResolved]
	(
	@userId			AS ForeignKey,
	@questionId		AS ForeignKey,
	@openGraphId	AS VARCHAR(40),
	@success		AS BIT				OUTPUT
	)
AS

--###
--[api].[saveQuestionOpenGraphResolved]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



--variables

SET @success = 0 --false



UPDATE
	Gabs.dbo.questionFacebook

SET
    resolvedOpenGraphId                 = @openGraphId
    
WHERE
		questionFacebook.questionId     = @questionId


        
SET @success = 1 --true

--PRINT @success

GO
