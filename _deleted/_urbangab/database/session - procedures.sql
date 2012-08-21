SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [login].[checkSession]
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


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--DECLARE	@userId			AS INT = 1
--DECLARE	@sessionId		AS UNIQUEIDENTIFIER		
--DECLARE	@sessionKey		AS UNIQUEIDENTIFIER		

CREATE PROCEDURE [login].[createSession]
	(
	@userId			AS INT,
	@sessionId		AS UNIQUEIDENTIFIER		OUTPUT,
	@sessionKey		AS UNIQUEIDENTIFIER		OUTPUT
	)
AS

--###
--login.createSession
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



DECLARE @session	TABLE
	(
	sessionId		UNIQUEIDENTIFIER,
	sessionKey		UNIQUEIDENTIFIER
	)



INSERT INTO
	session.dbo.session
(
	userId
)

OUTPUT
	inserted.sessionId		AS sessionId,
	inserted.sessionKey		AS sessionKey

INTO
	@session
	
VALUES
(
	@userId
)



SELECT
	@sessionId		= session.sessionId,
	@sessionKey		= session.sessionKey 
	
FROM	
	@session		AS session
	




GO

