Public Class users
    Inherits System.Web.UI.Page

    Private Const VIEW_USERS As String = "Gabs.tools.viewUsers",
        COMMAND_TIMEOUT As Int32 = 60

#If CONFIG = "Release" Then

    'Private Const CONNECTION_STRING As String = "Server=WIN-FKVLOOSI1RO;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"
    Private Const CONNECTION_STRING As String = "Server=69.65.42.214;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"

#Else

    Private Const CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"

#End If

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Using connection As New Data.SqlClient.SqlConnection(CONNECTION_STRING),
            viewUsers As New Data.SqlClient.SqlCommand(VIEW_USERS, connection)

            connection.Open()

            viewUsers.CommandType = Data.CommandType.StoredProcedure
            viewUsers.CommandTimeout = COMMAND_TIMEOUT

            Using users As Data.SqlClient.SqlDataReader = viewUsers.ExecuteReader()

                Dim html As String = ""

                If users.HasRows() Then

                    While (users.Read())

                        Dim image = System.Convert.ToBase64String(DirectCast(users("picture"), Byte()))

                        html &= String.Concat(
                            "<li>",
                            "<img src=""data:image/png;base64,", image, """ />",
                            users("userId"), "-",
                            users("username"),
                            "</li>")

                    End While

                End If

                Me.users.InnerHtml = html

            End Using

        End Using

    End Sub

End Class