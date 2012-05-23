SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [tools].[createQuestion]
	(
	@question		VARCHAR(50),
	@questionId		INT				OUTPUT
	)
AS

--###
--[tools].[createQuestion]
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Gabs.bot.question
	
VALUES
	(
	@question
	)



SELECT @questionId = SCOPE_IDENTITY()
GO
