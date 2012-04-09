
var sessionId = "677814a9-1e60-4715-bdd1-0a34b82075a0",
sessionKey = "f238df06-abd0-42f7-a4b8-cc01df78fd38",
baseUrl = "http://75.144.228.69:55555";
//    baseUrl = "http://localhost";

var myScroll,
latitude = 0.0,
longitude = 0.0,
accuracy = 0.0,
geo,
questionColumns =
{
    "questionId": 0,
    "userId": 1,
    "username": 2,
    "question": 3,
    "link": 4,
    "radius": 5,
    "latitude": 6,
    "longitude": 7,
    "timestamp": 8,
    "resolved": 9,
    "answers": 10
};


document.addEventListener( "DOMContentLoaded", onReady, false );
document.addEventListener( "touchmove", function ( event ) { event.preventDefault(); }, false );

function onReady()
{
    
    document.removeEventListener( "DOMContentLoaded", onReady, false );
    
    if ( navigator.userAgent.match( /iPhone/i ) || navigator.userAgent.match( /iPod/i ) )
    {
        
        $( "body" ).data( "browser", "iPhone" );
        
    };
    
    showGeo();
    
    setTimeout( function ()
               {
               
               showQuestions();
               
               }, 200 );
    
    $( ".ask" ).bind( "submit", function ( event )
                     {
                     
                     sendQuestion();
                     return false;
                     
                     } );
    
    $( "footer li" ).bind( "click", function ()
                          {
                          
                          var tab = $( this ).data( "tab" );
                          
                          switch ( tab )
                          {
                          case "questions":
                          
                          showQuestions();
                          break;
                          
                          case "map":
                          
                          showMap();
                          break;
                          
                          case "top":
                          
                          showTop();
                          showGeo();
                          break;
                          
                          case "profile":
                          
                          showProfile();
                          break;
                          
                          };
                          
                          } );
    
    setGeolocation();
    setInterval( setGeolocation, 60000 );
    
};

function setGeolocation()
{
    
    geo = navigator.geolocation.watchPosition( 
                                              function ( position )
                                              {
                                              
                                              latitude = position.coords.latitude;
                                              longitude = position.coords.longitude;
                                              accuracy = position.coords.accuracy;
                                              
                                              $( ".geo" ).append( latitude.toString().substr( 0, 9 ) + "," + longitude.toString().substr( 0, 10 ) + "," + accuracy.toString().substr( 0, 4 ) + "<br />" );
                                              
                                              },
                                              function ()
                                              {
                                              
                                              alert( "Could not determine your GPS location. Check to see if location services are locked or disabled.." );
                                              
                                              },
                                              { maximumAge: 50000, enableHighAccuracy: true } );
    
    setTimeout( function () { navigator.geolocation.clearWatch( geo ) }, 5000 );
    
};

function showGeo()
{
    
    $( ".view" ).empty().append( '<section class="geo scrollable vertical"></section>' );
    
};

