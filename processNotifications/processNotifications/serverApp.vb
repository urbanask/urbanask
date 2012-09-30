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
        _deleteFromWork As String,
        _logProcedureStatitics As Boolean,
        _moveToWork As String,
        _saveError As String,
        _smsApiUrl As String,
        _smsApiKey As String,
        _smsApiToken As String,
        _smsFrom As String,
        _smsBody As String,
        _twitterApiKey As String,
        _twitterApiSecret As String,
        _twitterToken As String,
        _twitterTokenSecret As String,
        _viewSmsActions As String,
        _viewTwitterActions As String,
        _twitterBody As String,
        _workCount As Int32,
        _questionUrl As String


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
        _deleteFromWork = Parameters.Parameter.GetValue("deleteFromWork")
        _moveToWork = Parameters.Parameter.GetValue("moveToWork")
        _saveError = Parameters.Parameter.GetValue("saveError")
        _smsApiKey = Parameters.Parameter.GetValue("smsApiKey")
        _smsApiToken = Parameters.Parameter.GetValue("smsApiToken")
        _smsApiUrl = Parameters.Parameter.GetValue("smsApiUrl")
        _smsBody = Parameters.Parameter.GetValue("smsBody")
        _smsFrom = Parameters.Parameter.GetValue("smsFrom")
        _twitterApiKey = Parameters.Parameter.GetValue("twitterApiKey")
        _twitterApiSecret = Parameters.Parameter.GetValue("twitterApiSecret")
        _twitterToken = Parameters.Parameter.GetValue("twitterToken")
        _twitterTokenSecret = Parameters.Parameter.GetValue("twitterTokenSecret")
        _twitterBody = Parameters.Parameter.GetValue("twitterBody")
        _viewSmsActions = Parameters.Parameter.GetValue("viewSmsActions")
        _viewTwitterActions = Parameters.Parameter.GetValue("viewTwitterActions")
        _questionUrl = Parameters.Parameter.GetValue("questionUrl")

    End Sub

    Protected Overrides Sub refreshParameters()

        _logProcedureStatitics = Parameters.Parameter.GetBooleanValue("logProcedureStatitics")
        _workCount = Parameters.Parameter.GetInt32Value("workCount")

    End Sub

