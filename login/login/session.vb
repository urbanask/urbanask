#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

Public Class session : Implements System.Web.IHttpHandler

#Region "constants"

    Private Const CREATE_SESSION_PROC As String = "session.login.createSession",
        CHECK_AUTHORIZATION_PROC As String = "Gabs.login.checkAuthorization",
        COMMAND_TIMEOUT As Int32 = 60

#If CONFIG = "Release" Then

    Private Const GABS_CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;"
    Private Const SESSION_CONNECTION_STRING As String = "Server=SERVER2008;Database=session;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;"

#Else

    Private Const GABS_CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;",
        SESSION_CONNECTION_STRING As String = "Server=SERVER2008;Database=session;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;"

#End If

#End Region

    Public Sub ProcessRequest(
        context As Web.HttpContext) _
        Implements System.Web.IHttpHandler.ProcessRequest

        Dim authorization As String = Nothing

        If context.Request.Headers.Item("x-authorization") IsNot Nothing Then

            authorization = context.Request.Headers("x-authorization")

        End If

        If authorization Is Nothing Then

            authorization = context.Request.QueryString("x-authorization")

        End If

        If authorization IsNot Nothing _
            AndAlso authorization <> "" Then

            Dim credentialSplit() As String = Text.Encoding.UTF8.GetString(
                Convert.FromBase64String(fromBase64UrlString(authorization))).Split(":"c)

            If credentialSplit.Length = 2 Then

                Dim username As String = credentialSplit(0),
                    password As String = credentialSplit(1)

                Using gabsConnection As New Data.SqlClient.SqlConnection(GABS_CONNECTION_STRING),
                    sessionConnection As New Data.SqlClient.SqlConnection(SESSION_CONNECTION_STRING),
                    checkAuthorization As New Data.SqlClient.SqlCommand(CHECK_AUTHORIZATION_PROC, gabsConnection),
                    createSession As New Data.SqlClient.SqlCommand(CREATE_SESSION_PROC, sessionConnection)

                    gabsConnection.Open()

                    checkAuthorization.CommandType = Data.CommandType.StoredProcedure
                    checkAuthorization.CommandTimeout = COMMAND_TIMEOUT

                    checkAuthorization.Parameters.AddWithValue("@username", username)
                    checkAuthorization.Parameters.Add("@userId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
                    checkAuthorization.Parameters.Add("@hash", Data.SqlDbType.Char, 88).Direction = Data.ParameterDirection.Output
                    checkAuthorization.Parameters.Add("@hashType", Data.SqlDbType.VarChar, 10).Direction = Data.ParameterDirection.Output
                    checkAuthorization.Parameters.Add("@salt", Data.SqlDbType.Char, 8).Direction = Data.ParameterDirection.Output
                    checkAuthorization.Parameters.Add("@iterations", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output

                    checkAuthorization.ExecuteNonQuery()

                    If System.Convert.ToInt32(checkAuthorization.Parameters("@userId").Value) > 0 Then

                        Dim hash As New Hashing.hash(
                            username,
                            password,
                            checkAuthorization.Parameters("@hashType").Value.ToString(),
                            checkAuthorization.Parameters("@salt").Value.ToString(),
                            Convert.ToInt32(checkAuthorization.Parameters("@iterations").Value))

                        If hash.hash = checkAuthorization.Parameters("@hash").Value.ToString() Then

                            sessionConnection.Open()

                            createSession.CommandType = Data.CommandType.StoredProcedure
                            createSession.CommandTimeout = COMMAND_TIMEOUT

                            createSession.Parameters.AddWithValue("@userId", Convert.ToInt32(checkAuthorization.Parameters("@userId").Value))
                            createSession.Parameters.Add("@sessionId", Data.SqlDbType.UniqueIdentifier).Direction = Data.ParameterDirection.Output
                            createSession.Parameters.Add("@sessionKey", Data.SqlDbType.UniqueIdentifier).Direction = Data.ParameterDirection.Output

                            createSession.ExecuteNonQuery()

                            sendSuccessResponse(
                                context,
                                createSession.Parameters("@sessionId").Value.ToString(),
                                createSession.Parameters("@sessionKey").Value.ToString())

                        Else

                            sendErrorResponse(context)

                        End If

                    Else

                        sendErrorResponse(context)

                    End If

                End Using

            Else

                sendErrorResponse(context)

            End If

        Else

            sendErrorResponse(context)

        End If

    End Sub

    Public ReadOnly Property IsResusable As Boolean _
        Implements System.Web.IHttpHandler.IsReusable

        Get

            Return True

        End Get

    End Property

    Private Function fromBase64UrlString(
        base64String As String) As String

        Dim padLength As Int32 = base64String.Length + (4 - base64String.Length Mod 4) Mod 4

        Return base64String.Replace("-"c, "+"c).Replace("_"c, "/"c).PadRight(padLength, "="c)

    End Function

    Private Sub sendSuccessResponse(
        context As Web.HttpContext,
        session As String,
        key As String)

        context.Response.Headers.Remove("Server")
        context.Response.Headers.Add("x-session", String.Concat(session, ":", key))
        'context.Response.Headers.Add("Content-Length", response.Length.ToString())

    End Sub

    Private Sub sendErrorResponse(
        context As Web.HttpContext)

        context.Response.StatusCode = 401
        context.Response.StatusDescription = "Unauthorized"
        context.Response.Headers.Remove("Server")
        'context.Response.Headers.Add("WWW-Authenticate", "Basic")

    End Sub

End Class

