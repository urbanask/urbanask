SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [messaging].[insertAnswerMessage]
	(
	@message	AS VARCHAR(600),
	@processed	AS BIT				OUTPUT
	)
AS
BEGIN

--###
--messaging.insertAnswerMessage
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



	--###
	--default
	--###
	 
	SELECT @processed = 0;



	INSERT INTO
		Messaging.answers.answerQueue 	
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
	


END
GO
