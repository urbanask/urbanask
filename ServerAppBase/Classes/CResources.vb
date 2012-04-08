Option Explicit On 
Option Strict On

Imports System.Drawing

Friend Class CResources

#Region "    enumerations"

    Public Enum EIconColor As Byte

        RedIcon
        YellowIcon
        GreenIcon

    End Enum

#End Region

    Friend Shared ReadOnly Property GreenIcon() As Drawing.Icon

        Get

            Dim oAssembly As Reflection.Assembly
            Dim oStream As IO.Stream
            Dim oIcon As Drawing.Icon

            Try

                oAssembly = Reflection.Assembly.GetExecutingAssembly()
                oStream = oAssembly.GetManifestResourceStream("ATR.Utility.ServerAppBase.Green.ICO")

                oIcon = New Drawing.Icon(oStream)

                Return oIcon

            Finally

                oStream.Close()

            End Try

        End Get

    End Property

    Friend Shared ReadOnly Property RedIcon() As Drawing.Icon

        Get

            Dim oAssembly As Reflection.Assembly
            Dim oStream As IO.Stream
            Dim oIcon As Drawing.Icon

            Try

                oAssembly = Reflection.Assembly.GetExecutingAssembly()
                oStream = oAssembly.GetManifestResourceStream("ATR.Utility.ServerAppBase.Red.ICO")

                oIcon = New Drawing.Icon(oStream)

                Return oIcon

            Finally

                oStream.Close()

            End Try

        End Get

    End Property

    Friend Shared ReadOnly Property YellowIcon() As Drawing.Icon

        Get

            Dim oAssembly As Reflection.Assembly
            Dim oStream As IO.Stream
            Dim oIcon As Drawing.Icon

            Try

                oAssembly = Reflection.Assembly.GetExecutingAssembly()
                oStream = oAssembly.GetManifestResourceStream("ATR.Utility.ServerAppBase.Yellow.ICO")

                oIcon = New Drawing.Icon(oStream)

                Return oIcon

            Finally

                oStream.Close()

            End Try

        End Get

    End Property

End Class
