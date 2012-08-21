
DECLARE @userId AS ForeignKey
SET @userId = 117

/*
SELECT * FROM [user] WHERE userId = @userId
SELECT * FROM userBadge WHERE userId = @userId
SELECT * FROM userFacebook WHERE userId = @userId
SELECT * FROM userPicture WHERE userId = @userId
SELECT * FROM userRegion WHERE userId = @userId
SELECT * FROM answer WHERE userId = @userId
SELECT * FROM answer INNER JOIN answerFlag ON answer.answerId = answerFlag.answerId WHERE answer.userId = @userId
SELECT * FROM answer INNER JOIN answerVote ON answer.answerId = answerVote.answerId WHERE answer.userId = @userId
SELECT * FROM question WHERE userId = @userId
SELECT * FROM question INNER JOIN questionFlag ON question.questionId = questionFlag.questionId WHERE question.userId = @userId
SELECT * FROM question INNER JOIN questionVote ON question.questionId = questionVote.questionId WHERE question.userId = @userId
SELECT * FROM answer INNER JOIN question ON question.questionId = answer.questionId WHERE question.userId = @userId
SELECT * FROM reputation WHERE userId = @userId
SELECT * FROM [top].topUser WHERE userId = @userId 
*/
DELETE FROM userFacebook WHERE userId = @userId


