<%@ Import Namespace="System" %>
<%@ Page Language="VB" Debug="true" %>

<!doctype html>
<html lang="en">
<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# urbanask: http://ogp.me/ns/fb/urbanask#">
    <title>urbanAsk</title>

    <meta property="fb:app_id"      content="267603823260704" /> 
    <meta property="og:type"        content="urbanask:question" /> 
    <meta property="og:image"       content="http://urbanask.com/images/icon-large.png" />
    <meta property="og:url"         content="<% =getUrl() %>" /> 
    <meta property="og:title"       content="&quot;<% =getTitle() %>&quot;" />
    <meta property="og:description" content="Can you help me find this?" /> 

    <meta name="apple-mobile-web-app-capable"           content="yes" />
    <meta name="viewport"                               content="width=device-width, initial-scale=1, user-scalable=no" />
    <meta name="apple-mobile-web-app-status-bar-style"  content="black" />
    <link rel="apple-touch-startup-image"               href="images/splash.png" /> 
    <link rel="apple-touch-icon"                        href="images/icon.png" />
    <link rel="icon"                                    type="image/png" href="images/icon.png" />

</head>

<body>

    <script>

        //var APP_URL = 'http://75.144.228.69:55555/urbangab/index.html';
        var APP_URL = 'http://urbanask.com/index.html';

        window.onload = function () {

            var questionId = window.location.queryString()['question-id'];
            window.location.href = APP_URL + '?question-id=' + questionId;

        };

        window.location.queryString = function () {

            var result = {},
                queryString = location.search.substring( 1 ),
                re = /([^&=]+)=([^&]*)/g,
                m;

            while ( m = re.exec( queryString ) ) {

                if ( typeof result[decodeURIComponent( m[1] )] == 'undefined' ) {

                    result[decodeURIComponent( m[1] )] = decodeURIComponent( m[2] );

                } else {

                    if ( typeof result[decodeURIComponent( m[1] )] == 'string' ) {

                        result[decodeURIComponent( m[1] )] = [result[decodeURIComponent( m[1] )]];

                    };

                    result[decodeURIComponent( m[1] )].push( decodeURIComponent( m[2] ) )

                };

            };

            return result;

        };

    </script>

    <script runat="server">
    
        private Const APP_URL = "http://urbanask.com/questions.aspx"
        
        Private ReadOnly Property getUrl() As String
            
            Get
                
                Dim url As String = APP_URL
                
                url += "?title=" + Request.QueryString.Item("title") _
                    + "&question-id=" + Request.QueryString.Item("question-id")
                
                Return url
                
            End Get

        End Property
        
        Private ReadOnly Property getTitle() As String
            
            Get

                Dim title As String = Request.QueryString.Item("title")
                
                Return title
                
            End Get
            
        End Property
        
    </script>

</body>
</html>

