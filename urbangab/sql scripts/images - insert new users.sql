
INSERT INTO
	Gabs.bot.[user]

SELECT 
	[user].userId					AS userId,
	userRegion.regionId				AS regionId
	
FROM
	Gabs.dbo.[user]					AS [user]
	
	INNER JOIN
	Gabs.dbo.userPicture			AS userPicture
	ON [user].userId				= userPicture.userId
	
	INNER JOIN
	Gabs.dbo.userRegion				AS userRegion
	ON [user].userId				= userRegion.userId
	
	LEFT JOIN
	Gabs.bot.[user]					AS botUser
	ON [user].userId				= botUser.userId
	
WHERE
		[user].userId				BETWEEN 100000 AND 147494
	AND	botUser.userId				IS NULL
	
	



