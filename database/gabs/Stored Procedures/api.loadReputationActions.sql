SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [api].[loadReputationActions]

AS

--###
--[api].[loadReputationActions]
--###p
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	reputationAction.reputationActionId		AS id,
	reputationAction.name					AS name,
	reputationAction.reputation				AS reputation

FROM
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									(INDEX(pk_reputationAction), NOLOCK)

OPTION
	(FORCE ORDER, LOOP JOIN, MAXDOP 1)
GO
