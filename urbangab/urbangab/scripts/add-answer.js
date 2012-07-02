function showAddAnswer( question ) {

    var addAnswer = document.getElementById( 'add-answer-page' ),
        cancelButton = document.getElementById( 'cancel-answer-button' ),
        answerText = document.getElementById( 'answer-text' ),
        locations = document.getElementById( 'locations' ),
        locationsView = document.getElementById( 'locations-view' ),
        places = new google.maps.places.PlacesService( document.createElement( 'div' ) ),
        scrollLocations;

    places.searchRequest = {

        location: new google.maps.LatLng( question.latitude, question.longitude ),
        radius: LOCATION_RADIUS,
        types: ['establishment']

    };

    addListeners();
    answerText.value = '';
    autocompleteLocations();
    addAnswer.removeClass( 'hide' );
    window.setTimeout( function () { addAnswer.removeClass( 'top-slide' ); }, 50 );

    if ( window.deviceInfo.brand != 'ios' ) {

        answerText.focus();

    };

    if ( window.deviceInfo.brand == 'ios'
        && window.deviceInfo.type == 'handheld'
        && window.deviceInfo.mode == 'browser' ) {

        window.scrollTo( 0, 0 );

    };

    if ( window.deviceInfo.iscroll ) {

        scrollLocations = new iScroll( 'locations-view' );

    };

    function close() {

        addAnswer.addClass( 'top-slide' );
        window.setTimeout( function () { addAnswer.addClass( 'hide' ) }, 800 );
        removeListeners();

        if ( scrollLocations ) {

            scrollLocations.destroy();
            scrollLocations = null;

        };

    };

    function autocompleteLocations() {

        places.searchRequest.name = answerText.value;
        places.search( places.searchRequest, function ( results, status ) {

            var html = '';

            for ( var index = 0; index < results.length; index++ ) {

                var existingAnswerClass = '',
                    existingAnswer = '';

                if ( question[QUESTION_COLUMNS.answers].item( results[index].id, ANSWER_COLUMNS.locationId ) ) {

                    existingAnswerClass = ' existing-answer';
                    existingAnswer = '<div class="existing-answer-caption">' + STRINGS.existingAnswer + '</div>';

                };

                html +=
                        '<li class="location-item list-item' + existingAnswerClass + '" '
                    + 'data-location-id="' + results[index].id + '" '
                    + 'data-reference="' + results[index].reference + '" '
                    + 'data-address="' + results[index].vicinity + '" '
                    + 'data-latitude="' + results[index].geometry.location.lat() + '" '
                    + 'data-longitude="' + results[index].geometry.location.lng() + '" '
                    + 'data-name="' + results[index].name.htmlEncode() + '">'
                    + '<div class="location-body">' + results[index].name + '</div>'
                    + '<div class="location-info">' + results[index].vicinity + '</div>'
                    + existingAnswer
                    + '</li>';

            };

            locations.innerHTML = html;
            updateScrollLocations();

        } );

    };

    function updateScrollLocations() {

        if ( window.deviceInfo.iscroll ) {

            setTimeout( function () {

                scrollLocations.refresh();

            }, 0 );

        };

    };

    function locationsClick( event ) {

        selectItem( event );

        window.setTimeout( function () {

            var locationItem = event.target.closestByClassName( 'location-item' );

            if ( locationItem && !locationItem.hasClass( 'existing-answer' ) ) {

                showAnswerConfirm( locationItem )

            };

            window.setTimeout( function () { unselectItem( event ); }, 100 );

        }, 100 );

    };

    function keyboardUp( event ) {

        addAnswer.addClass( 'add-answer-keyboard-up' );
        locationsView.addClass( 'locations-view-keyboard-up' );
        updateScrollLocations();

    };

    function keyboardDown( event ) {

        addAnswer.removeClass( 'add-answer-keyboard-up' );
        locationsView.removeClass( 'locations-view-keyboard-up' );
        updateScrollLocations();

    };

    function answerSubmit( event ) {

        event.preventDefault();

    };

    function removeListeners() {

        addAnswer.removeEventListener( 'close', close, false );
        locations.removeEventListener( 'click', locationsClick, false );
        cancelButton.removeEventListener( 'click', close, false );
        answerText.removeEventListener( 'keyup', autocompleteLocations, false );
        document.getElementById( 'answer' ).removeEventListener( 'submit', answerSubmit, false );

        if ( window.deviceInfo.brand == 'ios'
            && window.deviceInfo.type == 'handheld' ) {

            answerText.removeEventListener( 'focus', keyboardUp, false );
            answerText.removeEventListener( 'blur', keyboardDown, false );

        };

        if ( !window.deviceInfo.mobile ) {

            locations.removeEventListener( 'mouseover', hoverItem, false );
            locations.removeEventListener( 'mouseout', unhoverItem, false );

        };

    };

    function addListeners() {

        addAnswer.addEventListener( 'close', close, false );
        locations.addEventListener( 'click', locationsClick, false );
        cancelButton.addEventListener( 'click', close, false );
        answerText.addEventListener( 'keyup', autocompleteLocations, false );
        document.getElementById( 'answer' ).addEventListener( 'submit', answerSubmit, false );

        if ( window.deviceInfo.brand == 'ios'
            && window.deviceInfo.type == 'handheld' ) {

            answerText.addEventListener( 'focus', keyboardUp, false );
            answerText.addEventListener( 'blur', keyboardDown, false );

        };

        if ( !window.deviceInfo.mobile ) {

            locations.addEventListener( 'mouseover', hoverItem, false );
            locations.addEventListener( 'mouseout', unhoverItem, false );

        };

    };

    function saveAnswer( question, location ) {

        var from = new google.maps.LatLng( question.latitude, question.longitude ),
            to = new google.maps.LatLng( location.latitude, location.longitude ),
            distance = window.Math.floor( google.maps.geometry.spherical.computeDistanceBetween( from, to ) ),
            message = question.questionId
                + '~' + location.locationId
                + '~' + location.reference
                + '~' + location.name
                + '~' + location.address
                + '~' + location.note
                + '~' + location.link
                + '~' + location.phone
                + '~' + location.latitude
                + '~' + location.longitude
                + '~' + distance,
            resource = '/messaging/answers',
            session = getSession( resource );

        document.getElementById( 'answer-text' ).value = '';
        close();
        scrollUp();

        ajax( API_URL + resource, {

            "type": "POST",
            "data": message,
            "headers": { "x-session": session },
            "cache": false,
            "success": function ( data, status ) {

                //create answer
                var answer = [];
                answer[ANSWER_COLUMNS.answerId] = 0;
                answer[ANSWER_COLUMNS.questionId] = question.questionId;
                answer[ANSWER_COLUMNS.userId] = _account[ACCOUNT_COLUMNS.userId];
                answer[ANSWER_COLUMNS.username] = _account[ACCOUNT_COLUMNS.username];
                answer[ANSWER_COLUMNS.reputation] = formatNumber( getReputation() );
                answer[ANSWER_COLUMNS.locationId] = location.locationId;
                answer[ANSWER_COLUMNS.location] = location.name;
                answer[ANSWER_COLUMNS.locationAddress] = location.address;
                answer[ANSWER_COLUMNS.note] = location.note;
                answer[ANSWER_COLUMNS.link] = location.link;
                answer[ANSWER_COLUMNS.phone] = location.phone;
                answer[ANSWER_COLUMNS.latitude] = location.latitude;
                answer[ANSWER_COLUMNS.longitude] = location.longitude;
                answer[ANSWER_COLUMNS.distance] = distance;
                answer[ANSWER_COLUMNS.timestamp] = new window.Date();
                answer[ANSWER_COLUMNS.selected] = 0;
                answer[ANSWER_COLUMNS.voted] = 0;
                answer[ANSWER_COLUMNS.votes] = 0;

                var questionItem = _nearbyQuestions.item( question.questionId )
                    || _questions.item( question.questionId )
                    || _everywhereQuestions.item( question.questionId );
                if ( questionItem ) { updateAnswerCount( question.questionId  ); };
                question[QUESTION_COLUMNS.answers].push( answer );
                question[QUESTION_COLUMNS.answerCount] += 1;

                var html = getAnswerItem( answer, question, { letter: '&#x2022;', newItem: true } ),
                        markers = '&markers=color:gray|size:mid|' + location.latitude + "," + location.longitude,
                        questionMap = document.getElementById( 'question-map' ),
                        mapUrl = questionMap.getAttribute( 'src' ).replace( '&zoom=12', '' ),
                        answers = document.getElementById( 'answers' ),
                        answerCount = document.getElementById( 'question-view' ).childByClassName( 'answer-count' );

                //show answer
                document.getElementById( 'answers' ).removeClass( 'hide' );
                document.getElementById( 'no-answers' ).addClass( 'hide' );
                answers.insertAdjacentHTML( 'afterBegin', html );
                window.setTimeout( function () { answers.firstChild.removeClass( 'height-zero' ) }, 500 );
                questionMap.setAttribute( 'src', mapUrl + markers );

                //show answer count
                answerCount.addClass( 'fadeable' ).addClass( 'fade' );
                window.setTimeout( function () {

                    answerCount.textContent = question[QUESTION_COLUMNS.answerCount];
                    answerCount.removeClass( 'fade' );
                    window.setTimeout( function () { answerCount.removeClass( 'fadeable' ); }, 1000 );

                }, 750 );

                showNotification( STRINGS.notificationAnswerQuestion, { footer: STRINGS.notification.answerSaved } );
                showToolbar( 'question', { question: question } );

                if ( questionItem ) {

                    showQuestions( _account[ACCOUNT_COLUMNS.regions][0][REGION_COLUMNS.name], _questions, document.getElementById( 'questions' ) );
                    showQuestions( STRINGS.questionsNearby, _nearbyQuestions, document.getElementById( 'nearby-questions' ) );
                    showQuestions( STRINGS.questionsEverywhere, _everywhereQuestions, document.getElementById( 'everywhere-questions' ) );

                };

            },
            "error": function ( response, status, error ) {

                error == 'Unauthorized'
                    ? logoutApp()
                    : showMessage( STRINGS.error.saveAnswer );

            }

        } );

    };

    function updateAnswerCount( questionId ) {

        var nearby = _nearbyQuestions.item( questionId ),
            question = _questions.item( questionId ),
            everywhere = _everywhereQuestions.item( questionId );

        if ( nearby ) { nearby[QUESTION_COLUMNS.answerCount] += 1; };
        if ( question ) { question[QUESTION_COLUMNS.answerCount] += 1; };
        if ( everywhere ) { everywhere[QUESTION_COLUMNS.answerCount] += 1; };

    };

    function showAnswerConfirm( locationItem ) {

        var answerConfirmPage = document.getElementById( 'answer-confirm-page' ),
            answerConfirm = document.getElementById( 'answer-confirm' ),
            answerText = document.getElementById( 'answer-text' ),
            location = document.getElementById( 'answer-confirm-location' ),
            map = document.getElementById( 'answer-confirm-map' ),
            ok = document.getElementById( 'answer-confirm-ok' ),
            cancel = document.getElementById( 'answer-confirm-cancel' ),
            note = document.getElementById( 'location-note' ),
            viewport = document.getElementById( 'viewport' ),
            mapUrl = 'http://maps.google.com/maps/api/staticmap?center='
                + question.latitude + ',' + question.longitude
                + '&size=260x150'
                + ( window.deviceInfo.mobile ? '&scale=2' : '' )
                + '&maptype=roadmap&sensor=true&style=hue:blue&markers=color:black|size:mid|'
                + question.latitude + ',' + question.longitude
                + '&markers=color:gray|size:mid|' + locationItem.getDataset( 'latitude' ) + "," + locationItem.getDataset( 'longitude' );

        answerText.blur();
        answerText.disabled = true;

        if ( location.firstChild ) { location.removeChild( location.firstChild ); };
        location.appendChild( locationItem.cloneNode( true ).removeClass( 'select' ).removeClass( 'hover' ).addClass( 'confirm-item' ) );
        note.value = '';
        map.setAttribute( 'src', mapUrl );

        answerConfirmPage.removeClass( 'hide' );
        answerConfirm.style.top = ( ( viewport.clientHeight - answerConfirm.clientHeight ) / 2 ) + 'px';
        answerConfirm.style.left = ( ( viewport.clientWidth - answerConfirm.clientWidth ) / 2 ) + 'px';
        window.setTimeout( function () { answerConfirmPage.removeClass( 'fade' ); }, 50 );

        addListeners();

        function close() {

            removeListeners();

            answerConfirmPage.addClass( 'fade' );
            window.setTimeout( function () { answerConfirmPage.addClass( 'hide' ); }, 1000 );

        };

        function okClick( event ) {

            event.preventDefault();
            ok.focus();
            answerText.disabled = false;

            close();

            places.getDetails( { reference: locationItem.getDataset( 'reference' ) }, function ( place, status ) {

                if ( status == google.maps.places.PlacesServiceStatus.OK ) {

                    saveAnswer( 
                        question,
                        {
                            "name": locationItem.getDataset( 'name' ),
                            "address": locationItem.getDataset( 'address' ),
                            "locationId": locationItem.getDataset( 'location-id' ),
                            "reference": locationItem.getDataset( 'reference' ),
                            "latitude": locationItem.getDataset( 'latitude' ),
                            "longitude": locationItem.getDataset( 'longitude' ),
                            "note": note.value.trim(),
                            "link": place.website ? place.website : '',
                            "phone": place.formatted_phone_number ? place.formatted_phone_number : ''
                        }
                    );

                } else {

                    showMessage( status );

                };

            } );

        };

        function cancelClick( event ) {

            event.preventDefault();
            cancel.focus();

            answerText.disabled = false;
            answerText.focus();

            close();

        };

        function removeListeners() {

            answerConfirm.removeEventListener( 'submit', okClick, false );
            ok.removeEventListener( 'click', okClick, false );
            ok.removeEventListener( 'touchstart', selectButton, false );
            ok.removeEventListener( 'touchend', unselectButton, false );
            ok.removeEventListener( 'mousedown', selectButton, false );
            ok.removeEventListener( 'mouseup', unselectButton, false );
            cancel.removeEventListener( 'click', cancelClick, false );
            cancel.removeEventListener( 'touchstart', selectButton, false );
            cancel.removeEventListener( 'touchend', unselectButton, false );
            cancel.removeEventListener( 'mousedown', selectButton, false );
            cancel.removeEventListener( 'mouseup', unselectButton, false );

        };

        function addListeners() {

            answerConfirm.addEventListener( 'submit', okClick, false );
            ok.addEventListener( 'click', okClick, false );
            ok.addEventListener( 'touchstart', selectButton, false );
            ok.addEventListener( 'touchend', unselectButton, false );
            ok.addEventListener( 'mousedown', selectButton, false );
            ok.addEventListener( 'mouseup', unselectButton, false );
            cancel.addEventListener( 'click', cancelClick, false );
            cancel.addEventListener( 'touchstart', selectButton, false );
            cancel.addEventListener( 'touchend', unselectButton, false );
            cancel.addEventListener( 'mousedown', selectButton, false );
            cancel.addEventListener( 'mouseup', unselectButton, false );

        };

    };

};
