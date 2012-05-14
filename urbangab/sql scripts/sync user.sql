
SELECT * FROM [user] WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM [userFacebook] WHERE userId < 100000 ORDER BY [userFacebook].userId DESC
SELECT * FROM [userEmail] WHERE userId < 100000 ORDER BY [userEmail].userId
SELECT * FROM userRegion WHERE userId < 100000
SELECT * FROM userPicture WHERE userId < 100
SELECT * FROM question WHERE userId < 100000 ORDER BY timestamp DESC
SELECT * FROM answer WHERE userId < 100000 ORDER BY timestamp DESC
SELECT * FROM answerVote WHERE userId < 100000
SELECT * FROM answerVote WHERE vote< 0 AND userId < 100000
SELECT * FROM questionVote WHERE userId < 100
SELECT * FROM userBadge WHERE userId < 100
SELECT * FROM reputation WHERE userId < 100

/*
DBCC CHECKIDENT( 'Gabs.dbo.[user]', RESEED, 127 )
DELETE FROM question WHERE questionId = 1105995
DELETE FROM answer WHERE answerId = 4250081
UPDATE question SET question = 'Used Marshall cab' WHERE questionId = 1105852
SELECT username, authtypeId FROM [user] WHERE userId < 100
SELECT * FROM question WHERE questionId = 1106045
SELECT * FROM reputation WHERE itemId = 1105914
DELETE FROM question WHERE question = 'edible panties'
UPDATE [user] SET 
hash='bFxydZg4GPGQqojigQxzbIcQw62jD3C4WeyXvB0fpB+1YHMSgAh1PIPHvpOsqqpT+gxTKG2hRl30kVhumuRuQg==',
salt='7iJyqg==',
authTypeId = 2 WHERE userId = 7
UPDATE [userFacebook] SET facebookId='_100003577822117' WHERE userId = 59
DELETE FROM [user] WHERE userId IN (49, 50)
*/

