#Region " options "

Option Explicit On
Option Strict On
Option Compare Binary

#End Region

#Region " imports "

Imports System.Security
Imports System.Text

#End Region

Public Class hash

    Private Const DEFAULT_ITERATIONS As Int32 = 5
    Private Const DEFAULT_HASH_TYPE As String = "SHA512"

    Public ReadOnly username As String
    Public ReadOnly password As String
    Public ReadOnly hashType As String
    Public ReadOnly salt As String
    Public ReadOnly iterations As Int32
    Public ReadOnly hash As String

    Public Sub New( _
        username As String, _
        password As String, _
        hashType As String, _
        salt As String, _
        iterations As Int32)

        Me.username = username
        Me.password = password
        Me.hashType = hashType
        Me.salt = salt
        Me.iterations = iterations

        Dim hashBytes() As Byte = Encoding.UTF8.GetBytes(String.Concat(username, password, salt))

        Select Case hashType
            Case "SHA256"

                Using hasher As New Cryptography.SHA256Managed

                    For index As Int32 = 1 To iterations

                        hashBytes = hasher.ComputeHash(hashBytes)

                    Next index

                    Me.hash = Convert.ToBase64String(hasher.ComputeHash(hashBytes))

                End Using

            Case "SHA512"

                Using hasher As New Cryptography.SHA512Managed

                    For index As Int32 = 1 To iterations

                        hashBytes = hasher.ComputeHash(hashBytes)

                    Next index

                    Me.hash = Convert.ToBase64String(hasher.ComputeHash(hashBytes))

                End Using

        End Select

    End Sub

    Public Sub New( _
        username As String, _
        password As String)

        Me.New(username, password, DEFAULT_HASH_TYPE, Hashing.Hash.createSalt(), DEFAULT_ITERATIONS)

    End Sub

    Private Shared Function createSalt(Optional size As Int32 = 4) As String

        Dim random As New Cryptography.RNGCryptoServiceProvider(),
            salt(size - 1) As Byte

        random.GetNonZeroBytes(salt)

        Return Convert.ToBase64String(salt)

    End Function

End Class
