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
        _processBounties As String,
        _lookupBounties As String,
        _gabsConnectionString As String,
        _logProcedureStatitics As Boolean,
        _count As Int32,
        _bounties As System.Collections.Generic.LinkedList(Of bounty)

    Private Structure bounty
        Public beginMinutes As Int32,
            endMinutes As Int32,
            amount As Int32

        Public Sub New( _
            beginMinutes As Int32,
            endMinutes As Int32,
            amount As Int32)

            Me.beginMinutes = beginMinutes
            Me.endMinutes = endMinutes
            Me.amount = amount

        End Sub

    End Structure

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
        _commandTimeout = Parameters.Parameter.GetInt32Value("commandTimeout")
        _processBounties = Parameters.Parameter.GetValue("processBounties")
        _lookupBounties = Parameters.Parameter.GetValue("lookupBounties")
        _gabsConnectionString = Parameters.Parameter.GetValue("gabsConnectionString")

    End Sub

    Private Sub initializeLookups()

        _bounties = New System.Collections.Generic.LinkedList(Of bounty)

        Using gabs As New Data.SqlClient.SqlConnection(_gabsConnectionString)

            gabs.Open()

            Using command As New SqlClient.SqlCommand(_lookupBounties, gabs)

                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = _commandTimeout

                Using bounties As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                    If bounties.HasRows() Then

                        While (bounties.Read())

                            _bounties.AddLast(New bounty(
                                CInt(bounties("beginMinutes")),
                                CInt(bounties("endMinutes")),
                                CInt(bounties("amount"))
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

                Me.processBounties(gabs)

            End If

        End Using

    End Sub

    Private Sub processBounties( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        For Each bounty In _bounties

            If MyBase.IsAppActive() Then

                Using command As New SqlClient.SqlCommand(_processBounties, connection)

                    command.CommandType = CommandType.StoredProcedure
                    command.CommandTimeout = _commandTimeout

                    command.Parameters.AddWithValue("@beginMinutes", bounty.beginMinutes)
                    command.Parameters.AddWithValue("@endMinutes", bounty.endMinutes)
                    command.Parameters.AddWithValue("@bounty", bounty.amount)
                    command.Parameters.AddWithValue("@count", _count)

                    command.ExecuteNonQuery()

                End Using

                Me.logProcedureStatistics(_processBounties, startTime)

            End If

        Next bounty

        Me.logStatistics("processBounties", startTime)

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




