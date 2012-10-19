/* dup images */

SELECT DISTINCT
	userPicture.userId					AS userId
	
FROM
	Gabs.dbo.[userPicture]				AS userPicture

WHERE
	userPicture.picture IN (
	
SELECT 
	userPicture.picture
	
FROM
	Gabs.dbo.[user]					AS [user]
	
	INNER JOIN
	Gabs.dbo.userPicture			AS userPicture
	ON [user].userId				= userPicture.userId
	
WHERE
	[user].userId					BETWEEN 100000 AND 147494

GROUP BY
	userPicture.picture
	
HAVING
	COUNT(*)	> 1 
	
)

ORDER BY
	userPicture.userId				ASC
	
	
	
	
	

SELECT * FROM
--DELETE FROM
	Gabs.dbo.userPicture
	
WHERE userId IN (
143850,
144954,
146259,
146262
)

