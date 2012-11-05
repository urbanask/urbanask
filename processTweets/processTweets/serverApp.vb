#Region "options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region "imports "

Imports System.Data
Imports Utility
Imports System.Security
Imports System.Text.Encoding

#End Region

Public Class serverApp : Inherits Utility.ServerAppBase.ServerAppBase

#Region "    variables "

    Private _batchSize As Int32,
        _baseUrl As String,
        _commandTimeout As Int32,
        _connection As Data.SqlClient.SqlConnection,
        _connectionString As String,
        _createSession As String,
        _deleteFromWork As String,
        _hashTag As String,
        _loadSession As String,
        _loadUser As String,
        _logProcedureStatitics As Boolean,
        _messagingUrl As String,
        _moveToWork As String,
        _questionPrefix1 As String,
        _questionPrefix2 As String,
        _savePending As String,
        _twitterApiKey As String,
        _twitterApiSecret As String,
        _twitterToken As String,
        _twitterTokenSecret As String,
        _tweetBody As String,
        _viewTweets As String,
        _workCount As Int32

    Private Const GOOGLE_GEOCODE_URL As String = "http://maps.googleapis.com/maps/api/geocode/json?address=%1&sensor=false",
        GOOGLE_REVERSE_GEOCODE_URL As String = "http://maps.googleapis.com/maps/api/geocode/json?latlng=%1,%2&sensor=false"

    Private Structure Question

        Public twitterId As String,
            screenName As String,
            latitude As Double,
            longitude As Double,
            region As String,
            question As String

        Public Sub New(
            twitterId As String,
            screenName As String,
            latitude As Double,
            longitude As Double,
            region As String,
            question As String)

            Me.twitterId = twitterId
            Me.screenName = screenName
            Me.latitude = latitude
            Me.longitude = longitude
            Me.region = region
            Me.question = question

        End Sub

    End Structure

#End Region

#Region "    functions "

    Public Shared Sub main()

        Dim app As New serverApp

    End Sub

#Region "    initialization "

    Protected Overrides Sub initializeParameters()

        Me.initializeConfigParameters()

    End Sub

    Private Sub initializeConfigParameters()

        _batchSize = Parameters.Parameter.GetInt32Value("batchSize")
        _baseUrl = Parameters.Parameter.GetValue("baseUrl")
        _commandTimeout = Parameters.Parameter.GetInt32Value("commandTimeout")
        _connectionString = Parameters.Parameter.GetValue("connectionString")
        _createSession = Parameters.Parameter.GetValue("createSession")
        _hashTag = Parameters.Parameter.GetValue("hashTag")
        _messagingUrl = Parameters.Parameter.GetValue("messagingUrl")
        _moveToWork = Parameters.Parameter.GetValue("moveToWork")
        _deleteFromWork = Parameters.Parameter.GetValue("deleteFromWork")
        _loadSession = Parameters.Parameter.GetValue("loadSession")
        _loadUser = Parameters.Parameter.GetValue("loadUser")
        _questionPrefix1 = Parameters.Parameter.GetValue("questionPrefix1")
        _questionPrefix2 = Parameters.Parameter.GetValue("questionPrefix2")
        _savePending = Parameters.Parameter.GetValue("savePending")
        _twitterApiKey = Parameters.Parameter.GetValue("twitterApiKey")
        _twitterApiSecret = Parameters.Parameter.GetValue("twitterApiSecret")
        _twitterToken = Parameters.Parameter.GetValue("twitterToken")
        _twitterTokenSecret = Parameters.Parameter.GetValue("twitterTokenSecret")
        _tweetBody = Parameters.Parameter.GetValue("tweetBody")
        _viewTweets = Parameters.Parameter.GetValue("viewTweets")

    End Sub

    Protected Overrides Sub refreshParameters()

        _logProcedureStatitics = Parameters.Parameter.GetBooleanValue("logProcedureStatitics")
        _workCount = Parameters.Parameter.GetInt32Value("workCount")

    End Sub

