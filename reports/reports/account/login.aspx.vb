Public Class login

    Inherits System.Web.UI.Page

    Private Sub LoginUser_Authenticate(
        ByVal sender As Object,
        ByVal e As System.Web.UI.WebControls.AuthenticateEventArgs) _
        Handles LoginUser.Authenticate

        e.Authenticated = True

    End Sub

End Class