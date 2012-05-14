SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
--CHECKPOINT; 
--GO 
--DBCC DROPCLEANBUFFERS; 
--GO
--DECLARE	@reputationActionId		INT = 6
--DECLARE	@reputation				INT = 2
--DECLARE	@days					INT = 3
--DECLARE	@count					INT = 1000
--DECLARE	@expirationDays			INT = 2

CREATE PROCEDURE [reputation].[processEditedQuestion]
	(
	@reputationActionId		INT,
	@reputation				INT,
	@days					INT,
	@count					INT,
	@expirationDays			INT
	)
AS

--###
--[reputation].[processEditedQuestion]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ROWCOUNT @count;



-- variables

DECLARE @reputations				TABLE
	(
	userId							ForeignKey,
	itemId							ForeignKey,
	timestamp						DATETIME2
	)




/*

INSERT INTO
	Gabs.dbo.reputation

SELECT
	reputation.userId			AS userId,
	@reputationActionId			AS reputationActionId, 
	reputation.itemId			AS itemId,
	@reputation					AS reputation,
	reputation.timestamp		AS timestamp

FROM
	@reputations				AS reputation
	
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



UPDATE
	Gabs.dbo.[user]
	
SET
	reputation				= reputation + @reputation

FROM
	@reputations			AS reputation

	INNER JOIN
	Gabs.dbo.[user]			AS [user]
	WITH					( NOLOCK, INDEX( pk_user ) )
	ON	reputation.userId	= [user].userId

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )
*/
GO
GRANT EXECUTE ON  [reputation].[processEditedQuestion] TO [processReputation]
GO
