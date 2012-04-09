#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports Microsoft.VisualBasic
Imports System.Data

#End Region

Public Class account : Inherits api.messageHandler

    Private Const LOAD_ACCOUNT As String = "Gabs.api.loadAccount",
        SAVE_ACCOUNT As String = "Gabs.api.saveAccount",
        JSON_ACCOUNT_COLUMNS As String =
              "[" _
            & """userId""," _
            & """username""," _
            & """displayName""," _
            & """reputation""," _
            & """metricDistances""," _
            & """languageId""," _
            & """tagline""" _
            & "]"

    Protected Overrides Sub process(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext,
        request As String,
        userId As Int32)

        Dim resource As String = context.Request.PathInfo

        Select Case resource

            Case "" '/api/account

                loadAccount(context, connection, userId)

            Case "/save" '/api/account/save

                saveAccount(context, connection, userId)

            Case "/columns" '/api/account/columns

                loadColumns(context)

            Case Else

                sendErrorResponse(context, 404, "Not Found")

        End Select


    End Sub

    Private Sub loadAccount(
      context As Web.HttpContext,
      connection As SqlClient.SqlConnection,
      userId As Int32)

        Using command As New SqlClient.SqlCommand(LOAD_ACCOUNT, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)

            sendSuccessResponse(context, createJsonAccount(command))

        End Using

    End Sub

    Private Sub saveAccount(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        userId As Int32)

        Dim queries As Collections.Specialized.NameValueCollection = context.Request.QueryString,
            username As String = queries("username"),
            tagline As String = queries("tagline"),
            regionId As String = queries("regionId")

        Using command As New SqlClient.SqlCommand(SAVE_ACCOUNT, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@username", username)
            command.Parameters.AddWithValue("@tagline", tagline)
            command.Parameters.AddWithValue("@regionId", regionId)

            command.ExecuteNonQuery()

        End Using

    End Sub

    Private Sub loadColumns(
        context As Web.HttpContext)

        sendSuccessResponse(context, JSON_ACCOUNT_COLUMNS)

    End Sub

    Private Function createJsonAccount(command As Data.SqlClient.SqlCommand) As String

        Using user As Data.SqlClient.SqlDataReader = command.ExecuteReader()

            Dim response As String = "["

            If user.HasRows() Then

                user.Read()

                response &= String.Concat(
                    "[",
                    user("userId"), ",""",
                    user("username"), """,""",
                    user("displayName"), """,",
                    user("reputation"), ",",
                    user("metricDistances"), ",",
                    user("languageId"), ",""",
                    user("tagline"), """,[")

                If user.NextResult() Then

                    If user.HasRows() Then

                        While (user.Read())

                            response &= String.Concat(
                                 "[",
                                 user("regionId"), ",""",
                                 user("name"), """",
                                 "],")

                        End While

                        response = response.Substring(0, response.Length - 1) 'remove last comma

                    End If

                End If

                response &= "]]"

            End If

            response &= "]"

            Return response

        End Using

    End Function

    Protected Overrides Function isValid(
        context As System.Web.HttpContext,
        request As String) As Boolean

        Return True

    End Function

End Class


