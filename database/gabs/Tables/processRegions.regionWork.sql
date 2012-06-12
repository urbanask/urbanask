CREATE TABLE [processRegions].[regionWork]
(
[regionWorkId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[questionId] [dbo].[foreignKey] NOT NULL,
[region] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [processRegions].[regionWork] ADD CONSTRAINT [pk_regionWork] PRIMARY KEY NONCLUSTERED  ([regionWorkId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_regionWork] ON [processRegions].[regionWork] ([region], [questionId]) ON [PRIMARY]
GO
