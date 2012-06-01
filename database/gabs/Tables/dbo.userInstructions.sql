CREATE TABLE [dbo].[userInstructions]
(
[userInstructionsId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[postQuestion] [int] NOT NULL CONSTRAINT [DF_userInstruction_postQuestion] DEFAULT ((0)),
[viewQuestions] [int] NOT NULL CONSTRAINT [DF_userInstructions_viewQuestions] DEFAULT ((0)),
[viewQuestion] [int] NOT NULL CONSTRAINT [DF_userInstructions_viewQuestion] DEFAULT ((0)),
[addAnswer] [int] NOT NULL CONSTRAINT [DF_userInstructions_addAnswer] DEFAULT ((0)),
[toolbar] [int] NOT NULL CONSTRAINT [DF_userInstructions_toolbar] DEFAULT ((0))
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userInstructions] TO [api]
GRANT UPDATE ON  [dbo].[userInstructions] TO [api]
GRANT INSERT ON  [dbo].[userInstructions] TO [login]
GO

ALTER TABLE [dbo].[userInstructions] ADD CONSTRAINT [pk_userInstructions] PRIMARY KEY NONCLUSTERED  ([userInstructionsId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_userInstructions_userId] ON [dbo].[userInstructions] ([userId], [postQuestion]) ON [PRIMARY]
GO
