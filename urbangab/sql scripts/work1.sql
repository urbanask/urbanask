
SELECT * FROM [user] WHERE userId = 24
SELECT * FROM userInstructions WHERE userId = 24
SELECT * FROM question WHERE userId < 100000 ORDER BY timestamp DESC
SELECT * FROM system.action ORDER BY timestamp DESC
SELECT * FROM Gabs.dbo.userNotification WHERE userId = 24 AND viewed = 0

--UPDATE userInstructions SET push = 0 WHERE userId = 24
--UPDATE [user] SET pushNotifications = 1 WHERE userId = 24

SELECT * FROM Gabs.processNotifications.notificationNew
SELECT * FROM Gabs.processNotifications.notificationWork
SELECT LEN(description),* FROM Gabs.processNotifications.notificationError



