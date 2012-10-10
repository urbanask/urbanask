
DECLARE @signupDate AS DATETIME2 = '9/23/2012'
DECLARE @userIds TABLE ( userId INT ) 
INSERT INTO @userIds SELECT DISTINCT userId FROM [user] WHERE signupDate BETWEEN @signupDate AND DATEADD( DAY, 1, @signupDate )
DECLARE @totalUsers DECIMAL( 4, 0 )
SELECT @totalUsers = COUNT(*) FROM @userIds
SELECT CAST( @signupDate AS VARCHAR ) + '    ' + CAST( CASE WHEN @totalUsers = 0 THEN 0 ELSE COUNT( DISTINCT action.userId ) / @totalUsers END AS VARCHAR )
FROM system.action INNER JOIN @userIds as userIds ON action.userId = userIds.userId 
WHERE actionTypeId = 7 AND timestamp BETWEEN DATEADD( DAY, 1, @signupDate ) AND DATEADD( DAY, 2, @signupDate )
SELECT CAST( @signupDate AS VARCHAR ) + '    ' + CAST( CASE WHEN @totalUsers = 0 THEN 0 ELSE COUNT( DISTINCT action.userId ) / @totalUsers END AS VARCHAR )
FROM system.action INNER JOIN @userIds as userIds ON action.userId = userIds.userId 
WHERE actionTypeId = 7 AND timestamp BETWEEN DATEADD( DAY, 2, @signupDate ) AND DATEADD( DAY, 8, @signupDate )
SELECT CAST( @signupDate AS VARCHAR ) + '    ' + CAST( CASE WHEN @totalUsers = 0 THEN 0 ELSE COUNT( DISTINCT action.userId ) / @totalUsers END AS VARCHAR )
FROM system.action INNER JOIN @userIds as userIds ON action.userId = userIds.userId 
WHERE actionTypeId = 7 AND timestamp BETWEEN DATEADD( DAY, 8, @signupDate ) AND DATEADD( DAY, 31, @signupDate )
GO

