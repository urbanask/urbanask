Public Class _Default
    Inherits System.Web.UI.Page

    Private Const CREATE_USER_PICTURE_PROC As String = "Gabs.login.createUserPicture",
        VIEW_USER As String = "Gabs.login.createUserPicture",
        COMMAND_TIMEOUT As Int32 = 60

#If CONFIG = "Release" Then

    Private Const CONNECTION_STRING As String = "Server=WIN-FKVLOOSI1RO;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"

#Else

    Private Const CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"

#End If

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


    End Sub

    Private Sub save_Click(sender As Object, e As System.EventArgs) Handles save.Click

        Using connection As New Data.SqlClient.SqlConnection(CONNECTION_STRING),
            createUserPicture As New Data.SqlClient.SqlCommand(CREATE_USER_PICTURE_PROC, connection)

            connection.Open()

            Using web As New Net.WebClient(),
                stream As IO.Stream = web.OpenRead(url.Text),
                imageSource As Drawing.Image = Drawing.Image.FromStream(stream),
                image As Drawing.Image = imageSource.GetThumbnailImage(50, 50, Function() False, IntPtr.Zero),
                icon As Drawing.Image = imageSource.GetThumbnailImage(32, 32, Function() False, IntPtr.Zero),
                imageStream As New IO.MemoryStream,
                iconStream As New IO.MemoryStream

                image.Save(imageStream, System.Drawing.Imaging.ImageFormat.Png)
                icon.Save(iconStream, System.Drawing.Imaging.ImageFormat.Png)

                createUserPicture.CommandType = Data.CommandType.StoredProcedure
                createUserPicture.CommandTimeout = COMMAND_TIMEOUT

                createUserPicture.Parameters.AddWithValue("@userId", userId.Text)
                createUserPicture.Parameters.AddWithValue("@picture", imageStream.GetBuffer())
                createUserPicture.Parameters.AddWithValue("@icon", iconStream.GetBuffer())

                createUserPicture.ExecuteNonQuery()

            End Using

        End Using

    End Sub

End Class