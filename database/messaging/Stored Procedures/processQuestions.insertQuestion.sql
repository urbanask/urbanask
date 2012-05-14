SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [processQuestions].[insertQuestion]
	(
	@questionId		AS PrimaryKey,
	@userId			AS ForeignKey,
	@latitude		AS DECIMAL(9,7),
	@longitude		AS DECIMAL(10,7),
	@question		AS VARCHAR(50),
	@timestamp		AS DATETIME2
	)
AS

--###
--processQuestions.insertQuestion
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Gabs.dbo.question
	(
	questionId,
	userId,
	latitude,
	longitude,
	question,
	timestamp,
	resolved,
	bounty
	)

VALUES
	(
	@questionId,
	@userId,
	@latitude,
	@longitude,
	@question,
	@timestamp,
	0,
	0
	)
	


GO
