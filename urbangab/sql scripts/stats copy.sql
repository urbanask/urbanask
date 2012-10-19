
DECLARE @users TABLE
    (
    userId INT, 
    username VARCHAR(100), 
    displayName VARCHAR(100), 
    tagline varchar(256), 
    reputation INT, 
    hash char(88), 
    salt char(8), 
    iterations int, 
    hashTypeId int, 
    enabled bit, 
    metricDistances int, 
    languageId int, 
    signupDate datetime2, 
    authTypeId  int       
    )
INSERT INTO @users
SELECT [user].*
FROM [user] 
WHERE [user].userId < 100000 
AND [user].userId NOT IN ( 23, 57, 58, 59, 60, 62, 118, 137, 146, 147, 159, 166, 167, 174, 177, 178, 179, 180, 182, 183, 184,
185, 194, 203, 217, 218, 222, 223, 225, 226, 227, 228, 229, 232, 235, 257, 258, 269, 289, 262, 253, 249, 244, 242, 212,
204, 202, 201, 200, 199, 198, 197, 196, 195, 193, 65, 138, 288, 0, 213, 279,274,209,207,190,171,164,155,128,
291,287,276,261,251,247,240,239,237,231,220,219,210,205,188,186,172,169,163,162,161,153,148,66,
290,282,278,277,275,273,256,252,250,248,243,241,236,230,221,216,215,214,208,206,189,187,176,175,173,170,165,154,149,134)
ORDER BY signupDate DESC

--SELECT * FROM @users

--questions
--SELECT users.userId, COUNT(*)
--FROM @users AS users
--INNER JOIN question ON users.userId = question.userId
--WHERE users.userId NOT IN (1,2,10)
--GROUP BY users.userId WITH ROLLUP

--signups/mo
--SELECT CAST( YEAR(users.signupDate) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(users.signupDate) AS VARCHAR ), 2 ) , COUNT(*)
--FROM @users AS users
--WHERE users.signupDate > '5/1/2012'
--GROUP BY CAST( YEAR(users.signupDate) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(users.signupDate) AS VARCHAR ), 2 )
--ORDER BY CAST( YEAR(users.signupDate) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(users.signupDate) AS VARCHAR ), 2 )

--questions/mo
--SELECT CAST( YEAR(question.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(question.timestamp) AS VARCHAR ), 2 ), COUNT(question.questionId)
--FROM @users AS users
--INNER JOIN Gabs.dbo.question ON users.userId = question.userId
--WHERE question.timestamp > '5/1/2012'
--GROUP BY CAST( YEAR(question.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(question.timestamp) AS VARCHAR ), 2 )
--ORDER BY CAST( YEAR(question.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(question.timestamp) AS VARCHAR ), 2 )

--answers/mo
--SELECT CAST( YEAR(answer.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(answer.timestamp) AS VARCHAR ), 2 ), COUNT(answer.answerId)
--FROM @users AS users
--INNER JOIN Gabs.dbo.answer ON users.userId = answer.userId
--WHERE answer.timestamp > '5/1/2012'
--GROUP BY CAST( YEAR(answer.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(answer.timestamp) AS VARCHAR ), 2 )
--ORDER BY CAST( YEAR(answer.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(answer.timestamp) AS VARCHAR ), 2 )


--users that asked questions/mo
--SELECT CAST( YEAR(question.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(question.timestamp) AS VARCHAR ), 2 ), COUNT(DISTINCT question.userId)
--FROM @users AS users
--INNER JOIN Gabs.dbo.question ON users.userId = question.userId
--WHERE question.timestamp > '5/1/2012'
--GROUP BY CAST( YEAR(question.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(question.timestamp) AS VARCHAR ), 2 )
--ORDER BY CAST( YEAR(question.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(question.timestamp) AS VARCHAR ), 2 )


--users that answered/mo
SELECT CAST( YEAR(answer.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(answer.timestamp) AS VARCHAR ), 2 ), COUNT(DISTINCT answer.userId)
FROM @users AS users
INNER JOIN Gabs.dbo.answer ON users.userId = answer.userId
WHERE answer.timestamp > '5/1/2012'
GROUP BY CAST( YEAR(answer.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(answer.timestamp) AS VARCHAR ), 2 )
ORDER BY CAST( YEAR(answer.timestamp) AS VARCHAR ) + '-' + RIGHT( '0' + CAST( MONTH(answer.timestamp) AS VARCHAR ), 2 )
