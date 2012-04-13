﻿#Region "options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region "imports "

Imports System.Data
Imports Utility

#End Region

Public Class serverApp : Inherits Utility.ServerAppBase.ServerAppBase

    Private Const MESSAGE_LENGTH As Int32 = 12
    Private _batchSize As Int32,
        _commandTimeout As Int32,
        _deleteErrorsFromWork As String,
        _deleteFromWork As String,
        _gabsConnectionString As String,
        _insertAnswer As String,
        _logProcedureStatitics As Boolean,
        _messagingConnectionString As String,
        _moveToError As String,
        _moveToWork As String,
        _viewAnswerMessage As String,
        _workCount As Int32

    Private Enum messageColumns

        userId
        questionId
        locationId
        reference
        location
        locationAddress
        note
        link
        phone
        latitude
        longitude
        distance

    End Enum

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
        _deleteErrorsFromWork = Parameters.Parameter.GetValue("deleteErrorsFromWork")
        _deleteFromWork = Parameters.Parameter.GetValue("deleteFromWork")
        _gabsConnectionString = Parameters.Parameter.GetValue("gabsConnectionString")
        _insertAnswer = Parameters.Parameter.GetValue("insertAnswer")
        _messagingConnectionString = Parameters.Parameter.GetValue("messagingConnectionString")
        _moveToError = Parameters.Parameter.GetValue("moveToError")
        _moveToWork = Parameters.Parameter.GetValue("moveToWork")
        _viewAnswerMessage = Parameters.Parameter.GetValue("viewAnswerMessage")

    End Sub

    Protected Overrides Sub refreshParameters()

        _workCount = Parameters.Parameter.GetInt32Value("workCount")
        _logProcedureStatitics = Parameters.Parameter.GetBooleanValue("logProcedureStatitics")

    End Sub

