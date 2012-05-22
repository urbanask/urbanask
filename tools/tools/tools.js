window.onload = function () {

    document.getElementById( 'url' ).addEventListener( 'keypress', function () {

        document.getElementById( 'picture' ).src = this.value;

    }, false );

};
