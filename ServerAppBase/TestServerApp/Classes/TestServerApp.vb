#Region " options"

Option Explicit On 
Option Strict On

#End Region

#Region " imports"

#End Region

Public Class TestServerApp

    Inherits NHXS.Utility.ServerAppBase.ServerAppBase

#Region "    variables"

#End Region

    Protected Overrides Sub Process()

        Me.LogAndMail("hi", Diagnostics.EventLogEntryType.Error)

    End Sub

End Class
