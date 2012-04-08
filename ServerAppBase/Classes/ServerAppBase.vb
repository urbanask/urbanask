#Region "options "

Option Explicit On 
Option Strict On

#End Region

#Region "imports "

Imports System.Windows
Imports System.Windows.Forms
Imports System.Web
Imports NHXS.Utility.Parameters
Imports System.Diagnostics
Imports VB = Microsoft.VisualBasic

#End Region

Public MustInherit Class ServerAppBase

#Region "    variables "

    'members
    Protected _running As Boolean
    Private WithEvents _systemTray As New Forms.NotifyIcon
    Private WithEvents _wait As New NHXS.Utility.ServerAppBase.Wait
    Private _previousErrorMessage As String

    'error parameters
    Private _errorMailTo As String
    Private _errorMailFrom As String
    Private _errorMailSMTPServer As String
    Private _errorMailSubject As String
    Private _fatalErrorMessage As String

    'scheduling parameters
    Protected _enabled As Boolean
    Protected _shutdownApplication As Boolean
    Protected _threadMillisecondsTimeout As Int32
    Private _scheduleType As String
    Private _recurrence As String
    Private _refreshRate As Int32
    Private _days As Collections.ArrayList
    Private _ordinal As String
    Private _startTime As String
    Private _stopTime As String
    Private _lastRunDate As String

#End Region

#Region "    enumerations "

    Protected Enum IconColor As Byte

        RedIcon
        YellowIcon
        GreenIcon
        Disabled

    End Enum

#End Region

#Region "    functions - public "

    Public Sub New()

        Dim message As String

        Try

            _running = True

            Me.InitializeVariables()
            Me.InitializeSystemTrayIcon()
            Me.InitializeParametersBase()

            Me.ProcessBase()

        Catch exception As System.Exception

            message = Me.FatalError(exception)
            Me.LogAndMail(message, EventLogEntryType.Error)

        Finally

            Me.CleanUp()

        End Try

    End Sub

#End Region

#Region "    functions - protected "

    Protected Function IsAppActive() As Boolean

        Dim returnValue As Boolean

        returnValue = _running And (Not _shutdownApplication) And _enabled

        Return returnValue

    End Function

    Protected Sub Log( _
        ByVal message As String)

        Me.Log(message, Diagnostics.EventLogEntryType.Information)

    End Sub

    Protected Sub Log( _
        ByVal message As String, _
        ByVal entryType As Diagnostics.EventLogEntryType)

        EventLog.WriteEntry(Application.ProductName, message, entryType)

    End Sub

    Protected Sub LogAndMail( _
        ByVal message As String)

        Me.LogAndMail(_errorMailTo, message, EventLogEntryType.Information)

    End Sub

    Protected Sub LogAndMail( _
        ByVal message As String, _
        ByVal entryType As EventLogEntryType)

        Me.LogAndMail(_errorMailTo, message, entryType)

    End Sub

    Protected Sub LogAndMail( _
        ByVal mailTo As String, _
        ByVal message As String, _
        ByVal entryType As EventLogEntryType)

        EventLog.WriteEntry(Application.ProductName, message, entryType)

        If entryType = EventLogEntryType.Information Then

            Me.MailLog(mailTo, message)

        Else

            If message <> _previousErrorMessage Then

                Me.MailLog(mailTo, message)

            End If

        End If

        _previousErrorMessage = message

    End Sub

    Protected Sub Pause()

        Windows.Forms.Application.DoEvents()
        Threading.Thread.CurrentThread.Sleep(_threadMillisecondsTimeout)

    End Sub

    Protected Sub Pause( _
        ByVal seconds As Int32)

        Dim wait As NHXS.Utility.ServerAppBase.Wait

        wait = New NHXS.Utility.ServerAppBase.Wait
        wait.Start(seconds)

    End Sub

    Protected Sub DoEvents()

        Windows.Forms.Application.DoEvents()
        Threading.Thread.CurrentThread.Sleep(10)

    End Sub

#End Region

