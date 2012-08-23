
-- $8.40

SELECT
    answer.userId,
    COUNT( * )  AS questions,           
    COUNT( * )     * .15  AS amount    
FROM
    Gabs.dbo.answer         AS answer
WHERE 
        answer.userId              = 18 -- molly
    AND timestamp           >= '08/20/2012 20:42:00'
    
GROUP BY
    answer.userId 
    

--$25
--$45.15
--PAID

SELECT
    answer.userId,
    COUNT( * )  AS questions,           
    COUNT( * )     * .15  AS amount    
    
FROM
    Gabs.dbo.answer         AS answer
WHERE 
        userId              = 10 -- larissa
    AND timestamp           >= '08/20/2012 20:42:00'
    
GROUP BY
    answer.userId





