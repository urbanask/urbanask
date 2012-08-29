
SELECT * FROM [user] WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM [userFacebook] WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM [userTwitter] WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM [userEmail] WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM userRegion WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM userPicture WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM question WHERE userId < 100000 ORDER BY timestamp DESC
SELECT * FROM answer WHERE userId < 100000 ORDER BY timestamp DESC
SELECT * FROM answerVote WHERE userId < 100000
SELECT * FROM answerVote WHERE vote< 0 AND userId < 100000
SELECT * FROM questionVote WHERE userId < 100
SELECT * FROM userBadge WHERE userId < 100
SELECT * FROM reputation WHERE userId < 100

SELECT * FROM Gabs.lookup.region ORDER BY name
SELECT * FROM Gabs.processRegions.regionNew

/*
INSERT INTO Gabs.lookup.region ( parentRegionId, name ) VALUES ( 1, 'Newton Booth, Sacramento, CA, USA' );
INSERT INTO Gabs.lookup.regionName VALUES ( 58, 'Newton Booth, Sacramento, CA, USA' );
DBCC CHECKIDENT( 'Gabs.dbo.[user]', RESEED, 127 )
DELETE FROM question WHERE questionId = 1109137
DELETE FROM answer WHERE answerId = 4250081
UPDATE question SET bounty = 0 WHERE regionId = 14 AND bounty = 100
SELECT username, authtypeId FROM [user] WHERE userId < 100
SELECT * FROM question WHERE question LIKE '%chalk%'
SELECT * FROM reputation WHERE itemId = 1105914
SELECT * FROM answer WHERE location LIKE '%ace%'
SELECT * FROM userFacebook WHERE email LIKE '%thinkingstiff%'
DELETE FROM question WHERE questionId = 1110251
UPDATE [user] SET 
hash='bFxydZg4GPGQqojigQxzbIcQw62jD3C4WeyXvB0fpB+1YHMSgAh1PIPHvpOsqqpT+gxTKG2hRl30kVhumuRuQg==',
salt='7iJyqg==',
authTypeId = 2 WHERE userId = 7
UPDATE [userFacebook] SET facebookId='_100003577822117' WHERE facebookId='100003577822117'
UPDATE [userTwitter] SET twitterId='_509992905' WHERE twitterId = '509992905'
DELETE FROM [user] WHERE userId IN (49, 50)
*/

