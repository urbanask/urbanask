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

    Private _commandTimeout As Int32,
        _logProcedureStatitics As Boolean,
        _days As Int32,
        _count As Int32,
        _lookupBadges As String,
        _gabsConnectionString As String,
        _badges As System.Collections.Generic.LinkedList(Of badge)

#Region "    structures "

    Private Structure badge
        Public badgeId As Int32,
            unlimited As Boolean,
            procedure As String

        Public Sub New( _
            badgeId As Int32,
            unlimited As Boolean,
            procedure As String)

            Me.badgeId = badgeId
            Me.unlimited = unlimited
            Me.procedure = procedure

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

        _commandTimeout = Parameters.Parameter.GetInt32Value("commandTimeout")
        _days = Parameters.Parameter.GetInt32Value("days")
        _count = Parameters.Parameter.GetInt32Value("count")
        _lookupBadges = Parameters.Parameter.GetValue("lookupBadges")
        _gabsConnectionString = Parameters.Parameter.GetValue("gabsConnectionString")

    End Sub

    Private Sub initializeLookups()

        _badges = New System.Collections.Generic.LinkedList(Of badge)

        Using gabs As New Data.SqlClient.SqlConnection(_gabsConnectionString)

            gabs.Open()

            Using command As New SqlClient.SqlCommand(_lookupBadges, gabs)

                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = _commandTimeout

                Using badges As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                    If badges.HasRows() Then

                        While (badges.Read())

                            _badges.AddLast(New badge(
                                CInt(badges("badgeId")),
                                CBool(badges("unlimited")),
                                CStr(badges("procedure"))
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

                Me.processBadges(gabs)

            End If

        End Using

    End Sub

    Private Sub processBadges( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        For Each badge In _badges

            If MyBase.IsAppActive() Then

                Me.processBadge(connection, badge)

            End If

        Next badge

        Me.logStatistics("processBadges", startTime)

    End Sub

    Private Sub processBadge( _
        connection As Data.SqlClient.SqlConnection,
        badge As badge)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(badge.procedure, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            command.Parameters.AddWithValue("@badgeId", badge.badgeId)
            command.Parameters.AddWithValue("@unlimited", badge.unlimited)
            command.Parameters.AddWithValue("@days", _days)
            command.Parameters.AddWithValue("@count", _count)

            command.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(badge.procedure, startTime)
        Me.logStatistics("processBadge", startTime)

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




