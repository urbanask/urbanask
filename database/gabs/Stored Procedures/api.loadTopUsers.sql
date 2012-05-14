SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE @regionId		AS INT = 1 --sacramento

CREATE PROCEDURE [api].[loadTopUsers]
	(
	@regionId		AS ForeignKey
	)
AS

--###
--[api].[loadTopUsers]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT	
	topUser.regionId						AS regionId,
	topUser.topTypeId						AS topTypeId,
	topUser.intervalId						AS intervalId,
	topUser.userId							AS userId,
	topUser.username						AS username,
	topUser.reputation						AS reputation,
	topUser.totalQuestions					AS totalQuestions,
	topUser.totalAnswers					AS totalAnswers,
	topUser.totalBadges						AS totalBadges,
	topUser.topScore						AS topScore
	
FROM
	Gabs.[top].topUser						AS topUser
	WITH									( NOLOCK, INDEX(ix_topUser_regionId) )

WHERE
		topUser.regionId					= @regionId

ORDER BY
	topUser.topTypeId						ASC,
	topUser.intervalId						ASC,
	topUser.topScore						DESC

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)	
GO
