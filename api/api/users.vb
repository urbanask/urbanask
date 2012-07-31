#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports Microsoft.VisualBasic
Imports System.Data

#End Region

Public Class users : Inherits api.messageHandler

    Private Const LOAD_USER As String = "Gabs.api.loadUser",
        LOAD_USER_PICTURE As String = "Gabs.api.loadUserPicture",
        LOAD_USER_ICON As String = "Gabs.api.loadUserIcon",
        LOAD_TOP_USERS As String = "Gabs.api.loadTopUsers",
        VERIFY_USER_EMAIL As String = "Gabs.login.verifyUserEmail",
        VERIFIED_URL As String = "http://urbanask.com",
        JSON_USER_COLUMNS As String =
              "[" _
            & """userId""," _
            & """username""," _
            & """displayName""," _
            & """reputation""," _
            & """signupDate""," _
            & """tagline""," _
            & """totalQuestions""," _
            & """totalAnswers""," _
            & """totalBadges""" _
            & "]",
        MESSAGE_LENGTH_MAX As Int32 = 600,
        ROW_COUNT_MAX As Int32 = 200,
        ROW_COUNT_DEFAULT As Int32 = 30,
        USER_ROW_COUNT_DEFAULT As Int32 = 10,
        EXPIRATION_DAYS_DEFAULT As Int32 = 2

    Protected Overrides Sub process(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext,
        request As String,
        userId As Int32)

        Dim resource As String = context.Request.PathInfo,
            queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

        Select Case resource

            Case "" '/api/users

                loadUsers(context, connection, queries)

            Case "/columns" '/api/users/columns

                loadColumns(context)

            Case "/verifyemail" '/api/users/verifyemail

                verifyEmail(context, connection, queries)

            Case Else

                If IsNumeric(resource.Substring(1)) Then '/api/users/{id}

                    loadUser(context, connection, queries, userId)

                ElseIf resource.EndsWith("/picture") Then '/api/users/{id}/picture

                    loadPicture(context, connection)

                ElseIf resource.EndsWith("/icon") Then '/api/users/{id}/icon

                    loadIcon(context, connection)

                Else

                    sendErrorResponse(context, 404, "Not Found")

                End If

        End Select

        'Dim response As Web.HttpResponse = context.Response

        'response.Write("<div>IsMobileDevice:" & context.Request.Browser.IsMobileDevice & "</div>")
        'response.Write("<div>LogonUserIdentity.IsAnonymous:" & context.Request.LogonUserIdentity.IsAnonymous & "</div>")
        'response.Write("<div>UserHostAddress:" & context.Request.UserHostAddress & "</div>")

    End Sub

    Private Sub loadUsers(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection)

        If queries("interval") <> "" Then

            loadTopUsers(context, connection, queries)

        Else

            MyBase.sendErrorResponse(context, 404, "Not Found")

        End If

    End Sub

    Private Sub loadTopUsers(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection)

        Using command As New SqlClient.SqlCommand(LOAD_TOP_USERS, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@latitude", queries("latitude"))
            command.Parameters.AddWithValue("@longitude", queries("longitude"))
            command.Parameters.AddWithValue("@interval", queries("interval"))
            command.Parameters.AddWithValue("@count", Me.count(queries))

            MyBase.sendSuccessResponse(context, createJsonUsers(command))

        End Using

    End Sub

    Private Sub loadUser(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        currentUserId As Int32)

        Dim userId As String = context.Request.PathInfo.Substring(1) 'remove "/"

        Using command As New SqlClient.SqlCommand(LOAD_USER, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@currentUserId", currentUserId)
            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@count", Me.userCount(queries))
            command.Parameters.AddWithValue("@expirationDays", Me.expirationDays(queries))

            MyBase.sendSuccessResponse(context, createJsonUser(command))

        End Using

    End Sub

    Private Sub verifyEmail(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection)

        Using command As New SqlClient.SqlCommand(VERIFY_USER_EMAIL, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@guid", queries("guid"))
            command.ExecuteNonQuery()

            context.Response.Redirect(VERIFIED_URL, True)

        End Using

    End Sub

    Private Sub loadPicture(
      context As Web.HttpContext,
      connection As SqlClient.SqlConnection)

        Dim userId As String = context.Request.PathInfo.Split("/"c)(1)

        Using command As New SqlClient.SqlCommand(LOAD_USER_PICTURE, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)

            sendImageResponse(context, DirectCast(command.ExecuteScalar(), Byte()))

        End Using

    End Sub

    Private Sub loadIcon(
      context As Web.HttpContext,
      connection As SqlClient.SqlConnection)

        Dim userId As String = context.Request.PathInfo.Split("/"c)(1)

        Using command As New SqlClient.SqlCommand(LOAD_USER_ICON, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)

            sendImageResponse(context, DirectCast(command.ExecuteScalar(), Byte()))

        End Using

    End Sub

    Protected Sub sendImageResponse(
        context As Web.HttpContext,
        image() As Byte)

        context.Response.Headers.Remove("Server")
        context.Response.Headers.Add("Content-Length", image.Length.ToString())
        context.Response.ContentType = "image/png"

        context.Response.BinaryWrite(image)

    End Sub

    Private Sub loadColumns(
        context As Web.HttpContext)

        sendSuccessResponse(context, JSON_USER_COLUMNS)

    End Sub

    Private Function createJsonUsers(command As Data.SqlClient.SqlCommand) As String

        Using users As Data.SqlClient.SqlDataReader = command.ExecuteReader()

            Dim response As String = "["

            If users.HasRows() Then

                While (users.Read())

                    response &= String.Concat(
                        "[",
                        users("userId"), ",""",
                        users("username"), """,""",
                        users("displayName"), """,",
                        users("reputation"), ",""",
                        users("signupDate"), """,""",
                        MyBase.jsonEncode(CStr(users("tagline"))), """,",
                        users("totalQuestions"), ",",
                        users("totalAnswers"), ",",
                        users("totalBadges"),
                        "],")

                End While

                response = response.Substring(0, response.Length - 1) 'remove last comma

            End If

            response &= "]"

            Return response

        End Using

    End Function

    Private Function createJsonUser(command As Data.SqlClient.SqlCommand) As String

        Using user As Data.SqlClient.SqlDataReader = command.ExecuteReader()

            Dim response As String = "["

            If user.HasRows() Then

                user.Read()

                'user
                response &= String.Concat(
                    "[",
                    user("userId"), ",""",
                    user("username"), """,""",
                    user("displayName"), """,",
                    user("reputation"), ",""",
                    user("signupDate"), """,""",
                    MyBase.jsonEncode(CStr(user("tagline"))), """,",
                    user("totalQuestions"), ",",
                    user("totalAnswers"), ",",
                    user("totalBadges"),
                    ",[")

                'badges
                If user.NextResult() Then

                    If user.HasRows() Then

                        While (user.Read())

                            response &= String.Concat(
                                "[",
                                user("badgeClassId"), ",""",
                                user("badge"), """,""",
                                user("description"), """,",
                                user("unlimited"), ",",
                                user("badges"),
                                "],")

                        End While

                        response = response.Substring(0, response.Length - 1) 'remove last comma

                    End If

                End If

                response &= "],["

                'questions
                If user.NextResult() Then

                    If user.HasRows() Then

                        While (user.Read())

                            response &= String.Concat(
                                "[",
                                user("questionId"), ",",
                                user("userId"), ",""",
                                user("username"), """,",
                                user("reputation"), ",""",
                                MyBase.jsonEncode(CStr(user("question"))), """,""",
                                user("link"), """,",
                                user("latitude"), ",",
                                user("longitude"), ",""",
                                user("timestamp"), """,",
                                user("resolved"), ",",
                                user("expired"), ",",
                                user("bounty"), ",",
                                user("voted"), ",",
                                user("votes"), ",",
                                user("answers"),
                                "],")

                        End While

                        response = response.Substring(0, response.Length - 1) 'remove last comma

                    End If

                End If

                response &= "],["

                'answers
                If user.NextResult() Then

                    If user.HasRows() Then

                        While (user.Read())

                            response &= String.Concat(
                                "[",
                                user("answerId"), ",",
                                user("questionId"), ",",
                                user("userId"), ",""",
                                user("username"), """,",
                                user("reputation"), ",""",
                                user("locationId"), """,""",
                                MyBase.jsonEncode(user("location").ToString()), """,""",
                                user("locationAddress"), """,""",
                                MyBase.jsonEncode(user("note").ToString()), """,""",
                                user("link").ToString(), """,""",
                                user("phone").ToString(), """,",
                                user("latitude"), ",",
                                user("longitude"), ",",
                                user("distance"), ",""",
                                user("timestamp"), """,",
                                user("selected"), ",",
                                user("voted"), ",",
                                user("votes"),
                                "],")

                        End While

                        response = response.Substring(0, response.Length - 1) 'remove last comma

                    End If

                End If

                response &= "],["

                'reputation
                If user.NextResult() Then

                    If user.HasRows() Then

                        While (user.Read())

                            response &= String.Concat(
                                "[",
                                user("reputationId"), ",""",
                                user("reputationAction"), """,",
                                user("questionId"), ",""",
                                MyBase.jsonEncode(CStr(user("question"))), """,",
                                user("reputation"), ",""",
                                user("timestamp"),
                                """],")

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

    Private ReadOnly Property userCount(queries As Collections.Specialized.NameValueCollection) As Integer

        Get

            Dim countString As String = queries("count"),
                countValue As Integer = 0

            If Microsoft.VisualBasic.IsNumeric(countString) Then

                countValue = Convert.ToInt32(countString)

                Select Case countValue
                    Case 0

                        Return USER_ROW_COUNT_DEFAULT

                    Case Is > ROW_COUNT_MAX

                        Return ROW_COUNT_MAX

                    Case Else

                        Return countValue

                End Select

            Else

                Return USER_ROW_COUNT_DEFAULT

            End If

        End Get

    End Property

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

    Protected Overrides Function isAuthorized(
        context As System.Web.HttpContext,
        ByRef userId As Int32) As Boolean

        Dim authorized As Boolean = True

        Return authorized

    End Function

End Class


