CREATE TABLE [dbo].[userInstructions]
(
[userInstructionsId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[userId] [dbo].[foreignKey] NOT NULL,
[postQuestion] [int] NOT NULL CONSTRAINT [DF_userInstruction_postQuestion] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userInstructions] ADD CONSTRAINT [pk_userInstructions] PRIMARY KEY NONCLUSTERED  ([userInstructionsId]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_userInstructions_userId] ON [dbo].[userInstructions] ([userId], [postQuestion]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[userInstructions] TO [api]
GRANT INSERT ON  [dbo].[userInstructions] TO [login]
GO
