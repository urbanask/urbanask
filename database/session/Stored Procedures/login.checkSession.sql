SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE login.checkSession
	(
	@sessionId			AS UNIQUEIDENTIFIER,
	@sessionKey			AS UNIQUEIDENTIFIER	OUTPUT,
	@userId				AS ForeignKey OUTPUT
	)
AS

--###
--login.checkSession
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT @userId = 0;



SELECT
	@sessionKey											= session.sessionKey,
	@userId												= session.userId
	
FROM
	session.dbo.session									AS session
	WITH												(NOLOCK, INDEX(pk_session))

WHERE
		session.sessionId								= @sessionId
	AND	DATEDIFF( D, session.timestamp, GETDATE() )		< 60  --2 months

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)


GO
