#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports Microsoft.VisualBasic
Imports System.Data

#End Region

Public Class top : Inherits api.messageHandler

    Private Const LOAD_TOP_USERS As String = "Gabs.api.loadTopUsers",
        JSON_TOP_USER_COLUMNS As String =
              "[" _
            & """regionId""," _
            & """topTypeId""," _
            & """intervalId""," _
            & """userId""," _
            & """username""," _
            & """reputation""," _
            & """totalQuestions""," _
            & """totalAnswers""," _
            & """totalBadges""," _
            & """topScore""" _
            & "]",
        MESSAGE_LENGTH_MAX As Int32 = 200,
        ROW_COUNT_MAX As Int32 = 200,
        ROW_COUNT_DEFAULT As Int32 = 30

    Protected Overrides Sub process(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext,
        request As String,
        userId As Int32)

        Dim resource As String = context.Request.PathInfo,
            queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

        Select Case resource

            Case "/topUsers" '/api/top/topUsers

                loadTopUsers(context, connection, queries)

            Case "/topUsers/columns" '/api/top/topUsers/columns

                loadColumns(context)

            Case Else

                sendErrorResponse(context, 404, "Not Found")

        End Select

    End Sub

    Private Sub loadTopUsers(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection)

        Using command As New SqlClient.SqlCommand(LOAD_TOP_USERS, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@regionId", queries("regionId"))

            MyBase.sendSuccessResponse(context, createJsonTopUsers(command))

        End Using

    End Sub

    Private Sub loadColumns(
        context As Web.HttpContext)

        sendSuccessResponse(context, JSON_TOP_USER_COLUMNS)

    End Sub

    Private Function createJsonTopUsers(command As Data.SqlClient.SqlCommand) As String

        Using topUser As Data.SqlClient.SqlDataReader = command.ExecuteReader()

            Dim response As String = "["

            If topUser.HasRows() Then

                While (topUser.Read())

                    response += String.Concat(
                        "[",
                        topUser("regionId"), ",",
                        topUser("topTypeId"), ",",
                        topUser("intervalId"), ",",
                        topUser("userId"), ",""",
                        topUser("username"), """,",
                        topUser("reputation"), ",",
                        topUser("totalQuestions"), ",",
                        topUser("totalAnswers"), ",",
                        topUser("totalBadges"), ",",
                        topUser("topScore"),
                        "],")

                End While

                response = response.Substring(0, response.Length - 1) 'remove last comma

            End If

            response &= "]"

            Return response

        End Using

    End Function

    Protected Overrides Function isValid(
        context As System.Web.HttpContext,
        request As String) As Boolean

        If request.Length < MESSAGE_LENGTH_MAX Then

            Return True

        Else

            Return False

        End If

    End Function

    Private ReadOnly Property count(queries As Collections.Specialized.NameValueCollection) As Integer

        Get

            Dim countString As String = queries("count"),
                countValue As Integer = 0

            If Microsoft.VisualBasic.IsNumeric(countString) Then

                countValue = Convert.ToInt32(countString)

                Select Case countValue
                    Case 0

                        Return ROW_COUNT_DEFAULT

                    Case Is > ROW_COUNT_MAX

                        Return ROW_COUNT_MAX

                    Case Else

                        Return countValue

                End Select

            Else

                Return ROW_COUNT_DEFAULT

            End If

        End Get

    End Property

    Protected Overrides Function isAuthorized(
        context As System.Web.HttpContext,
        ByRef userId As Int32) As Boolean

        Dim authorized As Boolean,
            auth As New authorization(context, authorized, userId)

        Return authorized

    End Function

End Class


