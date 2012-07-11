#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

Public Class loginTwitter : Implements System.Web.IHttpHandler

#Region "constants"

    Private Const CREATE_SESSION_PROC As String = "session.login.createSession",
        CHECK_AUTHORIZATION_PROC As String = "Gabs.login.checkAuthorizationTwitter",
        CREATE_USER_PROC As String = "Gabs.login.createTwitterUser",
        CREATE_USER_PICTURE_PROC As String = "Gabs.login.createUserPicture",
        CONSUMER_KEY As String = "LYmBn0COBIkkcRXpImTAJA",
        CONSUMER_SECRET As String = "wsIo3xDOPD6BPviujjk5L1kwXEMYuTTIwToCGq0pxY",
        COMMAND_TIMEOUT As Int32 = 60,
        METRIC_DEFAULT As Int32 = 0,
        LANGUAGE_DEFAULT As Int32 = 1,
        TWITTER_AUTH_TYPE As Int32 = 3

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

        Dim queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

        If queries("returnUrl") <> "" Then

            Dim tokenResponse As String = Twitterizer.OAuthUtility.GetRequestToken(CONSUMER_KEY, CONSUMER_SECRET, queries("returnUrl")).Token
            sendUrlResponse(context, Twitterizer.OAuthUtility.BuildAuthorizationUri(tokenResponse, True).ToString())

        ElseIf queries("oauth_token") <> "" Then

            Dim tokenResponse As Twitterizer.OAuthTokenResponse = Twitterizer.OAuthUtility.GetAccessToken(
                    CONSUMER_KEY,
                    CONSUMER_SECRET,
                    queries("oauth_token"),
                    queries("oauth_verifier")),
                twitterId As String = tokenResponse.UserId.ToString(),
                screenName As String = tokenResponse.ScreenName,
                token As String = tokenResponse.Token,
                tokenSecret As String = tokenResponse.TokenSecret

            Using gabsConnection As New Data.SqlClient.SqlConnection(GABS_CONNECTION_STRING),
                checkAuthorization As New Data.SqlClient.SqlCommand(CHECK_AUTHORIZATION_PROC, gabsConnection),
                sessionConnection As New Data.SqlClient.SqlConnection(SESSION_CONNECTION_STRING),
                createUser As New Data.SqlClient.SqlCommand(CREATE_USER_PROC, gabsConnection),
                createSession As New Data.SqlClient.SqlCommand(CREATE_SESSION_PROC, sessionConnection),
                createUserPicture As New Data.SqlClient.SqlCommand(CREATE_USER_PICTURE_PROC, gabsConnection)

                gabsConnection.Open()

                checkAuthorization.CommandType = Data.CommandType.StoredProcedure
                checkAuthorization.CommandTimeout = COMMAND_TIMEOUT

                checkAuthorization.Parameters.AddWithValue("@twitterId", twitterId)
                checkAuthorization.Parameters.Add("@userId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
                checkAuthorization.Parameters.Add("@hash", Data.SqlDbType.Char, 88).Direction = Data.ParameterDirection.Output
                checkAuthorization.Parameters.Add("@hashType", Data.SqlDbType.VarChar, 10).Direction = Data.ParameterDirection.Output
                checkAuthorization.Parameters.Add("@salt", Data.SqlDbType.Char, 8).Direction = Data.ParameterDirection.Output
                checkAuthorization.Parameters.Add("@iterations", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
                checkAuthorization.Parameters.Add("@enabled", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output

                checkAuthorization.ExecuteNonQuery()

                If System.Convert.ToInt32(checkAuthorization.Parameters("@userId").Value) > 0 Then

                    If System.Convert.ToBoolean(checkAuthorization.Parameters("@enabled").Value) Then

                        Dim userId As Int32 = CInt(checkAuthorization.Parameters("@userId").Value)

                        Dim hash As New Hashing.hash(
                                twitterId,
                                tokenSecret,
                                checkAuthorization.Parameters("@hashType").Value.ToString(),
                                checkAuthorization.Parameters("@salt").Value.ToString(),
                                Convert.ToInt32(checkAuthorization.Parameters("@iterations").Value))

                        If hash.hash = checkAuthorization.Parameters("@hash").Value.ToString() Then

                            loadSession(sessionConnection, createSession, context, userId)

                        Else

                            sendErrorResponse(context)

                        End If

                    Else

                        sendErrorResponse(context)

                    End If

                Else

                    Dim hash As New Hashing.hash(twitterId, tokenSecret),
                        tokens As New Twitterizer.OAuthTokens(),
                        user As Twitterizer.TwitterResponse(Of Twitterizer.TwitterUser),
                        location As String = ""

                    tokens.AccessToken = token
                    tokens.AccessTokenSecret = tokenSecret
                    tokens.ConsumerKey = CONSUMER_KEY
                    tokens.ConsumerSecret = CONSUMER_SECRET
                    user = Twitterizer.TwitterUser.Show(tokens, CDec(twitterId))

                    If user.Result = Twitterizer.RequestResult.Success Then

                        location = user.ResponseObject.Location

                    End If

                    createUser.CommandType = Data.CommandType.StoredProcedure
                    createUser.CommandTimeout = COMMAND_TIMEOUT

                    createUser.Parameters.AddWithValue("@suggestedUsername", screenName)
                    createUser.Parameters.AddWithValue("@tagline", "")
                    createUser.Parameters.AddWithValue("@hash", hash.hash)
                    createUser.Parameters.AddWithValue("@salt", hash.salt)
                    createUser.Parameters.AddWithValue("@iterations", hash.iterations)
                    createUser.Parameters.AddWithValue("@hashType", hash.hashType)
                    createUser.Parameters.AddWithValue("@metricDistances", METRIC_DEFAULT)
                    createUser.Parameters.AddWithValue("@languageId", LANGUAGE_DEFAULT)
                    createUser.Parameters.AddWithValue("@authTypeId", TWITTER_AUTH_TYPE)
                    createUser.Parameters.AddWithValue("@twitterId", twitterId)
                    createUser.Parameters.AddWithValue("@screenName", screenName)
                    createUser.Parameters.AddWithValue("@token", token)
                    createUser.Parameters.AddWithValue("@tokenSecret", tokenSecret)
                    createUser.Parameters.AddWithValue("@location", location)
                    createUser.Parameters.Add("@userId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output
                    createUser.Parameters.Add("@username", Data.SqlDbType.VarChar, 100).Direction = Data.ParameterDirection.Output

                    createUser.ExecuteNonQuery()

                    Dim userId As Int32 = CInt(createUser.Parameters("@userId").Value),
                        username As String = createUser.Parameters("@username").Value.ToString(),
                        url As String = "https://api.twitter.com/1/users/profile_image?screen_name=" + screenName + "&size=bigger"

                    Using web As New Net.WebClient(),
                        stream As IO.Stream = web.OpenRead(url),
                        imageSource As Drawing.Image = Drawing.Image.FromStream(stream),
                        image As Drawing.Image = imageSource.GetThumbnailImage(50, 50, Function() False, IntPtr.Zero),
                        icon As Drawing.Image = imageSource.GetThumbnailImage(32, 32, Function() False, IntPtr.Zero),
                        imageStream As New IO.MemoryStream,
                        iconStream As New IO.MemoryStream

                        image.Save(imageStream, System.Drawing.Imaging.ImageFormat.Png)
                        icon.Save(iconStream, System.Drawing.Imaging.ImageFormat.Png)

                        createUserPicture.CommandType = Data.CommandType.StoredProcedure
                        createUserPicture.CommandTimeout = COMMAND_TIMEOUT

                        createUserPicture.Parameters.AddWithValue("@userId", userId)
                        createUserPicture.Parameters.AddWithValue("@picture", imageStream.GetBuffer())
                        createUserPicture.Parameters.AddWithValue("@icon", iconStream.GetBuffer())

                        createUserPicture.ExecuteNonQuery()

                    End Using

                    loadSession(sessionConnection, createSession, context, userId, username)

                End If

            End Using

        Else

            sendErrorResponse(context)

        End If

    End Sub

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

        If username <> "" Then

            Dim response As String = "{""username"":""" & jsonEncode(username) & """}"
            context.Response.Headers.Add("Content-Length", response.Length.ToString())

#If CONFIG <> "Debug" Then

        context.Response.ContentType = "application/json"

#End If

            context.Response.Write(response)

        End If

    End Sub

    Private Sub sendUrlResponse(
        context As Web.HttpContext,
        url As String)

        context.Response.Headers.Remove("Server")

        Dim response As String = "{""url"":""" & jsonEncode(url) & """}"
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

