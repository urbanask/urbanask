Option Explicit On 
Option Strict On

Imports System.IO

Public Class CDirectory

#Region "    variables"

    Private m_sOriginalDirectory As String = ""
    Private m_sDirectory As String = ""

#End Region

#Region "    functions"

    Friend Sub New()

    End Sub

    Friend Sub New( _
        ByVal sDirectory As String)

        Fix(sDirectory)

    End Sub

    Friend Function Fix( _
        ByVal sDirectory As String) As String

        m_sOriginalDirectory = sDirectory

        If m_sOriginalDirectory.Length > 0 Then

            m_sDirectory = m_sOriginalDirectory

            If Not m_sDirectory.EndsWith("\") Then

                m_sDirectory = m_sDirectory & "\"

            End If

        End If

        Return m_sDirectory

    End Function

#End Region

#Region "    properties"

    Friend ReadOnly Property Directory() As String

        Get

            Return m_sDirectory

        End Get

    End Property

#End Region

End Class