#Region "    functions - mustoverride "

    Protected MustOverride Sub Process()

#End Region

#Region "    functions - overridable "

    Protected Overridable Sub InitializeParameters()

    End Sub

    Protected Overridable Sub RefreshParameters()

    End Sub

#End Region

#Region "    functions - private "

    Private Sub InitializeVariables()

        _previousErrorMessage = ""
        _errorMailTo = ""
        _fatalErrorMessage = ""
        _threadMillisecondsTimeout = 0
        _enabled = True 'assume true so false on load will log

        'default errors
        _errorMailTo = "matt.walton@nhxs.com"
        _errorMailFrom = "ServerAppBase"
        _errorMailSMTPServer = "atr2kex"
        _errorMailSubject = "ServerApp Error"

    End Sub

    Private Sub InitializeParametersBase()

        Me.InitializeErrorParameters()
        Me.RefreshParametersBase()
        Me.RefreshParameters()
        Me.InitializeScheduleParameters()
        Me.InitializeParameters()

    End Sub

    Private Sub InitializeErrorParameters()

        Dim message As String

        _errorMailTo = Parameter.GetValue("ErrorMailTo")
        _errorMailFrom = Parameter.GetValue("ErrorMailFrom")
        _errorMailSMTPServer = Parameter.GetValue("ErrorMailSMTPServer")
        _errorMailSubject = Parameter.GetValue("ErrorMailSubject")
        _fatalErrorMessage = Parameter.GetValue("FatalErrorMessage")

        message = ""

        Select Case ""
            Case _errorMailTo

                message = "ErrorMailTo is a required parameter."

            Case _errorMailFrom

                message = "ErrorMailFrom is a required parameter."

            Case _errorMailSubject

                message = "FatalErrorMailSubject is a required parameter."

            Case _errorMailSMTPServer

                message = "ErrorMailSMTPServer is a required parameter."

            Case _fatalErrorMessage

                message = "FatalErrorMessage is a required parameter."

        End Select

        If message.Length > 0 Then

            Throw New ArgumentException(message)

        End If

    End Sub

    Private Sub InitializeScheduleParameters()

        Dim count As Int32
        Dim parameterName As String
        Dim day As String
        Dim message As String = ""

        _scheduleType = Parameter.GetValue("Schedule/Type")
        _recurrence = Parameter.GetValue("Schedule/Recurrence")
        _days = Parameter.GetValues("Schedule/Days")

        If Parameter.IsParameter("Schedule/Ordinal") Then

            _ordinal = Parameter.GetValue("Schedule/Ordinal")

        End If

        If _days.Count = 0 Then

            message = "Day is a required parameter."

        End If

        Select Case ""
            Case _scheduleType

                message = "ScheduleType is a required parameter."

            Case _recurrence

                message = "Recurrence is a required parameter."

        End Select

        If message.Length > 0 Then

            Throw New System.ApplicationException(message)

        End If

    End Sub

    Private Sub InitializeSystemTrayIcon()

        Dim contextMenu As Forms.ContextMenu
        Dim eventHandler As System.EventHandler
        Dim caption As String

        contextMenu = New Forms.ContextMenu

        eventHandler = New System.EventHandler(AddressOf SystemTrayDisableClickHandler)
        contextMenu.MenuItems.Add("&Disable", eventHandler)

        eventHandler = New System.EventHandler(AddressOf SystemTrayExitClickHandler)
        contextMenu.MenuItems.Add("E&xit", eventHandler)

        Me.UpdateSystemTrayIcon(IconColor.RedIcon)

        If Parameter.Environment <> "Production" Then

            caption = Application.ProductName & " [" & Parameter.Environment & "]"

        Else

            caption = Application.ProductName

        End If

        _systemTray.Text = caption

        _systemTray.ContextMenu = contextMenu
        _systemTray.Visible = True

        Me.DoEvents()

    End Sub

    Private Sub CleanUp()

        Try

            _systemTray.Visible = False
            _systemTray.Dispose()

        Finally

            _wait = Nothing
            _systemTray = Nothing

        End Try

    End Sub

    Private Sub ProcessBase()

        Dim enabled As Boolean

        Do

            If Me.IsAppActive() Then

                If Me.IsScheduled() Then

                    Try

                        Me.UpdateSystemTrayIcon(IconColor.GreenIcon)

                        Me.Process()

                    Finally

                        Me.UpdateSystemTrayIcon(IconColor.YellowIcon)
                        Me.UpdateSystemTrayIcon(IconColor.RedIcon)

                    End Try

                End If

            End If

            If (_running) And (Not _shutdownApplication) Then

                _wait.Start(_refreshRate)

            End If

        Loop While (_running) And (Not _shutdownApplication)

    End Sub

    Private Sub SetEnabledState()

        If _enabled Then

            Me.EnableApplication()

        Else

            Me.DisableApplication()

        End If

        _systemTray.ContextMenu.MenuItems(0).Enabled = True

    End Sub

    Private Sub RefreshParametersBase()

        Dim enabled As Boolean
        Dim message As String
        Dim value As String

        _refreshRate = Convert.ToInt32(Parameter.GetValue("Schedule/RefreshRate"))
        _shutdownApplication = Convert.ToBoolean(Parameter.GetValue("ShutdownApplication"))
        _startTime = Parameter.GetValue("Schedule/StartTime")
        _stopTime = Parameter.GetValue("Schedule/StopTime")
        _lastRunDate = Parameter.GetValue("Schedule/LastRunDate")

        enabled = Convert.ToBoolean(Parameter.GetValue("Enabled"))

        If enabled <> _enabled Then 'enabled state has changed

            _enabled = enabled
            Me.SetEnabledState()

        End If

        If _refreshRate <= 0 Then

            message = "RefreshRate parameter must be greater then 0."
            Throw New System.ApplicationException(message)

        End If

        If _shutdownApplication Then

            message = "ShutdownApplication parameter set to 'True'."
            Me.Log(message, EventLogEntryType.Information)

        End If

        If _startTime.Length = 0 Then

            _startTime = "00:00"

        Else

            If Not VB.IsDate(_startTime) Then

                message = "StartTime parameter must be a valid time."
                Throw New System.ApplicationException(message)

            End If

        End If

        If _stopTime.Length = 0 Then

            _stopTime = "23:59"

        Else

            If Not VB.IsDate(_stopTime) Then

                message = "StopTime parameter must be a valid time."
                Throw New System.ApplicationException(message)

            End If

        End If

        If _lastRunDate.Length = 0 Then

            _lastRunDate = "1/1/1971"

        Else

            If Not VB.IsDate(_lastRunDate) Then

                message = "LastRunDate parameter must be a valid datetime."
                Throw New System.ApplicationException(message)

            End If

        End If

        value = Parameter.GetValue("ThreadMillisecondsTimeout")

        If value = "" Then

            message = "ThreadMillisecondsTimeout is a required parameter in the .config file."
            Throw New System.ApplicationException(message)

        Else

            _threadMillisecondsTimeout = Convert.ToInt32(value)

        End If

        Me.RefreshParameters()

    End Sub

    Private Sub EnableApplication()

        Dim message As String
        Dim caption As String

        message = "Application has been enabled."
        Me.Log(message, EventLogEntryType.Warning)

        If Parameter.Environment <> "Production" Then

            caption = Application.ProductName & " [" & Parameter.Environment & "]"

        Else

            caption = Application.ProductName

        End If

        _systemTray.Text = caption
        Me.UpdateSystemTrayIcon(IconColor.RedIcon)

        _systemTray.ContextMenu.MenuItems(0).Text = "Disable"

        Me.InitializeParametersBase()

    End Sub

    Private Sub DisableApplication()

        Dim message As String
        Dim caption As String

        message = "Application has been disabled."
        Me.Log(message, EventLogEntryType.Warning)

        If Parameter.Environment <> "Production" Then

            caption = Application.ProductName & " [" & Parameter.Environment & "]" & " (Disabled)"

        Else

            caption = Application.ProductName & " (Disabled)"

        End If

        _systemTray.Text = caption
        Me.UpdateSystemTrayIcon(IconColor.Disabled)

        _systemTray.ContextMenu.MenuItems(0).Text = "Enable"
        _wait.Stop()

    End Sub

    Private Function IsScheduled() As Boolean

        Dim returnValue As Boolean

        Select Case _scheduleType
            Case "Daily"

                returnValue = Me.IsScheduledDaily()

            Case "Weekly"

                returnValue = Me.IsScheduledWeekly()

            Case "Monthly"

                returnValue = Me.IsScheduledMonthly()

        End Select

        Return returnValue

    End Function

    Private Function IsScheduledDaily() As Boolean

        Dim day As String
        Dim today As String
        Dim isDay As Boolean
        Dim startTime As DateTime
        Dim lastRunDate As DateTime
        Dim returnValue As Boolean

        day = _days.Item(0).ToString()
        today = DateTime.Now.DayOfWeek.ToString()

        Select Case day
            Case "EveryDay"

                isDay = True

            Case "WeekDays"

                If today <> "Saturday" And today <> "Sunday" Then

                    isDay = True

                End If

            Case "Weekends"

                If today = "Saturday" Or today = "Sunday" Then

                    isDay = True

                End If

        End Select

        If isDay Then

            returnValue = Me.IsScheduledRecurrence()

        End If

        Return returnValue

    End Function

    Private Function IsScheduledWeekly() As Boolean

        Dim today As String
        Dim day As String
        Dim isDay As Boolean
        Dim startTime As DateTime
        Dim lastRunDate As DateTime
        Dim returnValue As Boolean

        today = DateTime.Now.DayOfWeek.ToString()

        For Each day In _days

            If Not isDay Then

                If day = today Then

                    isDay = True

                End If

            End If

        Next day

        If isDay Then

            returnValue = Me.IsScheduledRecurrence()

        End If

        Return returnValue

    End Function

    Private Function IsScheduledMonthly() As Boolean

        Dim today As String
        Dim day As String
        Dim isDay As Boolean
        Dim returnValue As Boolean

        If _ordinal = "" Then 'day of month

            today = DateTime.Now.Day.ToString()

        Else    'weekday of month

            today = DateTime.Now.DayOfWeek.ToString()

        End If

        For Each day In _days

            If Not isDay Then

                If day = today Then

                    If IsOrdinal() Then

                        isDay = True

                    End If

                End If

            End If

        Next day

        If isDay Then

            returnValue = Me.IsScheduledRecurrence()

        End If

        Return returnValue

    End Function

    Private Function IsScheduledRecurrence() As Boolean

        Dim startTime As DateTime
        Dim lastRunDate As DateTime
        Dim returnValue As Boolean

        If IsScheduledHour() Then

            Select Case _recurrence
                Case "Once"

                    startTime = Convert.ToDateTime(_startTime)
                    lastRunDate = Convert.ToDateTime(_lastRunDate)

                    If DateTime.Compare(startTime, lastRunDate) >= 0 Then 'hasn't run today

                        _lastRunDate = DateTime.Now.ToString
                        Parameter.SetValue("Schedule/LastRunDate", _lastRunDate)

                        returnValue = True

                    End If

                Case "Unlimited"

                    returnValue = True

            End Select

        End If

        Return returnValue

    End Function

    Private Function IsOrdinal() As Boolean

        Dim returnValue As Boolean
        Dim today As Int32
        Dim count As Int32

        If _ordinal = "" Then

            returnValue = True

        Else

            today = DateTime.Now.Day
            count = today \ 7

            If (today Mod 7) > 0 Then

                count += 1

            End If

            Select Case _ordinal
                Case "1st"

                    If count = 1 Then

                        returnValue = True

                    End If

                Case "2nd"

                    If count = 2 Then

                        returnValue = True

                    End If

                Case "3rd"

                    If count = 3 Then

                        returnValue = True

                    End If

                Case "4th"

                    If count = 4 Then

                        returnValue = True

                    End If

                Case "Last"

                    Throw New System.ApplicationException("Method not available.")

            End Select

        End If

        Return returnValue

    End Function

    Private Function IsScheduledHour() As Boolean

        Dim returnValue As Boolean
        Dim startTime As DateTime
        Dim stopTime As New DateTime

        startTime = Convert.ToDateTime(_startTime)
        stopTime = Convert.ToDateTime(_stopTime)

        If DateTime.Compare(DateTime.Now(), startTime) >= 0 Then

            If DateTime.Compare(DateTime.Now(), stopTime) <= 0 Then

                returnValue = True

            End If

        End If

        Return returnValue

    End Function

    Private Sub MailLog( _
        ByVal mailTo As String, _
        ByVal message As String)

        Dim mailMessage As Mail.MailMessage
        Dim machineName As String

        If _errorMailTo.Length > 0 Then

            mailMessage = New Mail.MailMessage

            machineName = Environment.MachineName

            mailMessage.To = mailTo
            mailMessage.From = _errorMailFrom
            mailMessage.Subject = _errorMailSubject & " [" & machineName & "]"
            mailMessage.Body = message

            Mail.SmtpMail.SmtpServer = _errorMailSMTPServer

            Mail.SmtpMail.Send(mailMessage)

        End If

    End Sub

    Private Sub UpdateSystemTrayIcon( _
        ByVal color As ServerAppBase.IconColor)

        Dim icon As Drawing.Icon
        Dim wait As New NHXS.Utility.ServerAppBase.Wait

        If _enabled Then

            wait.Start(1) 'one second pause for traffic light effect

            Select Case color
                Case IconColor.RedIcon

                    icon = Resources.RedIcon

                Case IconColor.YellowIcon

                    icon = Resources.YellowIcon

                Case IconColor.GreenIcon

                    icon = Resources.GreenIcon

            End Select

        Else

            icon = Resources.DisabledIcon

        End If

        _systemTray.Icon = icon

    End Sub

