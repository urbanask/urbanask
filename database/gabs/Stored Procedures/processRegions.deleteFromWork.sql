SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE processRegions.deleteFromWork

AS

--###
--processRegions.deleteFromWork
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



IF EXISTS
(

	SELECT
		regionWork.regionWorkId             AS regionWorkId
		
	FROM
		Gabs.processRegions.regionWork	    AS regionWork
		WITH								( NOLOCK, INDEX( pk_regionWork ) )
			
)
BEGIN



    DELETE FROM
        Gabs.processRegions.regionWork



END
GO
