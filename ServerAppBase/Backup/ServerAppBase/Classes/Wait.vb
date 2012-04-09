#Region "options "

Option Explicit On 
Option Strict On

#End Region

#Region "imports "

Imports System.Windows.Forms

#End Region

Public Class Wait

#Region "    variables "

    Private _running As Boolean

#End Region

#Region "    events "

    Public Event Waiting(ByRef running As Boolean)

#End Region

#Region "    functions "

    Public Sub Start( _
        ByVal secondsToWait As Int32)

        Dim start As Date
        Dim secondsElapsed As Double
        Dim timeUp As Boolean

        _running = True
        start = DateTime.Now

        Do

            Application.DoEvents()
            Threading.Thread.Sleep(100)

            RaiseEvent Waiting(_running)

            secondsElapsed = DateTime.Now.Subtract(start).TotalSeconds()
            timeUp = (secondsElapsed >= secondsToWait)

        Loop Until (timeUp) Or (Not _running)

    End Sub

    Public Sub [Stop]()

        _running = False

    End Sub

#End Region

End Class
