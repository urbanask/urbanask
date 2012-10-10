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
        SAVE_NOTIFICATION_VIEWED As String = "Gabs.api.saveNotificationViewed",
        SAVE_INSTRUCTION_VIEWED As String = "Gabs.api.saveInstructionViewed",
        RESET_INSTRUCTIONS As String = "Gabs.api.resetInstructions",
        JSON_ACCOUNT_COLUMNS As String =
              "[" _
            & """userId""," _
            & """username""," _
            & """displayName""," _
            & """reputation""," _
            & """metricDistances""," _
            & """languageId""," _
            & """tagline""," _
            & """regions""," _
            & """notifications""," _
            & """instructions""," _
            & """facebook""," _
            & """phone""" _
            & "]"

    Protected Overrides Sub process(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext,
        request As String,
        userId As Int32)

        Dim resource As String = context.Request.PathInfo,
            queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

        Select Case resource

            Case "" '/api/account

                loadAccount(context, connection, userId)

            Case "/save" '/api/account/save

                If queries("userNotificationId") <> "" Then

                    saveNotificationViewed(context, connection, queries, userId)

                Else

                    saveAccount(context, connection, queries, userId)

                End If

            Case "/instructions/save" '/api/account/instructions/save

                saveInstructionViewed(context, connection, queries, userId)

            Case "/instructions/reset" '/api/account/instructions/reset

                resetInstructions(context, connection, queries, userId)

            Case "/columns" '/api/account/columns

                loadColumns(context)

            Case Else

                MyBase.sendErrorResponse(context, 404, "Not Found")

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
        queries As Collections.Specialized.NameValueCollection,
        userId As Int32)

        Dim username As String = queries("username"),
            tagline As String = queries("tagline"),
            phoneNumber As String = unformatPhoneNumber(queries("phoneNumber")),
            regionId As String = queries("regionId"),
            pushNotifications As Int32 = Convert.ToInt32(queries("pushNotifications"))

        Using command As New SqlClient.SqlCommand(SAVE_ACCOUNT, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@username", username)
            command.Parameters.AddWithValue("@tagline", tagline)
            command.Parameters.AddWithValue("@phoneNumber", phoneNumber)
            command.Parameters.AddWithValue("@regionId", regionId)
            command.Parameters.AddWithValue("@pushNotifications", pushNotifications)
            command.Parameters.Add("@error", SqlDbType.VarChar, 256).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If command.Parameters("@error").Value.ToString() <> "" Then

                MyBase.sendErrorResponse(context, 412, command.Parameters("@error").Value.ToString())

            End If

        End Using

    End Sub

    Private Sub saveNotificationViewed(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        userId As Int32)

        Dim userNotificationId As String = queries("userNotificationId")

        Using command As New SqlClient.SqlCommand(SAVE_NOTIFICATION_VIEWED, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@userNotificationId", userNotificationId)

            command.ExecuteNonQuery()

        End Using

    End Sub

    Private Sub saveInstructionViewed(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        userId As Int32)

        Dim type As String = queries("type")

        Using command As New SqlClient.SqlCommand(SAVE_INSTRUCTION_VIEWED, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@type", type)

            command.ExecuteNonQuery()

        End Using

    End Sub

    Private Sub resetInstructions(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        queries As Collections.Specialized.NameValueCollection,
        userId As Int32)

        Using command As New SqlClient.SqlCommand(RESET_INSTRUCTIONS, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)

            command.ExecuteNonQuery()

        End Using

    End Sub

    Private Function unformatPhoneNumber(number As String) As String

        Dim unformattedNumber As String = ""

        For index As Int32 = 0 To number.Length - 1

            If Microsoft.VisualBasic.IsNumeric(number(index)) Then

                unformattedNumber &= number(index)

            End If

        Next index

        Return unformattedNumber

    End Function

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

                Dim pushNotifications As String = CStr(user("pushNotifications"))

                'regions
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

                response &= "],["

                'notifications
                If user.NextResult() Then

                    If user.HasRows() Then

                        While (user.Read())

                            response &= String.Concat(
                                "[",
                                user("userNotificationId"), ",""",
                                user("notification"), """,""",
                                user("objectType"), """,",
                                user("itemId"), ",""",
                                MyBase.jsonEncode(CStr(user("objectDescription"))), """,",
                                user("viewed"), ",""",
                                user("timestamp"),
                                """],")

                        End While

                        response = response.Substring(0, response.Length - 1) 'remove last comma

                    End If

                End If

                response &= "],["

                'instructions
                If user.NextResult() Then

                    If user.HasRows() Then

                        user.Read()

                        response &= String.Concat(
                            user("postQuestion"), ",",
                            user("viewQuestions"), ",",
                            user("viewQuestion"), ",",
                            user("addAnswer"), ",",
                            user("toolbar"), ",",
                            user("askedQuestionSMSNotification"), ",",
                            user("intro"), ",",
                            user("push")
                            )

                    End If

                End If

                response &= "],["

                'facebook
                If user.NextResult() Then

                    If user.HasRows() Then

                        user.Read()

                        response &= String.Concat(
                            """", user("facebookId"), """"
                            )

                    End If

                End If

                response &= "],["

                'phone
                If user.NextResult() Then

                    If user.HasRows() Then

                        user.Read()

                        response &= String.Concat(
                            """", user("number"), """,",
                            user("notifications"), ",",
                            user("verified")
                            )

                    End If

                End If

                response &= "],"

                'additional account fields
                response &= pushNotifications

                response &= "]"

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

    Protected Overrides Function isAuthorized(
        context As System.Web.HttpContext,
        ByRef userId As Int32) As Boolean

        Dim authorized As Boolean,
            auth As New authorization(context, authorized, userId)

        Return authorized

    End Function

End Class


