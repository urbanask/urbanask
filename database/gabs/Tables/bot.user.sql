CREATE TABLE [bot].[user]
(
[userId] [dbo].[foreignKey] NOT NULL,
[regionId] [dbo].[foreignKey] NOT NULL
) ON [PRIMARY]
GO
GRANT SELECT ON  [bot].[user] TO [tools]
GO

ALTER TABLE [bot].[user] ADD 
CONSTRAINT [pk_botUser] PRIMARY KEY CLUSTERED  ([userId], [regionId]) ON [PRIMARY]
GO
