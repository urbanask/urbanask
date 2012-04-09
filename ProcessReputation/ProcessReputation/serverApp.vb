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
        _gabsConnectionString As String,
        _logProcedureStatitics As Boolean,
        _lookupReputationActions As String,
        _expirationDays As Int32,
        _count As Int32,
        _days As Int32,
        _reputationActions As System.Collections.Generic.LinkedList(Of reputationAction)

#Region "    structures "

    Private Structure reputationAction
        Public reputationActionId As Int32,
            procedure As String,
            reputation As String

        Public Sub New( _
            reputationActionId As Int32,
            procedure As String,
            reputation As String)

            Me.reputationActionId = reputationActionId
            Me.procedure = procedure
            Me.reputation = reputation

        End Sub

    End Structure

#End Region

#Region "    functions "

    Public Shared Sub main()

        Dim app As New serverApp

    End Sub

#Region "    initialization "

    Protected Overrides Sub initializeParameters()

        Me.initializeConfigParameters()
        Me.initializeLookups()

    End Sub

    Private Sub initializeConfigParameters()

        _count = Parameters.Parameter.GetInt32Value("count")
        _days = Parameters.Parameter.GetInt32Value("days")
        _expirationDays = Parameters.Parameter.GetInt32Value("expirationDays")
        _lookupReputationActions = Parameters.Parameter.GetValue("lookupReputationActions")
        _commandTimeout = Parameters.Parameter.GetInt32Value("commandTimeout")
        _gabsConnectionString = Parameters.Parameter.GetValue("gabsConnectionString")

    End Sub

    Private Sub initializeLookups()

        _reputationActions = New System.Collections.Generic.LinkedList(Of reputationAction)

        Using gabs As New Data.SqlClient.SqlConnection(_gabsConnectionString)

            gabs.Open()

            Using command As New SqlClient.SqlCommand(_lookupReputationActions, gabs)

                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = _commandTimeout

                Using reputationActions As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                    If reputationActions.HasRows() Then

                        While (reputationActions.Read())

                            _reputationActions.AddLast(New reputationAction(
                                CInt(reputationActions("reputationActionId")),
                                CStr(reputationActions("procedure")),
                                CStr(reputationActions("reputation"))
                            ))

                        End While

                    End If

                End Using

            End Using

        End Using

    End Sub

    Protected Overrides Sub refreshParameters()

        _logProcedureStatitics = Parameters.Parameter.GetBooleanValue("logProcedureStatitics")

    End Sub

#End Region

    Protected Overrides Sub process()

        Using gabs As New Data.SqlClient.SqlConnection(_gabsConnectionString)

            gabs.Open()

            If MyBase.IsAppActive() Then

                Me.processReputationActions(gabs)

            End If

        End Using

    End Sub

    Private Sub processReputationActions( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        For Each reputationAction In _reputationActions

            If MyBase.IsAppActive() Then

                Me.processReputationAction(connection, reputationAction)

            End If

        Next reputationAction

        Me.logStatistics("processReputationActions", startTime)

    End Sub

    Private Sub processReputationAction( _
        connection As Data.SqlClient.SqlConnection,
        reputationAction As reputationAction)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(reputationAction.procedure, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            command.Parameters.AddWithValue("@reputationActionId", reputationAction.reputationActionId)
            command.Parameters.AddWithValue("@reputation", reputationAction.reputation)
            command.Parameters.AddWithValue("@days", _days)
            command.Parameters.AddWithValue("@count", _count)
            command.Parameters.AddWithValue("@expirationDays", _expirationDays)

            command.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(reputationAction.procedure, startTime)
        Me.logStatistics("processReputationAction", startTime)

    End Sub

    Private Sub logStatistics( _
        description As String, _
        startTime As DateTime)

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




