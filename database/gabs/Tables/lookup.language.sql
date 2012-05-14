CREATE TABLE [lookup].[language]
(
[languageId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[code] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[language] ADD CONSTRAINT [pk_language] PRIMARY KEY CLUSTERED  ([languageId]) ON [PRIMARY]
GO
