<%@ Import Namespace="System" %>
<%@ Page Language="VB" Debug="true" %>

<!doctype html>
<html lang="en" itemscope itemtype="http://schema.org/Product">
<head>
    <title>urbanAsk</title>

    <meta name="apple-mobile-web-app-capable"           content="yes" />
    <meta name="viewport"                               content="width=device-width, initial-scale=1, user-scalable=no" />
    <meta name="apple-mobile-web-app-status-bar-style"  content="black" />
    <meta property="og:url"                             content="http://urbanAsk.com" />
    <meta property="og:title"                           content="urbanAsk" />
    <meta property="og:type"                            content="website" />
    <meta property="og:site_name"                       content="urbanAsk" />
    <meta property="og:description"                     content="The exciting new way to find things locally and help others do the same." />
    <meta property="og:image"                           content="http://urbanAsk.com/images/icon-large.png" />
    <meta itemprop="name"                               content="urbanAsk" />
    <meta itemprop="description"                        content="The exciting new way to find things locally and help others do the same." />
    <meta itemprop="image"                              content="http://urbanAsk.com/images/icon-large.png" />
    <link rel="apple-touch-startup-image"               href="images/splash.png" /> 
    <link rel="apple-touch-icon"                        href="images/icon.png" />
    <link rel="icon"                                    type="image/png" href="images/icon.png" />

    <style>

        body {
            background-color: black;
            font-family: Helvetica Neue, Helvetica, Verdana, Tahoma, Andale Mono, Monaco, Courier New;
            height: 480px;
            margin: 0 auto;
            overflow: hidden;
            position: relative;
            text-align: center;
            width: 320px;
        }

        .hide {
            display: none !important;
        }
        
        #install-header {
            font: normal 35px/35px Monaco;
            letter-spacing: -1px;
            margin-bottom: 10px;
            text-align: center;    
        }

        .install-item {
            display: block;
            height: 34px;
            line-height: 34px;
            margin-left: 20px;
            vertical-align: top;
        }

        #install-page {
            background-color: black;
            color: white;
            height: 100%;
            left: 0;
            margin: 0;
            position: absolute;
            text-align: left;
            top: 0;
            width: 100%;
        }

        #install-steps,
        #facebook-steps {
            margin: 10px 0 0 0;
            padding: 0;
        }

        #install-view {
            margin: 10px 0 0 30px;
        }

        #splash {
            height: 460px;
            opacity: 1;
            position: absolute; 
            top: 0;
            transition:             opacity 500ms ease;
                -moz-transition:    opacity 500ms ease;
                -ms-transition:     opacity 500ms ease;
                -o-transition:      opacity 500ms ease;
                -webkit-transition: opacity 500ms ease;
            width: 320px;
            z-index: 9999;
        }

        .fade {
            opacity: 0 !important;
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

    <img id="splash" alt="" src="images/splash.png" />
    <section id="install-page" class="hide"></section>

    <script>

        var APP_URL = 'http://75.144.228.69:55555/urbanask-alpha/index.html',
        //var BETA_URL = 'http://75.144.228.69:55555/urbangab/index.html',
//            postData2 = atob( '<% =getPostData2() %>' ),
            postData = '<% =getPostData() %>';

        window.onload = function () {

            initializeEnvironment();

            if ( postData ) { //from facebook canvas

                window.location.href = APP_URL;

            } else if ( window.iOSDevice && window.iOSDeviceMode == 'browser' ) {

                hideSplashPage();
                showInstallPage();

            } else {

                window.location.href = APP_URL;

            };

        };

        function showInstallPage() {

            var html =
                  '<div id="install-view">'
                + '<header id="install-header">'
                + '<img src="images/icon.png" />'
                + '<div>urbanAsk</div>'
                + '</header>'
                + '<div>If using Facebook Mobile:</div>'
                + '<ol id="facebook-steps">'
                + '<li class="install-item">1. Tap <img src="images/install-share.png" /> above.</li>'
                + '<li class="install-item">2. Tap <img src="images/install-safari.png" /></li>'
                + '</ol>'
                + '<div>If using Mobile Safari:</div>'
                + '<ol id="install-steps">'
                + '<li class="install-item">1. Tap <img src="images/install-share.png" /> below.</li>'
                + '<li class="install-item">2. Tap <img src="images/install-homescreen.png" /></li>'
                + '<li class="install-item">3. Tap <img src="images/install-add.png" /></li>'
                + '</ol>'
                + '</div>';

            document.getElementById( 'install-page' ).innerHTML = html;
            document.getElementById( 'install-page' ).removeAttribute( 'class' );

        };

        function hideSplashPage() {

            window.setTimeout( function () {

                var splash = document.getElementById( 'splash' );
                splash.className = 'fade';
                window.setTimeout( function () { splash.className = 'hide'; }, 500 );

            }, 1 );

        };

        function initializeEnvironment() {

            if ( window.navigator.userAgent.indexOf( 'iPhone' ) > -1
                || window.navigator.userAgent.indexOf( 'iPod' ) > -1 ) {

                window.iOSDevice = true

                if ( !window.navigator.standalone && window.navigator.userAgent.indexOf( 'Safari' ) > -1 ) {

                    window.iOSDeviceMode = 'browser';

                } else if ( window.navigator.standalone && window.navigator.userAgent.indexOf( 'Safari' ) == -1 ) {

                    window.iOSDeviceMode = 'standalone';

                } else if ( !window.navigator.standalone && window.navigator.userAgent.indexOf( 'Safari' ) == -1 ) {

                    window.iOSDeviceMode = 'webview';

                };

            };

        };

    </script>

    <script runat="server">
    
        Private ReadOnly Property getPostData2() As String
            
            Get
                
                Dim postData As String = Request.Form.Item("signed_request"),
                    base64Data As String = ""
                
                If postData IsNot Nothing AndAlso postData.Length Then
                
           
                    base64Data = postData.Split("."c)(1)
                    'Dim decodedBytes() As Byte = HttpServerUtility.UrlTokenDecode(base64Data).Length
                    'Dim decodedString As String = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(base64Data))
                    
                End If
                
                Return base64Data
                
            End Get
            
        End Property
        
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

