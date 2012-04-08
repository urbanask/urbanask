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

    Private Const MESSAGE_LENGTH As Int32 = 4
    Private _batchSize As Int32
    Private _commandTimeout As Int32
    Private _deleteErrorsFromWork As String
    Private _deleteFromWork As String
    Private _gabsConnectionString As String
    Private _insertQuestion As String
    Private _logProcedureStatitics As Boolean
    Private _messagingConnectionString As String
    Private _moveToError As String
    Private _moveToWork As String
    Private _viewQuestionMessage As String
    Private _workCount As Int32

    Private Enum messageColumns

        userId
        latitude
        longitude
        question

    End Enum

#Region "    functions "

    Public Shared Sub main()

        Dim app As New ServerApp

    End Sub

#Region "    initialization "

    Protected Overrides Sub initializeParameters()

        Me.initializeConfigParameters()

    End Sub

    Private Sub initializeConfigParameters()

        _batchSize = Parameters.Parameter.GetInt32Value("BatchSize")
        _commandTimeout = Parameters.Parameter.GetInt32Value("CommandTimeout")
        _deleteErrorsFromWork = Parameters.Parameter.GetValue("deleteErrorsFromWork")
        _deleteFromWork = Parameters.Parameter.GetValue("deleteFromWork")
        _gabsConnectionString = Parameters.Parameter.GetValue("gabsConnectionString")
        _insertQuestion = Parameters.Parameter.GetValue("InsertQuestion")
        _messagingConnectionString = Parameters.Parameter.GetValue("messagingConnectionString")
        _moveToError = Parameters.Parameter.GetValue("MoveToError")
        _moveToWork = Parameters.Parameter.GetValue("MoveToWork")
        _viewQuestionMessage = Parameters.Parameter.GetValue("ViewQuestionMessage")

    End Sub

    Protected Overrides Sub refreshParameters()

        _workCount = Parameters.Parameter.GetInt32Value("WorkCount")
        _logProcedureStatitics = Parameters.Parameter.GetBooleanValue("LogProcedureStatitics")

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

                Me.processQuestions(messaging, gabs)

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

    Private Sub processQuestions( _
        ByVal messaging As Data.SqlClient.SqlConnection, _
        ByVal gabs As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_viewQuestionMessage, messaging),
            questions As New Data.DataTable("question"),
            errors As New Data.DataTable("error")

            questions.Columns.Add("questionId")
            questions.Columns.Add("userId")
            questions.Columns.Add("latitude")
            questions.Columns.Add("longitude")
            questions.Columns.Add("question")
            questions.Columns.Add("timestamp")

            errors.Columns.Add("questionId")
            errors.Columns.Add("message")
            errors.Columns.Add("timestamp")

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            Using messages As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                While (messages.Read())

                    Dim message() As String = messages("message").ToString().Split("~"c)

                    If message.Length = MESSAGE_LENGTH Then

                        Dim row As Data.DataRow = questions.NewRow()
                        row("questionId") = messages("questionId")
                        row("userId") = message(messageColumns.userId)
                        row("latitude") = message(messageColumns.latitude)
                        row("longitude") = message(messageColumns.longitude)
                        row("question") = message(messageColumns.question)
                        row("timestamp") = messages("timestamp")
                        questions.Rows.Add(row)

                    Else

                        Dim row As Data.DataRow = errors.NewRow()
                        row("questionId") = messages("questionId")
                        row("message") = messages("message")
                        row("timestamp") = messages("timestamp")
                        errors.Rows.Add(row)

                    End If

                End While

            End Using

            Me.logProcedureStatistics(_viewQuestionMessage, startTime)

            If questions.Rows.Count > 0 Then

                Using insertQuestions As New SqlClient.SqlCommand(_insertQuestion, gabs)

                    insertQuestions.CommandType = CommandType.StoredProcedure
                    insertQuestions.CommandTimeout = _commandTimeout
                    insertQuestions.UpdatedRowSource = UpdateRowSource.None

                    insertQuestions.Parameters.Add(New SqlClient.SqlParameter("@questionId", Data.SqlDbType.Int, 0, "questionId"))
                    insertQuestions.Parameters.Add(New SqlClient.SqlParameter("@userId", Data.SqlDbType.Int, 0, "userId"))
                    insertQuestions.Parameters.Add(New SqlClient.SqlParameter("@latitude", Data.SqlDbType.Decimal, 9, "latitude"))
                    insertQuestions.Parameters.Add(New SqlClient.SqlParameter("@longitude", Data.SqlDbType.Decimal, 10, "longitude"))
                    insertQuestions.Parameters.Add(New SqlClient.SqlParameter("@question", Data.SqlDbType.VarChar, 50, "question"))
                    insertQuestions.Parameters.Add(New SqlClient.SqlParameter("@timestamp", Data.SqlDbType.DateTime2, 7, "timestamp"))

                    Using adapter As New Data.SqlClient.SqlDataAdapter()

                        adapter.InsertCommand = insertQuestions
                        adapter.UpdateBatchSize = _batchSize

                        adapter.Update(questions)

                    End Using

                    Me.logProcedureStatistics(_insertQuestion, startTime)

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

                    moveErrors.Parameters.Add(New SqlClient.SqlParameter("@questionId", Data.SqlDbType.Int, 0, "questionId"))
                    moveErrors.Parameters.Add(New SqlClient.SqlParameter("@message", Data.SqlDbType.VarChar, 150, "message"))
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

        Me.logStatistics("processQuestions", startTime)

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




