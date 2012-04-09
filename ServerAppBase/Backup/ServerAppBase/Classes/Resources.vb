#Region "options "

Option Explicit On 
Option Strict On

#End Region

Friend Class Resources

#Region "    properties "

    Friend Shared ReadOnly Property GreenIcon() As Drawing.Icon

        Get

            Dim currentAssembly As Reflection.Assembly
            Dim name As String
            Dim icon As Drawing.Icon

            currentAssembly = Reflection.Assembly.GetExecutingAssembly()
            name = "NHXS.Utility.ServerAppBase.Green.ICO"

            Using stream As IO.Stream = currentAssembly.GetManifestResourceStream(name)

                icon = New Drawing.Icon(stream)

            End Using

            Return icon

        End Get

    End Property

    Friend Shared ReadOnly Property RedIcon() As Drawing.Icon

        Get

            Dim currentAssembly As Reflection.Assembly
            Dim name As String
            Dim icon As Drawing.Icon

            currentAssembly = Reflection.Assembly.GetExecutingAssembly()
            name = "NHXS.Utility.ServerAppBase.Red.ICO"

            Using stream As IO.Stream = currentAssembly.GetManifestResourceStream(name)

                icon = New Drawing.Icon(stream)

            End Using

            Return icon

        End Get

    End Property

    Friend Shared ReadOnly Property YellowIcon() As Drawing.Icon

        Get

            Dim currentAssembly As Reflection.Assembly
            Dim name As String
            Dim icon As Drawing.Icon

            currentAssembly = Reflection.Assembly.GetExecutingAssembly()
            name = "NHXS.Utility.ServerAppBase.Yellow.ICO"

            Using stream As IO.Stream = currentAssembly.GetManifestResourceStream(name)

                icon = New Drawing.Icon(stream)

            End Using

            Return icon

        End Get

    End Property

    Friend Shared ReadOnly Property DisabledIcon() As Drawing.Icon

        Get

            Dim currentAssembly As Reflection.Assembly
            Dim name As String
            Dim icon As Drawing.Icon

            currentAssembly = Reflection.Assembly.GetExecutingAssembly()
            name = "NHXS.Utility.ServerAppBase.Disabled.ICO"

            Using stream As IO.Stream = currentAssembly.GetManifestResourceStream(name)

                icon = New Drawing.Icon(stream)

            End Using

            Return icon

        End Get

    End Property

#End Region

End Class
