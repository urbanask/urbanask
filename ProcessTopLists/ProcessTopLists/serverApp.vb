#Region "options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region "imports "

Imports System.Data
Imports Utility
Imports VB = Microsoft.VisualBasic

#End Region

Public Class serverApp : Inherits Utility.ServerAppBase.ServerAppBase

    Private _commandTimeout As Int32,
        _logProcedureStatitics As Boolean,
        _lookupRegions As String,
        _lookupIntervals As String,
        _lookupTopTypes As String,
        _processUsersReputation As String,
        _processUsersQuestions As String,
        _processUsersAnswers As String,
        _processUsersBadges As String,
        _processRegionRollup As String,
        _connectionString As String,
        _count As Int32,
        _beginningOfTime As Date,
        _regions As System.Collections.Generic.LinkedList(Of region),
        _intervals As System.Collections.Generic.LinkedList(Of interval),
        _topTypes As System.Collections.Generic.LinkedList(Of topType)

#Region "    structures "

    Private Structure region
        Public regionId As Int32,
            level As Int32

        Public Sub New( _
            regionId As Int32,
            level As Int32)

            Me.regionId = regionId
            Me.level = level

        End Sub

    End Structure

    Private Structure interval
        Public intervalId As Int32,
            name As String

        Public Sub New( _
            intervalId As Int32,
            name As String)

            Me.intervalId = intervalId
            Me.name = name

        End Sub

    End Structure

    Private Structure topType
        Public topTypeId As Int32

        Public Sub New( _
            topTypeId As Int32)

            Me.topTypeId = topTypeId

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

        _count = Parameters.Parameter.GetInt32Value("count")
        _lookupRegions = Parameters.Parameter.GetValue("lookupRegions")
        _lookupIntervals = Parameters.Parameter.GetValue("lookupIntervals")
        _lookupTopTypes = Parameters.Parameter.GetValue("lookupTopTypes")
        _processUsersReputation = Parameters.Parameter.GetValue("processUsersReputation")
        _processUsersQuestions = Parameters.Parameter.GetValue("processUsersQuestions")
        _processUsersAnswers = Parameters.Parameter.GetValue("processUsersAnswers")
        _processUsersBadges = Parameters.Parameter.GetValue("processUsersBadges")
        _processRegionRollup = Parameters.Parameter.GetValue("processRegionRollup")
        _connectionString = Parameters.Parameter.GetValue("connectionString")
        _beginningOfTime = Parameters.Parameter.GetDateTimeValue("beginningOfTime")

    End Sub

    Private Sub initializeLookups()

        _regions = New System.Collections.Generic.LinkedList(Of region)
        _intervals = New System.Collections.Generic.LinkedList(Of interval)
        _topTypes = New System.Collections.Generic.LinkedList(Of topType)

        Using connection As New Data.SqlClient.SqlConnection(_connectionString)

            connection.Open()

            Using command As New SqlClient.SqlCommand(_lookupRegions, connection)

                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = _commandTimeout

                Using regions As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                    If regions.HasRows() Then

                        While (regions.Read())

                            _regions.AddLast(New region(
                                CInt(regions("regionID")),
                                CInt(regions("level"))
                            ))

                        End While

                    End If

                End Using

            End Using

            Using command As New SqlClient.SqlCommand(_lookupIntervals, connection)

                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = _commandTimeout

                Using intervals As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                    If intervals.HasRows() Then

                        While (intervals.Read())

                            _intervals.AddLast(New interval(
                                CInt(intervals("intervalId")),
                                CStr(intervals("name"))
                            ))

                        End While

                    End If

                End Using

            End Using

            Using command As New SqlClient.SqlCommand(_lookupTopTypes, connection)

                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = _commandTimeout

                Using topTypes As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                    If topTypes.HasRows() Then

                        While (topTypes.Read())

                            _topTypes.AddLast(New topType(
                                CInt(topTypes("topTypeId"))
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

        Using gabs As New Data.SqlClient.SqlConnection(_connectionString)

            gabs.Open()

            If MyBase.IsAppActive() Then

                Me.processUsers(gabs)

            End If

            If MyBase.IsAppActive() Then

                Me.processRegionRollups(gabs)

            End If

        End Using

    End Sub

    Private Sub processUsers( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        For Each region In _regions

            If MyBase.IsAppActive() Then

                For Each interval In _intervals

                    If MyBase.IsAppActive() Then

                        Dim beginDate As Date = Me.beginDate(interval.name),
                            endDate As Date = DateTime.Parse(DateTime.Today.ToShortDateString + " 23:59:59")

                        Me.processUser(connection, region.regionId, interval.intervalId, beginDate, endDate)

                    End If

                Next interval

            End If

        Next region

        Me.logStatistics("processUsers", startTime)

    End Sub

    Private ReadOnly Property beginDate(interval As String) As Date

        Get

            Dim returnValue As Date

            Select Case interval
                Case "day"

                    returnValue = DateTime.Today

                Case "week"

                    returnValue = DateTime.Today.AddDays(-Microsoft.VisualBasic.Weekday(
                        DateTime.Today,
                        Microsoft.VisualBasic.FirstDayOfWeek.Monday) + 1)

                Case "month"

                    returnValue = DateTime.Today.AddDays(-DateTime.Today.Day + 1)

                Case "year"

                    returnValue = DateTime.Today.AddDays(-DateTime.Today.DayOfYear + 1)

                Case "all"

                    returnValue = _beginningOfTime

            End Select

            Return returnValue

        End Get

    End Property

    Private Sub processUser( _
        connection As Data.SqlClient.SqlConnection,
        regionId As Int32,
        intervalId As Int32,
        beginDate As Date,
        endDate As Date)

        Dim startTime As System.DateTime = System.DateTime.Now

        Me.processTopType(connection, _processUsersReputation, regionId, intervalId, beginDate, endDate)
        Me.processTopType(connection, _processUsersQuestions, regionId, intervalId, beginDate, endDate)
        Me.processTopType(connection, _processUsersAnswers, regionId, intervalId, beginDate, endDate)
        Me.processTopType(connection, _processUsersBadges, regionId, intervalId, beginDate, endDate)

        Me.logStatistics("processUser", startTime)

    End Sub

    Private Sub processTopType( _
        connection As Data.SqlClient.SqlConnection,
        procedure As String,
        regionId As Int32,
        intervalId As Int32,
        beginDate As Date,
        endDate As Date)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(procedure, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            command.Parameters.AddWithValue("@regionId", regionId)
            command.Parameters.AddWithValue("@intervalId", intervalId)
            command.Parameters.AddWithValue("@beginDate", beginDate)
            command.Parameters.AddWithValue("@endDate", endDate)
            command.Parameters.AddWithValue("@count", _count)

            command.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(procedure + "( region: " + regionId.ToString() + ", interval: " + intervalId.ToString() + ")", startTime)
        Me.logStatistics("processTopType", startTime)

    End Sub

    Private Sub processRegionRollups( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        For Each region In _regions

            If MyBase.IsAppActive() Then

                For Each topType In _topTypes

                    If MyBase.IsAppActive() Then

                        For Each interval In _intervals

                            If MyBase.IsAppActive() Then

                                Me.processRegionRollup(connection, region.regionId, topType.topTypeId, interval.intervalId)

                            End If

                        Next interval

                    End If

                Next topType

            End If

        Next region

        Me.logStatistics("processRegionRollups", startTime)

    End Sub

    Private Sub processRegionRollup( _
        connection As Data.SqlClient.SqlConnection,
        regionId As Int32,
        topTypeId As Int32,
        intervalId As Int32)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_processRegionRollup, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            command.Parameters.AddWithValue("@regionId", regionId)
            command.Parameters.AddWithValue("@topTypeId", topTypeId)
            command.Parameters.AddWithValue("@intervalId", intervalId)
            command.Parameters.AddWithValue("@count", _count)

            command.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(String.Concat("( region: ", regionId, ", topTypeId: ", topTypeId, ", interval: ", intervalId, ")"), startTime)
        Me.logStatistics("processRegionRollup", startTime)

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




