SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [reputation].[lookupReputationActions]

AS

--###
--[reputation].[lookupReputationActions]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	reputationAction.reputationActionId		AS reputationActionId,
	reputationAction.reputation				AS reputation,
	reputationAction.[procedure]			AS [procedure]

FROM
	Gabs.lookup.reputationAction			AS reputationAction
	WITH									( NOLOCK, INDEX( pk_reputationAction ) )

WHERE
	reputationAction.enabled				= 1 --true

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


GO
GRANT EXECUTE ON  [reputation].[lookupReputationActions] TO [processReputation]
GO
