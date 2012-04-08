#Region "options "

Option Explicit On 
Option Strict On
Option Compare Binary

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
    Private _running As Boolean
    Private WithEvents _systemTray As Forms.NotifyIcon
    Private WithEvents _wait As NHXS.Utility.ServerAppBase.Wait
    Private _previousErrorMessage As String = ""
    Private _lastErrorTime As System.DateTime
    Private _errorCount As Int32
    Private _errorMax As Int32 'errors per _errorTimeLimit
    Private _errorTimeLimit As Int32 'minutes to allow _errorMax errors
    Private _enoughErrors As Boolean

    'error parameters
    Private _mailTo As String
    Private _errorMailFrom As String
    Private _smtpServer As String
    Private _informationMailFrom As String

    'scheduling parameters
    Private _enabled As Boolean
    Private _shutdownApplication As Boolean
    Private _threadMillisecondsTimeout As Int32
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

        Me.AddExceptionHandler()
        Me.Log("Application starting.", Diagnostics.EventLogEntryType.Information)
        _lastErrorTime = System.DateTime.Now

        Do

            Me.Initialize()
            Me.Run()

        Loop Until _enoughErrors Or (Not _running) Or _shutdownApplication

        Me.Log("Application stopping.", Diagnostics.EventLogEntryType.Information)

    End Sub

    Sub AddExceptionHandler()

        Dim currentDomain As AppDomain = AppDomain.CurrentDomain
        AddHandler currentDomain.UnhandledException, AddressOf ApplicationExceptionHandler

    End Sub

    Sub ApplicationExceptionHandler( _
        ByVal sender As Object, _
        ByVal argument As System.UnhandledExceptionEventArgs)

        Dim exception As System.Exception
        Dim message As String

        exception = DirectCast(argument.ExceptionObject, System.Exception)
        message = exception.GetBaseException.Message
        Diagnostics.EventLog.WriteEntry(Forms.Application.ProductName, message, EventLogEntryType.Error)

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

        Diagnostics.EventLog.WriteEntry(Forms.Application.ProductName, message, entryType)

    End Sub

    Protected Sub LogAndMail( _
        ByVal message As String)

        Me.LogAndMail(_mailTo, message, Diagnostics.EventLogEntryType.Information)

    End Sub

    Protected Sub LogAndMail( _
        ByVal message As String, _
        ByVal entryType As Diagnostics.EventLogEntryType)

        Me.LogAndMail(_mailTo, message, entryType)

    End Sub

    Protected Sub LogAndMail( _
        ByVal mailTo As String, _
        ByVal message As String, _
        ByVal entryType As Diagnostics.EventLogEntryType)

        Dim assemblyName As String

        assemblyName = My.Application.Info.AssemblyName

        Diagnostics.EventLog.WriteEntry(assemblyName, message, entryType)

        If entryType = Diagnostics.EventLogEntryType.Information Then

            Me.MailLog(_informationMailFrom, mailTo, message)

        Else

            If message <> _previousErrorMessage Then

                Me.MailLog(_errorMailFrom, mailTo, message)

            End If

        End If

        _previousErrorMessage = message

    End Sub

    Protected Sub Pause()

        Windows.Forms.Application.DoEvents()
        Threading.Thread.Sleep(_threadMillisecondsTimeout)

    End Sub

    Protected Sub Pause( _
        ByVal seconds As Int32)

        _wait.Start(seconds)

    End Sub

    Protected Sub DoEvents()

        Windows.Forms.Application.DoEvents()
        Threading.Thread.Sleep(10)

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

    Private Sub Initialize()

        Me.InitializeVariables()
        Me.InitializeSystemTrayIcon()
        Me.InitializeParametersBase()

    End Sub

    Private Sub InitializeVariables()

        _running = True

        _threadMillisecondsTimeout = 0
        _enabled = True 'assume true so false on load will log
        _systemTray = New Windows.Forms.NotifyIcon
        _wait = New NHXS.Utility.ServerAppBase.Wait
        _errorMax = 10 'errors per _errorTimeLimit
        _errorTimeLimit = 10 'minutes to allow _errorMax errors

        'default errors
        _mailTo = "matt.walton@nhxs.com"
        _errorMailFrom = "ServerAppError@nhxs.com"
        _informationMailFrom = "ServerAppInfo@nhxs.com"
        _smtpServer = "MAIL-PROD-1"

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

        message = ""
        _mailTo = Parameters.Parameter.GetValue("ErrorMailTo")

        Select Case ""
            Case _mailTo

                message = "ErrorMailTo is a required parameter."

        End Select

        If message.Length > 0 Then

            Throw New System.ApplicationException(message)

        End If

    End Sub

    Private Sub InitializeScheduleParameters()

        Dim message As String = ""

        _scheduleType = Parameters.Parameter.GetValue("Schedule/Type")
        _recurrence = Parameters.Parameter.GetValue("Schedule/Recurrence")
        _days = Parameters.Parameter.GetValues("Schedule/Days")

        If Parameters.Parameter.IsParameter("Schedule/Ordinal") Then

            _ordinal = Parameters.Parameter.GetValue("Schedule/Ordinal")

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

        contextMenu = New Forms.ContextMenu

        eventHandler = New System.EventHandler(AddressOf Me.SystemTrayDisableClickHandler)
        contextMenu.MenuItems.Add("&Disable", eventHandler)

        eventHandler = New System.EventHandler(AddressOf Me.SystemTrayExitClickHandler)
        contextMenu.MenuItems.Add("E&xit", eventHandler)

        _systemTray.ContextMenu = contextMenu

        Me.SetSystemTrayIcon(IconColor.RedIcon)
        Me.SetSystemTrayCaption()

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

        System.GC.Collect()

    End Sub

    Private Sub Run()

        Try

            Me.ProcessBase()

        Catch exception As System.Exception

            Me.HandleException(exception)

        Finally

            Me.CleanUp()

        End Try

    End Sub

    Private Sub ProcessBase()

        Do

            If Me.IsAppActive() Then

                If Me.IsScheduled() Then

                    Try

                        Me.SetSystemTrayIcon(IconColor.GreenIcon)
                        Me.Process()
                        Me.SetLastRunDate()

                    Finally

                        Me.SetSystemTrayIcon(IconColor.YellowIcon)
                        Me.SetSystemTrayIcon(IconColor.RedIcon)

                    End Try

                End If

            End If

            'TODO: System.GC.Collect()  'needs more testing

            If (_running) And (Not _shutdownApplication) Then

                _wait.Start(_refreshRate)

            End If

        Loop While (_running) And (Not _shutdownApplication)

    End Sub

    Private Sub SetSystemTrayCaption()

        Dim caption As Text.StringBuilder

        caption = New Text.StringBuilder(128)

        If Parameters.Parameter.Product <> "" Then

            caption.Append(Parameters.Parameter.Product)
            caption.Append("/")

        End If

        caption.Append(My.Application.Info.AssemblyName)

        If Parameters.Parameter.Environment <> "Production" Then

            caption.Append(" [")
            caption.Append(Parameters.Parameter.Environment)
            caption.Append("]")

        End If

        If Not _enabled Then

            caption.Append(" (Disabled)")

        End If

        _systemTray.Text = caption.ToString()

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

        _refreshRate = Convert.ToInt32(Parameters.Parameter.GetValue("Schedule/RefreshRate"))
        _shutdownApplication = Convert.ToBoolean(Parameters.Parameter.GetValue("ShutdownApplication"))
        _startTime = Parameters.Parameter.GetValue("Schedule/StartTime")
        _stopTime = Parameters.Parameter.GetValue("Schedule/StopTime")
        _lastRunDate = Parameters.Parameter.GetValue("Schedule/LastRunDate")

        enabled = System.Convert.ToBoolean(Parameters.Parameter.GetValue("Enabled"))

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

        message = "Application has been enabled."
        Me.Log(message, EventLogEntryType.Warning)

        Me.SetSystemTrayCaption()
        Me.SetSystemTrayIcon(IconColor.RedIcon)

        _systemTray.ContextMenu.MenuItems(0).Text = "Disable"

        Me.InitializeParametersBase()

    End Sub

    Private Sub DisableApplication()

        Dim message As String

        message = "Application has been disabled."
        Me.Log(message, EventLogEntryType.Warning)

        Me.SetSystemTrayCaption()
        Me.SetSystemTrayIcon(IconColor.Disabled)

        _systemTray.ContextMenu.MenuItems(0).Text = "Enable"
        _wait.Stop()

    End Sub

    Protected Function IsScheduled() As Boolean

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

        If Me.IsScheduledHour() Then

            Select Case _recurrence
                Case "Once"

                    startTime = System.Convert.ToDateTime(_startTime)
                    lastRunDate = System.Convert.ToDateTime(_lastRunDate)

                    If System.DateTime.Compare(startTime, lastRunDate) >= 0 Then 'hasn't run today

                        returnValue = True

                    End If

                Case "Unlimited"

                    returnValue = True

            End Select

        End If

        Return returnValue

    End Function

    Private Sub SetLastRunDate()

        Dim startTime As System.DateTime
        Dim lastRunDate As System.DateTime

        If _recurrence = "Once" Then

            startTime = System.Convert.ToDateTime(_startTime)
            lastRunDate = System.Convert.ToDateTime(_lastRunDate)

            If System.DateTime.Compare(startTime, lastRunDate) >= 0 Then 'hasn't run today

                _lastRunDate = System.DateTime.Now.ToString()
                Parameters.Parameter.SetValue("Schedule/LastRunDate", _lastRunDate)

            End If

        End If

    End Sub

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
        ByVal mailFrom As String, _
        ByVal mailTo As String, _
        ByVal message As String)

        Dim subject As Text.StringBuilder
        Dim client As Net.Mail.SmtpClient

        subject = New Text.StringBuilder(128)

        subject.Append(My.Application.Info.AssemblyName)
        subject.Append(" Message")
        subject.Append(" [")
        subject.Append(System.Environment.MachineName)
        subject.Append("]")

        Using mailMessage As New Net.Mail.MailMessage(mailFrom, mailTo, subject.ToString(), message)

            client = New Net.Mail.SmtpClient(_smtpServer)
            client.Send(mailMessage)

        End Using

    End Sub

    Private Sub SetSystemTrayIcon( _
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

                Case Else

                    icon = Nothing

            End Select

        Else

            icon = Resources.DisabledIcon

        End If

        _systemTray.Icon = icon

    End Sub

    Private Function IsRetryError( _
        ByVal exception As System.Exception) As Boolean

        Dim errorMessage As String
        Dim returnvalue As Boolean

        errorMessage = exception.Message

        Select Case True
            Case errorMessage.IndexOf("The remote server returned an error: (500) Internal Server Error.") > -1, _
                errorMessage.IndexOf("The underlying connection was closed") > -1, _
                errorMessage.IndexOf("The operation has timed-out.") > -1, _
                errorMessage.IndexOf("Timeout expired.") > -1, _
                errorMessage.IndexOf("was deadlocked on lock resources with another process") > -1, _
                errorMessage.IndexOf("General network error.") > -1, _
                errorMessage.IndexOf("connection was forcibly closed by the remote host.") > -1, _
                errorMessage.IndexOf("Exception of type 'System.OutOfMemoryException' was thrown") > -1, _
                errorMessage.IndexOf("The remote server returned an error: (401) Unauthorized.") > -1, _
                errorMessage.IndexOf("The remote server returned an error: (503) Server Unavailable.") > -1, _
                errorMessage.IndexOf("A transport-level error has occurred when receiving results from the server") > -1, _
                errorMessage.IndexOf("A connection attempt failed because the connected party did not properly respond") > -1, _
                errorMessage.IndexOf("Could not continue scan with NOLOCK due to data movement.") > -1, _
                errorMessage.IndexOf("This SqlTransaction has completed; it is no longer usable.") > -1

                returnvalue = True

            Case Else

                returnvalue = False

        End Select

        Return returnvalue

    End Function

    Private Sub HandleException( _
        ByVal exception As System.Exception)

        Dim message As String
        Dim now As System.DateTime

        message = Me.FatalError(exception)

        If Me.IsRetryError(exception) Then

            Me.Log(message, Diagnostics.EventLogEntryType.Error)

            now = System.DateTime.Now

            If now.Subtract(_lastErrorTime).TotalMinutes > _errorTimeLimit Then

                _lastErrorTime = System.DateTime.Now
                _errorCount = 0

            Else

                _errorCount += 1

                If _errorCount >= _errorMax Then

                    Me.MailLog(_errorMailFrom, _mailTo, message)
                    _enoughErrors = True

                End If

            End If

        Else

            Me.LogAndMail(message, Diagnostics.EventLogEntryType.Error)
            _running = False

        End If

    End Sub

#End Region

#Region "    properties "

    Private ReadOnly Property FatalError( _
        ByVal exception As System.Exception) As String

        Get

            Dim retrunValue As String
            Dim server As String
            Dim application As String
            Dim product As String
            Dim environment As String
            Dim exceptionMessage As String
            Dim stackTrace As String

            retrunValue = _
                  "The following FATAL error occurred and the application is exiting:\n\n" _
                & "Server:      {0}\n" _
                & "Application: {1}\n" _
                & "Product:     {2}\n" _
                & "Environment: {3}\n\n" _
                & "Error:\n" _
                & "{4}\n\n" _
                & "Stack:\n" _
                & "{5}\n\n"
            retrunValue = retrunValue.Replace("\n", VB.ControlChars.Lf)

            server = System.Environment.MachineName
            application = My.Application.Info.AssemblyName
            product = Parameters.Parameter.Product
            environment = Parameters.Parameter.Environment
            exceptionMessage = exception.Message()
            stackTrace = exception.StackTrace()

            retrunValue = String.Format( _
                retrunValue, _
                server, _
                application, _
                product, _
                environment, _
                exceptionMessage, _
                stackTrace)

            Return retrunValue

        End Get

    End Property

#End Region

#Region "    properties - protected "

    Protected Property Running() As Boolean

        Get

            Return _running

        End Get

        Set(ByVal running As Boolean)

            _running = running

        End Set

    End Property

    Protected Property Enabled() As Boolean

        Get

            Return _enabled

        End Get

        Set(ByVal enabled As Boolean)

            _enabled = enabled

        End Set

    End Property

    Protected Property ShutdownApplication() As Boolean

        Get

            Return _shutdownApplication

        End Get

        Set(ByVal shutdownApplication As Boolean)

            _shutdownApplication = shutdownApplication

        End Set

    End Property

    Protected Property ThreadMillisecondsTimeout() As Int32

        Get

            Return _threadMillisecondsTimeout

        End Get

        Set(ByVal threadMillisecondsTimeout As Int32)

            _threadMillisecondsTimeout = threadMillisecondsTimeout

        End Set

    End Property

#End Region

#Region "    event functions "

    Private Sub OnSystemTrayExitClick( _
        ByVal sender As Object, _
        ByVal arguments As System.EventArgs)

        _running = False
        _wait.Stop()

    End Sub

    Private Sub OnSystemTrayDisableClick( _
        ByVal sender As Object, _
        ByVal arguments As System.EventArgs)

        _systemTray.ContextMenu.MenuItems(0).Enabled = False

        _enabled = Not _enabled
        Parameters.Parameter.SetValue("Enabled", _enabled.ToString())

        Me.SetEnabledState()

    End Sub

    Private Sub OnWaitWaiting( _
        ByRef running As Boolean)

        Static lastRefresh As System.DateTime = System.DateTime.Now

        'refresh parameters every 10 seconds
        If DateTime.Now.Subtract(lastRefresh).Seconds >= 10 Then

            Me.RefreshParametersBase()
            Me.RefreshParameters()

            lastRefresh = System.DateTime.Now

        End If

        If (Not _running) Or (_shutdownApplication) Then

            _wait.Stop()

        End If

    End Sub

#End Region

#Region "    event handlers "

    Private Sub SystemTrayExitClickHandler( _
        ByVal sender As Object, _
        ByVal arguments As System.EventArgs)

        Me.OnSystemTrayExitClick(sender, arguments)

    End Sub

    Private Sub SystemTrayDisableClickHandler( _
        ByVal sender As Object, _
        ByVal arguments As System.EventArgs)

        Me.OnSystemTrayDisableClick(sender, arguments)

    End Sub

    Private Sub WaitWaitingHandler( _
        ByRef running As Boolean) _
        Handles _wait.Waiting

        Me.OnWaitWaiting(running)

    End Sub

#End Region

End Class


