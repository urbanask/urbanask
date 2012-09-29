#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "
Imports System.Data

#End Region

Public MustInherit Class messageHandler : Implements System.Web.IHttpHandler

#Region "constants"

#If CONFIG = "Release" Then

    Protected Const CONNECTION_STRING As String = "Server=WIN-FKVLOOSI1RO;Database=Gabs;uid=api;pwd=firsttimeforlettuce;Connect Timeout=600;"

#Else

    Protected Const CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=api;pwd=firsttimeforlettuce;Connect Timeout=600;"

#End If

    Protected Const COMMAND_TIMEOUT As Int32 = 60,
        SAVE_LOG As String = "Gabs.api.saveLog"

#End Region

    Protected MustOverride Function isValid(
        context As Web.HttpContext,
        request As String) As Boolean
    Protected MustOverride Function isAuthorized(
        context As Web.HttpContext,
        ByRef userId As Int32) As Boolean
    Protected MustOverride Sub process(
        connection As System.Data.SqlClient.SqlConnection,
        context As Web.HttpContext,
        request As String,
        userId As Int32)

    Public Sub ProcessRequest(
        context As Web.HttpContext) _
        Implements System.Web.IHttpHandler.ProcessRequest

        Dim userId As Integer

        If isAuthorized(context, userId) Then

            Dim request As String = getRequest(context),
                queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

            If userId = 0 Then

                Int32.TryParse(queries("currentUserId"), userId)

            End If

            If isValid(context, request) Then

                Using connection As New Data.SqlClient.SqlConnection(CONNECTION_STRING)

                    connection.Open()
                    process(connection, context, request, userId)
                    saveLog(connection, context, request, userId)

                End Using

            Else

                sendErrorResponse(context, 415, "Unsupported Media Type")

            End If

        Else

            sendErrorResponse(context, 401, "Unauthorized")

        End If

    End Sub

    Private Sub saveLog( _
        connection As System.Data.SqlClient.SqlConnection,
        context As Web.HttpContext,
        request As String,
        userId As Int32)

        Using command As New SqlClient.SqlCommand(SAVE_LOG, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@userId", userId)
            command.Parameters.AddWithValue("@path", context.Request.Path)
            command.Parameters.AddWithValue("@query", context.Request.Url.Query)
            command.Parameters.AddWithValue("@request", request)
            command.Parameters.AddWithValue("@ipAddress", context.Request.UserHostAddress)

            command.ExecuteNonQuery()

        End Using

    End Sub

    Public ReadOnly Property IsResusable As Boolean _
        Implements System.Web.IHttpHandler.IsReusable

        Get

            Return True

        End Get

    End Property

    Public Function parameters( _
        context As Web.HttpContext,
        parameter As String) As String

        Dim value As String = ""

        If context.Request.Headers.Item("x-session") IsNot Nothing Then
            ' context.Request.Params
            ' session = context.Request.Headers("x-session").Split(":"c)

        End If

        If value = "" Then

            If context.Request.QueryString("x-session") IsNot Nothing Then

                value = Web.HttpUtility.UrlDecode(context.Request.QueryString("x-session")).Split(":"c)(0)

            End If

        End If

        Return value

    End Function

    Private Function getRequest(
        context As Web.HttpContext) As String

        If context.Request.ContentLength = 0 Then

            Return ""

        Else

            Return System.Text.Encoding.UTF8.GetString(context.Request.BinaryRead(context.Request.ContentLength))

        End If

    End Function

    Protected Sub sendSuccessResponse(
        context As Web.HttpContext,
        Optional response As String = "")

        context.Response.Headers.Remove("Server")

        If response <> "" Then

            context.Response.Headers.Add("Content-Length", response.Length.ToString())

#If CONFIG <> "Debug" Then

            ' context.Response.ContentType = "application/json"

#End If

            context.Response.Write(response)

        End If

    End Sub

    Protected Sub sendErrorResponse(
        context As Web.HttpContext,
        errorNumber As Int32,
        errorMessage As String)

        context.Response.StatusCode = errorNumber
        context.Response.StatusDescription = errorMessage
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

'Dim response As Web.HttpResponse = context.Response

'response.Write("<div>url.absoluteuri: " & context.Request.Url.AbsoluteUri & "</div>")
'response.Write("<div>Url.Host: " & context.Request.Url.Host & "</div>")

'response.Write("<div>AppRelativeCurrentExecutionFilePath:" & context.Request.AppRelativeCurrentExecutionFilePath & "</div>")
'response.Write("<div>CurrentExecutionFilePath:" & context.Request.CurrentExecutionFilePath & "</div>")
'response.Write("<div>CurrentExecutionFilePathExtension:" & context.Request.CurrentExecutionFilePathExtension & "</div>")
'response.Write("<div>FilePath:" & context.Request.FilePath & "</div>")
'response.Write("<div>Path:" & context.Request.Path & "</div>")
'response.Write("<div>PathInfo:" & context.Request.PathInfo & "</div>")
'response.Write("<div>RawUrl:" & context.Request.RawUrl & "</div>")
'response.Write("<div>RequestType:" & context.Request.RequestType & "</div>")
'response.Write("<div>Url.AbsolutePath:" & context.Request.Url.AbsolutePath & "</div>")
'response.Write("<div>querystring(latitude):" & context.Request.QueryString("latitude") & "</div>")

'For index As Int32 = 0 To context.Request.QueryString.Count - 1

'    response.Write(String.Concat("<div>QueryString:", context.Request.QueryString.GetKey(index), "=", context.Request.QueryString.Get(index), "</div>"))

'Next index

