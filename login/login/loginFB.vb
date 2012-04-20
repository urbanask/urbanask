#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

Public Class loginFB : Implements System.Web.IHttpHandler

#Region "constants"

    Private Const CREATE_SESSION_PROC As String = "session.login.createSession",
        CHECK_AUTHORIZATION_PROC As String = "Gabs.login.checkAuthorizationFacebook",
        UPDATE_HASH_PROC As String = "Gabs.login.updateFacebookHash",
        CREATE_USER_PROC As String = "Gabs.login.createFacebookUser",
        CREATE_USER_PICTURE_PROC As String = "Gabs.login.createFacebookUserPicture",
        COMMAND_TIMEOUT As Int32 = 60,
        METRIC_DEFAULT As Int32 = 0,
        LANGUAGE_DEFAULT As Int32 = 1,
        FACEBOOK_AUTH_TYPE As Int32 = 2

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
                Convert.FromBase64String(
                fromBase64UrlString(authorization)
                )).Split(":"c)

            If credentialSplit.Length = 3 AndAlso
                context.Request.QueryString("location") IsNot Nothing AndAlso
                context.Request.QueryString("email") IsNot Nothing Then

                Dim facebookId As String = credentialSplit(0),
                    username As String = credentialSplit(1),
                    password As String = credentialSplit(2),
                    regionId As Int32 = 1,
                    location As String = context.Request.QueryString("location"),
                    email As String = context.Request.QueryString("email"),
                    accessToken As String = context.Request.QueryString("accessToken"),
                    latitude As String = context.Request.QueryString("latitude"),
                    longitude As String = context.Request.QueryString("longitude")

                Using gabsConnection As New Data.SqlClient.SqlConnection(GABS_CONNECTION_STRING),
                    sessionConnection As New Data.SqlClient.SqlConnection(SESSION_CONNECTION_STRING),
                    checkAuthorization As New Data.SqlClient.SqlCommand(CHECK_AUTHORIZATION_PROC, gabsConnection),
                    createSession As New Data.SqlClient.SqlCommand(CREATE_SESSION_PROC, sessionConnection),
                    updateHash As New Data.SqlClient.SqlCommand(UPDATE_HASH_PROC, gabsConnection),
                    createUser As New Data.SqlClient.SqlCommand(CREATE_USER_PROC, gabsConnection),
                    createUserPicture As New Data.SqlClient.SqlCommand(CREATE_USER_PICTURE_PROC, gabsConnection)

                    gabsConnection.Open()

                    checkAuthorization.CommandType = Data.CommandType.StoredProcedure
                    checkAuthorization.CommandTimeout = COMMAND_TIMEOUT

                    checkAuthorization.Parameters.AddWithValue("@facebookId", facebookId)
                    checkAuthorization.Parameters.Add("@userId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
                    checkAuthorization.Parameters.Add("@hash", Data.SqlDbType.Char, 88).Direction = Data.ParameterDirection.Output
                    checkAuthorization.Parameters.Add("@hashType", Data.SqlDbType.VarChar, 10).Direction = Data.ParameterDirection.Output
                    checkAuthorization.Parameters.Add("@salt", Data.SqlDbType.Char, 8).Direction = Data.ParameterDirection.Output
                    checkAuthorization.Parameters.Add("@iterations", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
                    checkAuthorization.Parameters.Add("@enabled", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output

                    checkAuthorization.ExecuteNonQuery()

                    Dim userId As Int32,
                        newAccount As Boolean = False

                    If System.Convert.ToInt32(checkAuthorization.Parameters("@userId").Value) > 0 Then

                        If System.Convert.ToBoolean(checkAuthorization.Parameters("@enabled").Value) = False Then

                            sendErrorResponse(context)

                        Else

                            userId = CInt(checkAuthorization.Parameters("@userId").Value)

                            Dim hash As New Hashing.hash(
                                    username,
                                    password,
                                    checkAuthorization.Parameters("@hashType").Value.ToString(),
                                    checkAuthorization.Parameters("@salt").Value.ToString(),
                                    Convert.ToInt32(checkAuthorization.Parameters("@iterations").Value))

                            If hash.hash <> checkAuthorization.Parameters("@hash").Value.ToString() Then

                                updateHash.CommandType = Data.CommandType.StoredProcedure
                                updateHash.CommandTimeout = COMMAND_TIMEOUT

                                updateHash.Parameters.AddWithValue("@userId", userId)
                                updateHash.Parameters.AddWithValue("@hash", hash.hash)
                                updateHash.Parameters.AddWithValue("@accessToken", accessToken)

                                updateHash.ExecuteNonQuery()

                            End If

                        End If

                    Else

                        Dim hash As New Hashing.hash(username, password)

                        newAccount = True

                        createUser.CommandType = Data.CommandType.StoredProcedure
                        createUser.CommandTimeout = COMMAND_TIMEOUT

                        createUser.Parameters.AddWithValue("@username", username)
                        createUser.Parameters.AddWithValue("@tagline", "")
                        createUser.Parameters.AddWithValue("@hash", hash.hash)
                        createUser.Parameters.AddWithValue("@salt", hash.salt)
                        createUser.Parameters.AddWithValue("@iterations", hash.iterations)
                        createUser.Parameters.AddWithValue("@hashType", hash.hashType)
                        createUser.Parameters.AddWithValue("@metricDistances", METRIC_DEFAULT)
                        createUser.Parameters.AddWithValue("@languageId", LANGUAGE_DEFAULT)
                        createUser.Parameters.AddWithValue("@authTypeId", FACEBOOK_AUTH_TYPE)
                        createUser.Parameters.AddWithValue("@facebookId", facebookId)
                        createUser.Parameters.AddWithValue("@regionId", regionId)
                        createUser.Parameters.AddWithValue("@location", location)
                        createUser.Parameters.AddWithValue("@email", email)
                        createUser.Parameters.AddWithValue("@accessToken", accessToken)
                        createUser.Parameters.Add("@userId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output

                        createUser.ExecuteNonQuery()

                        userId = CInt(createUser.Parameters("@userId").Value)

                        Dim url As String = "https://graph.facebook.com/" + facebookId + "/picture"

                        Using web As New Net.WebClient(),
                            stream As IO.Stream = web.OpenRead(url),
                            picture As Drawing.Image = Drawing.Image.FromStream(stream),
                            icon As Drawing.Image = picture.GetThumbnailImage(32, 32, Function() False, IntPtr.Zero),
                            pictureStream As New IO.MemoryStream,
                            iconStream As New IO.MemoryStream

                            picture.Save(pictureStream, System.Drawing.Imaging.ImageFormat.Png)
                            icon.Save(iconStream, System.Drawing.Imaging.ImageFormat.Png)

                            createUserPicture.CommandType = Data.CommandType.StoredProcedure
                            createUserPicture.CommandTimeout = COMMAND_TIMEOUT

                            createUserPicture.Parameters.AddWithValue("@userId", userId)
                            createUserPicture.Parameters.AddWithValue("@picture", pictureStream.GetBuffer())
                            createUserPicture.Parameters.AddWithValue("@icon", iconStream.GetBuffer())

                            createUserPicture.ExecuteNonQuery()

                        End Using

                    End If

                    loadSession(sessionConnection, createSession, context, userId, newAccount)

                End Using

            Else

                sendErrorResponse(context)

            End If

        Else

            sendErrorResponse(context)

        End If

    End Sub

    Private Sub loadSession( _
        sessionConnection As Data.SqlClient.SqlConnection, _
        createSession As Data.SqlClient.SqlCommand,
        context As Web.HttpContext,
        userId As Int32,
        newAccount As Boolean)

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
            newAccount)

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
        newAccount As Boolean)

        context.Response.Headers.Remove("Server")
        context.Response.Headers.Add("x-session", String.Concat(session, ":", key))

        Dim response As String = "{""newAccount"":" & newAccount.ToString().ToLower() & "}"

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

End Class