#End Region

    Protected Overrides Sub process()

        Using connection As New Data.SqlClient.SqlConnection(_connectionString)

            connection.Open()

            If MyBase.IsAppActive() Then

                Me.moveToWork(connection)

            End If

            If MyBase.IsAppActive() Then

                Me.processSmsNotifications(connection)

            End If

            If MyBase.IsAppActive() Then

                Me.processTwitterNotifications(connection)

            End If

            If MyBase.IsAppActive() Then

                Me.deleteFromWork(connection)

            End If

        End Using

    End Sub

    Private Sub moveToWork( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_moveToWork, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            command.Parameters.AddWithValue("@workCount", _workCount)

            command.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(_moveToWork, startTime)
        Me.logStatistics("moveToWork", startTime)

    End Sub

    Private Sub processSmsNotifications( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_viewSmsActions, connection),
            errors As New Data.DataTable("errors")

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            errors.Columns.Add("notificationId")
            errors.Columns.Add("description")
            errors.Columns.Add("error")

            Using actions As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                While (actions.Read())

                    Dim phoneNumber As String = actions("phoneNumber").ToString(),
                        body As String = String.Format(_smsBody, actions("body").ToString()),
                        url As String = String.Format(_smsApiUrl, _smsApiKey),
                        request As String = String.Concat(
                            "From=", System.Web.HttpUtility.UrlEncode(_smsFrom),
                            "&To=", System.Web.HttpUtility.UrlEncode(phoneNumber),
                            "&Body=", System.Web.HttpUtility.UrlEncode(body)),
                        web = New Net.WebClient(),
                        token = Convert.ToBase64String(Text.Encoding.UTF8.GetBytes(String.Format("{0}:{1}", _smsApiKey, _smsApiToken))),
                        header = String.Format("Basic {0}", token)

                    web.Headers.Add(Net.HttpRequestHeader.Authorization, header)
                    web.Headers(Net.HttpRequestHeader.ContentType) = "application/x-www-form-urlencoded"

                    Try

                        Dim jsonResponse As String = web.UploadString(url, request)

                    Catch ex As Exception

                        Dim errorRow As Data.DataRow = errors.NewRow()
                        errorRow("notificationId") = CInt(actions("notificationId"))
                        errorRow("description") = request
                        errorRow("error") = ex.Message
                        errors.Rows.Add(errorRow)

                    End Try

                End While

                Me.logProcedureStatistics(_viewSmsActions, startTime)

            End Using

            saveErrors(connection, errors, startTime)

        End Using

        Me.logStatistics("processSmsNotifications", startTime)

    End Sub

    Private Sub processTwitterNotifications( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_viewTwitterActions, connection),
            errors As New Data.DataTable("errors")

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            errors.Columns.Add("notificationId")
            errors.Columns.Add("description")
            errors.Columns.Add("error")

            Using actions As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                While (actions.Read())

                    Dim twitterId As String = actions("twitterId").ToString(),
                        questionId As String = actions("questionId").ToString(),
                        latitude As Double = System.Convert.ToDouble(actions("latitude")),
                        longitude As Double = System.Convert.ToDouble(actions("longitude")),
                        link As String = String.Format(_questionUrl, questionId),
                        body As String = String.Format(_twitterBody, twitterId, actions("body").ToString(), link),
                        tokens As New Twitterizer.OAuthTokens(),
                        options As New Twitterizer.StatusUpdateOptions

                    tokens.AccessToken = _twitterToken
                    tokens.AccessTokenSecret = _twitterTokenSecret
                    tokens.ConsumerKey = _twitterApiKey
                    tokens.ConsumerSecret = _twitterApiSecret

                    options.Latitude = latitude
                    options.Longitude = longitude

                    Dim response As Twitterizer.TwitterResponse(Of Twitterizer.TwitterStatus) _
                            = Twitterizer.TwitterStatus.Update(tokens, body, options)

                    If response.Result = Twitterizer.RequestResult.Success Then

                        'save post id

                    Else

                        Dim errorRow As Data.DataRow = errors.NewRow()
                        errorRow("notificationId") = CInt(actions("notificationId"))
                        errorRow("description") = body
                        errorRow("error") = response.ErrorMessage
                        errors.Rows.Add(errorRow)

                    End If

                End While

                Me.logProcedureStatistics(_viewTwitterActions, startTime)

            End Using

            saveErrors(connection, errors, startTime)

        End Using

        Me.logStatistics("processTwitterNotifications", startTime)

    End Sub

    Private Sub saveErrors( _
        ByVal connection As Data.SqlClient.SqlConnection, _
        ByVal errors As Data.DataTable,
        ByVal startTime As System.DateTime)

        If errors.Rows.Count > 0 Then

            Using errorCommand As New SqlClient.SqlCommand(_saveError, connection)

                errorCommand.CommandType = CommandType.StoredProcedure
                errorCommand.CommandTimeout = _commandTimeout
                errorCommand.UpdatedRowSource = UpdateRowSource.None

                errorCommand.Parameters.Add(New SqlClient.SqlParameter("@notificationId", Data.SqlDbType.Int, 0, "notificationId"))
                errorCommand.Parameters.Add(New SqlClient.SqlParameter("@description", Data.SqlDbType.VarChar, 255, "description"))
                errorCommand.Parameters.Add(New SqlClient.SqlParameter("@error", Data.SqlDbType.VarChar, 255, "error"))

                Using adapter As New Data.SqlClient.SqlDataAdapter()

                    adapter.UpdateBatchSize = _batchSize
                    adapter.InsertCommand = errorCommand

                    adapter.Update(errors)

                End Using

                Me.logProcedureStatistics(_saveError, startTime)

            End Using

        End If


    End Sub

    Private Sub deleteFromWork( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using delete As New SqlClient.SqlCommand(_deleteFromWork, connection)

            delete.CommandType = CommandType.StoredProcedure
            delete.CommandTimeout = _commandTimeout

            delete.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(_deleteFromWork, startTime)
        Me.logStatistics("deleteFromWork", startTime)

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




