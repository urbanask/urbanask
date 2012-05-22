
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [messaging].[insertQuestionMessage]
	(
	@message	AS VARCHAR(150),
	@processed	AS BIT			OUTPUT
	)
AS

--###
--[messaging].[insertQuestionMessage]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



--###
--default
--###
 
SELECT @processed = 0;



INSERT INTO
	Messaging.questions.questionQueue	
	(
	[message]
	)
    
VALUES
	(
	@message
	)



--###
--success
--###

SELECT @processed = 1;



GO
