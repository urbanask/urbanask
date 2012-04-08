#Region "options "

Option Explicit On 
Option Strict On
Option Compare Binary

#End Region

Public Class Parameter

#Region "    functions "

    Public Shared Function GetValue( _
        ByVal name As String,
        Optional ByVal isOptional As Boolean = False) As String

        Dim configurationFile As String = Parameters.Parameter.ConfigurationFile
        Dim product As String = Parameters.Parameter.Product(configurationFile)
        Dim environment As String = Parameters.Parameter.Environment(configurationFile)

        Dim returnValue As String = Parameters.Parameter.GetValue(name, configurationFile, product, environment, isOptional)

        Return returnValue

    End Function

    Public Shared Function GetValue( _
        ByVal name As String, _
        ByVal configurationFile As String,
        Optional ByVal isOptional As Boolean = False) As String

        Dim product As String = Parameters.Parameter.Product(configurationFile)
        Dim environment As String = Parameters.Parameter.Environment(configurationFile)

        Dim returnValue As String = Parameters.Parameter.GetValue(name, configurationFile, product, environment, isOptional)

        Return returnValue

    End Function

    Public Shared Function GetValue( _
        ByVal name As String, _
        ByVal configurationFile As String, _
        ByVal environment As String,
        Optional ByVal isOptional As Boolean = False) As String

        Dim product As String = Parameters.Parameter.Product(configurationFile)
        Dim returnValue As String = Parameters.Parameter.GetValue(name, configurationFile, product, environment, isOptional)

        Return returnValue

    End Function

    Public Shared Function GetValue( _
        ByVal name As String, _
        ByVal configurationFile As String, _
        ByVal product As String, _
        ByVal environment As String,
        Optional ByVal isOptional As Boolean = False) As String

        Dim returnValue As String = ""
        Dim valueXmlNode As Xml.XmlNode = Nothing
        Dim value As Xml.XmlNode

        Dim xmlDocument As New Xml.XmlDocument
        xmlDocument.Load(configurationFile)

        'check environment section 
        Dim xPath As String = "configuration/Parameters/{0}"
        xPath = String.Format(xPath, environment)
        Dim xmlNode As Xml.XmlNode = xmlDocument.SelectSingleNode(xPath)

        If (xmlNode IsNot Nothing) Then

            valueXmlNode = xmlNode.SelectSingleNode(name)

            If (valueXmlNode IsNot Nothing) Then

                value = valueXmlNode.FirstChild()

                If (value IsNot Nothing) Then

                    returnValue = value.Value()

                End If

            End If

        End If

        'check product section 
        If (valueXmlNode Is Nothing) AndAlso (product <> "") Then

            xPath = "configuration/Parameters/{0}"
            xPath = String.Format(xPath, product)
            xmlNode = xmlDocument.SelectSingleNode(xPath)

            If (xmlNode IsNot Nothing) Then

                valueXmlNode = xmlNode.SelectSingleNode(name)

                If (valueXmlNode IsNot Nothing) Then

                    value = valueXmlNode.FirstChild()

                    If (value IsNot Nothing) Then

                        returnValue = value.Value()

                    End If

                End If

            End If

        End If

        'check default section
        If (valueXmlNode Is Nothing) Then

            xPath = "configuration/Parameters/Default"
            xmlNode = xmlDocument.SelectSingleNode(xPath)

            If (xmlNode IsNot Nothing) Then

                valueXmlNode = xmlNode.SelectSingleNode(name)

                If (valueXmlNode IsNot Nothing) Then

                    value = valueXmlNode.FirstChild()

                    If (value IsNot Nothing) Then

                        returnValue = value.Value()

                    End If

                End If

            End If

        End If

        If Not isOptional Then

            If (valueXmlNode Is Nothing) OrElse (returnValue = "") Then

                Dim message As String = "'{0}' is required and does not exist or is empty in the .config file (Product: {1}, Environment: {2})."
                message = String.Format(message, name, product, environment)
                Throw New Parameters.ParameterException(message)

            End If

        End If

        Return returnValue

    End Function

    Public Shared Function GetInt32Value( _
        ByVal name As String,
        Optional ByVal isOptional As Boolean = False) As Int32

        Dim configurationFile As String = Parameters.Parameter.ConfigurationFile()
        Dim returnValue As Int32 = Parameters.Parameter.GetInt32Value(name, configurationFile, isOptional)

        Return returnValue

    End Function

    Public Shared Function GetInt32Value( _
        ByVal name As String, _
        ByVal configurationFile As String,
        Optional ByVal isOptional As Boolean = False) As Int32

        Dim returnValue As Int32 = 0

        Dim value As String = Parameters.Parameter.GetValue(name, configurationFile, isOptional)

        If value = "" Then

            returnValue = 0

        Else

            returnValue = System.Convert.ToInt32(value)

        End If

        Return returnValue

    End Function

    Public Shared Function GetBooleanValue( _
        ByVal name As String, _
        ByVal configurationFile As String,
        Optional ByVal isOptional As Boolean = False) As Boolean

        Dim returnValue As Boolean

        Dim value As String = Parameters.Parameter.GetValue(name, configurationFile, isOptional)

        If value = "" Then

            returnValue = False

        Else

            returnValue = System.Convert.ToBoolean(value)

        End If

        Return returnValue

    End Function

    Public Shared Function GetBooleanValue( _
        ByVal name As String,
        Optional ByVal isOptional As Boolean = False) As Boolean

        Dim configurationFile As String
        Dim returnValue As Boolean

        configurationFile = Parameters.Parameter.ConfigurationFile()
        returnValue = Parameters.Parameter.GetBooleanValue(name, configurationFile, isOptional)

        Return returnValue

    End Function

    Public Shared Function GetDateTimeValue( _
        ByVal name As String, _
        ByVal configurationFile As String,
        Optional ByVal isOptional As Boolean = False) As System.DateTime

        Dim value As String
        Dim returnValue As System.DateTime

        value = Parameters.Parameter.GetValue(name, configurationFile, isOptional)

        If Microsoft.VisualBasic.IsDate(value) Then

            returnValue = System.Convert.ToDateTime(value)

        Else

            returnValue = Nothing

        End If

        Return returnValue

    End Function

    Public Shared Function GetDateTimeValue( _
        ByVal name As String,
        Optional ByVal isOptional As Boolean = False) As System.DateTime

        Dim configurationFile As String
        Dim returnValue As System.DateTime

        configurationFile = Parameters.Parameter.ConfigurationFile()
        returnValue = Parameters.Parameter.GetDateTimeValue(name, configurationFile, isOptional)

        Return returnValue

    End Function

    Public Shared Function GetValues( _
        ByVal name As String,
        Optional ByVal isOptional As Boolean = False) As Collections.ArrayList

        Dim configurationFile As String
        Dim returnValue As Collections.ArrayList

        configurationFile = Parameters.Parameter.ConfigurationFile
        returnValue = Parameters.Parameter.GetValues(name, configurationFile, isOptional)

        Return returnValue

    End Function

    Public Shared Function GetValues( _
        ByVal name As String, _
        ByVal configurationFile As String,
        Optional ByVal isOptional As Boolean = False) As Collections.ArrayList

        Dim values As Collections.ArrayList
        Dim valueXmlNode As Xml.XmlNode
        Dim product As String
        Dim environment As String
        Dim xmlDocument As Xml.XmlDocument
        Dim xPath As String
        Dim xmlNode As Xml.XmlNode
        Dim valueXmlElement As Xml.XmlElement
        Dim value As String

        values = New Collections.ArrayList
        valueXmlNode = Nothing
        product = Parameters.Parameter.Product(configurationFile)
        environment = Parameters.Parameter.Environment(configurationFile)

        xmlDocument = New Xml.XmlDocument
        xmlDocument.Load(configurationFile)

        'check environment section
        xPath = "configuration/Parameters/{0}"
        xPath = String.Format(xPath, environment)
        xmlNode = xmlDocument.SelectSingleNode(xPath)

        If (xmlNode IsNot Nothing) Then

            valueXmlNode = xmlNode.SelectSingleNode(name)

            If (valueXmlNode IsNot Nothing) Then

                For Each valueXmlElement In valueXmlNode.ChildNodes

                    value = valueXmlElement.FirstChild.Value
                    values.Add(value)

                Next valueXmlElement

            End If

        End If

        If (product <> "") Then

            'check product section
            xPath = "configuration/Parameters/{0}"
            xPath = String.Format(xPath, product)
            xmlNode = xmlDocument.SelectSingleNode(xPath)

            If (xmlNode IsNot Nothing) Then

                valueXmlNode = xmlNode.SelectSingleNode(name)

                If (valueXmlNode IsNot Nothing) Then

                    For Each valueXmlElement In valueXmlNode.ChildNodes

                        value = valueXmlElement.FirstChild.Value
                        values.Add(value)

                    Next valueXmlElement

                End If

            End If

        End If

        'check default section
        xPath = "configuration/Parameters/Default"
        xmlNode = xmlDocument.SelectSingleNode(xPath)

        If (xmlNode IsNot Nothing) Then

            valueXmlNode = xmlNode.SelectSingleNode(name)

            If (valueXmlNode IsNot Nothing) Then

                For Each valueXmlElement In valueXmlNode.ChildNodes

                    value = valueXmlElement.FirstChild.Value
                    values.Add(value)

                Next valueXmlElement

            End If

        End If

        If Not isOptional Then

            If (values.Count = 0) Then

                Dim message As String = "'{0}' is required and does not exist or is empty in the .config file (Product: {1}, Environment: {2})."
                message = String.Format(message, name, product, environment)
                Throw New Parameters.ParameterException(message)

            End If

        End If

        Return values

    End Function

    Public Shared Sub SetValue( _
        ByVal name As String, _
        ByVal value As String)

        Dim configurationFile As String

        configurationFile = Parameters.Parameter.ConfigurationFile
        Parameters.Parameter.SetValue(name, value, configurationFile)

    End Sub

    Public Shared Sub SetValue( _
        ByVal name As String, _
        ByVal value As String, _
        ByVal configurationFile As String)

        Dim product As String
        Dim environment As String
        Dim xmlDocument As Xml.XmlDocument
        Dim xPath As String
        Dim xmlNode As Xml.XmlNode
        Dim message As String
        Dim valueXmlNode As Xml.XmlNode
        Dim valueNode As Xml.XmlNode
        Dim parameterSet As Boolean

        product = Parameters.Parameter.Product(configurationFile)
        environment = Parameters.Parameter.Environment(configurationFile)

        xmlDocument = New Xml.XmlDocument
        xmlDocument.PreserveWhitespace = True
        xmlDocument.Load(configurationFile)

        'try environment section
        xPath = "configuration/Parameters/{0}"
        xPath = String.Format(xPath, environment)
        xmlNode = xmlDocument.SelectSingleNode(xPath)

        If (xmlNode IsNot Nothing) Then

            valueXmlNode = xmlNode.SelectSingleNode(name)

            If (valueXmlNode IsNot Nothing) Then

                valueNode = valueXmlNode.ChildNodes(1) 'second node, skip whitespace
                valueNode.Value = value

                xmlDocument.Save(configurationFile)

                parameterSet = True

            End If

        End If

        'try product section
        If (Not parameterSet) AndAlso (product <> "") Then

            xPath = "configuration/Parameters/{0}"
            xPath = String.Format(xPath, product)
            xmlNode = xmlDocument.SelectSingleNode(xPath)

            If (xmlNode IsNot Nothing) Then

                valueXmlNode = xmlNode.SelectSingleNode(name)

                If (valueXmlNode IsNot Nothing) Then

                    valueNode = valueXmlNode.ChildNodes(1) 'second node, skip whitespace
                    valueNode.Value = value

                    xmlDocument.Save(configurationFile)

                    parameterSet = True

                End If

            End If

        End If

        'try default section
        If Not parameterSet Then

            xPath = "configuration/Parameters/Default"
            xmlNode = xmlDocument.SelectSingleNode(xPath)

            If (xmlNode IsNot Nothing) Then

                valueXmlNode = xmlNode.SelectSingleNode(name)

                If (valueXmlNode IsNot Nothing) Then

                    valueNode = valueXmlNode.ChildNodes(1) 'second node, skip whitespace
                    valueNode.Value = value

                    xmlDocument.Save(configurationFile)

                    parameterSet = True

                End If

            End If

        End If

        If Not parameterSet Then

            message = "Parameter '{0}' does not exist (Product: {1}, Environment: {2})."
            message = String.Format(message, name, product, environment)
            Throw New Parameters.ParameterException(message)

        End If

    End Sub

    Public Shared Function IsParameter( _
        ByVal name As String) As Boolean

        Dim configurationFile As String
        Dim returnValue As Boolean

        configurationFile = Parameters.Parameter.ConfigurationFile
        returnValue = Parameters.Parameter.IsParameter(name, configurationFile)

        Return returnValue

    End Function

    Public Shared Function IsParameter( _
        ByVal name As String, _
        ByVal configurationFile As String) As Boolean

        Dim product As String
        Dim environment As String
        Dim xmlDocument As Xml.XmlDocument
        Dim xPath As String
        Dim xmlNode As Xml.XmlNode
        Dim returnValue As Boolean

        product = Parameters.Parameter.Product(configurationFile)
        environment = Parameters.Parameter.Environment(configurationFile)

        xmlDocument = New Xml.XmlDocument
        xmlDocument.Load(configurationFile)

        'check environment section
        xPath = "configuration/Parameters/{0}/{1}"
        xPath = String.Format(xPath, environment, name)
        xmlNode = xmlDocument.SelectSingleNode(xPath)

        If (xmlNode Is Nothing) AndAlso (product <> "") Then

            'check product section
            xPath = "configuration/Parameters/{0}/{1}"
            xPath = String.Format(xPath, product, name)
            xmlNode = xmlDocument.SelectSingleNode(xPath)

        End If

        If (xmlNode Is Nothing) Then

            'check default section
            xPath = "configuration/Parameters/Default/{0}"
            xPath = String.Format(xPath, name)
            xmlNode = xmlDocument.SelectSingleNode(xPath)

        End If

        If (xmlNode IsNot Nothing) Then

            returnValue = True

        End If

        Return returnValue

    End Function

    Private Shared Function GetAppSetting( _
        ByVal name As String, _
        ByVal configurationFile As String) As String

        Dim appSetting As String
        Dim xmlDocument As Xml.XmlDocument
        Dim xPath As String
        Dim xmlNode As Xml.XmlNode

        appSetting = ""

        xmlDocument = New Xml.XmlDocument
        xmlDocument.Load(configurationFile)

        xPath = "configuration/appSettings/add[@key = ""{0}""]"
        xPath = String.Format(xPath, name)
        xmlNode = xmlDocument.SelectSingleNode(xPath)

        If (xmlNode IsNot Nothing) Then

            appSetting = xmlNode.Attributes("value").Value

        End If

        Return appSetting

    End Function

