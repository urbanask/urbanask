#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports Microsoft.VisualBasic
Imports System.Data

#End Region

Public Class lookups : Inherits api.messageHandler

    Public Const LOAD_REPUTATION_ACTIONS As String = "Gabs.api.loadReputationActions",
        LOAD_REGIONS As String = "Gabs.api.loadRegions",
        LOAD_REGION_BY_NAME As String = "Gabs.api.loadRegionByName"

    Protected Overrides Sub process(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext,
        request As String,
        userId As Int32)

        Dim queries As Collections.Specialized.NameValueCollection = context.Request.QueryString

        Select Case context.Request.PathInfo

            Case "/reputationActions"

                loadReputationActions(connection, context)

            Case "/regions"

                If queries("region") = "" Then

                    loadRegions(connection, context)

                Else

                    loadRegionByName(connection, context, queries("region"))

                End If

            Case Else

                MyBase.sendErrorResponse(context, 404, "Not Found")

        End Select

    End Sub

    Private Sub loadReputationActions(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext)

        Using command As New SqlClient.SqlCommand(LOAD_REPUTATION_ACTIONS, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            MyBase.sendSuccessResponse(context, createReputationActions(command))

        End Using

    End Sub

    Private Sub loadRegions(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext)

        Using command As New SqlClient.SqlCommand(LOAD_REGIONS, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            MyBase.sendSuccessResponse(context, createRegions(command))

        End Using

    End Sub

    Private Sub loadRegionByName(
        connection As SqlClient.SqlConnection,
        context As Web.HttpContext,
        region As String)

        Using command As New SqlClient.SqlCommand(LOAD_REGION_BY_NAME, connection)

            command.CommandType = CommandType.StoredProcedure
            command.CommandTimeout = COMMAND_TIMEOUT

            command.Parameters.AddWithValue("@region", region)
            command.Parameters.Add("@regionId", SqlDbType.Int).Direction = ParameterDirection.Output

            command.ExecuteNonQuery()

            MyBase.sendSuccessResponse(context, createRegion(command.Parameters("@regionId").Value.ToString()))

        End Using

    End Sub

    Private Function createReputationActions(command As Data.SqlClient.SqlCommand) As String

        Using rows As Data.SqlClient.SqlDataReader = command.ExecuteReader()

            Dim response As String = "["

            If rows.HasRows() Then

                While (rows.Read())

                    response &= String.Concat(
                        "{",
                        """id"":", rows("id"), ",",
                        """name"":""", rows("name"), """,",
                        """reputation"":", rows("reputation"),
                        "},")

                End While

                response = response.Substring(0, response.Length - 1) 'remove last comma

            End If

            response &= "]"

            Return response

        End Using

    End Function

    Private Function createRegion(regionId As String) As String

        Return "{""regionId"":" + MyBase.jsonEncode(regionId) + "}"

    End Function

    Private Function createRegions(command As Data.SqlClient.SqlCommand) As String

        Using rows As Data.SqlClient.SqlDataReader = command.ExecuteReader()

            Dim response As String = "["

            If rows.HasRows() Then

                While (rows.Read())

                    response &= String.Concat(
                        "[",
                        rows("id"), ",""",
                        rows("name"), """,",
                        rows("level"),
                        "],")

                End While

                response = response.Substring(0, response.Length - 1) 'remove last comma

            End If

            response &= "]"

            Return response

        End Using

    End Function

    Protected Overrides Function isValid(
        context As System.Web.HttpContext,
        request As String) As Boolean

        Return True

    End Function

    Protected Overrides Function isAuthorized(
        context As System.Web.HttpContext,
        ByRef userId As Int32) As Boolean

        Dim authorized As Boolean,
            auth As New authorization(context, authorized, userId)

        Return authorized

    End Function

End Class