#End Region

    Protected Overrides Sub process()

        Using connection As New Data.SqlClient.SqlConnection(_connectionString)

            connection.Open()

            If MyBase.IsAppActive() Then

                Me.moveToWork(connection)

            End If

            If MyBase.IsAppActive() Then

                Me.processTweets(connection)

            End If

            If MyBase.IsAppActive() Then

                'Me.deleteFromWork(connection)

            End If

        End Using

    End Sub

    Private Sub moveToWork( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using command As New SqlClient.SqlCommand(_moveToWork, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            command.Parameters.AddWithValue("@workCount", _workCount)

            command.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(_moveToWork, startTime)
        Me.logStatistics("moveToWork", startTime)

    End Sub

    Private Sub processTweets( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now, _
            questions As New System.Collections.Generic.List(Of Question)

        Using command As New SqlClient.SqlCommand(_viewTweets, connection),
            pending As New Data.DataTable("pending")

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = _commandTimeout

            pending.Columns.Add("twitterId")
            pending.Columns.Add("screenName")
            pending.Columns.Add("tweet")
            pending.Columns.Add("tweetId")
            pending.Columns.Add("tweetLatitude")
            pending.Columns.Add("tweetLongitude")
            pending.Columns.Add("tweetLocation")
            pending.Columns.Add("userLocation")
            pending.Columns.Add("region")
            pending.Columns.Add("latitude")
            pending.Columns.Add("longitude")

            Using tweets As Data.SqlClient.SqlDataReader = command.ExecuteReader()

                While (tweets.Read())

                    Dim twitterId As String = tweets("twitterId").ToString(),
                        screenName As String = tweets("screenName").ToString(),
                        tweet As String = tweets("tweet").ToString(),
                        tweetId As String = tweets("tweetId").ToString(),
                        tweetLatitude As Double = System.Convert.ToDouble(tweets("tweetLatitude")),
                        tweetLongitude As Double = System.Convert.ToDouble(tweets("tweetLongitude")),
                        tweetLocation As String = tweets("tweetLocation").ToString(),
                        userLocation As String = tweets("userLocation").ToString(),
                        latitude As Double,
                        longitude As Double,
                        region As String = "",
                        question As String = "",
                        post As Boolean = False

                    If tweet.ToLower.Contains(_hashTag) Then

                        'change this to a collection of prefixes
                        Dim strippedTweet As String = tweet.Replace(_hashTag, "") _
                                .Replace(_questionPrefix1, "") _
                                .Replace(_questionPrefix2, "") _
                                .Trim(),
                            location As String = ""

                        If strippedTweet.ToLower.Contains("@") Then

                            location = strippedTweet.Split("@"c)(1).Trim()

                            If getGeocode(location, latitude, longitude, region) Then

                                question = strippedTweet.Split("@"c)(0).Trim()
                                post = True

                            End If

                        End If

                        If Not post AndAlso tweetLatitude <> 0 AndAlso tweetLocation <> "" Then

                            If getGeocode(tweetLocation, latitude, longitude, region) Then

                                latitude = tweetLatitude
                                longitude = tweetLongitude
                                question = strippedTweet
                                post = True

                            End If

                        End If

                        If Not post AndAlso userLocation <> "" Then

                            If getGeocode(userLocation, latitude, longitude, region) Then

                                question = strippedTweet
                                post = True

                            End If

                        End If

                    Else

                        If tweetLatitude <> 0 AndAlso tweetLocation <> "" Then

                            If getGeocode(tweetLocation, latitude, longitude, region) Then

                                latitude = tweetLatitude
                                longitude = tweetLongitude

                            End If

                        End If

                        If userLocation <> "" Then

                            getGeocode(userLocation, latitude, longitude, region)

                        End If

                    End If

                    If post Then

                        questions.Add(New Question( twitterId, screenName, latitude, longitude, region, question))

                    Else

                        Dim pendingRow As Data.DataRow = pending.NewRow()
                        pendingRow("twitterId") = twitterId
                        pendingRow("screenName") = screenName
                        pendingRow("tweet") = tweet
                        pendingRow("tweetId") = tweetId
                        pendingRow("tweetLatitude") = tweetLatitude
                        pendingRow("tweetLongitude") = tweetLongitude
                        pendingRow("tweetLocation") = tweetLocation
                        pendingRow("userLocation") = userLocation
                        pendingRow("region") = region
                        pendingRow("latitude") = latitude
                        pendingRow("longitude") = longitude
                        pending.Rows.Add(pendingRow)

                    End If

                End While

            End Using

            saveQuestions(connection, questions)
            savePending(connection, pending, startTime)

        End Using

        Me.logProcedureStatistics(_viewTweets, startTime)
        Me.logStatistics("processTweets", startTime)

    End Sub

    Private Sub saveQuestions( _
        ByVal connection As Data.SqlClient.SqlConnection, _
        ByVal questions As System.Collections.Generic.List(Of Question))

        Dim startTime As System.DateTime = System.DateTime.Now

        For Each question As serverApp.Question In questions

            saveQuestion( connection, question)

        Next question

        Me.logStatistics("saveQuestions", startTime)

    End Sub

    Private Sub saveQuestion(
        connection As SqlClient.SqlConnection,
        question As serverApp.Question)

        Dim userId As String = "",
            sessionId As String = "",
            sessionKey As String = ""

        If loadUser(connection, question.twitterId, question.screenName, userId) Then

            loadSession(connection, userId, sessionId, sessionKey)

            Dim message As String = String.Join("~", question.latitude, question.longitude, question.region, question.question),
                url As String = String.Concat(_baseUrl, _messagingUrl),
                hmac As New Cryptography.HMACSHA1(UTF8.GetBytes(sessionKey)),
                digest As String = toBase64UrlString(
                    System.Convert.ToBase64String(hmac.ComputeHash(UTF8.GetBytes(String.Concat(_messagingUrl, sessionId))))),
                session As String = String.Join(":", sessionId, digest),
                web As New Net.WebClient()

            web.Headers.Add("x-session", session)
            Dim post As String = web.UploadString(url, message)

            repostQuestion(question)

        End If

    End Sub

    Private Sub repostQuestion( _
        question As serverApp.Question)

        Dim startTime As System.DateTime = System.DateTime.Now

        Dim questionId As String = actions("questionId").ToString(),
            latitude As Double = System.Convert.ToDouble(actions("latitude")),
            longitude As Double = System.Convert.ToDouble(actions("longitude")),
            link As String = String.Format(_questionUrl, questionId),
            body As String = String.Format(_twitterBody, question.twitterId, actions("body").ToString(), link),
            tokens As New Twitterizer.OAuthTokens(),
            options As New Twitterizer.StatusUpdateOptions

        tokens.AccessToken = _twitterToken
        tokens.AccessTokenSecret = _twitterTokenSecret
        tokens.ConsumerKey = _twitterApiKey
        tokens.ConsumerSecret = _twitterApiSecret

        options.Latitude = latitude
        options.Longitude = longitude

        Dim response As Twitterizer.TwitterResponse(Of Twitterizer.TwitterStatus) _
                = Twitterizer.TwitterStatus.Update(tokens, body, options)

        If response.Result = Twitterizer.RequestResult.Success Then

            'save post id

        End If

        Me.logStatistics("repostQuestion", startTime)

    End Sub


    Private Function loadUser(
        connection As SqlClient.SqlConnection,
        twitterId As String,
        screenName As String,
        ByRef userId As String) As Boolean

        Dim returnValue As Boolean = False

        Using load As New SqlClient.SqlCommand(_loadUser, connection)

            load.CommandType = CommandType.StoredProcedure
            load.CommandTimeout = _commandTimeout

            load.Parameters.AddWithValue("@twitterId", twitterId)
            load.Parameters.AddWithValue("@username", screenName)
            load.Parameters.Add("@userId", SqlDbType.Int).Direction = ParameterDirection.Output
            load.Parameters.Add("@enabled", SqlDbType.Int).Direction = ParameterDirection.Output

            load.ExecuteNonQuery()

            If CBool(load.Parameters("@enabled").Value) Then

                userId = load.Parameters("@userId").Value.ToString()
                returnValue = True

            End If

        End Using

        Return returnValue

    End Function

    Private Sub loadSession(
        connection As SqlClient.SqlConnection,
        userId As String,
        ByRef sessionId As String,
        ByRef sessionKey As String)

        Using load As New SqlClient.SqlCommand(_loadSession, connection),
            create As New SqlClient.SqlCommand(_createSession, connection)

            load.CommandType = CommandType.StoredProcedure
            load.CommandTimeout = _commandTimeout

            load.Parameters.AddWithValue("@userId", userId)
            load.Parameters.Add("@sessionId", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output
            load.Parameters.Add("@sessionKey", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output

            load.ExecuteNonQuery()

            If load.Parameters("@sessionId").Value.ToString() <> "" Then

                sessionId = load.Parameters("@sessionId").Value.ToString()
                sessionKey = load.Parameters("@sessionKey").Value.ToString()

            Else

                create.CommandType = CommandType.StoredProcedure
                create.CommandTimeout = _commandTimeout

                create.Parameters.AddWithValue("@userId", userId)
                create.Parameters.Add("@sessionId", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output
                create.Parameters.Add("@sessionKey", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output

                create.ExecuteNonQuery()

                sessionId = create.Parameters("@sessionId").Value.ToString()
                sessionKey = create.Parameters("@sessionKey").Value.ToString()

            End If

        End Using

    End Sub

    Private Sub savePending( _
        ByVal connection As Data.SqlClient.SqlConnection, _
        ByVal pending As Data.DataTable,
        ByVal startTime As System.DateTime)

        If pending.Rows.Count > 0 Then

            Using command As New SqlClient.SqlCommand(_savePending, connection)

                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = _commandTimeout
                command.UpdatedRowSource = UpdateRowSource.None

                command.Parameters.Add(New SqlClient.SqlParameter("@twitterId", Data.SqlDbType.VarChar, 20, "twitterId"))
                command.Parameters.Add(New SqlClient.SqlParameter("@screenName", Data.SqlDbType.VarChar, 200, "screenName"))
                command.Parameters.Add(New SqlClient.SqlParameter("@tweet", Data.SqlDbType.VarChar, 256, "tweet"))
                command.Parameters.Add(New SqlClient.SqlParameter("@tweetId", Data.SqlDbType.VarChar, 100, "tweetId"))
                command.Parameters.Add(New SqlClient.SqlParameter("@tweetLatitude", Data.SqlDbType.Decimal, 0, "tweetLatitude"))
                command.Parameters.Add(New SqlClient.SqlParameter("@tweetLongitude", Data.SqlDbType.Decimal, 0, "tweetLongitude"))
                command.Parameters.Add(New SqlClient.SqlParameter("@tweetLocation", Data.SqlDbType.VarChar, 256, "tweetLocation"))
                command.Parameters.Add(New SqlClient.SqlParameter("@userLocation", Data.SqlDbType.VarChar, 256, "userLocation"))
                command.Parameters.Add(New SqlClient.SqlParameter("@region", Data.SqlDbType.VarChar, 100, "region"))
                command.Parameters.Add(New SqlClient.SqlParameter("@latitude", Data.SqlDbType.Decimal, 0, "latitude"))
                command.Parameters.Add(New SqlClient.SqlParameter("@longitude", Data.SqlDbType.Decimal, 0, "longitude"))

                Using adapter As New Data.SqlClient.SqlDataAdapter()

                    adapter.UpdateBatchSize = _batchSize
                    adapter.InsertCommand = command

                    adapter.Update(pending)

                End Using

                Me.logProcedureStatistics(_savePending, startTime)

            End Using

        End If

    End Sub

    Private Sub deleteFromWork( _
        ByVal connection As Data.SqlClient.SqlConnection)

        Dim startTime As System.DateTime = System.DateTime.Now

        Using delete As New SqlClient.SqlCommand(_deleteFromWork, connection)

            delete.CommandType = CommandType.StoredProcedure
            delete.CommandTimeout = _commandTimeout

            delete.ExecuteNonQuery()

        End Using

        Me.logProcedureStatistics(_deleteFromWork, startTime)
        Me.logStatistics("deleteFromWork", startTime)

    End Sub

    Private Function toBase64UrlString(
        base64String As String) As String

        Return base64String.Replace("+"c, "-"c).Replace("/"c, "_"c).Replace("=", "")

    End Function

    Private Function getGeocode(
        location As String,
        ByRef latitude As Double,
        ByRef longitude As Double,
        ByRef region As String) As Boolean

        Dim url As String = GOOGLE_GEOCODE_URL.Replace("%1", location),
            json As String = New Net.WebClient().DownloadString(url),
            returnValue As Boolean = False

        Dim serializer As New Web.Script.Serialization.JavaScriptSerializer,
            jsonObject As System.Collections.Generic.Dictionary(Of String, Object) =
                DirectCast(serializer.DeserializeObject(json), System.Collections.Generic.Dictionary(Of String, Object))

        If jsonObject("status").ToString() = "OK" Then

            Dim resultObjects() As Object = DirectCast(jsonObject("results"), Object())

            For Each resultObject As System.Collections.Generic.Dictionary(Of String, Object) In resultObjects

                If region = "" Then

                    Dim geometry As Object = resultObject("geometry"),
                        formattedAddress As String = resultObject("formatted_address").ToString()

                    If geometry IsNot Nothing Then

                        Dim geomeryObject As System.Collections.Generic.Dictionary(Of String, Object) =
                                DirectCast(geometry, System.Collections.Generic.Dictionary(Of String, Object)),
                            geoLocation As Object = geomeryObject("location")

                        If geoLocation IsNot Nothing Then

                            Dim geoLocationObject As System.Collections.Generic.Dictionary(Of String, Object) =
                                    DirectCast(geoLocation, System.Collections.Generic.Dictionary(Of String, Object))

                            region = resultObject("formatted_address").ToString()
                            Double.TryParse(geoLocationObject("lat").ToString, latitude)
                            Double.TryParse(geoLocationObject("lng").ToString, longitude)

                            returnValue = True

                        End If

                    End If

                End If

            Next resultObject

        End If

        Return returnValue

    End Function

    Private Sub logStatistics( _
            ByVal description As String, _
            ByVal startTime As DateTime)

        Dim stopTime As DateTime
        Dim time As String
        Dim log As String

        stopTime = System.DateTime.Now
        time = System.Convert.ToString(stopTime.Subtract(startTime).TotalSeconds)

        log = "{0}: {1}"
        log = String.Format(log, description, time)
        MyBase.Log(log, Diagnostics.EventLogEntryType.Information)

        Diagnostics.Debug.WriteLine(log)

    End Sub

    Private Sub logProcedureStatistics( _
        ByVal procedure As String, _
        ByVal startTime As DateTime)

        Dim stopTime As DateTime
        Dim time As String
        Dim log As String

        If _logProcedureStatitics Then

            stopTime = DateTime.Now()
            time = System.Convert.ToString(stopTime.Subtract(startTime).TotalSeconds)

            log = String.Format("procedure: {0}, time: {1}", procedure, time)
            MyBase.Log(log, Diagnostics.EventLogEntryType.Information)

            Diagnostics.Debug.WriteLine(log)

        End If

    End Sub

    Private Function jsonEncode(
        json As String) As String

        Return json _
            .Replace("&", "&amp;") _
            .Replace("\", "&#92;") _
            .Replace("""", "\""") _
            .Replace("<", "&lt;") _
            .Replace(">", "&gt;")

    End Function

#End Region


End Class




