SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [bounties].[lookupBounties]

AS

--###
--[bounties].[lookupBounties]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	bounty.beginMinutes		AS beginMinutes,
	bounty.endMinutes		AS endMinutes,
	bounty.amount			AS amount

FROM
	Gabs.lookup.bounty		AS bounty

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


GO
GRANT EXECUTE ON  [bounties].[lookupBounties] TO [processBounties]
GO
