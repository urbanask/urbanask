DECLARE @total DECIMAL
DECLARE @resolved DECIMAL
DECLARE @answered DECIMAL
DECLARE @asked DECIMAL
DECLARE @upvoted DECIMAL

SELECT @total = COUNT(*) FROM question
SELECT @resolved = COUNT(*) FROM question WHERE resolved = 1
SELECT @answered = COUNT( DISTINCT question.questionId ) FROM question INNER JOIN answer ON question.questionId = answer.questionId
SELECT @upvoted = COUNT( DISTINCT question.questionId ) FROM question INNER JOIN questionVote ON question.questionId = questionVote.questionId

PRINT 'total questions: ' + RTRIM( @total )
PRINT 'answered: ' + RTRIM( @answered ) + ' (' + RTRIM( CAST( ROUND( @answered / @total * 100, 0 ) AS INT ) ) + '%)'
PRINT 'resolved: ' + RTRIM( @resolved ) + ' (' + RTRIM( CAST( ROUND( @resolved / @total * 100, 0 ) AS INT ) ) + '%)'
PRINT 'upvoted: ' + RTRIM( @upvoted ) + ' (' + RTRIM( CAST( ROUND( @upvoted / @total * 100, 0 ) AS INT ) ) + '%)'
PRINT ''

SELECT @total = COUNT(*) FROM [user] WHERE userId < 100000
SELECT @answered = COUNT( DISTINCT userId ) FROM answer
SELECT @asked = COUNT( DISTINCT userId ) FROM question

PRINT 'total users: ' + RTRIM( @total )
PRINT 'answered: ' + RTRIM( @answered ) + ' (' + RTRIM( CAST( ROUND( @answered / @total * 100, 0 ) AS INT ) ) + '%)'
PRINT 'asked: ' + RTRIM( @asked ) + ' (' + RTRIM( CAST( ROUND( @asked / @total * 100, 0 ) AS INT ) ) + '%)'



