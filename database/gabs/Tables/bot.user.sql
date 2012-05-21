CREATE TABLE [bot].[user]
(
[userId] [dbo].[foreignKey] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [bot].[user] ADD CONSTRAINT [pk_botUser] PRIMARY KEY NONCLUSTERED  ([userId]) ON [PRIMARY]
GO
