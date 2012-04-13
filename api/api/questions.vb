﻿#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports Microsoft.VisualBasic
Imports System.Data

#End Region

Public Class questions : Inherits api.messageHandler

    Private Const LOAD_QUESTIONS_BY_COORDINATES As String = "Gabs.api.loadQuestionsByCoordinates",
        LOAD_QUESTIONS_BY_USER As String = "Gabs.api.loadQuestionsByUser",
        LOAD_QUESTIONS_BY_REGION As String = "Gabs.api.loadQuestionsByRegion",
        LOAD_QUESTION As String = "Gabs.api.loadQuestion",
        SAVE_QUESTION_VOTE As String = "Gabs.api.saveQuestionUpvote",
        SAVE_QUESTION_FLAG As String = "Gabs.api.saveQuestionFlag",
        JSON_QUESTION_COLUMNS As String =
              "[" _
            & """questionId""," _
            & """userId""," _
            & """username""," _
            & """reputation""," _
            & """question""," _
            & """link""," _
            & """latitude""," _
            & """longitude""," _
            & """timestamp""," _
            & """resolved""," _
            & """expired""," _
            & """bounty""," _
            & """voted""," _
            & """votes""," _
            & """answers""," _
            & "]",
        MESSAGE_LENGTH_MAX As Int32 = 600,
        ROW_COUNT_MAX As Int32 = 400,
        ROW_COUNT_DEFAULT As Int32 = 50,
        AGE_DAYS_MAX As Int32 = 30,
        AGE_DAYS_DEFAULT As Int32 = 14,
        EXPIRATION_DAYS_DEFAULT As Int32 = 2

    Protected Overrides Sub process(
         connection As SqlClient.SqlConnection,
         context As Web.HttpContext,
         request As String,
         userId As Int32)

        Dim resource As String = context.Request.PathInfo,
            queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

        Select Case resource

            Case "" '/api/questions

                loadQuestions(context, connection, queries, userId)

            Case "/columns"

                loadColumns(context)

            Case Else

                Dim slash As Int32 = resource.IndexOf("/"c, 1),
                    id As String = resource.Substring(1, If(slash - 1 > -1, slash - 1, resource.Length - 1)),
                    command As String = If(slash = -1, "", resource.Substring(slash + 1))

                If IsNumeric(id) Then '/api/questions/{id}

                    Select Case command
                        Case ""

                            loadQuestion(context, connection, queries, userId)

                        Case "upvote"

                            saveUpvote(context, connection, userId, id)

                        Case "flag"

                            saveFlag(context, connection, userId, id)

                    End Select

                Else

                    sendErrorResponse(context, 404, "Not Found")

                End If

        End Select

    End Sub

    Private Sub loadQuestions(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        userId As Int32)

        If queries("fromLatitude") <> "" Then

            loadQuestionsByCoordinates(context, connection, queries, userId)

        ElseIf queries("userId") <> "" Then

            loadQuestionsByUser(context, connection, queries)

        ElseIf queries("regionId") <> "" Then

            loadQuestionsByRegion(context, connection, queries, userId)

        End If

    End Sub

    Private Sub loadQuestionsByCoordinates(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        currentUserId As Int32)

        Using command As New SqlClient.SqlCommand(LOAD_QUESTIONS_BY_COORDINATES, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@currentUserId", currentUserId)
            command.Parameters.AddWithValue("@fromLatitude", queries("fromLatitude"))
            command.Parameters.AddWithValue("@fromLongitude", queries("fromLongitude"))
            command.Parameters.AddWithValue("@toLatitude", queries("toLatitude"))
            command.Parameters.AddWithValue("@toLongitude", queries("toLongitude"))
            command.Parameters.AddWithValue("@age", DateTime.Now().AddDays(-Me.age(queries)))
            command.Parameters.AddWithValue("@count", Me.count(queries))
            command.Parameters.AddWithValue("@expirationDays", Me.expirationDays(queries))

            sendSuccessResponse(context, createJsonQuestions(command))

        End Using

    End Sub

    Private Sub loadQuestionsByRegion(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        currentUserId As Int32)

        Using command As New SqlClient.SqlCommand(LOAD_QUESTIONS_BY_REGION, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@currentUserId", currentUserId)
            command.Parameters.AddWithValue("@regionId", queries("regionId"))
            command.Parameters.AddWithValue("@age", DateTime.Now().AddDays(-Me.age(queries)))
            command.Parameters.AddWithValue("@count", Me.count(queries))
            command.Parameters.AddWithValue("@expirationDays", Me.expirationDays(queries))

            sendSuccessResponse(context, createJsonQuestions(command))

        End Using

    End Sub

    Private Sub loadQuestionsByUser(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection)

        Using command As New SqlClient.SqlCommand(LOAD_QUESTIONS_BY_USER, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", queries("userId"))
            command.Parameters.AddWithValue("@count", Me.count(queries))
            command.Parameters.AddWithValue("@expirationDays", Me.expirationDays(queries))

            sendSuccessResponse(context, createJsonQuestions(command))

        End Using

    End Sub

    Private Sub loadQuestion(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        userId As Int32)

        Dim questionId As String = context.Request.PathInfo.Substring(1) 'remove "/"

        Using command As New SqlClient.SqlCommand(LOAD_QUESTION, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@questionId", questionId)
            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@expirationDays", Me.expirationDays(queries))

            sendSuccessResponse(context, createJsonQuestion(command))

        End Using

    End Sub

    Private Sub loadColumns(
        context As Web.HttpContext)

        sendSuccessResponse(context, JSON_QUESTION_COLUMNS)

    End Sub

    Private Sub saveUpvote(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        userId As Int32,
        questionId As String)

        Using command As New SqlClient.SqlCommand(SAVE_QUESTION_VOTE, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@questionId", questionId)
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
        questionId As String)

        Using command As New SqlClient.SqlCommand(SAVE_QUESTION_FLAG, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@questionId", questionId)
            command.Parameters.Add("@success", SqlDbType.Bit).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If System.Convert.ToInt32(command.Parameters("@success").Value) = 0 Then 'error

                MyBase.sendErrorResponse(context, 412, "Forbidden")

            End If

        End Using

    End Sub

    Private Function createJsonQuestions(command As Data.SqlClient.SqlCommand) As String

        Using questions As Data.SqlClient.SqlDataReader = command.ExecuteReader()

            Dim response As String = "["

            If questions.HasRows() Then

                While (questions.Read())

                    response &= String.Concat(
                        "[",
                        questions("questionId"), ",",
                        questions("userId"), ",""",
                        questions("username"), """,",
                        questions("reputation"), ",""",
                        MyBase.jsonEncode(CStr(questions("question"))), """,""",
                        questions("link"), """,",
                        questions("latitude"), ",",
                        questions("longitude"), ",""",
                        questions("timestamp"), """,",
                        questions("resolved"), ",",
                        questions("expired"), ",",
                        questions("bounty"), ",",
                        questions("voted"), ",",
                        questions("votes"), ",",
                        questions("answers"),
                        "],")

                End While

                response = response.Substring(0, response.Length - 1) 'remove last comma

            End If

            response &= "]"

            Return response

        End Using

    End Function

    Private Function createJsonQuestion(command As Data.SqlClient.SqlCommand) As String

        Using question As Data.SqlClient.SqlDataReader = command.ExecuteReader()

            Dim response As String = "["

            If question.HasRows() Then

                question.Read()

                response &= String.Concat(
                    "[",
                    question("questionId"), ",",
                    question("userId"), ",""",
                    question("username"), """,",
                    question("reputation"), ",""",
                    MyBase.jsonEncode(CStr(question("question"))), """,""",
                    question("link"), """,",
                    question("latitude"), ",",
                    question("longitude"), ",""",
                    question("timestamp"), """,",
                    question("resolved"), ",",
                    question("expired"), ",",
                    question("bounty"), ",",
                    question("voted"), ",",
                    question("votes"), ",",
                    question("answers"), ",[")

                If question.NextResult() Then

                    If question.HasRows() Then

                        While (question.Read())

                            response &= String.Concat(
                                "[",
                                question("answerId"), ",",
                                question("questionId"), ",",
                                question("userId"), ",""",
                                question("username"), """,",
                                question("reputation"), ",""",
                                question("locationId"), """,""",
                                MyBase.jsonEncode(question("location").ToString()), """,""",
                                question("locationAddress"), """,""",
                                MyBase.jsonEncode(question("note").ToString()), """,""",
                                question("link").ToString(), """,""",
                                question("phone").ToString(), """,",
                                question("latitude"), ",",
                                question("longitude"), ",",
                                question("distance"), ",""",
                                question("timestamp"), """,",
                                question("selected"), ",",
                                question("voted"), ",",
                                question("votes"),
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

        If request.Length < MESSAGE_LENGTH_MAX Then

            Return True

        Else

            Return False

        End If

    End Function

    Private ReadOnly Property expirationDays(queries As Collections.Specialized.NameValueCollection) As Integer

        Get

            Dim daysString As String = queries("expirationDays"),
                days As Int32 = 0

            If Microsoft.VisualBasic.IsNumeric(daysString) Then

                days = Convert.ToInt32(daysString)
                Return CInt(IIf(days = 0, EXPIRATION_DAYS_DEFAULT, days))

            Else

                Return EXPIRATION_DAYS_DEFAULT

            End If

        End Get

    End Property

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

    Private ReadOnly Property age(queries As Collections.Specialized.NameValueCollection) As Integer

        Get

            Dim ageString As String = queries("age"),
                ageValue As Integer = 0

            If Microsoft.VisualBasic.IsNumeric(ageString) Then

                ageValue = Convert.ToInt32(ageString)

                Select Case ageValue
                    Case 0

                        Return AGE_DAYS_DEFAULT

                    Case Is > AGE_DAYS_MAX

                        Return AGE_DAYS_MAX

                    Case Else

                        Return ageValue

                End Select

            Else

                Return AGE_DAYS_DEFAULT

            End If

        End Get

    End Property

End Class

