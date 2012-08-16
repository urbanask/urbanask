SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--DECLARE	@phoneNumber    AS VARCHAR(50) = '+19164022982'
--DECLARE	@userId			AS ForeignKey       
--DECLARE	@verified		AS INT				
--DECLARE	@stop		    AS INT				

CREATE PROCEDURE [api].[checkPhoneNumber]
	(
	@phoneNumber    AS VARCHAR(50),
	@userId			AS ForeignKey       OUTPUT,
	@verified		AS INT				OUTPUT,
	@stop		    AS INT				OUTPUT
	)
AS

--###
--[api].[checkPhoneNumber]
--###

SET NOCOUNT ON;
SET XACT_ABORT ON;



SET @userId = 0



SELECT
	@userId				    = userPhone.userId,
	@verified               = userPhone.verified,
	@stop                   = userPhone.stop

FROM
	Gabs.dbo.userPhone		AS userPhone
	WITH					( NOLOCK, INDEX( ix_userPhone_number ) )

WHERE
	userPhone.number        = @phoneNumber

OPTION
	( FORCE ORDER, LOOP JOIN, MAXDOP 1 )





--PRINT @userId

GO
