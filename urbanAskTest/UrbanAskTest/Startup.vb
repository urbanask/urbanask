#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System
Imports Microsoft.VisualStudio.TestTools
Imports UrbanAsk.Test.UrbanAskTest
Imports OpenQA.Selenium

#End Region

<UnitTesting.TestClass()>
Public Class Startup

#Region "    variables "

    Private _testContext As UnitTesting.TestContext

#End Region

#Region "    functions "

    <UnitTesting.AssemblyInitialize()>
    Public Shared Sub MyAssemblyInitialize(
        ByVal testContext As UnitTesting.TestContext)

        Utility.Initialize()

    End Sub

    ' Use ClassCleanup to run code after all tests in a class have run
    <UnitTesting.AssemblyCleanup()>
    Public Shared Sub MyAssemblyCleanup()

        Utility.Cleanup()

    End Sub

#End Region

#Region "    properties "

    Public Property TestContext() As UnitTesting.TestContext

        Get

            Return _testContext

        End Get

        Set(ByVal value As UnitTesting.TestContext)

            _testContext = value

        End Set

    End Property

#End Region

End Class
