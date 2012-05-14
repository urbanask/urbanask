CREATE TABLE [lookup].[bounty]
(
[bountyId] [dbo].[primaryKey] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[amount] [int] NOT NULL,
[beginMinutes] [int] NOT NULL,
[endMinutes] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [lookup].[bounty] ADD CONSTRAINT [pk_bounty] PRIMARY KEY CLUSTERED  ([bountyId]) ON [PRIMARY]
GO
GRANT SELECT ON  [lookup].[bounty] TO [processBounties]
GO
