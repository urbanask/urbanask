#Region "options "

Option Explicit On 
Option Strict On

#End Region

#Region "imports "

Imports System
Imports System.Collections

#End Region

<Serializable()> _
Public MustInherit Class KeyIndexListBase

    Inherits CollectionBase

#Region "    variables "

    Private _keys As System.Collections.Hashtable
    Private _locked As Boolean

#End Region

#Region "    functions "

    Protected Sub New()

        _keys = New System.Collections.Hashtable

    End Sub

    Protected Function AddKeyValue( _
        ByVal key As String, _
        ByVal item As System.Object) As Int32

        Dim message As String = ""
        Dim index As Int32 = -1

        If _locked Then

            message = "Collection is read-only"
            Throw New System.ApplicationException(message)

        Else

            If _keys.ContainsKey(key) Then

                message = "Key already exists in Collection."
                Throw New System.ArgumentOutOfRangeException(message)

            Else

                index = MyBase.List.Add(item)
                _keys.Add(key, item)

            End If

        End If

        Return index

    End Function

    Public Overridable Function Contains( _
        ByVal key As String) As Boolean

        Dim returnValue As Boolean

        returnValue = _keys.Contains(key)

        Return returnValue

    End Function

    Public Shadows Sub Clear()

        MyBase.Clear()
        _keys.Clear()

    End Sub

    Public Sub Lock()

        _locked = True

    End Sub

#End Region

#Region "    properties "

    Protected ReadOnly Property InnerItem( _
        ByVal key As String) As System.Object

        Get

            Dim item As System.Object
            Dim message As String

            If _keys.Contains(key) Then

                item = _keys.Item(key)

            Else

                message = "Key does not exist in KeyIndexList."
                Throw New System.ArgumentOutOfRangeException(message)

            End If

            Return item

        End Get

    End Property

    Protected ReadOnly Property InnerItem( _
        ByVal index As Int32) As System.Object

        Get

            Return MyBase.List.Item(index)

        End Get

    End Property

#End Region

End Class
