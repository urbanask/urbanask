SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [top].[lookupTopTypes]

AS

--###
--[top].[lookupTopTypes]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	topType.topTypeId		AS topTypeId

FROM
	Gabs.lookup.topType	    AS topType
	WITH					( NOLOCK, INDEX( pk_topType ) )

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


GO
GRANT EXECUTE ON  [top].[lookupTopTypes] TO [processTopLists]
GO
