Imports System.Web

Public Class removeHttpHeaders : Implements Web.IHttpModule

    Public Sub Init(ByVal context As Web.HttpApplication) Implements IHttpModule.Init

        AddHandler context.PreSendRequestHeaders, AddressOf OnPreSendRequestHeaders

    End Sub

    Public Sub Dispose() Implements IHttpModule.Dispose
    End Sub

    Private Sub OnPreSendRequestHeaders(sender As Object, args As System.EventArgs)

        HttpContext.Current.Response.Headers.Remove("Cache-Control")

    End Sub

End Class

