#Region "options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region "imports "

Imports System.Data
Imports Utility

#End Region

Public Class serverApp : Inherits Utility.ServerAppBase.ServerAppBase

    Private _batchSize As Int32,
        _commandTimeout As Int32,
        _connectionString As String,
        _logProcedureStatitics As Boolean,
        _streaming As Boolean = False,
        _twitterApiKey As String,
        _twitterApiSecret As String,
        _twitterToken As String,
        _twitterTokenSecret As String,
        _userAgent As String,
        _hashTag As String,
        _tokens As Twitterizer.OAuthTokens,
        _streamOptions As Twitterizer.Streaming.StreamOptions,
        _stream As Twitterizer.Streaming.TwitterStream,
        _connection As Data.SqlClient.SqlConnection

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
        _commandTimeout = Parameters.Parameter.GetInt32Value("commandTimeout")
        _connectionString = Parameters.Parameter.GetValue("connectionString")
        _userAgent = Parameters.Parameter.GetValue("userAgent")
        _hashTag = Parameters.Parameter.GetValue("hashTag")
        _twitterApiKey = Parameters.Parameter.GetValue("twitterApiKey")
        _twitterApiSecret = Parameters.Parameter.GetValue("twitterApiSecret")
        _twitterToken = Parameters.Parameter.GetValue("twitterToken")
        _twitterTokenSecret = Parameters.Parameter.GetValue("twitterTokenSecret")

        _tokens = New Twitterizer.OAuthTokens()
        _tokens.ConsumerKey = _twitterApiKey
        _tokens.ConsumerSecret = _twitterApiSecret
        _tokens.AccessToken = _twitterToken
        _tokens.AccessTokenSecret = _twitterTokenSecret

        _streamOptions = New Twitterizer.Streaming.StreamOptions()
        _streamOptions.Track.Add("#urbanask")
        _streamOptions.Track.Add("where can I find")
        _streamOptions.Track.Add("where can I get")
        _streamOptions.Track.Add("where can I buy")
        _streamOptions.Track.Add("where can I eat")
        _streamOptions.Track.Add("where I can find")
        _streamOptions.Track.Add("where I can get")
        _streamOptions.Track.Add("where I can buy")
        _streamOptions.Track.Add("where I can eat")

    End Sub

    Protected Overrides Sub refreshParameters()

        _logProcedureStatitics = Parameters.Parameter.GetBooleanValue("logProcedureStatitics")

    End Sub

#End Region

    Protected Overrides Sub process()

        If MyBase.IsAppActive() Then

            Me.processTwitterStream()

        End If

    End Sub

    Private Sub processTwitterStream()

        If Not _streaming Then

            Dim startTime As System.DateTime = System.DateTime.Now

            _stream = New Twitterizer.Streaming.TwitterStream(_tokens, _userAgent, _streamOptions)
            _stream.StartUserStream(
                AddressOf init,
                AddressOf stopped,
                AddressOf newTweet,
                AddressOf deletedTweet,
                AddressOf newDirectMessage,
                AddressOf deletedDirectMessage,
                AddressOf otherEvent,
                AddressOf rawJson
                )
            _streaming = True

            Me.logStatistics("processTwitterStream", startTime)

        End If

    End Sub

    Private Sub init(friends As Twitterizer.TwitterIdCollection)

    End Sub

    Private Sub stopped(reason As Twitterizer.Streaming.StopReasons)

        _streaming = False

    End Sub

    Private Sub newTweet(tweet As Twitterizer.TwitterStatus)

        Dim twitterId As String = "",
            screenName As String = "",
            message As String = tweet.Text,
            tweetId As String = "",
            tweetLatitude As String = "",
            tweetLongitude As String = "",
            tweetLocation As String = "",
            userLocation As String = ""

        If (Not IsNothing(tweet.Geo)) AndAlso (tweet.Geo.Coordinates.Count > 0) Then

            tweetLatitude = tweet.Geo.Coordinates(0).Latitude.ToString()
            tweetLongitude = tweet.Geo.Coordinates(0).Longitude.ToString()

        End If

        If (Not IsNothing(tweet.Place)) AndAlso (tweet.Place.FullName <> "") Then

            tweetLocation = tweet.Place.FullName

        End If

        If (Not IsNothing(tweet.User.Location)) AndAlso (tweet.User.Location <> "") Then

            userLocation = tweet.User.Location

        End If

        If tweetLatitude <> "" Or tweetLocation <> "" Or userLocation <> "" Or message.ToLower.IndexOf(_hashTag) > -1 Then

            twitterId = tweet.User.Id.ToString()
            screenName = tweet.User.ScreenName
            tweetId = tweet.Id.ToString()

            initializeConnection()

            Using saveMessage As New SqlClient.SqlCommand(_saveError, _connection)

                errorCommand.CommandType = CommandType.StoredProcedure
                errorCommand.CommandTimeout = _commandTimeout
                errorCommand.UpdatedRowSource = UpdateRowSource.None

                errorCommand.Parameters.Add(New SqlClient.SqlParameter("@notificationId", Data.SqlDbType.Int, 0, "notificationId"))
                errorCommand.Parameters.Add(New SqlClient.SqlParameter("@description", Data.SqlDbType.VarChar, 255, "description"))
                errorCommand.Parameters.Add(New SqlClient.SqlParameter("@error", Data.SqlDbType.VarChar, 255, "error"))

                Using adapter As New Data.SqlClient.SqlDataAdapter()

                    adapter.UpdateBatchSize = _batchSize
                    adapter.InsertCommand = errorCommand

                    adapter.Update(errors)

                End Using

                Me.logProcedureStatistics(_saveError, startTime)

            End Using

            Console.WriteLine(String.Format("New tweet: @{0}: {1}", screenName, message))

        End If

    End Sub

    Private Sub deletedTweet(deletedEvent As Twitterizer.Streaming.TwitterStreamDeletedEvent)

    End Sub

    Private Sub newDirectMessage(message As Twitterizer.TwitterDirectMessage)

    End Sub

    Private Sub deletedDirectMessage(deletedEvent As Twitterizer.Streaming.TwitterStreamDeletedEvent)

    End Sub

    Private Sub otherEvent(streamEvent As Twitterizer.Streaming.TwitterStreamEvent)

    End Sub

    Private Sub rawJson(jsong As String)

    End Sub

    Private Sub initializeConnection()

        If IsNothing(_connection) Then

            _connection = New Data.SqlClient.SqlConnection(_connectionString)

        End If

        If _connection.State <> ConnectionState.Open Then

            _connection.Open()

        End If

    End Sub

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
            time = Convert.ToString(stopTime.Subtract(startTime).TotalSeconds)

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

    Protected Overrides Sub Finalize()

        _stream.EndStream(Twitterizer.Streaming.StopReasons.StoppedByRequest, "manually shutting down application")
        _connection.Close()
        _connection.Dispose()

    End Sub

#End Region


End Class




