CREATE TABLE [lookup].[radius]
(
[radiusId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[miles] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[kilometers] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[radius] ADD CONSTRAINT [pk_radius] PRIMARY KEY CLUSTERED  ([radiusId]) ON [PRIMARY]
GO
