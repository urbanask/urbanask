#Region "options "

Option Explicit On 
Option Strict On

#End Region

#Region "imports "

Imports System.Diagnostics
Imports System.Windows.Forms

#End Region

Public Class Start

    Public Shared Sub Main()

        Dim app As TestServerApp

        EventLog.WriteEntry( _
            Application.ProductName, _
            "Application starting.", _
            EventLogEntryType.Information)

        app = New TestServerApp

        EventLog.WriteEntry( _
            Application.ProductName, _
            "Application stopping.", _
            EventLogEntryType.Information)

    End Sub

End Class
