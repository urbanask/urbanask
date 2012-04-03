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
    Public Sub TestMethod1()

        WebDriverUtility.NavigateTo(New System.Uri("http://facebook.com"), "Facebook")

        If WebDriverUtility.IsElementPresent("email") Then

            'TODO: put in .config
            Dim email As String = "facebooktest1@urbanask.com"
            Dim password As String = "hooba%stank1"
            Dim urbanAskFacebookID As String = "267603823260704"
            Dim applicationsPage As String = "https://www.facebook.com/settings/?tab=applications"
            Dim urbanAskPermissionPage As String = "http://www.facebook.com/connect/uiserver.php?app_id=267603823260704&method=permissions.request&redirect_uri=http%3A%2F%2Fapps.facebook.com%2Furbanask%2F%3Fref%3Dts&response_type=none&display=page&perms=email%2Cpublish_stream%2Cpublish_actions&auth_referral=1"

            'not logged in
            WebDriverUtility.Type("email", email)
            WebDriverUtility.TypeAndEnter("pass", password)
            WebDriverUtility.Click("loginbutton")
            WebDriverUtility.WaitForTitle("Facebook")
            WebDriverUtility.NavigateTo(New System.Uri(applicationsPage), "App Settings")

            'remove ua if it exists
            Dim elementID As String = String.Format(_culture, "application-li-{0}", urbanAskFacebookID)

            If WebDriverUtility.IsElementPresent(elementID) Then

                WebDriverUtility.Click(By.CssSelector(String.Format(_culture, "#{0} .fbsettingslistitemedit", elementID)))
                WebDriverUtility.Click(By.ClassName("fbSettingsExpandedDelete"))
                WebDriverUtility.Click(By.Name("remove"))
                Threading.Thread.Sleep(1000)
                WebDriverUtility.AssertElementNotPresent(elementID)

            End If

            WebDriverUtility.NavigateTo(New System.Uri(urbanAskPermissionPage), "Facebook")
            WebDriverUtility.Click("grant_required_clicked")
            WebDriverUtility.WaitForBodyText("urbanAsk would also like permission to")
            WebDriverUtility.Click("grant_clicked")
            WebDriverUtility.WaitForTitle("urbanAsk on Facebook")

        ElseIf WebDriverUtility.IsElementPresent("userNavigationLabel") Then

            'logged in
            WebDriverUtility.Click("userNavigationLabel")

        Else

            Assert.Fail("Unknown Facebook page")

        End If


    End Sub

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
