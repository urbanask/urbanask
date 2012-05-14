IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'processTopLists')
CREATE LOGIN [processTopLists] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [processTopLists] FOR LOGIN [processTopLists]
GO
