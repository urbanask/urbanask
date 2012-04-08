Option Explicit On 
Option Strict On

#Region "imports"

Imports System.Windows
Imports System.Windows.Forms
Imports System.Web
Imports ATR.Utility.Parameters

#End Region

Public MustInherit Class CServerAppBase

#Region "    variables"

    Private m_bRunning As Boolean
    Private WithEvents m_oSystemTray As New Forms.NotifyIcon()
    Private WithEvents m_oWait As New CWait()

    'error parameters
    Private m_sErrorMailTo As String
    Private m_sErrorMailFrom As String
    Private m_sErrorMailSMTPServer As String
    Private m_sErrorMailSubject As String
    Private m_sFatalErrorMessage As String

    'miscellaneous parameters
    Private m_iRefreshRate As Int32
    Private m_bShutdownApplication As Boolean

#End Region

#Region "    must inherit functions"

    Protected MustOverride Sub Process()

#End Region

#Region "    functions"

    Public Sub New()

        Dim sMessage As String

        Try
           
            m_bRunning = True

            InitializeVariables()
            InitializeParameters()
            InitializeSystemTrayIcon()

            StartProcessing()

        Catch oException As Exception

            sMessage = FatalError(oException)
            LogAndMail(sMessage, EventLogEntryType.Error)

            Stop

        Finally

            CleanUp()

        End Try

    End Sub

    Private Sub InitializeVariables()

        m_sFatalErrorMessage = ""

    End Sub

    Private Sub InitializeParameters()

        InitializeErrorParameters()

    End Sub

    Private Sub InitializeErrorParameters()

        Dim sError As String

        m_sErrorMailTo = CParameters.GetValue("ErrorMailTo")
        m_sErrorMailFrom = CParameters.GetValue("ErrorMailFrom")
        m_sErrorMailSMTPServer = CParameters.GetValue("ErrorMailSMTPServer")
        m_sErrorMailSubject = CParameters.GetValue("ErrorMailSubject")
        m_sFatalErrorMessage = CParameters.GetValue("FatalErrorMessage")

        sError = ""

        Select Case ""
            Case m_sErrorMailTo

                sError = "ErrorMailTo is a required parameter."

            Case m_sErrorMailFrom

                sError = "ErrorMailFrom is a required parameter."

            Case m_sErrorMailSubject

                sError = "FatalErrorMailSubject is a required parameter."

            Case m_sErrorMailSMTPServer

                sError = "ErrorMailSMTPServer is a required parameter."

            Case m_sFatalErrorMessage

                sError = "FatalErrorMessage is a required parameter."

        End Select

        If sError.Length > 0 Then

            Throw New Exception(sError)

        End If

    End Sub

    Private Sub InitializeSystemTrayIcon()

        Dim oSize As Drawing.Size
        Dim oContextMenu As Forms.ContextMenu
        Dim oEventHandler As System.EventHandler

        oContextMenu = New Forms.ContextMenu()
        oEventHandler = New System.EventHandler(AddressOf OnSystemTrayExitClick)
        oContextMenu.MenuItems.Add("E&xit", oEventHandler)

        UpdateSystemTrayIcon(CResources.EIconColor.RedIcon)

        m_oSystemTray.ContextMenu = oContextMenu
        m_oSystemTray.Text = Application.ProductName
        m_oSystemTray.Visible = True

    End Sub

    Private Sub UpdateSystemTrayIcon( _
        ByVal eIconColor As CResources.EIconColor)

        Dim oIcon As Drawing.Icon
        Dim sIconFile As String
        Dim oWait As New CWait()

        oWait.Start(1) 'one second pause for traffic light effect

        Select Case eIconColor
            Case eIconColor.RedIcon

                oIcon = CResources.RedIcon

            Case eIconColor.YellowIcon

                oIcon = CResources.YellowIcon

            Case eIconColor.GreenIcon

                oIcon = CResources.GreenIcon

        End Select

        m_oSystemTray.Icon = oIcon

    End Sub

    Private Sub CleanUp()

        Try

            m_oSystemTray.Visible = False
            m_oSystemTray.Dispose()

        Finally

            m_oWait = Nothing
            m_oSystemTray = Nothing

        End Try

    End Sub

    Private Sub StartProcessing()

        Do

            RefreshParameters()

            If (m_bRunning) And (Not m_bShutdownApplication) Then

                Process()

            End If

            If (m_bRunning) And (Not m_bShutdownApplication) Then

                m_oWait.Start(m_iRefreshRate)

            End If

        Loop While (m_bRunning) And (Not m_bShutdownApplication)

    End Sub

    Private Sub RefreshParameters()

        Dim sMessage As String

        m_iRefreshRate = Convert.ToInt32(CParameters.GetValue("RefreshRate"))
        m_bShutdownApplication = Convert.ToBoolean(CParameters.GetValue("ShutdownApplication"))

        If m_iRefreshRate <= 0 Then

            sMessage = "RefreshRate parameter must be greater then 0."
            Throw New Exception(sMessage)

        End If

        If m_bShutdownApplication Then

            sMessage = "ShutdownApplication parameter set to 'True'."
            Log(sMessage, EventLogEntryType.Information)

        End If

    End Sub

    Private Sub Log( _
        ByVal sMessage As String, _
        Optional ByVal eType As EventLogEntryType = EventLogEntryType.Information)

        EventLog.WriteEntry( _
            Application.ProductName, _
            sMessage, _
            eType)

    End Sub

    Private Sub LogAndMail( _
        ByVal sMessage As String, _
        Optional ByVal eType As EventLogEntryType = EventLogEntryType.Information)

        EventLog.WriteEntry(Application.ProductName, sMessage, eType)
        MailLog(sMessage)

    End Sub

    Private Sub MailLog( _
        ByVal sMessage As String)

        Dim oMailMessage As New Mail.MailMessage()

        If m_sErrorMailTo.Length > 0 Then

            oMailMessage.To = m_sErrorMailTo
            oMailMessage.From = m_sErrorMailFrom
            oMailMessage.Subject = m_sErrorMailSubject
            oMailMessage.Body = sMessage

            Mail.SmtpMail.SmtpServer = m_sErrorMailSMTPServer
            Mail.SmtpMail.Send(oMailMessage)

        End If

    End Sub

#End Region

#Region "    properties"

    Private ReadOnly Property FatalError( _
        ByVal oException As Exception) As String

        Get

            Dim sFatalError As String

            If m_sFatalErrorMessage.Length = 0 Then

                m_sFatalErrorMessage = _
                      "The following FATAL error occurred and the application is exiting:\n\n" _
                    & "Error:\n" _
                    & "{0}\n\n" _
                    & "Stack:\n" _
                    & "{1}\n\n"

            End If

            sFatalError = m_sFatalErrorMessage.Replace("\n", ControlChars.Lf)
            sFatalError = String.Format( _
                sFatalError, _
                oException.Message(), _
                oException.StackTrace())

            Return sFatalError

        End Get

    End Property



#End Region

#Region "    events"

    Private Sub OnSystemTrayExitClick( _
        ByVal oSender As Object, _
        ByVal oArguments As System.EventArgs)

        m_bRunning = False
        m_oWait.Stop()

    End Sub

#End Region



End Class


