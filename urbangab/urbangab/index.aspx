<%@ Import Namespace="System" %>
<%@ Page Language="VB" Debug="true" %>

<!doctype html>
<html lang="en" itemscope itemtype="http://schema.org/Product">
<head>
    <title>urbanAsk</title>

    <meta name="apple-mobile-web-app-capable"           content="yes" />
    <meta name="viewport"                               content="width=device-width, initial-scale=1, user-scalable=no" />
    <meta name="apple-mobile-web-app-status-bar-style"  content="black" />

    <meta property="og:url"                             content="http://urbanask.com" />
    <meta property="og:title"                           content="urbanAsk" />
    <meta property="og:type"                            content="website" />
    <meta property="og:site_name"                       content="urbanAsk" />
    <meta property="og:description"                     content="The exciting new way to find things locally and help others do the same." />
    <meta property="og:image"                           content="http://urbanask.com/images/icon-large.png" />
    <meta itemprop="name"                               content="urbanAsk" />
    <meta itemprop="description"                        content="The exciting new way to find things locally and help others do the same." />
    <meta itemprop="image"                              content="http://urbanask.com/images/icon-large.png" />

    <link rel="apple-touch-startup-image"               href="images/splash.png" /> 
    <link rel="apple-touch-icon"                        href="images/icon.png" />
    <link rel="icon"                                    type="image/png" href="images/icon.png" />
    <link rel="stylesheet"                              href="styles/urbanask.css" />

    <style>

        body {
            height: 480px;
            text-align: center;
        }

    </style>

    <script type="text/javascript">

        var _gaq = _gaq || [];
        _gaq.push( ['_setAccount', 'UA-23915674-8'] );
        _gaq.push( ['_trackPageview'] );

        (function () {
            var ga = document.createElement( 'script' ); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ( 'https:' == document.location.protocol ? 'https://ssl' : 'http://www' ) + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName( 'script' )[0]; s.parentNode.insertBefore( ga, s );
        } )();

    </script>

</head>

<body>

    <script>

        var APP_URL = 'http://urbanask.com/index.html',
        //var APP_URL = 'http://75.144.228.69:55555/urbanask-alpha/index.html',
            postData = '<% =getPostData() %>';

        window.onload = function () {

            if ( postData ) { //from facebook canvas

                window.location.href = APP_URL;

            } else {

                window.location.href = APP_URL;

            };

        };

    </script>

    <script runat="server">
    
        Private ReadOnly Property getPostData() As String
            
            Get
                
                Dim postData As String = Request.Form.Item("signed_request"),
                    base64Data As String = ""
                
                If postData IsNot Nothing AndAlso postData.Length Then
                
                    base64Data = postData.Split("."c)(1)
                        
                    Dim mod4 As Int32 = base64Data.Length Mod 4
                        
                    If mod4 > 0 Then
                            
                        base64Data += New String("=", 4 - mod4)
                            
                    End If

                    base64Data = Text.Encoding.UTF8.GetString(Convert.FromBase64String(base64Data))
                    
                End If
                
                Return base64Data
                
            End Get
            
        End Property

    </script>

</body>
</html>

