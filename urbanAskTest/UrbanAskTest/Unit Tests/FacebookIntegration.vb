﻿#Region " options "

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
    Private _driver As Selenium.IWebDriver = Driver

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
    Public Sub A_CreateAccount() 'force to run first

        Me.GoToFacebook()
        Me.VerifyLogin()
        Me.RemoveUrbanAsk()
        Me.AddUrbanAsk()

    End Sub

    <UnitTesting.TestMethod()>
    Public Sub TestActivity()

        Me.PostQuestion()
        Me.VerifyActivity()
        Me.DeleteActivity()

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
            _utility.Click(By.LinkText("Remove app"))
            _utility.Click(By.Name("remove"))
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

        Threading.Thread.Sleep(2000)
        _driver.SwitchTo().Frame("iframe_canvas")

        If _utility.IsElementPresent("save-edit") Then

            _utility.Click("save-edit")
            _utility.AssertElementNotPresent("save-edit")

        End If

        _utility.WaitForBodyText("Sacramento")

    End Sub

    Private Sub PostQuestion()

        Dim questions As Collections.ArrayList = Parameters.Parameter.GetValues("Questions", _configurationFile)
        Dim count As Int32 = questions.Count
        Dim random As New System.Random()
        Dim index As Int32 = random.Next(0, count - 1)
        Dim question As String = questions(index).ToString()
        _utility.TypeAndEnter(By.CssSelector("#ask input"), question)
        _utility.WaitForBodyText("question posted")

    End Sub

    Private Sub VerifyActivity()

    End Sub

    Private Sub DeleteActivity()

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
