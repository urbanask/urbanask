#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System.Data
Imports Microsoft.VisualBasic

#End Region

Public Class simpleGeo

    Const BASE_URL As String = "http://api.simplegeo.com"
    Const SIGNATURE_METHOD As String = "HMAC-SHA1"
    Const OAUTH_VERSION As String = "1.0"

    Private ReadOnly _consumerKey As String
    Private ReadOnly _consumerSecret As String

    Public Enum contextFilters

        query
        features
        weather
        address
        demographics
        intersections

    End Enum

    Public Sub New(
        consumerKey As String,
        consumerSecret As String)

        _consumerKey = consumerKey
        _consumerSecret = consumerSecret

    End Sub

    Public Function places(
        latitude As Double,
        longitude As Double,
        Optional options As String = "") As String

        If latitude < -90 AndAlso latitude > 90 Then

            Throw New System.ArgumentOutOfRangeException("latitude", latitude, "Must be between -90 and 90.")

        ElseIf longitude < -180 AndAlso longitude > 180 Then

            Throw New System.ArgumentOutOfRangeException("longitude", longitude, "Must be between -180 and 180.")

        Else

            Return sendRequest("GET", "/1.2/places", String.Concat("/", latitude, ",", longitude), options)

        End If

    End Function

    Public Function layers(
        Optional options As String = "") As String

        Return sendRequest("GET", "/0.1/layers", "", options)

    End Function

    Public Function features(
        handle As String) As String

        If handle.StartsWith("SG") Then

            Return sendRequest("GET", "/1.0/features", String.Concat("/", handle))

        Else

            Return sendRequest("GET", "/1.2/features", String.Concat("/", handle))

        End If

    End Function

    Public Function context(
        latitude As Double,
        longitude As Double,
        Optional options As String = "") As String

        If latitude < -90 AndAlso latitude > 90 Then

            Throw New System.ArgumentOutOfRangeException("latitude", latitude, "Must be between -90 and 90.")

        ElseIf longitude < -180 AndAlso longitude > 180 Then

            Throw New System.ArgumentOutOfRangeException("longitude", longitude, "Must be between -180 and 180.")

        Else

            Return sendRequest("GET", "/1.0/context", String.Concat("/", latitude, ",", longitude), options)

        End If

    End Function

    Public Function context(
        swLatitude As Double,
        swLongitude As Double,
        neLatitude As Double,
        neLongitude As Double,
        Optional options As String = "") As String

        If swLatitude < -90 AndAlso swLatitude > 90 Then

            Throw New System.ArgumentOutOfRangeException("swLatitude", swLatitude, "Must be between -90 and 90.")

        ElseIf swLongitude < -180 AndAlso swLongitude > 180 Then

            Throw New System.ArgumentOutOfRangeException("swLongitude", swLongitude, "Must be between -180 and 180.")

        ElseIf neLatitude < -90 AndAlso neLatitude > 90 Then

            Throw New System.ArgumentOutOfRangeException("neLatitude", neLatitude, "Must be between -90 and 90.")

        ElseIf neLongitude < -180 AndAlso swLongitude > 180 Then

            Throw New System.ArgumentOutOfRangeException("neLongitude", neLongitude, "Must be between -180 and 180.")

        Else

            Dim resource As String = String.Concat("/", swLatitude, ",", swLongitude, ",", neLatitude, ",", neLongitude)

            Return sendRequest("GET", "/1.0/context", resource, options)

        End If

    End Function

    Public Function context(
        addressLine1 As String,
        city As String,
        state As String,
        zip As String,
        Optional options As String = "") As String

        Dim address As String = String.Concat("address=""", addressLine1, ", ", city, ", ", state, ", ", zip, """").Replace(" "c, "+"c)
        options = String.Concat(address, IIf(options = "", "", "&" & options))

        Return sendRequest("GET", "/1.0/context", "/address", options)

    End Function

    Public Function context() As String

        Return sendRequest("GET", "/1.0/context", "/ip")

    End Function

    Public Function context(
        ip As String) As String

        Return sendRequest("GET", "/1.0/context", "/" & ip)

    End Function

    Private Function sendRequest(
        method As String,
        endpoint As String,
        Optional resource As String = "",
        Optional options As String = "") As String

        Dim baseUri As String = String.Concat(
            BASE_URL,
            endpoint,
            resource,
            ".json")
        Dim uri As String = String.Concat(
            baseUri,
            IIf(options = "", "", "?" & options))
        Dim timestamp As Int64 = Convert.ToInt64(DateTime.Now.Subtract(#1/1/1970#).TotalSeconds)
        Dim nonce As String = String.Concat(
            timestamp,
            New System.Random().Next(1000, 9999))
        Dim signature As String = Me.signature(method, baseUri, timestamp, nonce, options)
        Dim oauth As String = String.Concat(
            "OAuth oauth_consumer_key=""", _consumerKey,
            """,oauth_nonce=""", nonce,
            """,oauth_signature_method=""", SIGNATURE_METHOD,
            """,oauth_timestamp=""", timestamp,
            """,oauth_version=""", OAUTH_VERSION,
            """,oauth_signature=""", signature, """")

        Dim oauthRequest As Net.HttpWebRequest = CType(Net.WebRequest.Create(uri), Net.HttpWebRequest)
        oauthRequest.Method = method
        oauthRequest.Headers.Add(Net.HttpRequestHeader.Authorization, oauth)

        Using response As Net.HttpWebResponse = CType(oauthRequest.GetResponse(), Net.HttpWebResponse),
            responseStream As IO.Stream = response.GetResponseStream(),
            streamReader As IO.StreamReader = New IO.StreamReader(responseStream)

            Return streamReader.ReadToEnd()

        End Using

    End Function

    Private Function signature(
        method As String,
        baseUri As String,
        timestamp As Int64,
        nonce As String,
        options As String) As String

        If options <> "" Then

            Dim splitAmp() As String = options.Split("&"c)

            For index As Int32 = 0 To splitAmp.Length - 1

                Dim splitEq() As String = splitAmp(index).Split("="c)
                splitEq(1) = urlEncode(splitEq(1))
                splitAmp(index) = String.Join("=", splitEq)

            Next index

            options = String.Concat(String.Join("&", splitAmp), "&")

        End If

        Dim parameters As String = String.Concat(
            options,
            "oauth_consumer_key=", _consumerKey,
            "&oauth_nonce=", nonce,
            "&oauth_signature_method=", SIGNATURE_METHOD,
            "&oauth_timestamp=", timestamp,
            "&oauth_version=", OAUTH_VERSION)
        Dim signatureBaseString As String = String.Concat(
            method, "&",
            urlEncode(baseUri), "&",
            urlEncode(parameters))
        Dim key As String = String.Concat(_consumerSecret, "&")
        Dim hmac As New Security.Cryptography.HMACSHA1(Text.Encoding.UTF8.GetBytes(key))
        Dim hash() As Byte = hmac.ComputeHash(Text.Encoding.UTF8.GetBytes(signatureBaseString))

        Return Web.HttpUtility.UrlEncode(Convert.ToBase64String(hash))

    End Function

    Private Function urlEncode(data As String) As String

        Return data.
            Replace(":", "%3A").
            Replace("/", "%2F").
            Replace(",", "%2C").
            Replace("=", "%3D").
            Replace("&", "%26").
            Replace("""", "%34").
            Replace("+", "%43")

    End Function

End Class

