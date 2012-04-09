#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System.Data
Imports System.Text.Encoding

#End Region

Public Class authorization

    Private Const CHECK_SESSION_PROC As String = "session.login.checkSession",
        COMMAND_TIMEOUT As Int32 = 60,
        CONNECTION_STRING As String = "Server=SERVER2008;Database=session;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;"

    Public Sub New(
        context As Web.HttpContext,
        ByRef isAuthorized As Boolean,
        ByRef userId As Int32)

        Dim session() As String = Nothing

        If context.Request.Headers.Item("x-session") IsNot Nothing Then

            session = context.Request.Headers("x-session").Split(":"c)

        End If

        If session Is Nothing Then

            If context.Request.QueryString("x-session") IsNot Nothing Then

                session = Web.HttpUtility.UrlDecode(context.Request.QueryString("x-session")).Split(":"c)

            End If

        End If

        If session IsNot Nothing AndAlso session.Length = 2 Then

            Using connection As New Data.SqlClient.SqlConnection(CONNECTION_STRING),
                command As New SqlClient.SqlCommand(CHECK_SESSION_PROC, connection)

                connection.Open()

                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = COMMAND_TIMEOUT

                Dim sessionId As String = session(0)
                command.Parameters.AddWithValue("@sessionId", sessionId)
                command.Parameters.Add("@sessionKey", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output
                command.Parameters.Add("@userId", SqlDbType.Int).Direction = ParameterDirection.Output

                command.ExecuteNonQuery()

                If System.Convert.ToInt32(command.Parameters("@userId").Value) > 0 Then

                    userId = System.Convert.ToInt32(command.Parameters("@userId").Value)

                    Dim hmac As New Security.Cryptography.HMACSHA1(UTF8.GetBytes(command.Parameters("@sessionKey").Value.ToString())),
                        computedDigest As String = toBase64UrlString(
                            System.Convert.ToBase64String(
                            hmac.ComputeHash(
                            UTF8.GetBytes(
                            String.Concat(context.Request.Path, sessionId))))),
                        digest As String = session(1)

                    If digest = computedDigest Then

                        isAuthorized = True

                    End If

                End If

            End Using

        End If


    End Sub

    Private Function toBase64UrlString(
        base64String As String) As String

        Return base64String.Replace("+"c, "-"c).Replace("/"c, "_"c).Replace("=", "")

    End Function

End Class
