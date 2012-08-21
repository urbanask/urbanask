SET NOCOUNT ON
/*
SELECT COUNT(*) FROM question WHERE timestamp < DATEADD( HH, -24, GETDATE() ) --old
SELECT COUNT(*) FROM question WHERE timestamp > DATEADD( HH, -24, GETDATE() ) --new

SELECT COUNT(*) FROM answer WHERE timestamp < DATEADD( HH, -24, GETDATE() ) --old
SELECT COUNT(*) FROM answer WHERE timestamp > DATEADD( HH, -24, GETDATE() ) --new
*/

WHILE EXISTS( SELECT questionId FROM question WHERE timestamp < DATEADD( HH, -24, GETDATE() ) )
BEGIN

	UPDATE TOP(1000)	question SET	timestamp = DATEADD( S, -ROUND( RAND() * 72000, 0 ), GETDATE() )
	WHERE timestamp < DATEADD( HH, -24, GETDATE() )
	
END

WHILE EXISTS( SELECT answerId FROM answer WHERE timestamp < DATEADD( HH, -24, GETDATE() ) )
BEGIN

	UPDATE TOP(1000)	answer SET	timestamp = DATEADD( S, -ROUND( RAND() * 72000, 0 ), GETDATE() )
	WHERE timestamp < DATEADD( HH, -24, GETDATE() )
	
END

