SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [login].[createUserPicture]
	(
	@userId				AS ForeignKey,
	@picture			AS VARBINARY(MAX),
	@icon				AS VARBINARY(MAX)
	)
AS

--###
--[login].[createUserPicture]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



INSERT INTO
	Gabs.dbo.userPicture
	(
	userId,
	picture,
	icon
	)

VALUES
	(
	@userId,
	@picture,
	@icon
	)
GO
