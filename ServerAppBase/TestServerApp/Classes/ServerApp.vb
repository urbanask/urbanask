#Region " options"

Option Explicit On 
Option Strict On

#End Region

#Region " imports"

#End Region

Public Class ServerApp

    Inherits Utility.ServerAppBase.ServerAppBase

#Region "    variables"

#End Region

    Public Shared Sub Main()

        Dim app As New ServerApp

    End Sub

    Protected Overrides Sub Process()

        Dim a As Int32

        a = 1

        If a = 1 Then

            Throw New System.Exception("Timeout expired.")

        End If

    End Sub

End Class
