CREATE TABLE [dbo].[application]
(
[applicationId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[apiKey] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[enabled] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[application] ADD CONSTRAINT [pk_application] PRIMARY KEY NONCLUSTERED  ([applicationId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_application] ON [dbo].[application] ([apiKey], [applicationId]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[application] TO [messaging]
GRANT SELECT ON  [dbo].[application] TO [processAnswers]
GRANT SELECT ON  [dbo].[application] TO [processQuestions]
GO
