DECLARE @days		AS INT = 3


SELECT
	COUNT(*)							AS askQuestion
	
FROM
	Gabs.dbo.question					AS question
	WITH								(NOLOCK, INDEX(ix_question_longitude_latitude))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	question.questionId				= reputation.itemId
	AND	reputation.reputationActionId	= 1 --ask question
	AND	reputation.timestamp			> DATEADD( d, -3, GETDATE() )

WHERE
		question.timestamp				> DATEADD( d, -3, GETDATE() )
	AND	reputation.reputationId			IS NULL	






SELECT
	COUNT(*)							AS answerQuestion
	
FROM
	Gabs.dbo.answer						AS answer
	WITH								(NOLOCK, INDEX(ix_answer_timestamp))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	answer.answerId					= reputation.itemId
	AND	reputation.reputationActionId	= 2 --answer question
	AND	reputation.timestamp			> DATEADD( d, -3, GETDATE() )

WHERE
		answer.timestamp				> DATEADD( d, -3, GETDATE() )
	AND	reputation.reputationId			IS NULL	




SELECT
	COUNT(*)							AS upvoteAnswer
	
FROM
	Gabs.dbo.answerVote					AS answerVote
	WITH								(NOLOCK, INDEX(ix_answerVote_timestamp))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	answerVote.answerVoteId			= reputation.itemId
	AND	reputation.reputationActionId	= 3 --upvote answer
	AND	reputation.timestamp			> DATEADD( d, -3, GETDATE() )

WHERE
		answerVote.timestamp			> DATEADD( d, -3, GETDATE() )
	AND	reputation.reputationId			IS NULL	






SELECT
	COUNT(*)							AS resolveQuestion
	
FROM
	Gabs.dbo.question					AS question
	WITH								(NOLOCK, INDEX(ix_question_longitude_latitude))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	question.questionId				= reputation.itemId
	AND	reputation.reputationActionId	= 4 --resolve question
	AND	reputation.timestamp			> DATEADD( d, -3, GETDATE() )

WHERE
		question.timestamp				> DATEADD( d, -3, GETDATE() )
	AND	question.resolved				= 1 --true
	AND	reputation.reputationId			IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)






SELECT
	COUNT(*)							AS answerAccepted
	
FROM
	Gabs.dbo.answer						AS answer
	WITH								(NOLOCK, INDEX(ix_answer_timestamp))
	
	LEFT JOIN
	Gabs.dbo.reputation					AS reputation
	WITH								(NOLOCK, INDEX(ix_reputation_itemId))
	ON	answer.answerId					= reputation.itemId
	AND	reputation.reputationActionId	= 5 --answer accepted
	AND	reputation.timestamp			> DATEADD( d, -@days, GETDATE() )

WHERE
		answer.timestamp				> DATEADD( d, -@days, GETDATE() )
	AND	answer.selected					= 1 --true
	AND	reputation.reputationId			IS NULL	

OPTION
	  (FORCE ORDER, LOOP JOIN, MAXDOP 1)





