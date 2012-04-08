CREATE DATABASE [Messaging] ON  PRIMARY 
( NAME = N'MessagesData', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MessagesData.mdf' , SIZE = 39936KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'MessagesLog', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MessagesLog.ldf' , SIZE = 12352KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [Messaging] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Messaging].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [Messaging] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [Messaging] SET ANSI_NULLS ON 
GO

ALTER DATABASE [Messaging] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [Messaging] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [Messaging] SET ARITHABORT OFF 
GO

ALTER DATABASE [Messaging] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [Messaging] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [Messaging] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [Messaging] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [Messaging] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [Messaging] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [Messaging] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [Messaging] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [Messaging] SET QUOTED_IDENTIFIER ON 
GO

ALTER DATABASE [Messaging] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [Messaging] SET  DISABLE_BROKER 
GO

ALTER DATABASE [Messaging] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [Messaging] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [Messaging] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [Messaging] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [Messaging] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [Messaging] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [Messaging] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [Messaging] SET  READ_WRITE 
GO

ALTER DATABASE [Messaging] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [Messaging] SET  MULTI_USER 
GO

ALTER DATABASE [Messaging] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [Messaging] SET DB_CHAINING OFF 
GO