function showQuestions()
{
    
    var queryString = "fromLatitude=38.375&fromLongitude=-121.583333&toLatitude=38.85&toLongitude=-121.033333&count=25&age=30",
    url = "/api/questions",
    session = createSession( url );
    
    $( ".view" ).empty();
    $.ajax( baseUrl + url,
           {
           "type": "GET",
           "data": queryString,
           "headers": { "x-session": session },
           "cache": false,
           "success": function ( data, status )
           {
           
           $( "body" ).data( "questions", $.parseJSON( data ) )
           var questions = $( "body" ).data( "questions" );
           $( ".view" ).append( '<section class="questions"></section>' );
           
           if ( $( "body" ).data( "browser" ) == "iPhone" )
           {
           
           $( ".questions" ).addClass( "scrollable vertical" );
           
           };
           
           for ( var index = 0; index < questions.length; index++ )
           {
           
           var question = questions[index],
           answers = "",
           radius = "",
           age = Math.floor( ( new Date().getTime() - new Date( question[questionColumns.timestamp] ).getTime() ) / ( 1000 * 60 ) );
           
           if ( question[questionColumns.answers] > 10 )
           {
           
           answers = '<img class="resolved" src="images/resolved.png" />';
           
           }
           else
           {
           
           answers = '<div class="answers"><div>' + question[questionColumns.answers] + '</div></div>';
           
           };
           
           if ( age > 60 )
           {
           
           age = Math.floor( age / 60 ).toString() + " h";
           
           }
           else if ( age == 0 )
           {
           
           age = "now";
           
           }
           else
           {
           
           age = age.toString() + " m";
           
           };
           /*
            if ( question[questionColumns.radius] == 1 )
            {
            
            radius = '<img class="radius" src="images/walk28x16.png" />';
            
            }
            else if ( question[questionColumns.radius] == 2 )
            {
            
            radius = '<img class="radius" src="images/bike28x16.png" />';
            
            }
            else if ( question[questionColumns.radius] == 3 )
            {
            
            radius = '<img class="radius" src="images/drive28x16.png" />';
            
            };
            */
           
           var html =
           '<div class="question"'
           + 'data-question-id="' + question[questionColumns.questionId] + '" '
           + 'data-latitude="' + question[questionColumns.latitude] + '" '
           + 'data-longitude="' + question[questionColumns.longitude] + '">'
           + answers
           + '<div class="username question-header" data-user-id="' + question[questionColumns.userId] + '">'
           + question[questionColumns.username]
           + '</div>'
           + '<div class="body">' + question[questionColumns.question] + '</div>'
           + radius
           + '<div class="age question-header">' + age + '</div>'
           + '</div>'
           
           $( ".questions" ).append( html );
           
           };
           
           $( ".question" ).bind( "click", showQuestion );
           
           },
           "error": function ( obj, status, error )
           {
           
           $( "body" ).append( error + "<br />" );
           
           }
           
           } );
    
    
};

function sendQuestion()
{
    
    if ( $( ".ask-text" ).val() != "" && latitude != 0 )
    {
        
        var queryString = "0~" + latitude + "~" + longitude + "~" + $( ".ask-text" ).val(),
        url = "/messaging/questions",
        session = createSession( url );
        
        $.ajax( baseUrl + url,
               {
               
               "type": "POST",
               "data": queryString,
               "headers": { "x-session": session },
               "cache": false,
               "success": function ( data, status )
               {
               
               $( ".ask-text" ).val( "" );
               $( ".ask-button" ).focus();
               
               },
               "error": function ( obj, status, error )
               {
               
               $( ".view" ).append( error + "<br />" );
               
               }
               
               } );
        
    };
    
};

function showQuestion()
{
    
    var resource = "/api/questions/" + $( this ).data( "questionId" ),
    session = createSession( resource  );
    
    $.ajax( baseUrl + resource,
           {
           
           "type": "POST",
           "headers": { "x-session": session },
           "cache": false,
           "success": function ( data, status )
           {
           
           var question = $.parseJSON( data )[0];
           $( ".view" ).empty().append( '<section class="question-view"></section>' );
           
           if ( $( "body" ).data( "browser" ) == "iPhone" )
           {
           
           $( ".question-view" ).addClass( "scrollable vertical" );
           
           };
           
           var answers = "",
           age = Math.floor( ( new Date().getTime() - new Date( question[questionColumns.timestamp] ).getTime() ) / ( 1000 * 60 ) );
           
           if ( question[questionColumns.answers] > 10 )
           {
           
           answers = '<img class="resolved" src="images/resolved.png" />';
           
           }
           else
           {
           
           answers = '<div class="answers"><div>' + question[questionColumns.answers] + '</div></div>';
           
           };
           
           if ( age > 60 )
           {
           
           age = Math.floor( age / 60 ).toString() + " h";
           
           }
           else if ( age == 0 )
           {
           
           age = "now";
           
           }
           else
           {
           
           age = age.toString() + " m";
           
           };
           
           var html =
           '<div class="question"'
           + 'data-question-id="' + question[questionColumns.questionId] + '" '
           + 'data-latitude="' + question[questionColumns.latitude] + '" '
           + 'data-longitude="' + question[questionColumns.longitude] + '">'
           + answers
           + '<div class="username question-header" data-user-id="' + question[questionColumns.userId] + '">'
           + question[questionColumns.username]
           + '</div>'
           + '<div class="body">' + question[questionColumns.question] + '</div>'
           + '<div class="age question-header">' + age + '</div>'
           + '</div>'
           
           $( ".question-view" ).append( html );
           
           },
           "error": function ( obj, status, error )
           {
           
           $( ".view" ).empty().append( error + "<br />" );
           
           }
           
           } );
    
};

