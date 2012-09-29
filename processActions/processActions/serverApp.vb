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
        _copyToNotificationNew As String,
        _deleteFromWork As String,
        _saveActions As String,
        _logProcedureStatitics As Boolean,
        _moveToWork As String,
        _workCount As Int32


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
        _copyToNotificationNew = Parameters.Parameter.GetValue("copyToNotificationNew")
        _deleteFromWork = Parameters.Parameter.GetValue("deleteFromWork")
        _moveToWork = Parameters.Parameter.GetValue("moveToWork")
        _saveActions = Parameters.Parameter.GetValue("saveActions")

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

                Me.copyToNotificationNew(connection)

            End If

            If MyBase.IsAppActive() Then

                Me.saveActions(connection)

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

    Private Sub copyToNotificationNew( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_copyToNotificationNew, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            command.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(_copyToNotificationNew, startTime)
        Me.logStatistics("copyToNotificationNew", startTime)

    End Sub

    Private Sub saveActions( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_saveActions, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            command.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(_saveActions, startTime)
        Me.logStatistics("saveActions", startTime)

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




