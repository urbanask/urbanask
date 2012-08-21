SELECT
	*
FROM
	Gabs.dbo.question
WHERE
	question = 'snug'

SELECT * FROM answer WHERE questionId = 1104790
SELECT * FROM answerVote WHERE answerId IN (4248499,4248501)


SELECT * FROM [user] WHERE userId <= 10
SELECT * FROM [userPicture] WHERE userId <= 10
SET IDENTITY_INSERT dbo.[user] ON
/*
INSERT [user] (userId, username, displayName,reputation,hash,salt,iterations,hashTypeId,enabled,metricDistances,languageId,signupDate)
VALUES(10, 'quinnzel','Larissa Andrews',0,'53J6e4v+3UXFNGzxB1DUseNe/whkDtsVWnEam+IenEocT20IF4wm/2P5QTkBwLzNF1cVwkwvtkmrrf1YrpOe2w==','BsUsUQ==',5,2,1,0,1,'1/30/2012')
UPDATE [user] SET reputation = 0 WHERE userId < 20
DELETE FROM question WHERE userId < 20
DELETE FROM answer WHERE userId < 20
DELETE FROM userbadge WHERE badgeId <> 6
DELETE FROM reputation WHERE userId < 20
DELETE FROM answerVote WHERE userId < 20
DELETE FROM Gabs.[top].topUser
UPDATE TOP(1000000) answer SET timestamp = '1/1/2010' WHERE timestamp > '8/1/2011'
UPDATE TOP(1000000) question SET timestamp = '1/1/2010'  WHERE timestamp > '8/1/2011'
UPDATE [user] SET userName = 'AnthonyAlves', salt='RCObUQ==', hash='bGiA65M9uwnFQd8Xq5H+iKMLk6D45SoZUQir1KhA0tOoL5RFO4r7vbLC98NLRooMqw12wBcGuqNDhd7oTDNI7w==' WHERE userId =8
DELETE FROM userLocation WHERE userId > 9
INSERT INTO userLocation VALUES (10, 37.7, -122.5, 39.0, -120)
UPDATE userLocation SET fromLatitude = 37.7, fromLongitude = -122.5
INSERT INTO userBadge VALUES (10, 6, '1/30/2012')
*/
SELECT * FROM reputation
SELECT * FROM userBadge
SELECT COUNT(*) FROM answer WITH(NOLOCK, INDEX(ix_answer_questionId)) WHERE timestamp < '8/1/2011'
SELECT * FROM answer WITH(NOLOCK, INDEX(ix_answer_questionId)) WHERE answerId = 4044766
SELECT COUNT(*) FROM question WHERE timestamp > '8/1/2011'
SELECT * FROM userLocation








