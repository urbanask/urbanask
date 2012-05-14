SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [badges].[lookupBadges]

AS

--###
--[badges].[lookupBadges]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	badge.badgeId			AS badgeId,
	badge.unlimited			AS unlimited,
	badge.[procedure]		AS [procedure]

FROM
	Gabs.lookup.badge		AS badge
	WITH					( NOLOCK, INDEX( pk_badge ) )

WHERE
	badge.enabled			= 1 --true

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


GO
GRANT EXECUTE ON  [badges].[lookupBadges] TO [ProcessBadges]
GO
