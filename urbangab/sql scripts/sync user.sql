
SELECT * FROM [user] WHERE userId < 100000
SELECT * FROM [userFacebook] WHERE userId < 100000 ORDER BY [userFacebook].userId
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
DELETE FROM question WHERE questionId = 1105486
DELETE FROM answer WHERE answerId = 1105486
UPDATE question SET question = 'Voice changing Darth Vader helmet' WHERE questionId = 1105688
SELECT username, authtypeId FROM [user] WHERE userId < 100
SELECT * FROM userFacebook WHERE userId IN (46)
UPDATE [user] SET 
hash='bFxydZg4GPGQqojigQxzbIcQw62jD3C4WeyXvB0fpB+1YHMSgAh1PIPHvpOsqqpT+gxTKG2hRl30kVhumuRuQg==',
salt='7iJyqg==',
authTypeId = 2 WHERE userId = 7
UPDATE [userFacebook] SET facebookId='_100003577822117' WHERE userId = 59
DELETE FROM [user] WHERE userId IN (49, 50)
*/

