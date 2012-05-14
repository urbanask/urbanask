SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE	@userId					AS ForeignKey = 1
--DECLARE	@userNotificationId		AS ForeignKey = 4248908

CREATE PROCEDURE [api].[saveNotificationViewed]
	(
	@userId					AS ForeignKey,
	@userNotificationId		AS ForeignKey
	)
AS

--###
--[api].[saveNotificationViewed]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



UPDATE
	Gabs.dbo.userNotification
	
SET
	userNotification.viewed					= 1 --true
	
WHERE
		userNotification.userId				= @userId --sanity check for security
	AND	userNotification.userNotificationId	= @userNotificationId
	
	


GO
