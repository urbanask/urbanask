
/* images work */

SELECT * FROM bot.[user]
SELECT * FROM bot.question ORDER BY questionId DESC
SELECT * FROM bot.questionQueue
--DELETE FROM bot.questionQueue
SELECT * FROM bot.questionWork
--DELETE FROM bot.question WHERE questionId = 1051

SELECT 
	[user].userId
	
FROM
	Gabs.dbo.[user]					AS [user]
	
	INNER JOIN
	Gabs.dbo.userPicture			AS userPicture
	ON [user].userId				= userPicture.userId
	
	LEFT JOIN
	Gabs.bot.[user]                 AS botUser
	ON  userPicture.userId          = botUser.userId
	
WHERE
	    [user].userId				BETWEEN 100000 AND 147494
    AND botUser.userId              IS NULL




SELECT 
	[user].userId
	
FROM
	Gabs.dbo.[user]					AS [user]
	
	LEFT JOIN
	Gabs.dbo.userPicture			AS userPicture
	ON [user].userId				= userPicture.userId
	
WHERE
	[user].userId					BETWEEN 100000 AND 147494
	AND	userPicture.userPictureId	IS NULL
	
