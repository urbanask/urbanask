CREATE DATABASE [session] ON  PRIMARY 
( NAME = N'session_data', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\session_data.mdf' , SIZE = 2048KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'session_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\session_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [session] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [session].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [session] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [session] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [session] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [session] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [session] SET ARITHABORT OFF 
GO

ALTER DATABASE [session] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [session] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [session] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [session] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [session] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [session] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [session] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [session] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [session] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [session] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [session] SET  DISABLE_BROKER 
GO

ALTER DATABASE [session] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [session] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [session] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [session] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [session] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [session] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [session] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [session] SET  READ_WRITE 
GO

ALTER DATABASE [session] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [session] SET  MULTI_USER 
GO

ALTER DATABASE [session] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [session] SET DB_CHAINING OFF 
GO


