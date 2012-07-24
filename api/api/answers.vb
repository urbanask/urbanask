#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports Microsoft.VisualBasic
Imports System.Data

#End Region

Public Class answers : Inherits api.messageHandler

    Public Const JSON_ANSWER_COLUMNS As String =
              "[" _
            & """answerId""," _
            & """questionId""," _
            & """userId""," _
            & """username""," _
            & """reputation""," _
            & """locationId""," _
            & """location""," _
            & """locationAddress""," _
            & """note""," _
            & """link""," _
            & """phone""," _
            & """latitude""," _
            & """longitude""," _
            & """distance""," _
            & """timestamp""," _
            & """selected""," _
            & """voted""," _
            & """votes""" _
            & "]",
        MESSAGE_LENGTH_MAX As Int32 = 200,
        LOAD_ANSWERS As String = "Gabs.api.loadAnswers",
        SAVE_ANSWER_UPVOTE As String = "Gabs.api.saveAnswerUpvote",
        SAVE_ANSWER_DOWNVOTE As String = "Gabs.api.saveAnswerDownvote",
        SAVE_ANSWER_SELECT As String = "Gabs.api.saveAnswerSelect",
        SAVE_ANSWER_FLAG As String = "Gabs.api.saveAnswerFlag",
        SAVE_ANSWER_OPENGRAPH_POST As String = "Gabs.api.saveAnswerOpenGraphPost"

    Protected Overrides Sub process(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext,
        request As String,
        userId As Int32)

        Dim resource As String = context.Request.PathInfo,
            queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

        Select Case resource

            Case "" '/api/answers

                loadAnswers(context, connection, queries, userId)

            Case "/columns"

                loadColumns(context)

            Case Else

                Dim slash As Int32 = resource.IndexOf("/"c, 1),
                    id As String = resource.Substring(1, If(slash - 1 > -1, slash - 1, resource.Length - 1))

                If IsNumeric(id) Then '/api/answers/{id}

                    Select Case resource.Substring(slash + 1)
                        Case "upvote" '/api/answers/{id}/upvote

                            saveUpvote(context, connection, userId, id)

                        Case "downvote" '/api/answers/{id}/downvote

                            saveDownvote(context, connection, userId, id)

                        Case "flag" '/api/answers/{id}/flag

                            saveFlag(context, connection, userId, id)

                        Case "select" '/api/answers/{id}/select

                            saveSelect(context, connection, userId, id)

                        Case "opengraph/post" '/api/answers/{id}/opengraph/post

                            saveOpenGraphPost(context, connection, queries, userId, id)

                    End Select

                Else

                    sendErrorResponse(context, 404, "Not Found")

                End If

        End Select

    End Sub

    Private Sub loadAnswers(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        userId As Int32)

        Using command As New SqlClient.SqlCommand(LOAD_ANSWERS, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@questionId", queries("questionId"))
            command.Parameters.AddWithValue("@locationAddress", queries("locationAddress"))
            command.Parameters.Add("@answerId", SqlDbType.Int).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            Dim response As String = String.Concat("[", command.Parameters("@answerId").Value, "]")
            sendSuccessResponse(context, response)

        End Using

    End Sub

    Private Sub loadColumns(
        context As Web.HttpContext)

        sendSuccessResponse(context, JSON_ANSWER_COLUMNS)

    End Sub

    Private Sub saveDownvote(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        userId As Int32,
        answerId As String)

        Using command As New SqlClient.SqlCommand(SAVE_ANSWER_DOWNVOTE, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@answerId", answerId)
            command.Parameters.Add("@success", SqlDbType.Bit).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If System.Convert.ToInt32(command.Parameters("@success").Value) = 0 Then 'error

                MyBase.sendErrorResponse(context, 412, "Forbidden")

            End If

        End Using

    End Sub

    Private Sub saveFlag(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        userId As Int32,
        answerId As String)

        Using command As New SqlClient.SqlCommand(SAVE_ANSWER_FLAG, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@answerId", answerId)
            command.Parameters.Add("@success", SqlDbType.Bit).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If System.Convert.ToInt32(command.Parameters("@success").Value) = 0 Then 'error

                MyBase.sendErrorResponse(context, 412, "Forbidden")

            End If

        End Using

    End Sub

    Private Sub saveUpvote(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        userId As Int32,
        answerId As String)

        Using command As New SqlClient.SqlCommand(SAVE_ANSWER_UPVOTE, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@answerId", answerId)
            command.Parameters.Add("@success", SqlDbType.Bit).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If System.Convert.ToInt32(command.Parameters("@success").Value) = 0 Then 'error

                MyBase.sendErrorResponse(context, 412, "Forbidden")

            End If

        End Using

    End Sub

    Private Sub saveSelect(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        userId As Int32,
        answerId As String)

        Dim queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

        Using command As New SqlClient.SqlCommand(SAVE_ANSWER_SELECT, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@questionId", queries("questionId"))
            command.Parameters.AddWithValue("@answerId", answerId)
            command.Parameters.Add("@success", SqlDbType.Bit).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If System.Convert.ToInt32(command.Parameters("@success").Value) = 0 Then 'error

                MyBase.sendErrorResponse(context, 412, "Forbidden")

            End If

        End Using

    End Sub

    Private Sub saveOpenGraphPost(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        userId As Int32,
        answerId As String)

        Using command As New SqlClient.SqlCommand(SAVE_ANSWER_OPENGRAPH_POST, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@answerId", answerId)
            command.Parameters.AddWithValue("@openGraphId", queries("openGraphId"))
            command.Parameters.Add("@success", SqlDbType.Bit).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If System.Convert.ToInt32(command.Parameters("@success").Value) = 0 Then 'error

                MyBase.sendErrorResponse(context, 412, "Forbidden")

            End If

        End Using

    End Sub

    Protected Overrides Function isValid(
        context As System.Web.HttpContext,
        request As String) As Boolean

        If request.Length < MESSAGE_LENGTH_MAX Then

            Return True

        Else

            Return False

        End If

    End Function

    Protected Overrides Function isAuthorized(
        context As System.Web.HttpContext,
        ByRef userId As Int32) As Boolean

        Dim authorized As Boolean,
            auth As New authorization(context, authorized, userId)

        Return authorized

    End Function

End Class


