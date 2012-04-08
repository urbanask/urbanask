CREATE DATABASE [Gabs] ON  PRIMARY 
( NAME = N'GabsData', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\GabsData.mdf' , SIZE = 2110464KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'GabsLogs', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\GabsLogs.ldf' , SIZE = 3164032KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [Gabs] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Gabs].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [Gabs] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [Gabs] SET ANSI_NULLS ON 
GO

ALTER DATABASE [Gabs] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [Gabs] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [Gabs] SET ARITHABORT OFF 
GO

ALTER DATABASE [Gabs] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [Gabs] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [Gabs] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [Gabs] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [Gabs] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [Gabs] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [Gabs] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [Gabs] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [Gabs] SET QUOTED_IDENTIFIER ON 
GO

ALTER DATABASE [Gabs] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [Gabs] SET  DISABLE_BROKER 
GO

ALTER DATABASE [Gabs] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [Gabs] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [Gabs] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [Gabs] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [Gabs] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [Gabs] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [Gabs] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [Gabs] SET  READ_WRITE 
GO

ALTER DATABASE [Gabs] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [Gabs] SET  MULTI_USER 
GO

ALTER DATABASE [Gabs] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [Gabs] SET DB_CHAINING OFF 
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[answer](
	[answerId] [dbo].[primaryKey] NOT NULL,
	[questionId] [dbo].[foreignKey] NOT NULL,
	[userId] [dbo].[foreignKey] NOT NULL,
	[locationId] [varchar](50) NOT NULL,
	[location] [varchar](80) NOT NULL,
	[locationAddress] [varchar](100) NOT NULL,
	[latitude] [decimal](9, 7) NOT NULL,
	[longitude] [decimal](10, 7) NOT NULL,
	[distance] [int] NOT NULL,
	[reasonId] [dbo].[foreignKey] NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
	[selected] [int] NOT NULL,
	[votes] [int] NOT NULL,
 CONSTRAINT [pk_answer] PRIMARY KEY NONCLUSTERED 
(
	[answerId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[answer] ADD  CONSTRAINT [DF_answer_selected]  DEFAULT ((0)) FOR [selected]
GO

ALTER TABLE [dbo].[answer] ADD  CONSTRAINT [DF_answer_votes]  DEFAULT ((0)) FOR [votes]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[answerVote](
	[answerVoteId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[answerId] [dbo].[foreignKey] NOT NULL,
	[userId] [dbo].[foreignKey] NOT NULL,
	[vote] [int] NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_answerVote] PRIMARY KEY NONCLUSTERED 
(
	[answerVoteId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[answerVote] ADD  CONSTRAINT [DF_answerVote_timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[application](
	[applicationId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[apiKey] [char](4) NOT NULL,
	[enabled] [bit] NOT NULL,
 CONSTRAINT [pk_application] PRIMARY KEY NONCLUSTERED 
(
	[applicationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[question](
	[questionId] [dbo].[primaryKey] NOT NULL,
	[userId] [dbo].[foreignKey] NOT NULL,
	[question] [varchar](50) NOT NULL,
	[link] [varchar](256) NULL,
	[latitude] [decimal](9, 7) NOT NULL,
	[longitude] [decimal](10, 7) NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
	[resolved] [int] NOT NULL,
	[bounty] [int] NOT NULL,
 CONSTRAINT [pk_question] PRIMARY KEY NONCLUSTERED 
(
	[questionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[question] ADD  CONSTRAINT [DF_question_resolved]  DEFAULT ((0)) FOR [resolved]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[reputation](
	[reputationId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[userId] [dbo].[foreignKey] NOT NULL,
	[reputationActionId] [dbo].[foreignKey] NOT NULL,
	[itemId] [dbo].[foreignKey] NOT NULL,
	[reputation] [int] NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_reputation] PRIMARY KEY NONCLUSTERED 
(
	[reputationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[user](
	[userId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[username] [varchar](100) NOT NULL,
	[displayName] [varchar](100) NOT NULL,
	[reputation] [int] NOT NULL,
	[hash] [char](88) NOT NULL,
	[salt] [char](8) NOT NULL,
	[iterations] [int] NOT NULL,
	[hashTypeId] [dbo].[foreignKey] NOT NULL,
	[enabled] [bit] NOT NULL,
	[metricDistances] [int] NOT NULL,
	[languageId] [dbo].[foreignKey] NOT NULL,
	[signupDate] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_user] PRIMARY KEY NONCLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[user] ADD  CONSTRAINT [DF_user_reputation]  DEFAULT ((0)) FOR [reputation]
GO

ALTER TABLE [dbo].[user] ADD  CONSTRAINT [DF_user_enabled]  DEFAULT ((1)) FOR [enabled]
GO

ALTER TABLE [dbo].[user] ADD  CONSTRAINT [DF_user_metricDistances]  DEFAULT ((0)) FOR [metricDistances]
GO

ALTER TABLE [dbo].[user] ADD  CONSTRAINT [DF_user_signupDate]  DEFAULT (getdate()) FOR [signupDate]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[userBadge](
	[userBadgeId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[userId] [dbo].[foreignKey] NOT NULL,
	[badgeId] [dbo].[foreignKey] NOT NULL,
	[timestamp] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_userBadge] PRIMARY KEY NONCLUSTERED 
(
	[userBadgeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[userLocation](
	[userLocationId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[userId] [dbo].[foreignKey] NOT NULL,
	[fromLatitude] [decimal](9, 7) NOT NULL,
	[fromLongitude] [decimal](10, 7) NOT NULL,
	[toLatitude] [decimal](9, 7) NOT NULL,
	[toLongitude] [decimal](10, 7) NOT NULL,
 CONSTRAINT [pk_userLocation] PRIMARY KEY NONCLUSTERED 
(
	[userLocationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[userPicture](
	[userPictureId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[userId] [dbo].[foreignKey] NOT NULL,
	[picture] [varbinary](max) NOT NULL,
	[icon] [varbinary](max) NULL,
 CONSTRAINT [pk_userPicture] PRIMARY KEY NONCLUSTERED 
(
	[userPictureId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[userPictureDefault](
	[userPictureDefaultId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[picture] [varbinary](max) NOT NULL,
 CONSTRAINT [pk_userPictureDefault] PRIMARY KEY NONCLUSTERED 
(
	[userPictureDefaultId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[badge](
	[badgeId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[enabled] [int] NOT NULL,
	[badgeClassId] [dbo].[foreignKey] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](256) NOT NULL,
	[unlimited] [int] NOT NULL,
	[procedure] [varchar](150) NOT NULL,
 CONSTRAINT [pk_badge] PRIMARY KEY CLUSTERED 
(
	[badgeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[badgeClass](
	[badgeClassId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
 CONSTRAINT [pk_badgeClass] PRIMARY KEY CLUSTERED 
(
	[badgeClassId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[bounty](
	[bountyId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[amount] [int] NOT NULL,
	[beginMinutes] [int] NOT NULL,
	[endMinutes] [int] NULL,
 CONSTRAINT [pk_bounty] PRIMARY KEY CLUSTERED 
(
	[bountyId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[hashType](
	[hashTypeId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[type] [varchar](10) NOT NULL,
 CONSTRAINT [pk_hashType] PRIMARY KEY CLUSTERED 
(
	[hashTypeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[interval](
	[intervalId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
 CONSTRAINT [pk_interval] PRIMARY KEY CLUSTERED 
(
	[intervalId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[language](
	[languageId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[code] [char](4) NULL,
 CONSTRAINT [pk_language] PRIMARY KEY CLUSTERED 
(
	[languageId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[radius](
	[radiusId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[miles] [varchar](50) NOT NULL,
	[kilometers] [varchar](50) NULL,
 CONSTRAINT [pk_radius] PRIMARY KEY CLUSTERED 
(
	[radiusId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[reason](
	[reasonId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NOT NULL,
 CONSTRAINT [pk_reason] PRIMARY KEY CLUSTERED 
(
	[reasonId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[region](
	[regionId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[fromLatitude] [decimal](9, 7) NOT NULL,
	[toLatitude] [decimal](9, 7) NOT NULL,
	[fromLongitude] [decimal](10, 7) NOT NULL,
	[toLongitude] [decimal](10, 7) NOT NULL,
 CONSTRAINT [pk_region] PRIMARY KEY CLUSTERED 
(
	[regionId] ASC,
	[fromLatitude] ASC,
	[toLatitude] ASC,
	[fromLongitude] ASC,
	[toLongitude] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[reputationAction](
	[reputationActionId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](150) NULL,
	[reputation] [int] NOT NULL,
	[object] [varchar](50) NOT NULL,
 CONSTRAINT [pk_reputationAction] PRIMARY KEY CLUSTERED 
(
	[reputationActionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [lookup].[topType](
	[topTypeId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
 CONSTRAINT [pk_topType] PRIMARY KEY CLUSTERED 
(
	[topTypeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [top].[topUser](
	[topUserId] [dbo].[primaryKey] IDENTITY(1,1) NOT NULL,
	[regionId] [dbo].[foreignKey] NOT NULL,
	[topTypeId] [dbo].[foreignKey] NOT NULL,
	[intervalId] [dbo].[foreignKey] NOT NULL,
	[userId] [dbo].[foreignKey] NOT NULL,
	[username] [varchar](100) NOT NULL,
	[reputation] [int] NOT NULL,
	[totalQuestions] [int] NOT NULL,
	[totalAnswers] [int] NOT NULL,
	[totalBadges] [int] NOT NULL,
	[topScore] [int] NOT NULL,
 CONSTRAINT [pk_topUser] PRIMARY KEY NONCLUSTERED 
(
	[topUserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO




