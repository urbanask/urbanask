SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@userId		AS ForeignKey = 1
--DECLARE	@type		AS VARCHAR(50) = 'postQuestion'

CREATE PROCEDURE [api].[saveInstructionViewed]
	(
	@userId		AS ForeignKey,
	@type		AS VARCHAR(50)
	)
AS

--###
--[api].[saveInstructionViewed]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF @type = 'postQuestion'
BEGIN



	UPDATE
		Gabs.dbo.userInstructions
		
	SET
		postQuestion						= 1 --true
		
	WHERE
			userInstructions.userId			= @userId 



END
ELSE IF @type = 'viewQuestions'
BEGIN



	UPDATE
		Gabs.dbo.userInstructions
		
	SET
		viewQuestions						= 1 --true
		
	WHERE
			userInstructions.userId			= @userId 



END
ELSE IF @type = 'viewQuestion'
BEGIN



	UPDATE
		Gabs.dbo.userInstructions
		
	SET
		viewQuestion						= 1 --true
		
	WHERE
			userInstructions.userId			= @userId 



END
ELSE IF @type = 'addAnswer'
BEGIN



	UPDATE
		Gabs.dbo.userInstructions
		
	SET
		addAnswer							= 1 --true
		
	WHERE
			userInstructions.userId			= @userId 



END
ELSE IF @type = 'toolbar'
BEGIN



	UPDATE
		Gabs.dbo.userInstructions
		
	SET
		toolbar								= 1 --true
		
	WHERE
			userInstructions.userId			= @userId 



END
GO
