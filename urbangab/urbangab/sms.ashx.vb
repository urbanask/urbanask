Imports System.Web
Imports System.Web.Services

Public Class sms : Implements System.Web.IHttpHandler

    Sub ProcessRequest(ByVal context As Web.HttpContext) _
        Implements IHttpHandler.ProcessRequest

        context.Response.ContentType = "text/xml"

        context.Response.Write("<?xml version=""1.0"" encoding=""UTF-8""?>")
        context.Response.Write("<Response>")
        context.Response.Write("<Sms>" & data(context) & "</Sms>")
        context.Response.Write("</Response>")

    End Sub

    Private Function data(ByVal context As Web.HttpContext) As String

        If context.Request.ContentLength = 0 Then

            If context.Request.QueryString.Count > 0 Then

                Dim queryStrings As Collections.Specialized.NameValueCollection = context.Request.QueryString,
                    returnValue As String = ""

                For index As Integer = 0 To queryStrings.Count - 1

                    returnValue += String.Concat(queryStrings.Keys(index), "=", queryStrings(index), "&")

                Next index

                'Return Web.HttpUtility.UrlDecode(context.Request.QueryString("message"))
                Return Web.HttpUtility.UrlEncode(returnValue.Remove(returnValue.Length - 1)).Substring(0, 150)

            Else

                Return ""

            End If

        Else

            Return Text.Encoding.UTF8.GetString(context.Request.BinaryRead(context.Request.ContentLength))

        End If

    End Function

    ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return True
        End Get
    End Property

End Class