#End Region

#Region "    properties "

    Private ReadOnly Property FatalError( _
        ByVal exception As System.Exception) As String

        Get

            Dim retrunValue As String

            If _fatalErrorMessage = "" Then

                _fatalErrorMessage = _
                      "The following FATAL error occurred and the application is exiting:\n\n" _
                    & "Error:\n" _
                    & "{0}\n\n" _
                    & "Stack:\n" _
                    & "{1}\n\n"

            End If

            retrunValue = _fatalErrorMessage.Replace("\n", VB.ControlChars.Lf)
            retrunValue = String.Format( _
                retrunValue, _
                exception.Message(), _
                exception.StackTrace())

            Return retrunValue

        End Get

    End Property

#End Region

#Region "    event handlers "

    Private Sub SystemTrayExitClickHandler( _
        ByVal sender As Object, _
        ByVal arguments As System.EventArgs)

        _running = False
        _wait.Stop()

    End Sub

    Private Sub SystemTrayDisableClickHandler( _
        ByVal sender As Object, _
        ByVal arguments As System.EventArgs)

        _systemTray.ContextMenu.MenuItems(0).Enabled = False

        _enabled = Not _enabled
        Parameter.SetValue("Enabled", _enabled.ToString())

        Me.SetEnabledState()

    End Sub

    Private Sub WaitWaitingHandler( _
        ByRef running As Boolean) Handles _wait.Waiting

        Static lastRefresh As DateTime = DateTime.Now

        'refresh parameters every 10 seconds
        If DateTime.Now.Subtract(lastRefresh).Seconds >= 10 Then

            Me.RefreshParametersBase()
            Me.RefreshParameters()

            lastRefresh = DateTime.Now

        End If

        If (Not _running) Or (_shutdownApplication) Then

            _wait.Stop()

        End If

    End Sub

#End Region

End Class


