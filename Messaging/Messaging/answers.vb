#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System.Data

#End Region

Public Class answers : Inherits messaging.messageHandler

    Private Const INSERT_MESSAGE_PROC As String = "Messaging.messaging.insertAnswerMessage",
        MAX_MESSAGE_LENGTH As Int32 = 600

    Protected Overrides Sub processMessage(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext,
        messasge As String,
        userId As Int32)

        Dim answerMessage As String = String.Concat(userId, "~", messasge)

        Using command As New SqlClient.SqlCommand(INSERT_MESSAGE_PROC, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@message", answerMessage)
            command.Parameters.Add("@processed", SqlDbType.Bit).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If System.Convert.ToBoolean(command.Parameters("@processed").Value) Then

                MyBase.sendSuccessResponse(context)

            Else

                MyBase.sendErrorResponse(context, 500, "Internal Server Error")

            End If

        End Using

    End Sub

    Protected Overrides Function isValid(ByVal message As String) As Boolean

        If message.Length > 0 AndAlso message.Length < MAX_MESSAGE_LENGTH Then

            Return True

        Else

            Return False

        End If

    End Function

End Class


