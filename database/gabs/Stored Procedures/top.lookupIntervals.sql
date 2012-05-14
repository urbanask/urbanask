SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [top].[lookupIntervals]

AS

--###
--[top].[lookupIntervals]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	interval.intervalId		AS intervalId,
	interval.name			AS name

FROM
	Gabs.lookup.interval	AS interval
	WITH					( NOLOCK, INDEX( pk_interval ) )

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


GO
GRANT EXECUTE ON  [top].[lookupIntervals] TO [processTopLists]
GO
