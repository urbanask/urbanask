/// <reference path="/script/jquery.min-vsdoc.js"/>

$( function ()
{

    $( ".circle" ).each( function ()
    {

        var radius = $( this ).outerWidth() / 2,
            left = $( this ).offset().left,
            top = $( this ).offset().top;

        $( this ).data( 
        {

            "radius": radius,
            "left": left,
            "top": top,
            "clicked": false

        } );

    } );



    $( "body" ).data( { "hovering": false } )
    resetCircles( 1 );
    drawLines();



    function drawLines()
    {

/*        var element = $( ".lines" )[0],
            canvas = element.getContext( "2d" );

        element.width = element.width + 1;
        canvas.lineWidth = 1;
        canvas.strokeStyle = "#000000";
        canvas.beginPath();

        $( ".circle" ).each( function ()
        {

            var $this = $( this ),
                nextCircle = $this.next();

            if ( typeof nextCircle != "undefined" )
            {

                var x = Math.round( $this.offset().left + ( $this.outerWidth() / 2 ) ) + 0.5,
                    y = Math.round( $this.offset().top + ( $this.outerWidth() / 2 ) ) + 0.5,
                    nextX = Math.round( nextCircle.offset().left + ( nextCircle.outerWidth() / 2 ) ) + 0.5,
                    nextY = Math.round( nextCircle.offset().top + ( nextCircle.outerWidth() / 2 ) ) + 0.5;

                canvas.moveTo( x, y );
                canvas.lineTo( nextX, nextY );

            };

        } );

        canvas.stroke();
        */

    };

    function moveCircles( circles, expand, sourceX, sourceY )
    {

        circles.each( function ()
        {

            var $this = $( this ),
            data = $this.data(),
            circleX = data.left + data.radius,
            circleY = data.top + data.radius,
            a = Math.abs( sourceY - circleY ),
            b = Math.abs( sourceX - circleX ),
            c = Math.sqrt( ( a * a ) + ( b * b ) ),
            A = Math.acos( b / c ),
            C = 90 * ( Math.PI / 180 ),
            B = C - A,
            sinA = Math.sin( A ),
            sinB = Math.sin( B ),
            sinC = Math.sin( C ),
            newc = c + ( expand / 2 ),
            newa = ( newc * sinA ) / sinC,
            newb = ( newc * sinB ) / sinC,
            newX = sourceX + ( sourceX > circleX ? -newb : newb ),
            newY = sourceY + ( sourceY > circleY ? -newa : newa ),
            left = newX - data.radius,
            top = newY - data.radius;

            $this.animate( 
            {

                "left": left,
                "top": top

            }, 75, function ()
            {

                drawLines();

            } );

        } );

    };


    function expandCircle( circle, expand, event )
    {

        var $this = $( circle ),
            data = $this.data(),
            circleX = data.left + data.radius,
            circleY = data.top + data.radius;

        $( "body" ).data( "hovering", true );

        $this.animate( 
        {

            "width": ( 2 * data.radius ) + expand + "px",
            "height": ( 2 * data.radius ) + expand + "px",
            "left": data.left - ( expand / 2 ) + "px",
            "top": data.top - ( expand / 2 ) + "px",
            "border-top-left-radius": data.radius + ( expand / 2 ) + "px",
            "border-top-right-radius": data.radius + ( expand / 2 ) + "px",
            "border-bottom-left-radius": data.radius + ( expand / 2 ) + "px",
            "border-bottom-right-radius": data.radius + ( expand / 2 ) + "px"

        }, 75 );

        if ( $this.children( "div" ).length )
        {

            var h = data.radius + ( expand / 2 ),
                a = h / Math.sqrt( 2 ),
                size = 2 * a,
                padding = h - a;

            $this.children( "div" ).animate( 
            {

                "left": padding + "px",
                "top": padding + "px",
                "width": size + "px",
                "height": size + "px",
                "font-size": size + "px",
                "line-height": size + "px"

            }, 75 );

        };

        moveCircles( $this.siblings( ".circle" ), expand, circleX, circleY );

    };



    function resetCircles( speed )
    {

        $( ".circle" ).each( function ()
        {

            var $this = $( this ),
                data = $this.data();

            $this.stop().animate( 
             {

                 "width": ( 2 * data.radius ) + "px",
                 "height": ( 2 * data.radius ) + "px",
                 "left": data.left + "px",
                 "top": data.top + "px",
                 "border-top-left-radius": data.radius + "px",
                 "border-top-right-radius": data.radius + "px",
                 "border-bottom-left-radius": data.radius + "px",
                 "border-bottom-right-radius": data.radius + "px"

             }, speed );

            if ( $this.children( "div" ).length )
            {

                var h = data.radius,
                    a = h / Math.sqrt( 2 ),
                    size = 2 * a,
                    padding = h - a;

                $this.children( "div" ).animate( 
                {
                    "left": padding + "px",
                    "top": padding + "px",
                    "width": size + "px",
                    "height": size + "px",
                    "font-size": size + "px",
                    "line-height": size + "px"

                }, speed );

            };

        } );

        drawLines();
        $( "body" ).data( "hovering", false );

    };



    function inCircle( circle, x, y )
    {

        var radius = circle.outerWidth() / 2,
            circleX = circle.offset().left + radius,
            circleY = circle.offset().top + radius,
            xDiff = ( circleX - x ),
            yDiff = ( circleY - y ),
            mouseDistance = Math.sqrt( ( xDiff * xDiff ) + ( yDiff * yDiff ) );

        return ( mouseDistance > radius ? false : true );

    };



    $( ".circle" ).mouseleave( function ( event )
    {

        resetCircles( 75 );
        $( this ).data( "clicked", false );

    } );



    $( ".circle" ).mousemove( function ( event )
    {

        if ( inCircle( $( this ), event.pageX, event.pageY ) )
        {

            if ( !$( "body" ).data( "hovering" ) )
            {

                expandCircle( this, 50, event );

            };

        }
        else
        {

            if ( $( "body" ).data( "hovering" ) )
            {

                resetCircles( 75 );
                $( this ).data( "clicked", false );

            };

        };

    } );



    $( ".circle" ).click( function ( event )
    {

        if ( $( this ).data( "clicked" ) )
        {

            resetCircles( 75 );
            $( this ).data( "clicked", false );

        }
        else
        {

            if ( inCircle( $( this ), event.pageX, event.pageY ) )
            {

                $( this ).data( "clicked", true );
                expandCircle( this, 200, event );

            }
            else
            {

                resetCircles( 75 );
                $( this ).data( "clicked", false );

            };

        };



    } );


} );
