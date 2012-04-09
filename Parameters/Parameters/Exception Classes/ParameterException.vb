#Region "options "

Option Explicit On 
Option Strict On

#End Region

Public Class ParameterException

    Inherits System.ApplicationException

    Public Sub New()

        'default constructor

    End Sub

    Public Sub New( _
        ByVal message As String)

        MyBase.New(message)

    End Sub

    Public Sub New( _
        ByVal message As String, _
        ByVal innerException As Exception)

        MyBase.New(message, innerException)

    End Sub

End Class
