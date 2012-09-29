#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports Microsoft.VisualBasic
Imports System.Data

#End Region

Public Class errors : Inherits api.messageHandler

    Private Const SAVE_ERROR As String = "Gabs.api.saveError"

    Protected Overrides Sub process(
         connection As SqlClient.SqlConnection,
         context As Web.HttpContext,
         request As String,
         userId As Int32)

        Dim resource As String = context.Request.PathInfo,
            queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

        Select Case resource

            Case "" '/api/errors


            Case "/save" '/api/errors/save

                saveError(context, connection, queries, userId)

            Case Else

                sendErrorResponse(context, 404, "Not Found: " + resource)

        End Select

    End Sub

    Private Sub saveError(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        userId As Int32)

        Dim status As String = queries("status"),
            errorMessage As String = queries("error")

        Using command As New SqlClient.SqlCommand(SAVE_ERROR, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@status", status)
            command.Parameters.AddWithValue("@error", errorMessage)

            command.ExecuteNonQuery()

        End Using

    End Sub

    Protected Overrides Function isValid(
        context As System.Web.HttpContext,
        request As String) As Boolean

        Return True

    End Function

    Protected Overrides Function isAuthorized(
        context As System.Web.HttpContext,
        ByRef userId As Int32) As Boolean

        Return True

    End Function

End Class


