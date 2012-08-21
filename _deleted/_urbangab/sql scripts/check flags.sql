
SELECT questionId, COUNT(*) FROM questionFlag GROUP BY questionId
SELECT answerId, COUNT(*) FROM answerFlag GROUP BY answerId

SELECT * FROM questionFlag 