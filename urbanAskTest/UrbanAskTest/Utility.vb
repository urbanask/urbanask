#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System
Imports UrbanAsk
Imports UrbanAsk.Test
Imports OpenQA
Imports OpenQA.Selenium

#End Region

Public NotInheritable Class Utility

#Region "    variables "

    <System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2211:NonConstantFieldsShouldNotBeVisible")>
    Public Shared Driver As Selenium.IWebDriver = Nothing
    <System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2211:NonConstantFieldsShouldNotBeVisible")>
    Public Shared WebDriverUtility As UrbanAsk.Utility.WebDriverUtility

#End Region

#Region "    functions "

    Private Sub New()

    End Sub

    Public Shared Sub InitializeDriver()

        If (Driver Is Nothing) Then

            'Driver = New Chrome.ChromeDriver()
            Driver = New IE.InternetExplorerDriver()
            WebDriverUtility = New UrbanAsk.Utility.WebDriverUtility(Driver)

        End If

    End Sub

    Public Shared Sub CleanupDriver()

        If (Driver IsNot Nothing) Then

            Driver.Quit()

        End If

    End Sub

#End Region

End Class
