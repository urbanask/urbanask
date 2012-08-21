DECLARE @image VARBINARY(MAX);
SELECT @image = BulkColumn FROM OPENROWSET(BULK N'C:\temperance.png', SINGLE_BLOB) AS picture

INSERT INTO [dbo].[userPicture] ( userId, picture ) VALUES ( 13, @image )
--UPDATE [userPictureDefault] SET picture = @image


SELECT * FROM [user] WHERE userId = 509947


