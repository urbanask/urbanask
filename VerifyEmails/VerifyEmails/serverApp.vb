#Region "options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region "imports "

Imports System.Data
Imports Utility

#End Region

Public Class serverApp : Inherits Utility.ServerAppBase.ServerAppBase

    Private _batchSize As Int32,
        _commandTimeout As Int32,
        _connectionString As String,
        _logProcedureStatitics As Boolean,
        _viewVerifyEmail As String,
        _updateUserEmails As String,
        _deleteOldVerifyEmails As String,
        _workCount As Int32,
        _unverifiedStatus As Int32,
        _invalidStatus As Int32,
        _apiUrl As String,
        _emailFrom As String,
        _emailSubject As String,
        _emailText As String,
        _mailServer As String,
        _mailServerLogin As String,
        _mailServerPassword As String

#Region "    functions "

    Public Shared Sub main()

        Dim app As New serverApp

    End Sub

#Region "    initialization "

    Protected Overrides Sub initializeParameters()

        Me.initializeConfigParameters()

    End Sub

    Private Sub initializeConfigParameters()

        _batchSize = Parameters.Parameter.GetInt32Value("batchSize")
        _commandTimeout = Parameters.Parameter.GetInt32Value("commandTimeout")
        _connectionString = Parameters.Parameter.GetValue("connectionString")
        _viewVerifyEmail = Parameters.Parameter.GetValue("viewVerifyEmail")
        _updateUserEmails = Parameters.Parameter.GetValue("updateUserEmails")
        _deleteOldVerifyEmails = Parameters.Parameter.GetValue("deleteOldVerifyEmails")
        _unverifiedStatus = Parameters.Parameter.GetInt32Value("unverifiedStatus")
        _invalidStatus = Parameters.Parameter.GetInt32Value("invalidStatus")
        _apiUrl = Parameters.Parameter.GetValue("apiUrl")
        _emailFrom = Parameters.Parameter.GetValue("emailFrom")
        _emailSubject = Parameters.Parameter.GetValue("emailSubject")
        _emailText = Parameters.Parameter.GetValue("emailText")
        _mailServer = Parameters.Parameter.GetValue("mailServer")
        _mailServerLogin = Parameters.Parameter.GetValue("mailServerLogin")
        _mailServerPassword = Parameters.Parameter.GetValue("mailServerPassword")

    End Sub

    Protected Overrides Sub refreshParameters()

        _workCount = Parameters.Parameter.GetInt32Value("workCount")
        _logProcedureStatitics = Parameters.Parameter.GetBooleanValue("logProcedureStatitics")

    End Sub

#End Region

    Protected Overrides Sub process()

        Using connection As New Data.SqlClient.SqlConnection(_connectionString)

            connection.Open()

            If MyBase.IsAppActive() Then

                Me.processVerifyEmails(connection)

            End If

            If MyBase.IsAppActive() Then

                Me.deleteOldVerifyEmails(connection)

            End If

        End Using

    End Sub

    Private Sub processVerifyEmails( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_viewVerifyEmail, connection),
            userEmails As New Data.DataTable("userEmail")

            userEmails.Columns.Add("userId")
            userEmails.Columns.Add("emailStatusId")

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout
            command.Parameters.AddWithValue("@workCount", _workCount)

            Using emails As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                While (emails.Read())

                    Dim userId = System.Convert.ToInt32(emails("userId")),
                        email = emails("email").ToString(),
                        guid = emails("guid").ToString()

                    Dim row As Data.DataRow = userEmails.NewRow()
                    row("userId") = userId

                    If isEmailValid(email) Then

                        Dim url As String = String.Format(_apiUrl, guid),
                            emailText = String.Format(_emailText, url)

                        Try

                            Dim message As New Net.Mail.MailMessage(_emailFrom, email, _emailSubject, emailText),
                                client As New Net.Mail.SmtpClient(_mailServer)
                            client.Credentials = New Net.NetworkCredential(_mailServerLogin, _mailServerPassword)
                            client.Send(message)

                            row("emailStatusId") = _unverifiedStatus

                        Catch exception As System.Exception

                            MyBase.Log(exception.ToString, Diagnostics.EventLogEntryType.Warning)
                            row("emailStatusId") = _invalidStatus

                        End Try


                    Else

                        row("emailStatusId") = _invalidStatus

                    End If

                    userEmails.Rows.Add(row)

                End While

            End Using

            Me.logProcedureStatistics(_viewVerifyEmail, startTime)

            If userEmails.Rows.Count > 0 Then

                Using updateUserEmails As New SqlClient.SqlCommand(_updateUserEmails, connection)

                    updateUserEmails.CommandType = CommandType.StoredProcedure
                    updateUserEmails.CommandTimeout = _commandTimeout
                    updateUserEmails.UpdatedRowSource = UpdateRowSource.None

                    updateUserEmails.Parameters.Add(New SqlClient.SqlParameter("@userId", Data.SqlDbType.Int, 0, "userId"))
                    updateUserEmails.Parameters.Add(New SqlClient.SqlParameter("@emailStatusId", Data.SqlDbType.Int, 0, "emailStatusId"))

                    Using adapter As New Data.SqlClient.SqlDataAdapter()

                        adapter.InsertCommand = updateUserEmails
                        adapter.UpdateBatchSize = _batchSize

                        adapter.Update(userEmails)

                    End Using

                    Me.logProcedureStatistics(_updateUserEmails, startTime)

                End Using

            End If

        End Using

        Me.logStatistics("processVerifyEmails", startTime)

    End Sub

    Private Sub deleteOldVerifyEmails( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_deleteOldVerifyEmails, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout
            command.ExecuteNonQuery()

            Me.logProcedureStatistics(_deleteOldVerifyEmails, startTime)

        End Using

        Me.logStatistics("deleteOldVerifyEmails", startTime)

    End Sub

    Private Function isEmailValid(
        ByVal email As String) As Boolean

        If email.Length > 0 AndAlso
            email.IndexOf("@") > 0 AndAlso
            email.IndexOf(".") > 0 Then

            Return True

        Else

            Return False

        End If

    End Function

    Private Sub logStatistics( _
        ByVal description As String, _
        ByVal startTime As DateTime)

        Dim stopTime As DateTime
        Dim time As String
        Dim log As String

        stopTime = System.DateTime.Now
        time = System.Convert.ToString(stopTime.Subtract(startTime).TotalSeconds)

        log = "{0}: {1}"
        log = String.Format(log, description, time)
        MyBase.Log(log, Diagnostics.EventLogEntryType.Information)

        Diagnostics.Debug.WriteLine(log)

    End Sub

    Private Sub logProcedureStatistics( _
        ByVal procedure As String, _
        ByVal startTime As DateTime)

        Dim stopTime As DateTime
        Dim time As String
        Dim log As String

        If _logProcedureStatitics Then

            stopTime = DateTime.Now()
            time = Convert.ToString(stopTime.Subtract(startTime).TotalSeconds)

            log = String.Format("procedure: {0}, time: {1}", procedure, time)
            MyBase.Log(log, Diagnostics.EventLogEntryType.Information)

            Diagnostics.Debug.WriteLine(log)

        End If

    End Sub

#End Region


End Class




