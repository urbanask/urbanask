#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System.Data
Imports System.Web
Imports System.Security
Imports System.Text.Encoding

#End Region

Public Class sms : Implements System.Web.IHttpHandler

#Region " constants "

#If CONFIG = "Release" Then

    Private Const CONNECTION_STRING As String = "Server=WIN-FKVLOOSI1RO;Database=Gabs;uid=api;pwd=firsttimeforlettuce;Connect Timeout=600;",
        BASE_URL As String = "http://urbanask.com"

#Else

    Private Const CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=api;pwd=firsttimeforlettuce;Connect Timeout=600;",
        BASE_URL As String = "http://75.144.228.69:55555"

#End If

    Private Const COMMAND_TIMEOUT As Int32 = 60,
        CHECK_PHONE_NUMBER As String = "Gabs.api.checkPhoneNumber",
        VERIFY_PHONE_NUMBER As String = "Gabs.api.verifyPhoneNumber",
        LOAD_SESSION As String = "session.login.loadSession",
        CREATE_SESSION As String = "session.login.createSession",
        GOOGLE_MAPS_URL As String = "http://maps.googleapis.com/maps/api/geocode/json?address=%1&sensor=false",
        MESSAGING_URL As String = "/messaging/questions"

#End Region

    Sub ProcessRequest(ByVal context As Web.HttpContext) _
        Implements IHttpHandler.ProcessRequest

        Dim params As Collections.Specialized.NameValueCollection = context.Request.Params,
            body As String = params("Body")

        Select Case body.ToUpper()
            Case "STOP", "QUIT"

            Case "START"

            Case "HELP"

            Case "VERIFY"

                verifyNumber(context, params)

            Case Else

                saveQuestion(context, params, body)

        End Select

    End Sub

    Private Sub saveQuestion(
        context As Web.HttpContext,
        params As Collections.Specialized.NameValueCollection,
        body As String)

        Dim phoneNumber As String = params("From"),
            userId As String = "",
            question As String = If(body.Contains("@"), body.Split("@"c)(0).Trim(), body),
            latitude As String = "",
            longitude As String = "",
            region As String = "",
            sessionId As String = "",
            sessionKey As String = ""

        Using connection As New System.Data.SqlClient.SqlConnection(CONNECTION_STRING)

            connection.Open()

            If checkPhoneNumber(context, connection, phoneNumber, userId) Then

                If checkLocation(context, params, body, latitude, longitude, region) Then

                    loadSession(connection, userId, sessionId, sessionKey)

                    Dim message As String = String.Join("~", latitude, longitude, region, question),
                        url As String = String.Concat(BASE_URL, MESSAGING_URL),
                        hmac As New Cryptography.HMACSHA1(UTF8.GetBytes(sessionKey)),
                        digest As String = toBase64UrlString(
                            System.Convert.ToBase64String(hmac.ComputeHash(UTF8.GetBytes(String.Concat(MESSAGING_URL, sessionId))))),
                        session As String = String.Join(":", sessionId, digest),
                        web As New Net.WebClient()

                    web.Headers.Add("x-session", session)
                    Dim post As String = web.UploadString(url, message)

                    sendResponse(context, "Your question has been posted!")

                End If

            End If

        End Using

        'check users' default location

    End Sub

    Private Sub verifyNumber(
        context As Web.HttpContext,
        params As Collections.Specialized.NameValueCollection)

        Dim phoneNumber As String = params("From")

        Using connection As New System.Data.SqlClient.SqlConnection(CONNECTION_STRING),
            command As New SqlClient.SqlCommand(VERIFY_PHONE_NUMBER, connection)

            connection.Open()

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@phoneNumber", phoneNumber)
            command.Parameters.Add("@success", SqlDbType.Int).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If command.Parameters("@success").Value.ToString() = "1" Then

                sendResponse(context, String.Concat(
                    "Your number, ",
                    phoneNumber,
                    ", has been verified. You can now text questions to urbanAsk."))

            Else

                sendResponse(context, String.Concat(
                    "Your mobile number, ",
                    phoneNumber,
                    ", is not recognized. ",
                    "Login to urbanAsk and add your number to your account."))

            End If

        End Using

    End Sub

    Private Sub loadSession(
        connection As SqlClient.SqlConnection,
        userId As String,
        ByRef sessionId As String,
        ByRef sessionKey As String)

        Using load As New SqlClient.SqlCommand(LOAD_SESSION, connection),
            create As New SqlClient.SqlCommand(CREATE_SESSION, connection)

            load.CommandType = CommandType.StoredProcedure
            load.CommandTimeout = COMMAND_TIMEOUT

            load.Parameters.AddWithValue("@userId", userId)
            load.Parameters.Add("@sessionId", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output
            load.Parameters.Add("@sessionKey", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output

            load.ExecuteNonQuery()

            If load.Parameters("@sessionId").Value.ToString() <> "" Then

                sessionId = load.Parameters("@sessionId").Value.ToString()
                sessionKey = load.Parameters("@sessionKey").Value.ToString()

            Else

                create.CommandType = CommandType.StoredProcedure
                create.CommandTimeout = COMMAND_TIMEOUT

                create.Parameters.AddWithValue("@userId", userId)
                create.Parameters.Add("@sessionId", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output
                create.Parameters.Add("@sessionKey", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output

                create.ExecuteNonQuery()

                sessionId = create.Parameters("@sessionId").Value.ToString()
                sessionKey = create.Parameters("@sessionKey").Value.ToString()

            End If

        End Using

    End Sub

    Private Function toBase64UrlString(
        base64String As String) As String

        Return base64String.Replace("+"c, "-"c).Replace("/"c, "_"c).Replace("=", "")

    End Function

    Private Function checkPhoneNumber(
        context As Web.HttpContext,
        connection As SqlClient.SqlConnection,
        phoneNumber As String,
        ByRef userId As String) As Boolean

        Dim returnValue As Boolean = False

        Using command As New SqlClient.SqlCommand(CHECK_PHONE_NUMBER, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@phoneNumber", phoneNumber)
            command.Parameters.Add("@userId", SqlDbType.Int).Direction = ParameterDirection.Output
            command.Parameters.Add("@verified", SqlDbType.Int).Direction = ParameterDirection.Output
            command.Parameters.Add("@stop", SqlDbType.Int).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            If command.Parameters("@userId").Value.ToString() = "0" Then

                sendResponse(context, String.Concat(
                    "Your mobile number, ", phoneNumber, ", is not recognized. ",
                    "Login to urbanAsk and add your number to your account."))

            ElseIf command.Parameters("@verified").Value.ToString() = "0" Then

                sendResponse(context, String.Concat(
                    "Your mobile number, ", phoneNumber, ", is not verified. ",
                    "Respond with VERIFY and then resend your question."))

            ElseIf command.Parameters("@stop").Value.ToString() = "1" Then

                sendResponse(context, String.Concat(
                    "Your mobile number, ", phoneNumber, ", is set to ignore messages from urbanAsk. ",
                    "To activate your number respond with START."))

            Else

                userId = command.Parameters("@userId").Value.ToString()
                returnValue = True

            End If

        End Using

        Return returnValue

    End Function

    Private Function checkLocation(
        context As Web.HttpContext,
        params As Collections.Specialized.NameValueCollection,
        body As String,
        ByRef latitude As String,
        ByRef longitude As String,
        ByRef region As String) As Boolean

        Dim returnValue As Boolean = False,
            location As String = ""

        If body.Contains("@") Then

            location = body.Split("@"c)(1).Trim()

        ElseIf params("FromZip") <> "" Then

            location = params("FromZip")

        ElseIf params("FromCity") <> "" Then

            location = params("FromCity")

        End If

        If location <> "" Then

            If getGeocode(location, latitude, longitude, region) Then

                returnValue = True

            Else

                sendResponse(context, String.Concat(
                    """", location, """ is not recognized. ",
                    "Format: question @ location. Location is a postal code, city or neighborhood. ",
                    "Ex: tacos @ 95814"))

            End If

        Else

            sendResponse(context, String.Concat(
                "Add a location. ",
                "Format: question @ location. Location is a postal code, city or neighborhood. ",
                "Ex: tacos @ 95814"))

        End If

        Return returnValue

    End Function

    Private Function getGeocode(
        location As String,
        ByRef latitude As String,
        ByRef longitude As String,
        ByRef region As String) As Boolean

        Dim url As String = GOOGLE_MAPS_URL.Replace("%1", location),
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
                            latitude = geoLocationObject("lat").ToString()
                            longitude = geoLocationObject("lng").ToString()

                            returnValue = True

                        End If

                    End If

                End If

            Next resultObject

        End If

        Return returnValue

    End Function

    Private Sub sendResponse(
        context As Web.HttpContext,
        response As String)

        context.Response.Headers.Remove("Server")
        context.Response.Headers.Add("Content-Length", response.Length.ToString())
        context.Response.ContentType = "text/plain"

        'context.Response.Write("<?xml version=""1.0"" encoding=""UTF-8""?>")
        'context.Response.Write("<Response>")
        'context.Response.Write("<Sms>")
        context.Response.Write(response)
        'context.Response.Write("</Sms>")
        'context.Response.Write("</Response>")

    End Sub

    ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return True
        End Get
    End Property

    Private Class Data
        Dim results As Array
        Dim status As String
    End Class

End Class


