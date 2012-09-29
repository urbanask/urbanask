SELECT 1, 'questionQueue', COUNT(*)
  FROM Messaging.questions.questionQueue
 WITH (NOLOCK)

UNION

SELECT 2, 'questionWork',COUNT(*) 
  FROM Messaging.questions.questionWork 
 WITH (NOLOCK)

UNION

SELECT 3, 'questionError',COUNT(*) 
  FROM Messaging.questions.questionError
 WITH (NOLOCK)

UNION

SELECT 4, 'questions', COUNT(*) 
  FROM Gabs.dbo.question
 WITH (NOLOCK, INDEX(ix_question_longitude_latitude))
GO

/*
SELECT * FROM Messaging.questions.questionQueue
SELECT * FROM Messaging.questions.questionWork
SELECT * FROM Messaging.questions.questionError
SELECT TOP 1000 * FROM Gabs.dbo.question ORDER BY questionId DESC
INSERT INTO Messaging.questions.questionQueue SELECT message, timestamp FROM Messaging.questions.questionError
TRUNCATE TABLE Messaging.questions.questionQueue
TRUNCATE TABLE Messaging.questions.questionWork
TRUNCATE TABLE Messaging.questions.questionError
TRUNCATE TABLE Gabs.dbo.question
DELETE FROM Gabs.dbo.question WHERE question='undefined'
UPDATE Messaging.questions.questionWork SET message = '105~23.0395369~72.56596830~Pepper' WHERE questionWorkId = 3
DBCC CHECKIDENT( 'Messaging.questions.questionQueue', RESEED, 0 )
*/

SELECT 1, 'answerQueue', COUNT(*)
  FROM Messaging.answers.answerQueue 
 WITH (NOLOCK)

UNION

SELECT 2, 'answerWork',COUNT(*) 
  FROM Messaging.answers.answerWork
 WITH (NOLOCK)
 
UNION

SELECT 3, 'answerError',COUNT(*) 
  FROM Messaging.answers.answerError
 WITH (NOLOCK)
 
UNION

SELECT 4, 'answers', COUNT(*) 
  FROM Gabs.dbo.answer
  WITH (NOLOCK, INDEX(ix_answer_questionId))
GO

/*
SELECT * FROM Messaging.answers.answerQueue
SELECT * FROM Messaging.answers.answerWork
SELECT * FROM Messaging.answers.answerError
SELECT TOP 1000 * FROM Gabs.dbo.answer ORDER BY answerId DESC
TRUNCATE TABLE Messaging.answers.answerQueue
TRUNCATE TABLE Messaging.answers.answerWork
TRUNCATE TABLE Messaging.answers.answerError
TRUNCATE TABLE Gabs.dbo.answer
UPDATE Messaging.answers.answerWork SET answerWorkId = answerWorkId + 10
DELETE FROM Messaging.answers.answerWork WHERE answerWorkId = 1543135
DBCC CHECKIDENT( 'Messaging.answers.answerQueue', RESEED, 4252743 )
*/

