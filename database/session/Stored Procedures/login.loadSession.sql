SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--DECLARE	@userId			AS INT = 1
--DECLARE	@sessionId		AS UNIQUEIDENTIFIER		
--DECLARE	@sessionKey		AS UNIQUEIDENTIFIER		

CREATE PROCEDURE [login].[loadSession]
	(
	@userId			AS INT,
	@sessionId		AS UNIQUEIDENTIFIER		OUTPUT,
	@sessionKey		AS UNIQUEIDENTIFIER		OUTPUT
	)
AS

--###
--login.[loadSession]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT TOP 1
    @sessionId                  = session.sessionId,
    @sessionKey                 = session.sessionKey
      
FROM
    session.dbo.session         AS session
    WITH                        ( NOLOCK, INDEX( pk_session ) )
    
WHERE
    session.userId              = @userId
    
ORDER BY
    session.timestamp           DESC
    
    
    
    
--PRINT @sessionId
GO
GRANT EXECUTE ON  [login].[loadSession] TO [api]
GO