function showProfile()
{
    
    var url = "/api/account",
    session = createSession( url );
    
    $.ajax( baseUrl + url,
           {
           "type": "GET",
           "headers": { "x-session": session },
           "cache": false,
           "success": function ( data, status )
           {
           
           $( ".view" ).empty().append( '<section class="profile">' + data + '</section>' );
           
           },
           "error": function ( obj, status, error )
           {
           
           $( ".view" ).empty().append( error + "<br />" );
           
           }
           
           } );
    
};

function showMap()
{
    
    $( ".view" ).empty().append(
                                "<img src='http://maps.google.com/maps/api/staticmap?center=" 
                                + latitude + "," + longitude 
                                + "&zoom=15&size=320x369&maptype=roadmap&sensor=true&markers=color:black%7Clabel:ABC%7C" 
                                + latitude + "," + longitude 
                                + "' />" );
    
};

function showTop()
{
    
    
};

function createSession( url )
{
    
    return sessionId + ":" + toBase64UrlString(
                                               Crypto.util.bytesToBase64(
                                                                         Crypto.HMAC( Crypto.SHA1, url + sessionId, sessionKey, { asBytes: true } ) ) );
    
};

function toBase64UrlString( base64String )
{
    
    return base64String.replace( /\+/g, "-" ).replace( /\//g, "_" ).replace( /=/g, "" );
                                                      
                                                      };
                                                      
                                                      
                                                      
                                                      
                                                      
    /*
     * Crypto-JS v2.3.0
     * http://code.google.com/p/crypto-js/
     * Copyright (c) 2011, Jeff Mott. All rights reserved.
     * http://code.google.com/p/crypto-js/wiki/License
     */
                                                      
                                                      if ( typeof Crypto == "undefined" || !Crypto.util ) (function ()
                                                                                                           {
                                                                                                           var i = window.Crypto = {}, n = i.util = { rotl: function ( a, c ) { return a << c | a >>> 32 - c }, rotr: function ( a, c ) { return a << 32 - c | a >>> c }, endian: function ( a ) { if ( a.constructor == Number ) return n.rotl( a, 8 ) & 16711935 | n.rotl( a, 24 ) & 4278255360; for ( var c = 0; c < a.length; c++ ) a[c] = n.endian( a[c] ); return a }, randomBytes: function ( a ) { for ( var c = []; a > 0; a-- ) c.push( Math.floor( Math.random() * 256 ) ); return c }, bytesToWords: function ( a )
                                                                                                           {
                                                                                                           for ( var c = [], b = 0, d = 0; b < a.length; b++, d += 8 ) c[d >>> 5] |= a[b] << 24 -
                                                                                                           d % 32; return c
                                                                                                           }, wordsToBytes: function ( a ) { for ( var c = [], b = 0; b < a.length * 32; b += 8 ) c.push( a[b >>> 5] >>> 24 - b % 32 & 255 ); return c }, bytesToHex: function ( a ) { for ( var c = [], b = 0; b < a.length; b++ ) { c.push( ( a[b] >>> 4 ).toString( 16 ) ); c.push( ( a[b] & 15 ).toString( 16 ) ) } return c.join( "" ) }, hexToBytes: function ( a ) { for ( var c = [], b = 0; b < a.length; b += 2 ) c.push( parseInt( a.substr( b, 2 ), 16 ) ); return c }, bytesToBase64: function ( a )
                                                                                                           {
                                                                                                           if ( typeof btoa == "function" ) return btoa( j.bytesToString( a ) ); for ( var c = [], b = 0; b < a.length; b += 3 ) for ( var d = a[b] << 16 | a[b + 1] <<
                                                                                                                                                                                                                                      8 | a[b + 2], e = 0; e < 4; e++ ) b * 8 + e * 6 <= a.length * 8 ? c.push( "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt( d >>> 6 * ( 3 - e ) & 63 ) ) : c.push( "=" ); return c.join( "" )
                                                                                                           }, base64ToBytes: function ( a )
                                                                                                           {
                                                                                                           if ( typeof atob == "function" ) return j.stringToBytes( atob( a ) ); a = a.replace( /[^A-Z0-9+\/]/ig, "" ); for ( var c = [], b = 0, d = 0; b < a.length; d = ++b % 4 ) d != 0 && c.push( ( "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".indexOf( a.charAt( b - 1 ) ) & Math.pow( 2, -2 * d + 8 ) - 1 ) << d * 2 | "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".indexOf( a.charAt( b ) ) >>>
                                                                                                                                                                                                                                                                                                     6 - d * 2 ); return c
                                                                                                           } 
                                                                                                           }; i = i.charenc = {}; i.UTF8 = { stringToBytes: function ( a ) { return j.stringToBytes( unescape( encodeURIComponent( a ) ) ) }, bytesToString: function ( a ) { return decodeURIComponent( escape( j.bytesToString( a ) ) ) } }; var j = i.Binary = { stringToBytes: function ( a ) { for ( var c = [], b = 0; b < a.length; b++ ) c.push( a.charCodeAt( b ) & 255 ); return c }, bytesToString: function ( a ) { for ( var c = [], b = 0; b < a.length; b++ ) c.push( String.fromCharCode( a[b] ) ); return c.join( "" ) } }
                                                                                                           } )();
                                                      (function ()
                                                       {
                                                       var i = Crypto, n = i.util, j = i.charenc, a = j.UTF8, c = j.Binary, b = i.SHA1 = function ( d, e ) { var f = n.wordsToBytes( b._sha1( d ) ); return e && e.asBytes ? f : e && e.asString ? c.bytesToString( f ) : n.bytesToHex( f ) }; b._sha1 = function ( d )
                                                       {
                                                       if ( d.constructor == String ) d = a.stringToBytes( d ); var e = n.bytesToWords( d ), f = d.length * 8; d = []; var k = 1732584193, g = -271733879, l = -1732584194, m = 271733878, o = -1009589776; e[f >> 5] |= 128 << 24 - f % 32; e[( f + 64 >>> 9 << 4 ) + 15] = f; for ( f = 0; f < e.length; f += 16 )
                                                       {
                                                       for ( var q = k, r = g, s = l, t = m, u = o, h = 0; h < 80; h++ )
                                                       {
                                                       if ( h < 16 ) d[h] = e[f +
                                                                              h]; else { var p = d[h - 3] ^ d[h - 8] ^ d[h - 14] ^ d[h - 16]; d[h] = p << 1 | p >>> 31 } p = ( k << 5 | k >>> 27 ) + o + ( d[h] >>> 0 ) + ( h < 20 ? ( g & l | ~g & m ) + 1518500249 : h < 40 ? ( g ^ l ^ m ) + 1859775393 : h < 60 ? ( g & l | g & m | l & m ) - 1894007588 : ( g ^ l ^ m ) - 899497514 ); o = m; m = l; l = g << 30 | g >>> 2; g = k; k = p
                                                       } k += q; g += r; l += s; m += t; o += u
                                                       } return [k, g, l, m, o]
                                                       }; b._blocksize = 16; b._digestsize = 20
                                                       } )();
                                                      (function () { var i = Crypto, n = i.util, j = i.charenc, a = j.UTF8, c = j.Binary; i.HMAC = function ( b, d, e, f ) { if ( d.constructor == String ) d = a.stringToBytes( d ); if ( e.constructor == String ) e = a.stringToBytes( e ); if ( e.length > b._blocksize * 4 ) e = b( e, { asBytes: true } ); var k = e.slice( 0 ); e = e.slice( 0 ); for ( var g = 0; g < b._blocksize * 4; g++ ) { k[g] ^= 92; e[g] ^= 54 } b = b( k.concat( b( e.concat( d ), { asBytes: true } ) ), { asBytes: true } ); return f && f.asBytes ? b : f && f.asString ? c.bytesToString( b ) : n.bytesToHex( b ) } } )();
                                                      
