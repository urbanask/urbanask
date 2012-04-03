#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System
Imports Microsoft.VisualStudio.TestTools
Imports OpenQA
Imports OpenQA.Selenium
Imports UrbanAsk.Test.UrbanAskTest.Utility
Imports Utility

#End Region

<UnitTesting.TestClass()>
Public Class FacebookIntegration

#Region "    variables "

    Private _testContext As UnitTesting.TestContext
    Private _culture As Globalization.CultureInfo = Globalization.CultureInfo.CurrentCulture()
    Private _utility As UrbanAsk.Utility.WebDriverUtility = WebDriverUtility
    Private _configurationFile As String = ConfigurationFile

#End Region

#Region "    functions "

#Region "    initialize "

    <UnitTesting.ClassInitialize()>
    Public Shared Sub MyClassInitialize(ByVal testContext As TestContext)

    End Sub

    <UnitTesting.TestInitialize()>
    Public Sub MyTestInitialize()

    End Sub

#End Region

#Region "    tests "

    <UnitTesting.TestMethod()>
    Public Sub CreateAccount()

        Me.GoToFacebook()
        Me.VerifyLogin()
        Me.RemoveUrbanAsk()
        Me.AddUrbanAsk()

    End Sub

    Private Sub GoToFacebook()

        Dim facebookUrl As String = Parameters.Parameter.GetValue("FacebookUrl", _configurationFile)
        _utility.NavigateTo(New System.Uri(facebookUrl), "Facebook")

    End Sub

    Private Sub VerifyLogin()

        Dim testUserLoggedIn As Boolean = False

        If Me.IsLoggedIn Then

            If Me.IsTestUser Then

                testUserLoggedIn = True

            Else

                Me.Logout()

            End If

        End If

        If (Not testUserLoggedIn) Then

            Me.LogIn()

        End If

    End Sub

    Private Sub Logout()

        _utility.Click("userNavigationLabel")
        _utility.Click(By.XPath("//input[@value='Log Out']"))
        _utility.WaitForElementPresent("email")

    End Sub

    Private Sub LogIn()

        If _utility.IsElementPresent("email") Then

            Dim email As String = Parameters.Parameter.GetValue("FacebookUser1Email", _configurationFile)
            Dim password As String = Parameters.Parameter.GetValue("FacebookUser1Password", _configurationFile)

            _utility.Type("email", email)
            _utility.TypeAndEnter("pass", password)
            _utility.Click("loginbutton")
            _utility.WaitForTitle("Facebook")

        Else

            Assert.Fail("Unknown Facebook page")

        End If

    End Sub

    Private Sub RemoveUrbanAsk()

        Dim applicationsPageUrl As String = Parameters.Parameter.GetValue("FacebookApplicationsPageUrl", _configurationFile)
        _utility.NavigateTo(New System.Uri(applicationsPageUrl), "App Settings")

        'remove ua if it exists
        Dim applicationID As String = Parameters.Parameter.GetValue("FacebookApplicationID", _configurationFile)
        Dim elementID As String = String.Format(_culture, "application-li-{0}", applicationID)

        If _utility.IsElementPresent(elementID) Then

            _utility.Click(By.CssSelector(String.Format(_culture, "#{0} .fbsettingslistitemedit", elementID)))
            _utility.Click(By.ClassName("fbSettingsExpandedDelete"))
            _utility.Click(By.Name("remove"))
            Threading.Thread.Sleep(1000)
            _utility.AssertElementNotPresent(elementID)

        End If

    End Sub

    Private Sub AddUrbanAsk()

        Dim urbanAskPermissionPage As String = Parameters.Parameter.GetValue("FacebookPermissionPageUrl", _configurationFile)
        _utility.NavigateTo(New System.Uri(urbanAskPermissionPage), "Facebook")
        _utility.Click("grant_required_clicked")
        _utility.WaitForBodyText("urbanAsk would also like permission to")
        _utility.Click("grant_clicked")
        _utility.WaitForTitle("urbanAsk on Facebook")

    End Sub

#End Region

#Region "    properties "

    Private ReadOnly Property IsLoggedIn() As Boolean

        Get

            Return _utility.IsElementPresent("userNavigationLabel")

        End Get

    End Property

    Private ReadOnly Property IsTestUser() As Boolean

        Get

            Dim currentUser As String = _utility.GetText(By.ClassName("headerTinymanName"))
            Dim facebookUser1Name As String = Parameters.Parameter.GetValue("FacebookUser1Name", _configurationFile)
            Return (currentUser = facebookUser1Name)

        End Get

    End Property

#End Region

#Region "    cleanup "

    <UnitTesting.ClassCleanup()>
    Public Shared Sub MyClassCleanup()

    End Sub

    <UnitTesting.TestCleanup()>
    Public Sub MyTestCleanup()

    End Sub

#End Region

#End Region

#Region "    properties "

    Public Property TestContext() As TestContext

        Get

            Return _testContext

        End Get

        Set(ByVal value As UnitTesting.TestContext)

            _testContext = value

        End Set

    End Property

#End Region

End Class
