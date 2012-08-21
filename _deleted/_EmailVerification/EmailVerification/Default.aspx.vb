#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System
Imports System.Data
Imports System.Web
Imports Utility

#End Region

Public Class _Default

    Inherits UI.Page

#Region "    variables "

    Private _guid As String = Nothing
    Private _emailAddress As String = Nothing
    Private _connectionString As String = Nothing
    Private _success As Boolean = False
    Private _emailFromLogin As String = Nothing
    Private _emailFromPassword As String = Nothing
    Private _mailServer As String = Nothing
    Private _url As String = Nothing
    Private _emailFrom As String
    Private _emailSubject As String
    Private _insertTempVerifyEmailProcedure As String

#End Region

#Region "    functions "

    Private Sub VerifyButtonClick()

        Me.Initialize()
        'Me.InsertTempVerifyEmailRecord()
        Me.SendVerificationEmail()
        Me.Display()

    End Sub

    Private Sub Initialize()

        Dim configurationFile As String = MyBase.MapPath("~\web.config")
        _emailAddress = Me.EmailTextbox.Text.Trim
        _connectionString = Parameters.Parameter.GetValue("ConnectionString", configurationFile)
        _emailFromLogin = Parameters.Parameter.GetValue("EmailFromLogin", configurationFile)
        _emailFromPassword = Parameters.Parameter.GetValue("EmailFromPassword", configurationFile)
        _mailServer = Parameters.Parameter.GetValue("MailServer", configurationFile)
        _url = Parameters.Parameter.GetValue("Url", configurationFile)
        _emailFrom = Parameters.Parameter.GetValue("EmailFrom", configurationFile)
        _emailSubject = Parameters.Parameter.GetValue("EmailSubject", configurationFile)
        _insertTempVerifyEmailProcedure = Parameters.Parameter.GetValue("InsertTempVerifyEmailProcedure", configurationFile)
        _success = False

    End Sub

    Private Sub InsertTempVerifyEmailRecord()

        Using connection As New SqlClient.SqlConnection(_connectionString)

            Using command As New SqlClient.SqlCommand(_insertTempVerifyEmailProcedure, connection)

                command.CommandType = CommandType.StoredProcedure
                command.Parameters.AddWithValue("Email", _emailAddress)
                command.Parameters.Add("Guid", SqlDbType.UniqueIdentifier)
                command.Parameters("Guid").Direction = ParameterDirection.Output
                connection.Open()
                command.ExecuteNonQuery()
                _guid = command.Parameters("Guid").Value.ToString()

            End Using

        End Using

    End Sub

    Private Sub SendVerificationEmail()

        Dim authority As String = MyBase.Request.Url.GetLeftPart(UriPartial.Authority)
        Dim path As String = MyBase.ResolveUrl("~")
        _url = String.Format(_url, authority, path, _guid)
        Dim emailText As String = "Verify your email address: {0}"
        emailText = String.Format(emailText, _url)

        Try

            Dim message As New Net.Mail.MailMessage(_emailFrom, _emailAddress, _emailSubject, emailText)

            Dim client As New Net.Mail.SmtpClient(_mailServer)
            'Dim client As New Net.Mail.SmtpClient()
            client.Credentials = New Net.NetworkCredential(_emailFromLogin, _emailFromPassword)
            client.Send(message)
            _success = True

        Catch exception As System.Exception
            Me.Message.Text = exception.ToString

        End Try

    End Sub

    Private Sub Display()

        If _success Then

            Me.Message.Text = "Check your email"

        End If

    End Sub

#End Region

#Region "    event handlers "

    Protected Sub VerifyButtonClick(
        ByVal sender As System.Object,
        ByVal arguments As EventArgs) Handles VerifyButton.Click

        Me.VerifyButtonClick()

    End Sub

#End Region

End Class