#End Region

#Region "    properties "

    Public Shared ReadOnly Property ConfigurationFile() As String

        Get

            If IsWebApp() Then 'web app

                Dim file As New System.Uri(System.Reflection.Assembly.GetExecutingAssembly.CodeBase)
                Return IO.Path.GetDirectoryName(IO.Path.GetDirectoryName(file.AbsolutePath)) & "\web.config" 'remove bin or app_data

            Else

                Return System.Reflection.Assembly.GetEntryAssembly.Location & ".config"

            End If

        End Get

    End Property

    Private Shared ReadOnly Property IsWebApp() As Boolean

        Get

            Return System.Diagnostics.Process.GetCurrentProcess().ProcessName = "w3wp"

        End Get

    End Property

    Public Shared ReadOnly Property Environment( _
        ByVal configurationFile As String) As String

        Get

            Dim path As String = IO.Path.GetDirectoryName(configurationFile)
            Dim search As String = String.Format("{0}.Environment.*", IO.Path.GetFileName(configurationFile))

            Dim file() As String = System.IO.Directory.GetFiles( _
                path, _
                search, _
                IO.SearchOption.TopDirectoryOnly)

            If file.Length = 0 Then

                Return Parameters.Parameter.GetAppSetting("Environment", configurationFile)

            Else

                Return IO.Path.GetExtension(file(0)).Substring(1)

            End If

        End Get

    End Property

    Public Shared ReadOnly Property Environment() As String

        Get

            Return Parameters.Parameter.Environment(Parameters.Parameter.ConfigurationFile)

        End Get

    End Property

    Private Shared ReadOnly Property Product( _
        ByVal configurationFile As String) As String

        Get

            Dim path As String = IO.Path.GetDirectoryName(configurationFile)
            Dim search As String = String.Format("{0}.Product.*", IO.Path.GetFileName(configurationFile))

            Dim file() As String = System.IO.Directory.GetFiles( _
                path, _
                search, _
                IO.SearchOption.TopDirectoryOnly)

            If file.Length = 0 Then

                Return Parameters.Parameter.GetAppSetting("Product", configurationFile)

            Else

                Return IO.Path.GetExtension(file(0)).Substring(1)

            End If

        End Get

    End Property

    Public Shared ReadOnly Property Product() As String

        Get

            Return Parameters.Parameter.Product(Parameters.Parameter.ConfigurationFile)

        End Get

    End Property

#End Region

End Class
