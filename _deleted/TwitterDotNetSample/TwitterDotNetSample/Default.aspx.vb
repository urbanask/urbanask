#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System
Imports System.Web
Imports Twitterizer

#End Region

Public Class _Default

    Inherits Web.UI.Page

    Private Const _consumerKey As String = "LYmBn0COBIkkcRXpImTAJA"
    Private Const _consumerSecret As String = "wsIo3xDOPD6BPviujjk5L1kwXEMYuTTIwToCGq0pxY"
    'Private Const _returnUrl As String = "http://urbanask.com/twitterdotnetsample/default.aspx"
    Private Const _returnUrl As String = "http://localhost:49232/Default.aspx"

#Region "    function "

    Private Sub OnPageLoad()

        Dim token As String = MyBase.Request.QueryString("oauth_token")
        Dim verifier As String = "" '= MyBase.Request.QueryString("oauth_verifier")

        If (token Is Nothing) Then

            Me.SignInWithTwitter.Visible = True

        Else

            Me.SignInWithTwitter.Visible = False
            Dim tokens = Twitterizer.OAuthUtility.GetAccessToken(_consumerKey, _consumerSecret, token, verifier)
            Dim output As String = "Screen Name: {0}<br/>Token: {1}<br/>Token Secret: {2}<br/>User ID: {3}<br/>Verification String: {4}<br/>"
            output = String.Format(output, tokens.ScreenName, tokens.Token, tokens.TokenSecret, tokens.UserId, tokens.VerificationString)
            Me.Output.InnerHtml = output
            'Dim x As New TwitterDirectMessage()
            'x.Send(

        End If

    End Sub

    Private Sub OnSignInWithTwitterClick()

        Dim token As String = Twitterizer.OAuthUtility.GetRequestToken(_consumerKey, _consumerSecret, _returnUrl).Token
        MyBase.Response.Redirect(Twitterizer.OAuthUtility.BuildAuthorizationUri(token, True).ToString())

    End Sub

#End Region

#Region "    event handlers "

    Private Sub PageLoadHandler(
        sender As System.Object,
        arguments As System.EventArgs) _
        Handles Me.Load

        Me.OnPageLoad()

    End Sub

    Private Sub SignInWithTwitterClickHandler(
        sender As System.Object,
        arguments As System.EventArgs) _
        Handles SignInWithTwitter.Click

        Me.OnSignInWithTwitterClick()

    End Sub

#End Region

End Class