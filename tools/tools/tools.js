window.onload = function () {

    document.getElementById( 'url' ).addEventListener( 'keyup', function () {

        var picture = document.getElementById( 'picture' );
        picture.removeAttribute( 'style' );
        picture.src = this.value;

        window.setTimeout( function () {

            if ( picture.width > picture.height ) {

                x = ( picture.width - picture.height ) / 2;
                picture.style.height = '50px';

            } else if ( picture.width < picture.height ) {

                y = ( picture.height - picture.width ) / 2;
                picture.style.width = '50px';

            } else {

                picture.style.height = '50px';
                picture.style.width = '50px';

            };

            window.setTimeout( function () {

                if ( picture.width > picture.height ) {

                    picture.style.left = '-' + ( ( picture.width - picture.height ) / 2 ) + 'px';

                } else if ( picture.width < picture.height ) {

                    picture.style.top = '-' + ( ( picture.height - picture.width ) / 2 ) + 'px';

                };

            }, 50 );

        }, 50 );

    }, false );

};
