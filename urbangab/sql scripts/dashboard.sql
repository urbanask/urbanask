
SELECT * FROM [user] ORDER BY signupDate DESC
SELECT * FROM [userFacebook] WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM [userTwitter] WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM [userEmail] WHERE userId < 100000 ORDER BY userId DESC
SELECT * FROM [userPhone] WHERE userId < 100000 ORDER BY userId DESC
SELECT CONVERT(VARCHAR(10),timestamp,111), COUNT(DISTINCT userId) FROM Gabs.system.action GROUP BY CONVERT(VARCHAR(10),timestamp,111) ORDER BY CONVERT(VARCHAR(10),timestamp,111) DESC
SELECT CONVERT(VARCHAR(10),timestamp,111), COUNT( DISTINCT ipAddress ) FROM Gabs.system.apiLog GROUP BY CONVERT(VARCHAR(10),timestamp,111) ORDER BY CONVERT(VARCHAR(10),timestamp,111) DESC
SELECT * FROM system.apiLog ORDER BY timestamp DESC
SELECT * FROM question WHERE userId < 100000 ORDER BY timestamp DESC
SELECT * FROM answer WHERE userId < 100000 ORDER BY timestamp DESC
SELECT * FROM answerVote WHERE userId < 100000
SELECT * FROM questionVote WHERE userId < 100
SELECT * FROM Gabs.login.verifyMobileNumber
SELECT * FROM Gabs.login.verifyMobileNumberError

SELECT * FROM Gabs.lookup.region ORDER BY name
SELECT * FROM Gabs.processRegions.regionNew



/*
INSERT INTO Gabs.lookup.region ( parentRegionId, name ) VALUES ( 74, 'Berne, IN, USA' );
INSERT INTO Gabs.lookup.regionName VALUES ( 1, 'Sacramento' );
INSERT INTO question ( questionId, userId, question, latitude, longitude, region, regionId, timestamp, resolved, bounty, votes )
VALUES ( 1114309, 327, 'shoe cobbler', 37.7441077, -122.4296783, 'San Francisco, CA, USA', 2, GETDATE(), 0, 0, 0 )
DBCC CHECKIDENT( 'Gabs.dbo.[user]', RESEED, 127 )
DELETE FROM question WHERE userId = 327
DELETE FROM answer WHERE answerId IN (
4252789,
4252785,
4252786,
4252787 )
UPDATE answer SET latitude = 37.760609, longitude = -122.436482 WHERE answerId = 4252845
SELECT username, authtypeId FROM [user] WHERE userId < 100
SELECT * FROM question WHERE question LIKE '%goatmilk%'
SELECT * FROM Gabs.login.verifyMobileNumber
SELECT * FROM reputation WHERE itemId = 1105914
SELECT * FROM answer WHERE location LIKE '%ace%'
SELECT * FROM userFacebook WHERE email LIKE '%thinkingstiff%'
INSERT INTO userPhone ( userId, number, notifications, verified ) VALUES ( 2, '19165488356', 1, 1 )
DELETE FROM question WHERE questionId = 1110251
UPDATE [user] SET enabled = 0 WHERE userId = 3
UPDATE [userFacebook] SET facebookId='_100003577822117' WHERE facebookId='100003577822117'
UPDATE [userPhone] SET number='1111' WHERE number LIKE '%9164022982%'
UPDATE [userTwitter] SET twitterId='_509992905' WHERE twitterId = '509992905'
DELETE FROM [user] WHERE userId IN (49, 50)
DBCC CHECKIDENT( 'Messaging.answers.answerQueue', RESEED, 0 )
*/

