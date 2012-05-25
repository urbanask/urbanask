Public Class questions
    Inherits System.Web.UI.Page

    Private Const CREATE_QUESTION As String = "Gabs.tools.createQuestion",
        COMMAND_TIMEOUT As Int32 = 60

#If CONFIG = "Release" Then

    'Private Const CONNECTION_STRING As String = "Server=WIN-FKVLOOSI1RO;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"
    Private Const CONNECTION_STRING As String = "Server=69.65.42.214;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"

#Else

    Private Const CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=tools;pwd=brakeoutstakefork;Connect Timeout=600;"

#End If


    Private Sub save_Click(sender As Object, e As System.EventArgs) Handles save.Click

        Using connection As New Data.SqlClient.SqlConnection(CONNECTION_STRING),
            createQuestion As New Data.SqlClient.SqlCommand(CREATE_QUESTION, connection)

            connection.Open()

            createQuestion.CommandType = Data.CommandType.StoredProcedure
            createQuestion.CommandTimeout = COMMAND_TIMEOUT

            createQuestion.Parameters.AddWithValue("@question", Me.question.Text)
            createQuestion.Parameters.Add("@questionId", Data.SqlDbType.Int).Direction = Data.ParameterDirection.Output

            createQuestion.ExecuteNonQuery()

            If CInt(createQuestion.Parameters("@questionId").Value) > 0 Then

                Me.message.InnerText = createQuestion.Parameters("@questionId").Value
                Me.question.Text = ""

            Else

                Me.message.InnerText = "error"

            End If

        End Using

    End Sub

    Private Sub questions_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        Me.question.Focus()
    End Sub
End Class