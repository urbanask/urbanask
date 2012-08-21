#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System
Imports System.Data
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports Utility

#End Region


Partial Class VerifyEmail

    Inherits UI.Page

#Region "    variables "

    Private _connection As String
    Private _guid As String
    Private _getTempVerifyEmailProcedure As String
    Private _email As String = Nothing

#End Region

#Region "    functions "

    Private Sub OnPageLoad()

        Me.Initialize()
        Me.LoadPage()
        Me.Display()

    End Sub

    Private Sub Initialize()

        Dim configurationFile As String = MyBase.MapPath("~\web.config")
        _connection = Parameters.Parameter.GetValue("ConnectionString", configurationFile)
        _getTempVerifyEmailProcedure = Parameters.Parameter.GetValue("GetTempVerifyEmailProcedure", configurationFile)
        _guid = MyBase.Request("guid")

    End Sub

    Private Sub LoadPage()

        Using connection As New SqlClient.SqlConnection(_connection)

            Using command As New SqlClient.SqlCommand(_getTempVerifyEmailProcedure, connection)

                command.CommandType = CommandType.StoredProcedure
                command.Parameters.AddWithValue("Guid", _guid)

                Using adapter As New SqlClient.SqlDataAdapter(command)

                    Using dataTable As New Data.DataTable

                        connection.Open()
                        adapter.Fill(dataTable)

                        If (dataTable.Rows.Count > 0) Then

                            _email = dataTable.Rows(0)("Email").ToString()

                        End If

                    End Using

                End Using

            End Using

        End Using

    End Sub

    Private Sub Display()

        If (_email Is Nothing) Then

            Me.NoRecordFound.Visible = True
            Me.SuccessMessage.Visible = False

        Else

            Me.NoRecordFound.Visible = False
            Me.SuccessMessage.Text = String.Format(Me.SuccessMessage.Text, _email)
            Me.SuccessMessage.Visible = True

        End If

    End Sub

#End Region

#Region "    event handlers "

    Protected Sub PageLoadHandler( _
        ByVal sender As System.Object, _
        ByVal arguments As System.EventArgs) _
        Handles Me.Load

        Me.OnPageLoad()

    End Sub

#End Region

End Class
