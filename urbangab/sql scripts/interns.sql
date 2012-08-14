

SELECT
    answer.userId,
    RTRIM( CAST( DATEPART( MONTH, answer.timestamp ) AS VARCHAR ) + '/' 
    + CAST( DATEPART( DAY, answer.timestamp ) AS VARCHAR ) ),
    COUNT( * )  ,           
    COUNT( * )     * .15      
FROM
    Gabs.dbo.answer         AS answer
WHERE 
        userId              = 18 -- molly
    AND timestamp           >= '08/07/2012 17:00:00'
    
GROUP BY
    answer.userId,
    RTRIM( CAST( DATEPART( MONTH, answer.timestamp ) AS VARCHAR ) + '/' 
    + CAST( DATEPART( DAY, answer.timestamp ) AS VARCHAR ) )   


--$25

SELECT
    answer.userId,
    RTRIM( CAST( DATEPART( MONTH, answer.timestamp ) AS VARCHAR ) + '/' 
    + CAST( DATEPART( DAY, answer.timestamp ) AS VARCHAR ) ),
    COUNT( * ),           
    COUNT( * ) * .15            
    
FROM
    Gabs.dbo.answer         AS answer
WHERE 
        userId              = 10 -- larissa
    AND timestamp           >= '08/07/2012 17:00:00'
    
GROUP BY
    answer.userId,
    RTRIM( CAST( DATEPART( MONTH, answer.timestamp ) AS VARCHAR ) + '/' 
    + CAST( DATEPART( DAY, answer.timestamp ) AS VARCHAR ) )   





