
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

--DECLARE @userId			AS PrimaryKey = 1

CREATE PROCEDURE [api].[loadAccount]
	(
	@userId			AS PrimaryKey
	)
AS

--###
--[api].[loadAccount]
--###
 
SET NOCOUNT ON;
SET XACT_ABORT ON;



SELECT
	[user].userId							AS userId,
	[user].username							AS username,
	[user].displayName						AS displayName,
	[user].reputation						AS reputation,
	[user].metricDistances					AS metricDistances,
	[user].languageId						AS languageId,
	[user].tagline							AS tagline
	
FROM
	Gabs.dbo.[user]							AS [user]
	WITH									( NOLOCK, INDEX( pk_user ) )
	
WHERE
	[user].userId							= @userId

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )



SELECT
	region.regionId							AS regionId,
	region.name								AS name

FROM
	Gabs.dbo.userRegion						AS userRegion
	WITH									( NOLOCK, INDEX( ix_userRegion_userId ) )
	
	INNER JOIN
	Gabs.lookup.region						AS region
	WITH									( NOLOCK, INDEX( pk_region ) )
	ON	userRegion.regionId					= region.regionId

WHERE
	userRegion.userId						= @userId

OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )




/* unviewed notifications */

SELECT
	userNotification.userNotificationId		AS userNotificationId,
	notification.name						AS notification,
	objectType.name							AS objectType,
	userNotification.itemId					AS itemId,
	question.question						AS objectDescription,
	userNotification.viewed					AS viewed,
	userNotification.timestamp				AS timestamp

FROM
	Gabs.dbo.userNotification				AS userNotification
	WITH									( NOLOCK, INDEX( pk_userNotification ) )
	
	INNER JOIN
	Gabs.dbo.question						AS question
	WITH									( INDEX( pk_question ), NOLOCK )
	ON	userNotification.itemId				= question.questionId

	INNER JOIN
	Gabs.lookup.notification				AS notification
	WITH									( NOLOCK, INDEX( pk_notification ) )
	ON	userNotification.notificationId		= notification.notificationId	
	
	INNER JOIN
	Gabs.lookup.objectType					AS objectType
	WITH									( NOLOCK, INDEX( pk_objectType ) )
	ON	userNotification.objectTypeId		= objectType.objectTypeId	
	
WHERE
		userNotification.userId				= @userId
	AND	userNotification.objectTypeId		= 1 --question
	AND userNotification.viewed				= 0 --false
	
UNION

SELECT
	userNotification.userNotificationId		AS userNotificationId,
	notification.name						AS notification,
	objectType.name							AS objectType,
	userNotification.itemId					AS itemId,
	badge.description						AS objectDescription,
	userNotification.viewed					AS viewed,
	userNotification.timestamp				AS timestamp

FROM
	Gabs.dbo.userNotification				AS userNotification
	WITH									( NOLOCK, INDEX( pk_userNotification ) )
	
	INNER JOIN
	Gabs.lookup.badge						AS badge
	WITH									( INDEX( pk_badge ), NOLOCK )
	ON	userNotification.itemId				= badge.badgeId

	INNER JOIN
	Gabs.lookup.notification				AS notification
	WITH									( NOLOCK, INDEX( pk_notification ) )
	ON	userNotification.notificationId		= notification.notificationId	
	
	INNER JOIN
	Gabs.lookup.objectType					AS objectType
	WITH									( NOLOCK, INDEX( pk_objectType ) )
	ON	userNotification.objectTypeId		= objectType.objectTypeId	
	
WHERE
		userNotification.userId				= @userId
	AND	userNotification.objectTypeId		= 2 --badge
	AND userNotification.viewed				= 0 --false
	
ORDER BY
		userNotification.timestamp			DESC
	
OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)



SELECT
	userInstructions.postQuestion	AS postQuestion,
	userInstructions.viewQuestions	AS viewQuestions,
	userInstructions.viewQuestion	AS viewQuestion,
	userInstructions.addAnswer		AS addAnswer,
	userInstructions.toolbar		AS toolbar

FROM
	Gabs.dbo.userInstructions		AS userInstructions
	WITH							( NOLOCK, INDEX( ix_userInstructions_userId ) )
	
WHERE
	userInstructions.userId			= @userId



--facebook

SELECT
	userFacebook.facebookId			    AS facebookId

FROM
	Gabs.dbo.userFacebook				AS userFacebook
	WITH								( NOLOCK, INDEX( ix_userFacebook_userId ) )
    
WHERE
		userFacebook.userId			    = @userId 
	  
OPTION
	  ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


-- phone

SELECT
    userPhone.number                    AS number,
    userPhone.notifications             AS notifications,
    userPhone.verified                  AS verified
    
FROM
    Gabs.dbo.userPhone                  AS userPhone
    WITH                                ( NOLOCK, INDEX( ix_userPhone ) )
    
WHERE
        userPhone.userId                 = @userId
    
OPTION
    ( FORCE ORDER, LOOP JOIN, MAXDOP 1 )


GO
