#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region "imports"

Imports System.Data
Imports System.Web
Imports System.Security
Imports System.Text.Encoding

#End Region

Public Class login : Implements System.Web.IHttpHandler

#Region "constants"

    Private Const CREATE_SESSION_PROC As String = "session.login.createSession",
        CHECK_AUTHORIZATION_PROC As String = "Gabs.login.checkAuthorization",
        CREATE_USER_PROC As String = "Gabs.login.createUser",
        UPDATE_HASH_PROC As String = "Gabs.login.updateHash",
        COMMAND_TIMEOUT As Int32 = 60,
        METRIC_DEFAULT As Int32 = 0,
        LANGUAGE_DEFAULT As Int32 = 1,
        AUTH_TYPE_EMAIL As Int32 = 1,
        AUTH_TYPE_MOBILE As Int32 = 4

#If CONFIG = "Release" Then

    Private Const GABS_CONNECTION_STRING As String = "Server=WIN-FKVLOOSI1RO;Database=Gabs;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;",
        SESSION_CONNECTION_STRING As String = "Server=WIN-FKVLOOSI1RO;Database=session;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;"

#Else

    Private Const GABS_CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;",
        SESSION_CONNECTION_STRING As String = "Server=SERVER2008;Database=session;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;"

#End If

#End Region

    Public Sub ProcessRequest(
        context As Web.HttpContext) _
        Implements System.Web.IHttpHandler.ProcessRequest

        Dim authorization As String = Nothing,
            resource As String = context.Request.PathInfo

        If context.Request.Headers.Item("x-authorization") IsNot Nothing Then

            authorization = context.Request.Headers("x-authorization")

        End If

        If authorization Is Nothing Then

            authorization = context.Request.QueryString("x-authorization")

        End If

        If authorization IsNot Nothing _
            AndAlso authorization <> "" Then

            Dim credentialSplit() As String = Text.Encoding.UTF8.GetString(
                System.Convert.FromBase64String(fromBase64UrlString(authorization))).Split(":"c)

            If credentialSplit.Length = 2 Then

                Dim username As String = credentialSplit(0),
                    password As String = credentialSplit(1),
                    userId As Int32

                Using gabsConnection As New Data.SqlClient.SqlConnection(GABS_CONNECTION_STRING),
                    sessionConnection As New Data.SqlClient.SqlConnection(SESSION_CONNECTION_STRING),
                    checkAuthorization As New Data.SqlClient.SqlCommand(CHECK_AUTHORIZATION_PROC, gabsConnection),
                    createUser As New Data.SqlClient.SqlCommand(CREATE_USER_PROC, gabsConnection),
                    createSession As New Data.SqlClient.SqlCommand(CREATE_SESSION_PROC, sessionConnection),
                    updateHash As New Data.SqlClient.SqlCommand(UPDATE_HASH_PROC, gabsConnection)

                    gabsConnection.Open()

                    Select Case resource
                        Case "" '/logins/login

                            checkAuthorization.CommandType = Data.CommandType.StoredProcedure
                            checkAuthorization.CommandTimeout = COMMAND_TIMEOUT

                            checkAuthorization.Parameters.AddWithValue("@username", username)
                            checkAuthorization.Parameters.Add("@userId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
                            checkAuthorization.Parameters.Add("@hash", Data.SqlDbType.Char, 88).Direction = Data.ParameterDirection.Output
                            checkAuthorization.Parameters.Add("@hashType", Data.SqlDbType.VarChar, 10).Direction = Data.ParameterDirection.Output
                            checkAuthorization.Parameters.Add("@salt", Data.SqlDbType.Char, 8).Direction = Data.ParameterDirection.Output
                            checkAuthorization.Parameters.Add("@iterations", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
                            checkAuthorization.Parameters.Add("@enabled", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output

                            checkAuthorization.ExecuteNonQuery()

                            If System.Convert.ToInt32(checkAuthorization.Parameters("@userId").Value) > 0 Then

                                If System.Convert.ToBoolean(checkAuthorization.Parameters("@enabled").Value) Then

                                    userId = CInt(checkAuthorization.Parameters("@userId").Value)

                                    Dim hash As New Hashing.hash(
                                            username,
                                            password,
                                            checkAuthorization.Parameters("@hashType").Value.ToString(),
                                            checkAuthorization.Parameters("@salt").Value.ToString(),
                                            System.Convert.ToInt32(checkAuthorization.Parameters("@iterations").Value))

                                    If hash.hash = checkAuthorization.Parameters("@hash").Value.ToString() Then

                                        loadSession(sessionConnection, createSession, context, userId)

                                    Else

                                        sendErrorResponse(context)

                                    End If

                                Else

                                    sendErrorResponse(context)

                                End If

                            Else

                                sendErrorResponse(context)

                            End If

                        Case "/add" '/logins/login/add

                            If context.Request.QueryString("email") <> "" Then

                                saveEmailAccount(context, sessionConnection, createUser, updateHash, createSession, username, password)

                            ElseIf context.Request.QueryString("mobileNumber") <> "" Then

                                saveMobileAccount(context, sessionConnection, createUser, updateHash, createSession, username, password)

                            End If

                    End Select

                End Using

            Else

                sendErrorResponse(context)

            End If

        Else

            sendErrorResponse(context)

        End If

    End Sub

    Private Sub saveEmailAccount(
        context As Web.HttpContext,
        sessionConnection As Data.SqlClient.SqlConnection,
        createUser As Data.SqlClient.SqlCommand,
        updateHash As Data.SqlClient.SqlCommand,
        createSession As Data.SqlClient.SqlCommand,
        username As String,
        password As String)

        Dim hash As New Hashing.hash(username, password),
            email As String = context.Request.QueryString("email"),
            userId As Int32

        createUser.CommandType = Data.CommandType.StoredProcedure
        createUser.CommandTimeout = COMMAND_TIMEOUT

        createUser.Parameters.AddWithValue("@suggestedUsername", username)
        createUser.Parameters.AddWithValue("@tagline", "")
        createUser.Parameters.AddWithValue("@hash", hash.hash)
        createUser.Parameters.AddWithValue("@salt", hash.salt)
        createUser.Parameters.AddWithValue("@iterations", hash.iterations)
        createUser.Parameters.AddWithValue("@hashType", hash.hashType)
        createUser.Parameters.AddWithValue("@metricDistances", METRIC_DEFAULT)
        createUser.Parameters.AddWithValue("@languageId", LANGUAGE_DEFAULT)
        createUser.Parameters.AddWithValue("@authTypeId", AUTH_TYPE_EMAIL)
        createUser.Parameters.AddWithValue("@email", email)
        createUser.Parameters.Add("@userId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
        createUser.Parameters.Add("@username", Data.SqlDbType.VarChar, 100).Direction = Data.ParameterDirection.Output

        createUser.ExecuteNonQuery()
        userId = CInt(createUser.Parameters("@userId").Value)

        If username <> createUser.Parameters("@username").Value.ToString() Then

            username = createUser.Parameters("@username").Value.ToString()
            hash = New Hashing.hash(username, password)

            updateHash.CommandType = Data.CommandType.StoredProcedure
            updateHash.CommandTimeout = COMMAND_TIMEOUT
            updateHash.Parameters.AddWithValue("@userId", userId)
            updateHash.Parameters.AddWithValue("@hash", hash.hash)
            updateHash.ExecuteNonQuery()

        End If

        loadSession(sessionConnection, createSession, context, userId, username)

    End Sub

    Private Sub saveMobileAccount(
        context As Web.HttpContext,
        sessionConnection As Data.SqlClient.SqlConnection,
        createUser As Data.SqlClient.SqlCommand,
        updateHash As Data.SqlClient.SqlCommand,
        createSession As Data.SqlClient.SqlCommand,
        username As String,
        password As String)

        Dim hash As New Hashing.hash(username, password),
            number As String = unformatPhoneNumber(context.Request.QueryString("mobileNumber")),
            userId As Int32

        createUser.CommandType = Data.CommandType.StoredProcedure
        createUser.CommandTimeout = COMMAND_TIMEOUT

        createUser.Parameters.AddWithValue("@suggestedUsername", username)
        createUser.Parameters.AddWithValue("@tagline", "")
        createUser.Parameters.AddWithValue("@hash", hash.hash)
        createUser.Parameters.AddWithValue("@salt", hash.salt)
        createUser.Parameters.AddWithValue("@iterations", hash.iterations)
        createUser.Parameters.AddWithValue("@hashType", hash.hashType)
        createUser.Parameters.AddWithValue("@metricDistances", METRIC_DEFAULT)
        createUser.Parameters.AddWithValue("@languageId", LANGUAGE_DEFAULT)
        createUser.Parameters.AddWithValue("@authTypeId", AUTH_TYPE_MOBILE)
        createUser.Parameters.AddWithValue("@mobileNumber", number)
        createUser.Parameters.Add("@userId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
        createUser.Parameters.Add("@username", Data.SqlDbType.VarChar, 100).Direction = Data.ParameterDirection.Output
        createUser.Parameters.Add("@error", Data.SqlDbType.VarChar, 256).Direction = Data.ParameterDirection.Output

        createUser.ExecuteNonQuery()

        If createUser.Parameters("@error").Value.ToString() = "" Then

            userId = CInt(createUser.Parameters("@userId").Value)

            If username <> createUser.Parameters("@username").Value.ToString() Then

                username = createUser.Parameters("@username").Value.ToString()
                hash = New Hashing.hash(username, password)

                updateHash.CommandType = Data.CommandType.StoredProcedure
                updateHash.CommandTimeout = COMMAND_TIMEOUT
                updateHash.Parameters.AddWithValue("@userId", userId)
                updateHash.Parameters.AddWithValue("@hash", hash.hash)
                updateHash.ExecuteNonQuery()

            End If

            loadSession(sessionConnection, createSession, context, userId, username)

        Else

            sendErrorResponse(context, createUser.Parameters("@error").Value.ToString())

        End If

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

    Private Sub loadSession( _
        sessionConnection As Data.SqlClient.SqlConnection, _
        createSession As Data.SqlClient.SqlCommand,
        context As Web.HttpContext,
        userId As Int32,
        Optional username As String = "")

        sessionConnection.Open()

        createSession.CommandType = Data.CommandType.StoredProcedure
        createSession.CommandTimeout = COMMAND_TIMEOUT

        createSession.Parameters.AddWithValue("@userId", userId)
        createSession.Parameters.Add("@sessionId", Data.SqlDbType.UniqueIdentifier).Direction = Data.ParameterDirection.Output
        createSession.Parameters.Add("@sessionKey", Data.SqlDbType.UniqueIdentifier).Direction = Data.ParameterDirection.Output

        createSession.ExecuteNonQuery()

        sendSuccessResponse(
            context,
            createSession.Parameters("@sessionId").Value.ToString(),
            createSession.Parameters("@sessionKey").Value.ToString(),
            username)

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
        key As String,
        username As String)

        context.Response.Headers.Remove("Server")
        context.Response.Headers.Add("x-session", String.Concat(session, ":", key))

        Dim response As String = "{""username"":""" & jsonEncode(username) & """}"
        context.Response.Headers.Add("Content-Length", response.Length.ToString())

#If CONFIG <> "Debug" Then

        context.Response.ContentType = "application/json"

#End If

        context.Response.Write(response)

    End Sub

    Private Sub sendErrorResponse(
        context As Web.HttpContext)

        context.Response.StatusCode = 401
        context.Response.StatusDescription = "Unauthorized"
        context.Response.Headers.Remove("Server")
        'context.Response.Headers.Add("WWW-Authenticate", "Basic")

    End Sub

    Private Sub sendErrorResponse(
       context As Web.HttpContext, _
       errorMessage As String)

        context.Response.Headers.Remove("Server")

        Dim response As String = "{""error"":""" & jsonEncode(errorMessage) & """}"
        context.Response.Headers.Add("Content-Length", response.Length.ToString())

#If CONFIG <> "Debug" Then

        context.Response.ContentType = "application/json"

#End If

        context.Response.Write(response)

    End Sub

    Protected Function jsonEncode(
         json As String) As String

        Return json _
            .Replace("&", "&amp;") _
            .Replace("\", "&#92;") _
            .Replace("""", "\""") _
            .Replace("<", "&lt;") _
            .Replace(">", "&gt;")

    End Function

End Class

