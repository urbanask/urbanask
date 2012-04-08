Option Explicit On 
Option Strict On

Imports System.Threading
Imports System.Windows.Forms

Public Class CWait

#Region "    variables"

    Private m_bRunning As Boolean

#End Region

#Region "    events"

    Public Event Waiting(ByRef bRunning As Boolean)

#End Region

#Region "    functions"

    Public Sub Start( _
        ByVal iSecondsToWait As Int32)

        Dim dtStart As Date
        Dim dSecondsElapsed As Double
        Dim bTimeUp As Boolean

        m_bRunning = True
        dtStart = DateTime.Now

        Do

            Application.DoEvents()
            Thread.CurrentThread.Sleep(100)

            RaiseEvent Waiting(m_bRunning)

            dSecondsElapsed = Now.Subtract(dtStart).TotalSeconds()
            bTimeUp = (dSecondsElapsed >= iSecondsToWait)

        Loop Until (bTimeUp) Or (Not m_bRunning)

    End Sub

    Public Sub [Stop]()

        m_bRunning = False

    End Sub

#End Region

End Class
