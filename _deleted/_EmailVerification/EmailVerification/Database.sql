-- Set database and put user in grants at bottom
USE Gabs
GO

CREATE TABLE [dbo].[TempVerifyEmail](
	[TempVerifyEmailID]	INT				IDENTITY(1,1) NOT NULL,
	[Email]			VARCHAR(100)			NOT NULL,
	[Guid]			CHAR(36)			NOT NULL,
	[UpdateDate]		DATETIME			NOT NULL,
 CONSTRAINT [PK_TempVerifyEmail] PRIMARY KEY CLUSTERED 
(
[TempVerifyEmailID] ASC
)WITH (FILLFACTOR = 97, PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[TempVerifyEmail] ADD  CONSTRAINT [DF_TempVerifyEmail_UpdateDate]  DEFAULT (GETDATE()) FOR [UpdateDate]
GO


CREATE PROCEDURE [dbo].[InsertTempVerifyEmail]
	(
	@Email		varChar(100),
	@Guid		CHAR(36)	OUTPUT
	)

AS

--###
--InsertTempVerifyEmail
--###

SET NOCOUNT	ON
SET XACT_ABORT	ON



--###
--get guid
--###

SET @Guid = NEWID()



--###
--insert
--###

INSERT INTO
	dbo.TempVerifyEmail

	(
	Email,
	[Guid]
	)

VALUES

	(
	@Email,
	@Guid
	)
GO



CREATE PROCEDURE dbo.GetTempVerifyEmail
	(
	@Guid	CHAR(36)
	)

AS

--###
--GetTempVerifyEmail
--###

SET XACT_ABORT	ON
SET NOCOUNT	ON



--###
--return
--###

SELECT
	TempVerifyEmail.Email				AS Email

FROM
	dbo.TempVerifyEmail				AS TempVerifyEmail
	
WHERE
	TempVerifyEmail.[Guid]				= @Guid

OPTION
	(FORCE ORDER, LOOP JOIN, MAXDOP 1)



--###
--update login
--###

--TODO: update login record



--###
--delete
--###

SET ROWCOUNT 1

DELETE FROM
	dbo.TempVerifyEmail
	
WHERE
	TempVerifyEmail.[Guid]				= @Guid

OPTION
	(FORCE ORDER, LOOP JOIN, MAXDOP 1)
	
SET ROWCOUNT 0
	
GO


--GRANT EXECUTE ON InsertTempVerifyEmail TO ?
--GRANT EXECUTE ON GetTempVerifyEmail TO ?