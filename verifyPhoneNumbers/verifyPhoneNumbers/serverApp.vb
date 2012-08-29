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
        _viewVerifyPhoneNumbers As String,
        _deleteVerifyPhoneNumbers As String,
        _workCount As Int32,
        _smsApiUrl As String,
        _smsApiKey As String,
        _smsApiToken As String,
        _smsFrom As String,
        _smsBody As String

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
        _viewVerifyPhoneNumbers = Parameters.Parameter.GetValue("viewVerifyPhoneNumbers")
        _deleteVerifyPhoneNumbers = Parameters.Parameter.GetValue("deleteVerifyPhoneNumbers")
        _smsApiUrl = Parameters.Parameter.GetValue("smsApiUrl")
        _smsApiKey = Parameters.Parameter.GetValue("smsApiKey")
        _smsApiToken = Parameters.Parameter.GetValue("smsApiToken")
        _smsFrom = Parameters.Parameter.GetValue("smsFrom")
        _smsBody = Parameters.Parameter.GetValue("smsBody")

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

                Me.processVerifyPhoneNumbers(connection)

            End If

        End Using

    End Sub

    Private Sub processVerifyPhoneNumbers( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_viewVerifyPhoneNumbers, connection),
            deletePhoneNumbers As New Data.DataTable("phoneNumbers")

            deletePhoneNumbers.Columns.Add("userId")

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout
            command.Parameters.AddWithValue("@workCount", _workCount)

            Using verifyPhoneNumbers As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                While (verifyPhoneNumbers.Read())

                    Dim userId As Int32 = System.Convert.ToInt32(verifyPhoneNumbers("userId")),
                        phoneNumber As String = verifyPhoneNumbers("mobileNumber").ToString(),
                        url As String = String.Format(_smsApiUrl, _smsApiKey),
                        request As String = String.Concat(
                            "From=", System.Web.HttpUtility.UrlEncode(_smsFrom),
                            "&To=", System.Web.HttpUtility.UrlEncode(phoneNumber),
                            "&Body=", System.Web.HttpUtility.UrlEncode(_smsBody)),
                        web = New Net.WebClient(),
                        token = Convert.ToBase64String(Text.Encoding.UTF8.GetBytes(String.Format("{0}:{1}", _smsApiKey, _smsApiToken))),
                        header = String.Format("Basic {0}", token)

                    web.Headers.Add(Net.HttpRequestHeader.Authorization, header)
                    web.Headers(Net.HttpRequestHeader.ContentType) = "application/x-www-form-urlencoded"

                    Dim json As String = web.UploadString(url, request)

                    Dim row As Data.DataRow = deletePhoneNumbers.NewRow()
                    row("userId") = userId
                    deletePhoneNumbers.Rows.Add(row)

                End While

            End Using

            Me.logProcedureStatistics(_viewVerifyPhoneNumbers, startTime)

            If deletePhoneNumbers.Rows.Count > 0 Then

                Using delete As New SqlClient.SqlCommand(_deleteVerifyPhoneNumbers, connection)

                    delete.CommandType = CommandType.StoredProcedure
                    delete.CommandTimeout = _commandTimeout
                    delete.UpdatedRowSource = UpdateRowSource.None

                    delete.Parameters.Add(New SqlClient.SqlParameter("@userId", Data.SqlDbType.Int, 0, "userId"))

                    Using adapter As New Data.SqlClient.SqlDataAdapter()

                        adapter.UpdateBatchSize = _batchSize
                        adapter.InsertCommand = delete

                        adapter.Update(deletePhoneNumbers)

                    End Using

                    Me.logProcedureStatistics(_deleteVerifyPhoneNumbers, startTime)

                End Using

            End If

        End Using

        Me.logStatistics("processVerifyPhoneNumbers", startTime)

    End Sub

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




