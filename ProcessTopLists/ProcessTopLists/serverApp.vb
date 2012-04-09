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
        _lookupRegions As String,
        _lookupIntervals As String,
        _processUsersReputation As String,
        _processUsersQuestions As String,
        _processUsersAnswers As String,
        _processUsersBadges As String,
        _gabsConnectionString As String,
        _count As Int32,
        _beginningOfTime As Date,
        _regions As System.Collections.Generic.LinkedList(Of region),
        _intervals As System.Collections.Generic.LinkedList(Of interval)

#Region "    structures "

    Private Structure region
        Public regionId As Int32,
            fromLatitude As Decimal,
            toLatitude As Decimal,
            fromLongitude As Decimal,
            toLongitude As Decimal

        Public Sub New( _
            regionId As Int32,
            fromLatitude As Decimal,
            toLatitude As Decimal,
            fromLongitude As Decimal,
            toLongitude As Decimal)

            Me.regionId = regionId
            Me.fromLatitude = fromLatitude
            Me.toLatitude = toLatitude
            Me.fromLongitude = fromLongitude
            Me.toLongitude = toLongitude

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
        _processUsersReputation = Parameters.Parameter.GetValue("processUsersReputation")
        _processUsersQuestions = Parameters.Parameter.GetValue("processUsersQuestions")
        _processUsersAnswers = Parameters.Parameter.GetValue("processUsersAnswers")
        _processUsersBadges = Parameters.Parameter.GetValue("processUsersBadges")
        _gabsConnectionString = Parameters.Parameter.GetValue("gabsConnectionString")
        _beginningOfTime = Parameters.Parameter.GetDateTimeValue("beginningOfTime")

    End Sub

    Private Sub initializeLookups()

        _regions = New System.Collections.Generic.LinkedList(Of region)
        _intervals = New System.Collections.Generic.LinkedList(Of interval)

        Using gabs As New Data.SqlClient.SqlConnection(_gabsConnectionString)

            gabs.Open()

            Using command As New SqlClient.SqlCommand(_lookupRegions, gabs)

                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = _commandTimeout

                Using regions As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                    If regions.HasRows() Then

                        While (regions.Read())

                            _regions.AddLast(New region(
                                CInt(regions("regionID")),
                                CDec(regions("fromLatitude")),
                                CDec(regions("toLatitude")),
                                CDec(regions("fromLongitude")),
                                CDec(regions("toLongitude"))
                            ))

                        End While

                    End If

                End Using

            End Using

            Using command As New SqlClient.SqlCommand(_lookupIntervals, gabs)

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

                Me.processUsers(gabs)

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

                        Dim beginDate As Date,
                            endDate As Date = DateTime.Parse(DateTime.Today.ToShortDateString + " 23:59:59")


                        Select Case interval.name
                            Case "day"

                                beginDate = DateTime.Today

                            Case "week"

                                beginDate = DateTime.Today.AddDays(-Microsoft.VisualBasic.Weekday(
                                    DateTime.Today,
                                    Microsoft.VisualBasic.FirstDayOfWeek.Monday) + 1)

                            Case "month"

                                beginDate = DateTime.Today.AddDays(-DateTime.Today.Day + 1)

                            Case "year"

                                beginDate = DateTime.Today.AddDays(-DateTime.Today.DayOfYear + 1)

                            Case "all"

                                beginDate = _beginningOfTime

                        End Select

                        Me.processUser(connection, region.regionId, interval.intervalId, beginDate, endDate)

                    End If

                Next interval

            End If

        Next region

        Me.logStatistics("processUsers", startTime)

    End Sub

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




