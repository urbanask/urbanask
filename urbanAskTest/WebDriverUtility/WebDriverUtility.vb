#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System
Imports OpenQA
Imports OpenQA.Selenium
Imports Microsoft.VisualStudio.TestTools
Imports Microsoft.VisualStudio.TestTools.UnitTesting

#End Region


<Assembly: System.CLSCompliant(True)> 
Public Class WebDriverUtility

#Region "    constants "

    Private _timeout As New System.TimeSpan(0, 0, 5) '5 seconds
    Private _sleep As New System.TimeSpan(0, 0, 0, 0, 100) '.1 seconds

#End Region

#Region "    variables "

    Private _driver As OpenQA.Selenium.IWebDriver
    Private _start As DateTime
    Private _culture As Globalization.CultureInfo = Globalization.CultureInfo.CurrentCulture()

#End Region

#Region "    functions "

    Public Sub New( _
       ByVal driver As OpenQA.Selenium.IWebDriver)

        _driver = driver

    End Sub

    Public Overloads Sub NavigateTo(
        ByVal uri As System.Uri)

        _driver.Navigate().GoToUrl(uri)

    End Sub

    Public Overloads Sub NavigateTo(
        ByVal uri As System.Uri,
        ByVal title As String)

        _driver.Navigate().GoToUrl(uri)
        Me.AssertTitleContains(title)

    End Sub

    Public Overloads Sub AssertElementPresent(
       ByVal id As String)

        Me.AssertElementPresent(By.Id(id))

    End Sub

    Public Overloads Sub AssertElementPresent(
        ByVal by As OpenQA.Selenium.By)

        Dim elements As ObjectModel.ReadOnlyCollection(Of OpenQA.Selenium.IWebElement) = _driver.FindElements(by)

        If (elements.Count = 0) Then

            Dim message As String = "Element {0} is not present"
            UnitTesting.Assert.Fail(String.Format(_culture, message, by))

        End If

    End Sub

    Public Overloads Function IsElementPresent(
        ByVal id As String) As Boolean

        Return Me.IsElementPresent(By.Id(id))

    End Function

    Public Overloads Function IsElementPresent(
        ByVal by As OpenQA.Selenium.By) As Boolean

        Dim returnValue As Boolean = False

        Try

            _driver.FindElement(by)
            returnValue = True

        Catch exception As Selenium.NoSuchElementException

            'not present

        End Try

        Return returnValue

    End Function

    Public Overloads Function WaitForElementPresent(
        ByVal id As String) As Selenium.IWebElement

        Return Me.WaitForElementPresent(By.Id(id))

    End Function

    Public Overloads Function WaitForElementPresent(
        ByVal by As OpenQA.Selenium.By) As Selenium.IWebElement

        Dim returnValue As Selenium.IWebElement = Nothing

        Me.ResetTimeout()

        Do Until (Me.Timeout Or (returnValue IsNot Nothing))

            Try

                returnValue = _driver.FindElement(by)

            Catch exception As Selenium.NoSuchElementException

                returnValue = Nothing

            End Try

        Loop

        If (returnValue Is Nothing) Then

            Dim message As String = "Element {0} is not present"
            UnitTesting.Assert.Fail(String.Format(_culture, message, by))

        End If

        Return returnValue

    End Function

    Public Overloads Sub Click(
        ByVal id As String)

        Me.Click(By.Id(id))

    End Sub

    Public Overloads Sub Click(
        ByVal by As OpenQA.Selenium.By)

        Me.WaitForElementPresent(by).Click()

    End Sub

    Public Overloads Sub ClickAndEnter(
        ByVal id As String)

        Me.ClickAndEnter(By.Id(id))

    End Sub

    Public Overloads Sub ClickAndEnter(
       ByVal by As OpenQA.Selenium.By)

        Dim element As OpenQA.Selenium.IWebElement = Me.WaitForElementPresent(by)
        element.Click()
        element.SendKeys(Keys.Enter)

    End Sub

    Public Overloads Sub Type(
        ByVal id As String, _
        ByVal text As String)

        Me.Type(By.Id(id), text)

    End Sub

    Public Overloads Sub Type(
        ByVal by As OpenQA.Selenium.By, _
        ByVal text As String)

        Dim element As OpenQA.Selenium.IWebElement = Me.WaitForElementPresent(by)
        element.Clear()
        element.SendKeys(text)

    End Sub

    Public Overloads Sub TypeAndEnter(
        ByVal id As String, _
        ByVal text As String)

        Me.Type(By.Id(id), text)

    End Sub

    Public Overloads Sub TypeAndEnter(
        ByVal by As OpenQA.Selenium.By, _
        ByVal text As String)

        Dim element As OpenQA.Selenium.IWebElement = WaitForElementPresent(by)
        element.SendKeys(text)
        element.SendKeys(Keys.Enter)

    End Sub

    Public Overloads Function GetText(
        ByVal id As String) As String

        Return Me.GetText(By.Id(id))

    End Function

    Public Overloads Function GetText(
        ByVal by As OpenQA.Selenium.By) As String

        Return Me.WaitForElementPresent(by).Text

    End Function

    Public Sub AssertTitle(
        ByVal title As String)

        Dim message As String = String.Format(_culture, "Title does not match '{0}'", title)
        UnitTesting.Assert.AreEqual(title, _driver.Title, message)

    End Sub

    Public Sub AssertTitleContains(
        ByVal text As String)

        If (text IsNot Nothing) _
            AndAlso (Not _driver.Title.ToLower(_culture).Contains(text.ToLower(_culture))) Then

            Dim message As String = String.Format(_culture, "Title does not contain '{0}'", text)
            UnitTesting.Assert.Fail(message)

        End If

    End Sub

    Public Overloads Sub AssertElementNotPresent(
        ByVal id As String)

        Me.AssertElementNotPresent(By.Id(id))

    End Sub

    Public Overloads Sub AssertElementNotPresent(
        ByVal by As OpenQA.Selenium.By)

        Dim elements As ObjectModel.ReadOnlyCollection(Of OpenQA.Selenium.IWebElement) = _driver.FindElements(by)

        If (elements.Count > 0) Then

            Dim message As String = "Element {0} not present"
            UnitTesting.Assert.Fail(String.Format(_culture, message, by))

        End If

    End Sub

    Public Sub WaitForTitle(
        ByVal title As String)

        Me.ResetTimeout()
        Dim valid As Boolean = False

        Do Until (Me.Timeout Or valid)

            valid = (_driver.Title = title)

        Loop

        If (Not valid) Then

            Me.AssertTitle(title)

        End If

    End Sub

    Public Sub WaitForBodyText(
        ByVal bodyText As String)

        Me.ResetTimeout()

        Dim xpath As String = "*[contains(.,""{0}"")]"
        xpath = String.Format(_culture, xpath, bodyText)
        Dim elements As ObjectModel.ReadOnlyCollection(Of OpenQA.Selenium.IWebElement) = Nothing

        Dim valid As Boolean = False

        Do Until (Me.Timeout Or valid)

            elements = _driver.FindElements(By.XPath(xpath))
            valid = elements.Count <> 0

        Loop

        Assert.AreEqual(valid, True, String.Format(_culture, "Body text not found: ""{0}"".", bodyText))

    End Sub

    Private Sub Sleep()

        Threading.Thread.Sleep(_sleep)

    End Sub

    Private Sub ResetTimeout()

        _start = System.DateTime.Now

    End Sub

    Private Function Timeout() As Boolean

        Me.Sleep()
        Return ((System.DateTime.Now() - _start) > _timeout)

    End Function

#End Region

End Class
