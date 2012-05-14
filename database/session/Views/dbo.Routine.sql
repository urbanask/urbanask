SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 
CREATE VIEW [dbo].[Routine]
 
AS
 
SELECT
      Schemas.[Name]                      AS Owner,
      Object.[Name]                       AS [Name],
      Comments.[Text]                     AS Definition
 
FROM
      sysobjects                    AS Object
 
      INNER JOIN
      syscomments                         AS Comments
      ON    Object.[ID]             = Comments.[ID]
 
      INNER JOIN
      sys.schemas                   AS Schemas
      ON    Object.uid              = Schemas.schema_id
     
WHERE  
            --permission
            PERMISSIONS(Object.[ID])      != 0 --has permission
            --xtype
      AND   Object.xtype                  IN ('P','FN','TF', 'IF') --routines
 

GO
