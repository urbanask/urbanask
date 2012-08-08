

SELECT
    answer.userId,
    RTRIM( CAST( DATEPART( MONTH, answer.timestamp ) AS VARCHAR ) + '/' 
    + CAST( DATEPART( DAY, answer.timestamp ) AS VARCHAR ) ),
    COUNT( * )             
    
FROM
    Gabs.dbo.answer         AS answer
WHERE 
        userId              = 18 -- molly
    AND timestamp           >= '08/06/2012'
    
GROUP BY
    answer.userId,
    RTRIM( CAST( DATEPART( MONTH, answer.timestamp ) AS VARCHAR ) + '/' 
    + CAST( DATEPART( DAY, answer.timestamp ) AS VARCHAR ) )   



SELECT
    answer.userId,
    RTRIM( CAST( DATEPART( MONTH, answer.timestamp ) AS VARCHAR ) + '/' 
    + CAST( DATEPART( DAY, answer.timestamp ) AS VARCHAR ) ),
    COUNT( * )             
    
FROM
    Gabs.dbo.answer         AS answer
WHERE 
        userId              = 10 -- larissa
    AND timestamp           >= '08/06/2012'
    
GROUP BY
    answer.userId,
    RTRIM( CAST( DATEPART( MONTH, answer.timestamp ) AS VARCHAR ) + '/' 
    + CAST( DATEPART( DAY, answer.timestamp ) AS VARCHAR ) )   





