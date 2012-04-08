#Region "options "

Option Explicit On 
Option Strict On

#End Region

#Region "imports "

Imports System.Drawing

#End Region

Friend Class Resources

#Region "    properties "

    Friend Shared ReadOnly Property GreenIcon() As Drawing.Icon

        Get

            Dim currentAssembly As Reflection.Assembly
            Dim stream As IO.Stream
            Dim icon As Drawing.Icon

            Try

                currentAssembly = Reflection.Assembly.GetExecutingAssembly()
                stream = currentAssembly.GetManifestResourceStream("NHXS.Utility.ServerAppBase.Green.ICO")

                icon = New Drawing.Icon(stream)

                Return icon

            Finally

                stream.Close()

            End Try

        End Get

    End Property

    Friend Shared ReadOnly Property RedIcon() As Drawing.Icon

        Get

            Dim currentAssembly As Reflection.Assembly
            Dim stream As IO.Stream
            Dim icon As Drawing.Icon

            Try

                currentAssembly = Reflection.Assembly.GetExecutingAssembly()
                stream = currentAssembly.GetManifestResourceStream("NHXS.Utility.ServerAppBase.Red.ICO")

                icon = New Drawing.Icon(stream)

                Return icon

            Finally

                stream.Close()

            End Try

        End Get

    End Property

    Friend Shared ReadOnly Property YellowIcon() As Drawing.Icon

        Get

            Dim currentAssembly As Reflection.Assembly
            Dim stream As IO.Stream
            Dim icon As Drawing.Icon

            Try

                currentAssembly = Reflection.Assembly.GetExecutingAssembly()
                stream = currentAssembly.GetManifestResourceStream("NHXS.Utility.ServerAppBase.Yellow.ICO")

                icon = New Drawing.Icon(stream)

                Return icon

            Finally

                stream.Close()

            End Try

        End Get

    End Property

    Friend Shared ReadOnly Property DisabledIcon() As Drawing.Icon

        Get

            Dim currentAssembly As Reflection.Assembly
            Dim stream As IO.Stream
            Dim icon As Drawing.Icon

            Try

                currentAssembly = Reflection.Assembly.GetExecutingAssembly()
                stream = currentAssembly.GetManifestResourceStream("NHXS.Utility.ServerAppBase.Disabled.ICO")

                icon = New Drawing.Icon(stream)

                Return icon

            Finally

                stream.Close()

            End Try

        End Get

    End Property

#End Region

End Class