#End Region

    Protected Overrides Sub process()

        Using messaging As New Data.SqlClient.SqlConnection(_messagingConnectionString), _
            gabs As New Data.SqlClient.SqlConnection(_gabsConnectionString)

            messaging.Open()

            If MyBase.IsAppActive() Then

                Me.moveToWork(messaging)

            End If

            If MyBase.IsAppActive() Then

                Me.processAnswers(messaging, gabs)

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

    Private Sub processAnswers( _
        ByVal messaging As Data.SqlClient.SqlConnection, _
        ByVal gabs As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_viewAnswerMessage, messaging),
            answers As New Data.DataTable("answer"),
            errors As New Data.DataTable("error")

            answers.Columns.Add("answerId")
            answers.Columns.Add("userId")
            answers.Columns.Add("questionId")
            answers.Columns.Add("locationId")
            answers.Columns.Add("reference")
            answers.Columns.Add("location")
            answers.Columns.Add("locationAddress")
            answers.Columns.Add("note")
            answers.Columns.Add("link")
            answers.Columns.Add("phone")
            answers.Columns.Add("latitude")
            answers.Columns.Add("longitude")
            answers.Columns.Add("distance")
            answers.Columns.Add("timestamp")

            errors.Columns.Add("answerId")
            errors.Columns.Add("message")
            errors.Columns.Add("timestamp")

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            Using messages As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                While (messages.Read())

                    Dim message() As String = messages("message").ToString().Split("~"c)

                    If isMessageValid(message) Then

                        Dim row As Data.DataRow = answers.NewRow()
                        row("answerId") = messages("answerId")
                        row("userId") = message(messageColumns.userId)
                        row("questionId") = message(messageColumns.questionId)
                        row("locationId") = message(messageColumns.locationId)
                        row("reference") = message(messageColumns.reference)
                        row("location") = message(messageColumns.location)
                        row("locationAddress") = message(messageColumns.locationAddress)
                        row("note") = message(messageColumns.note)
                        row("link") = message(messageColumns.link)
                        row("phone") = message(messageColumns.phone)
                        row("latitude") = message(messageColumns.latitude)
                        row("longitude") = message(messageColumns.longitude)
                        row("distance") = message(messageColumns.distance)
                        row("timestamp") = messages("timestamp")
                        answers.Rows.Add(row)

                    Else

                        Dim row As Data.DataRow = errors.NewRow()
                        row("answerId") = messages("answerId")
                        row("message") = messages("message")
                        row("timestamp") = messages("timestamp")
                        errors.Rows.Add(row)

                    End If

                End While

            End Using

            Me.logProcedureStatistics(_viewAnswerMessage, startTime)

            If answers.Rows.Count > 0 Then

                Using insertAnswers As New SqlClient.SqlCommand(_insertAnswer, gabs)

                    insertAnswers.CommandType = CommandType.StoredProcedure
                    insertAnswers.CommandTimeout = _commandTimeout
                    insertAnswers.UpdatedRowSource = UpdateRowSource.None

                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@answerId", Data.SqlDbType.Int, 0, "answerId"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@userId", Data.SqlDbType.Int, 0, "userId"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@questionId", Data.SqlDbType.Int, 0, "questionId"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@locationId", Data.SqlDbType.VarChar, 50, "locationId"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@reference", Data.SqlDbType.VarChar, 300, "reference"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@location", Data.SqlDbType.VarChar, 80, "location"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@locationAddress", Data.SqlDbType.VarChar, 100, "locationAddress"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@note", Data.SqlDbType.VarChar, 40, "note"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@link", Data.SqlDbType.VarChar, 256, "link"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@phone", Data.SqlDbType.VarChar, 50, "phone"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@latitude", Data.SqlDbType.Decimal, 9, "latitude"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@longitude", Data.SqlDbType.Decimal, 10, "longitude"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@distance", Data.SqlDbType.Int, 0, "distance"))
                    insertAnswers.Parameters.Add(New SqlClient.SqlParameter("@timestamp", Data.SqlDbType.DateTime2, 7, "timestamp"))

                    Using adapter As New Data.SqlClient.SqlDataAdapter()

                        adapter.InsertCommand = insertAnswers
                        adapter.UpdateBatchSize = _batchSize

                        adapter.Update(answers)

                    End Using

                    Me.logProcedureStatistics(_insertAnswer, startTime)

                End Using

                Using delete As New SqlClient.SqlCommand(_deleteFromWork, messaging)

                    delete.CommandType = CommandType.StoredProcedure
                    delete.CommandTimeout = _commandTimeout

                    delete.ExecuteNonQuery()

                End Using

                Me.logProcedureStatistics(_deleteFromWork, startTime)

            End If

            If errors.Rows.Count > 0 Then

                Using moveErrors As New SqlClient.SqlCommand(_moveToError, gabs)

                    moveErrors.CommandType = CommandType.StoredProcedure
                    moveErrors.CommandTimeout = _commandTimeout
                    moveErrors.UpdatedRowSource = UpdateRowSource.None

                    moveErrors.Parameters.Add(New SqlClient.SqlParameter("@answerId", Data.SqlDbType.Int, 0, "answerId"))
                    moveErrors.Parameters.Add(New SqlClient.SqlParameter("@message", Data.SqlDbType.VarChar, 300, "message"))
                    moveErrors.Parameters.Add(New SqlClient.SqlParameter("@timestamp", Data.SqlDbType.DateTime2, 7, "timestamp"))

                    Using adapter As New Data.SqlClient.SqlDataAdapter()

                        adapter.InsertCommand = moveErrors
                        adapter.UpdateBatchSize = _batchSize

                        adapter.Update(errors)

                    End Using

                    Me.logProcedureStatistics(_moveToError, startTime)

                End Using

                Using deleteErrors As New SqlClient.SqlCommand(_deleteErrorsFromWork, messaging)

                    deleteErrors.CommandType = CommandType.StoredProcedure
                    deleteErrors.CommandTimeout = _commandTimeout

                    deleteErrors.ExecuteNonQuery()

                End Using

                Me.logProcedureStatistics(_deleteErrorsFromWork, startTime)

            End If

        End Using

        Me.logStatistics("processAnswers", startTime)

    End Sub

    Private Function isMessageValid(
        ByVal message() As String) As Boolean

        If message.Length = MESSAGE_LENGTH AndAlso
            message(messageColumns.location) <> "" AndAlso
            message(messageColumns.locationAddress) <> "" AndAlso
            Microsoft.VisualBasic.IsNumeric(message(messageColumns.userId)) AndAlso
            Microsoft.VisualBasic.IsNumeric(message(messageColumns.questionId)) AndAlso
            Microsoft.VisualBasic.IsNumeric(message(messageColumns.latitude)) AndAlso
            Microsoft.VisualBasic.IsNumeric(message(messageColumns.longitude)) AndAlso
            Microsoft.VisualBasic.IsNumeric(message(messageColumns.distance)) Then

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



