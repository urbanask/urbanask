Public Class profilePicture
    Inherits System.Web.UI.Page

    Private Const CREATE_USER_PICTURE_PROC As String = "Gabs.login.createUserPicture",
        GET_NEXT_USER As String = "Gabs.tools.getNextUser",
        COMMAND_TIMEOUT As Int32 = 60

#If CONFIG = "Release" Then

    'Private Const CONNECTION_STRING As String = "Server=WIN-FKVLOOSI1RO;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"
    Private Const CONNECTION_STRING As String = "Server=69.65.42.214;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"

#Else

    Private Const CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"

#End If

    Private Sub save_Click(sender As Object, e As System.EventArgs) Handles save.Click

        Using connection As New Data.SqlClient.SqlConnection(CONNECTION_STRING),
            getNextUser As New Data.SqlClient.SqlCommand(GET_NEXT_USER, connection),
            createUserPicture As New Data.SqlClient.SqlCommand(CREATE_USER_PICTURE_PROC, connection),
            web As New Net.WebClient(),
            stream As IO.Stream = web.OpenRead(url.Text),
            imageSource As Drawing.Image = Drawing.Image.FromStream(stream)

            Dim x As Int32,
                y As Int32,
                width As Int32,
                height As Int32,
                crop As Boolean = False

            If imageSource.Width > imageSource.Height Then

                x = (imageSource.Width - imageSource.Height) / 2
                y = 0
                width = imageSource.Height
                height = imageSource.Height
                crop = True

            ElseIf imageSource.Width < imageSource.Height Then

                x = 0
                y = (imageSource.Height - imageSource.Width) / 2
                width = imageSource.Width
                height = imageSource.Width
                crop = True

            End If

            Using croppedImage As Drawing.Image = If(crop, cropImage(imageSource, x, y, width, height), imageSource),
                image As Drawing.Image = croppedImage.GetThumbnailImage(50, 50, Function() False, IntPtr.Zero),
                icon As Drawing.Image = croppedImage.GetThumbnailImage(32, 32, Function() False, IntPtr.Zero),
                imageStream As New IO.MemoryStream,
                iconStream As New IO.MemoryStream

                connection.Open()

                getNextUser.CommandType = Data.CommandType.StoredProcedure
                getNextUser.CommandTimeout = COMMAND_TIMEOUT

                getNextUser.Parameters.Add("@userId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output

                getNextUser.ExecuteNonQuery()

                If CInt(getNextUser.Parameters("@userId").Value) > 0 Then

                    Dim userId = CInt(getNextUser.Parameters("@userId").Value)

                    image.Save(imageStream, System.Drawing.Imaging.ImageFormat.Png)
                    icon.Save(iconStream, System.Drawing.Imaging.ImageFormat.Png)

                    createUserPicture.CommandType = Data.CommandType.StoredProcedure
                    createUserPicture.CommandTimeout = COMMAND_TIMEOUT

                    createUserPicture.Parameters.AddWithValue("@userId", userId)
                    createUserPicture.Parameters.AddWithValue("@picture", imageStream.GetBuffer())
                    createUserPicture.Parameters.AddWithValue("@icon", iconStream.GetBuffer())

                    createUserPicture.ExecuteNonQuery()

                    Me.message.InnerText = userId
                    Me.url.Text = ""

                Else

                    Me.message.InnerText = "Done"

                End If

            End Using

        End Using

    End Sub

    Private Function cropImage(
        ByRef image As Drawing.Bitmap,
        ByVal x As Integer,
        ByVal y As Integer,
        ByVal width As Integer,
        ByVal height As Integer) As Drawing.Image


        Return image.Clone(New Drawing.Rectangle(x, y, width, height), image.PixelFormat)

    End Function

    Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        Me.url.Focus()
    End Sub

End Class