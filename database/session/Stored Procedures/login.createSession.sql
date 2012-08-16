SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
GRANT EXECUTE ON  [login].[createSession] TO [api]
GO
