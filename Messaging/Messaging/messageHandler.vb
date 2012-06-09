#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

Public MustInherit Class messageHandler : Implements System.Web.IHttpHandler

#Region "constants"

#If CONFIG = "Release" Then

    Protected Const CONNECTION_STRING As String = "Server=WIN-FKVLOOSI1RO;Database=Gabs;uid=messaging;pwd=chicogarciassanchez;Connect Timeout=600;"

#Else

    Protected Const CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=messaging;pwd=chicogarciassanchez;Connect Timeout=600;"

#End If

    Protected Const COMMAND_TIMEOUT As Int32 = 60

#End Region

    Protected MustOverride Function isValid(ByVal message As String) As Boolean
    Protected MustOverride Sub processMessage(
        connection As System.Data.SqlClient.SqlConnection,
        context As Web.HttpContext,
        messasge As String,
        userId As Int32)

    Public Sub ProcessRequest(
        context As Web.HttpContext) _
        Implements System.Web.IHttpHandler.ProcessRequest

        Dim isAuthorized As Boolean,
            userId As Int32,
            auth As New authorization(context, isAuthorized, userId)

        If isAuthorized Then

            Dim message As String = getMessage(context)

            If isValid(message) Then

                Using connection As New Data.SqlClient.SqlConnection(CONNECTION_STRING)

                    connection.Open()
                    processMessage(connection, context, message, userId)

                End Using

            Else

                sendErrorResponse(context, 415, "Unsupported Media Type")

            End If

        Else

            sendErrorResponse(context, 401, "Unauthorized")

        End If

    End Sub

    Public ReadOnly Property IsResusable As Boolean Implements System.Web.IHttpHandler.IsReusable

        Get

            Return True

        End Get

    End Property

    Private Function getMessage(ByVal context As Web.HttpContext) As String

        If context.Request.ContentLength = 0 Then

            If context.Request.QueryString("message") IsNot Nothing Then

                Return Web.HttpUtility.UrlDecode(context.Request.QueryString("message"))

            Else

                Return ""

            End If

        Else

            Return Text.Encoding.UTF8.GetString(context.Request.BinaryRead(context.Request.ContentLength))

        End If

    End Function

    Protected Sub sendSuccessResponse(
        context As Web.HttpContext)

        context.Response.Headers.Remove("Server")

    End Sub

    Protected Sub sendErrorResponse(
        ByVal context As Web.HttpContext,
        ByVal errorNumber As Int32,
        ByVal errorMessage As String)

        context.Response.StatusCode = errorNumber
        context.Response.StatusDescription = errorMessage
        context.Response.Headers.Remove("Server")

    End Sub

End Class
