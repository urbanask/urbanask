/// <reference path="/scripts/strings-en.js" />

'use strict';

(function() //( window )
{

    var document = window.document;

    if ( window.navigator.userAgent.indexOf( 'iPhone' ) > -1 || window.navigator.userAgent.indexOf( 'iPod' ) > -1 ) {

        document.body.dataset.browser = 'iPhone';
        if ( !window.navigator.standalone ) alert( 'install me' );

    } else {

        document.body.dataset.browser = '';

    };

    window.onload = function () {

        var _currentLocation = {},
            _session = {},
            _account = [],
            _userQuestions = [],
            _questions = [],
            _selectedQuestion = [],
            _swipeY = 0,
            _places,
            _searchRequest,
            LOCATION_RADIUS = 15000,
            LOCATION_TYPES = 'establishment',
            QUESTION_COLUMNS = {

                "questionId": 0,
                "userId": 1,
                "username": 2,
                "reputation": 3,
                "question": 4,
                "link": 5,
                "latitude": 6,
                "longitude": 7,
                "timestamp": 8,
                "resolved": 9,
                "expired": 10,
                "answerCount": 11,
                "answers": 12

            },
            ANSWER_COLUMNS = {

                "answerId": 0,
                "questionId": 1,
                "userId": 2,
                "username": 3,
                "reputation": 4,
                "locationId": 5,
                "location": 6,
                "locationAddress": 7,
                "latitude": 8,
                "longitude": 9,
                "distance": 10,
                "reasonId": 11,
                "timestamp": 12,
                "selected": 13,
                "voted": 14,
                "votes": 15

            },
            ACCOUNT_COLUMNS = {

                "userId": 0,
                "username": 1,
                "displayName": 2,
                "reputation": 3,
                "metricDistances": 4,
                "locations": 5

            },
            INTERVAL_COLUMNS = {

                "all": 0,
                "week": 1,
                "month": 2,
                "year": 3

            },
            LOCATION_COLUMNS = {

                "fromLatitude": 0,
                "fromLongitude": 1,
                "toLatitude": 2,
                "toLongitude": 3

            },
            USER_COLUMNS = {

                "userId": 0,
                "username": 1,
                "displayName": 2,
                "reputation": 3,
                "signupDate": 4,
                "totalQuestions": 5,
                "totalAnswers": 6,
                "questions": 7,
                "answers": 8

            };

        function addDefaultEventListeners() {

            var toolbar =  document.getElementById( 'toolbar' );
            document.getElementById( 'title' ).addEventListener( 'click', refresh, false );
            toolbar.addEventListener( 'click', toolbarClick, false );

            if ( document.body.dataset.browser == 'iPhone' ) {

                var viewport = document.getElementById( 'viewport' );
                viewport.addEventListener( 'touchmove', onTouchMove, false );
                viewport.addEventListener( 'touchstart', onTouchStart, false );
                toolbar.addEventListener( 'touchstart', selectToolbarItem, false );
                toolbar.addEventListener( 'touchend', unselectToolbarItem, false );

            } else {

                toolbar.addEventListener( 'mousedown', selectToolbarItem, false );
                toolbar.addEventListener( 'mouseup', unselectToolbarItem, false );

            };

        };

        function addEventListeners( page, previousPage ) {

            removeEventListeners( previousPage );

            switch( page ) {

                case 'account-page':

                    document.getElementById( 'logout' ).addEventListener( 'click', logout, false );

                    break;

                case 'add-answer-page':
                    
                    var location = document.getElementById( 'locations' )
                    
                    location.addEventListener( 'click', locationsClick, false );
                    document.getElementById( 'cancel-answer-button' ).addEventListener( 'click', hideAddAnswer, false );
                    document.getElementById( 'answer-text' ).addEventListener( 'keyup', autocompleteLocations, false );

                    if ( document.body.dataset.browser == 'iPhone' ) {

                        location.addEventListener( 'touchstart', selectItem, false );
                        location.addEventListener( 'touchend', unselectItem, false );

                    } else {

                        location.addEventListener( 'mousedown', selectItem, false );
                        location.addEventListener( 'mouseup', unselectItem, false );
                        location.addEventListener( 'mouseover', hoverItem, false );
                        location.addEventListener( 'mouseout', unhoverItem, false );

                    };

                    break;

                case 'answer-page':

                    var backButton = document.getElementById( 'back-button' );
                    backButton.addEventListener( 'click', goBack, false );

                    if ( document.body.dataset.browser == 'iPhone' ) {

                        backButton.addEventListener( 'touchstart', selectButton, false );
                        backButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

                        backButton.addEventListener( 'mousedown', selectButton, false );
                        backButton.addEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

                case 'login-page':

                    document.getElementById( 'login-page' ).addEventListener( 'submit', login, false );

                    break;

                case 'question-page':

                    var answers = document.getElementById( 'answers' ),
                        questionView = document.getElementById( 'question-view' ),
                        backButton = document.getElementById( 'back-button' );

                    questionView.addEventListener( 'click', questionItemClick, false );
                    answers.addEventListener( 'click', answerClick, false );
                    document.getElementById( 'question-map' ).addEventListener( 'click', questionItemClick, false );
                    backButton.addEventListener( 'click', goBack, false );

                    if ( document.body.dataset.browser == 'iPhone' ) {

                        answers.addEventListener( 'touchstart', selectItem, false );
                        answers.addEventListener( 'touchend', unselectItem, false );
                        questionView.addEventListener( 'touchstart', selectItem, false );
                        questionView.addEventListener( 'touchend', unselectItem, false );
                        backButton.addEventListener( 'touchstart', selectButton, false );
                        backButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

                        answers.addEventListener( 'mousedown', selectItem, false );
                        answers.addEventListener( 'mouseup', unselectItem, false );
                        answers.addEventListener( 'mouseover', hoverItem, false );
                        answers.addEventListener( 'mouseout', unhoverItem, false );
                        questionView.addEventListener( 'mousedown', selectItem, false );
                        questionView.addEventListener( 'mouseup', unselectItem, false );
                        questionView.addEventListener( 'mouseover', hoverItem, false );
                        questionView.addEventListener( 'mouseout', unhoverItem, false );
                        backButton.addEventListener( 'mousedown', selectButton, false );
                        backButton.addEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

                case 'question-map-page':

                    var backButton = document.getElementById( 'back-button' );
                    backButton.addEventListener( 'click', goBack, false );

                    if ( document.body.dataset.browser == 'iPhone' ) {

                        backButton.addEventListener( 'touchstart', selectButton, false );
                        backButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

                        backButton.addEventListener( 'mousedown', selectButton, false );
                        backButton.addEventListener( 'mouseup', unselectButton, false );

                    };

                case 'questions-page':

                    var questions = document.getElementById( 'questions' );
                    
                    questions.addEventListener( 'click', questionClick, false );
                    document.getElementById( 'ask' ).addEventListener( 'submit', saveQuestion, false );

                    if ( document.body.dataset.browser == 'iPhone' ) {

                        questions.addEventListener( 'touchstart', selectItem, false );
                        questions.addEventListener( 'touchend', unselectItem, false );

                    } else {

                        questions.addEventListener( 'mousedown', selectItem, false );
                        questions.addEventListener( 'mouseup', unselectItem, false );
                        questions.addEventListener( 'mouseover', hoverItem, false );
                        questions.addEventListener( 'mouseout', unhoverItem, false );

                    };

                    break;

                case 'user-page':

                    var backButton = document.getElementById( 'back-button' );
                    backButton.addEventListener( 'click', goBack, false );

                    if ( document.body.dataset.browser == 'iPhone' ) {

                        backButton.addEventListener( 'touchstart', selectButton, false );
                        backButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

                        backButton.addEventListener( 'mousedown', selectButton, false );
                        backButton.addEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

            };

        };

        function addWidthSlide( element ) {

            var start = element.indexOf( 'class="' ) + 7;
            return element.substring( 0, start ) + 'width-slide width-zero ' + element.substring( start );

        };

        function answerClick( event ) {

            var answer = event.target.closestByClassName( 'answer-item' );

            if ( answer ) {

                showPage( 'answer-page', { answerId: answer.dataset.id, answerLetter: answer.dataset.letter } );

            };

        };

        function autocompleteLocations() {

            _searchRequest.name = document.getElementById( 'answer-text' ).value;
            _places.search( _searchRequest, function ( results, status ) {

                var html = '';

                for ( var index = 0; index < results.length; index++ ) {

                    var existingAnswerClass = '',
                        existingAnswer = '';

                    if ( _selectedQuestion[QUESTION_COLUMNS.answers].item( results[index].id, ANSWER_COLUMNS.locationId ) ) {

                        existingAnswerClass = ' existing-answer';
                        existingAnswer = '<div class="existing-answer-caption">' + STRINGS.existingAnswer + '</div>';

                    };

                    html +=
                          '<li class="location-item list-item' + existingAnswerClass + '" '
                        + 'data-location-id="' + results[index].id + '" '
                        + 'data-address="' + results[index].vicinity + '" '
                        + 'data-latitude="' + results[index].geometry.location.lat() + '" '
                        + 'data-longitude="' + results[index].geometry.location.lng() + '" '
                        + 'data-name="' + results[index].name + '">'
                        + '<div class="location-body">' + results[index].name + '</div>'
                        + '<div class="location-info">' + results[index].vicinity + '</div>'
                        + existingAnswer
                        + '</li>';

                };

                document.getElementById( 'locations' ).innerHTML = html;

            } );

        };

        function checkLogin() {

            if ( _session.id && _session.key ) {

                loadData();
                showPage( 'questions-page' );

            } else {

                showPage( 'login-page' );

            };

        };

        function getAge( timestamp ) {

            var age = ~ ~( ( new window.Date().getTime() - new window.Date( timestamp ).getTime() ) / 60000 );

            if ( age > 1440 ) {

                age = ~ ~( age / 60 / 24 );
                return age == 1 ? age + ' ' + STRINGS.ageDay : age + ' ' + STRINGS.ageDays;

            } else if ( age > 60 ) {

                age = ~ ~( age / 60 );
                return age == 1 ? age + ' ' + STRINGS.ageHour : age + ' ' + STRINGS.ageHours;

            } else if ( age > 0 ) {

                return age == 1 ? age + ' ' + STRINGS.ageMinute : age + ' ' + STRINGS.ageMinutes;

            } else { //0

                return STRINGS.ageNow;

            };

        };

        function getAnswerItem( answer, letter ) {

            return '<li class="answer-item list-item" '
                + 'data-id="' + answer[ANSWER_COLUMNS.answerId] + '" '
                + 'data-letter="' + letter + '">'
                + '<div class="location-name">'
                + getLetter( letter )
                + getVotes( answer[ANSWER_COLUMNS.votes] )
                + getSelected( answer[ANSWER_COLUMNS.selected] )
                + answer[ANSWER_COLUMNS.location]
                + '</div>'
                + '<div class="location-address">' + answer[ANSWER_COLUMNS.locationAddress] + '</div>'
                + '<ul class="info">'
                + '<li class="info-item">' + getDistance( answer[ANSWER_COLUMNS.distance] ) + '</li>'
                + '<li class="info-item">' + getAge( answer[ANSWER_COLUMNS.timestamp] ) + '</li>'
                + '<li class="info-item">' + answer[ANSWER_COLUMNS.username] + '</li>'
                + '<li class="info-item">' + answer[ANSWER_COLUMNS.reputation] + '</li>'
                + '</ul>'
                + '</li>';

        };

        function getDistance( distance ) {

            var useMiles = !_account[ACCOUNT_COLUMNS.metricDistances];

            if ( useMiles ) distance = ~ ~( distance * 3.28 ); //meters to feet

            if ( distance > ( useMiles ? 527 : 99 ) ) { // 1/10th

                distance = useMiles ? ~ ~( distance / 5280 * 10 ) / 10 : ~ ~( distance / 1000 * 10 ) / 10;
                return distance + ' ' + ( useMiles ? STRINGS.distanceMiles : STRINGS.distanceKm );

            } else if ( distance > 0 ) {

                return distance + ' ' + ( useMiles ? STRINGS.distanceFeet : STRINGS.distanceMeters );

            } else { //0

                return STRINGS.distanceHere;

            };

        };

        function getLetter( letter ) {

            return letter ? '<span class="marker">' + letter + '</span>' : '';

        };

        function getListItemHeader( caption ) {

            return '<li class="list-header">' + caption + '</li>';

        };

        function getQuestionItem( question ) {

            var count = '',
                resolved = '';

            if ( question[QUESTION_COLUMNS.resolved] ) {

                count = STRINGS.checkmark;
                resolved = ' resolved';

            } else if ( question[QUESTION_COLUMNS.expired] ) { 

                count = STRINGS.xmark;
                resolved = ' unresolved';

            } else {

                count = question[QUESTION_COLUMNS.answerCount];

            };

            return '<li class="question-item list-item"'
                + 'data-id="' + question[QUESTION_COLUMNS.questionId] + '">'
                + '<div class="answer-count-view' + resolved + '"><div class="answer-count">' + count + '</div></div>'
                + '<div class="list-item-body">' + question[QUESTION_COLUMNS.question] + '</div>'
                + '<ul class="info">'
                + '<li class="info-item">' + getAge( question[QUESTION_COLUMNS.timestamp] ) + '</li>'
                + '<li class="info-item">' + question[QUESTION_COLUMNS.username] + '</li>'
                + '<li class="info-item">' + question[QUESTION_COLUMNS.reputation] + '</li>'
                + '</ul>'
                + '</li>';

        };

        function getSelected( selected ) {

            return selected ? '<span class="selected">' + STRINGS.checkmark + '</span>' : '';

        };

        function getSession( resource ) {

            return _session.id
                ? _session.id + ':' + toBase64UrlString( 
                    window.Crypto.util.bytesToBase64( 
                    window.Crypto.HMAC( window.Crypto.SHA1, resource + _session.id, _session.key, { asBytes: true } ) ) )
                : '';

        };

        function getUserQuestions() {

            var html = '';

            if ( _userQuestions.length ) {

                html += getListItemHeader( _account[ACCOUNT_COLUMNS.username] );

                for ( var index = 0; index < _userQuestions.length; index++ ) {

                    html += getQuestionItem( _userQuestions[index] );

                };

                html += getListItemHeader( STRINGS.local );

            };

            return html;

        };

        function getVoteCount( votes ) {

            return votes > 0 ? '+' + votes : votes

        };

        function getVotes( votes ) {

            if ( votes > 0 ) {

                return '<span class="votes votes-up">' + getVoteCount( votes ) + '</span>';

            } else if ( votes < 0 ) {

                return '<span class="votes votes-down">' + getVoteCount( votes ) + '</span>';

            } else {

                return '';

            };

        };

        function goBack( event ) {

            showPage( event.currentTarget.dataset.page, window.JSON.parse( event.currentTarget.dataset.options ) );

        };

        function titleClick( event ) {

            showPage( 'questions-page' );
            scrollUp();

        };

        function hideAddAnswer() {

            document.getElementById( 'add-answer-page' ).addClass( 'top-slide' );

        };

        function hideBackButton() {

            document.getElementById( 'back-button' ).style.display = 'none';

        };

        function hoverItem( event ) {

            var item = event.target.closestByClassName( 'list-item' );

            if ( item ) {

                item.addClass( 'hover' );

            };

        };

        function hidePage( page ) {

            if( page ) document.getElementById( page ).style.display = 'none';

        };

        function hideSplashPage() {

            window.setTimeout( function () { 

                var splash = document.getElementById( 'splash' );
                splash.addClass( 'fade' );
                window.setTimeout( function () { splash.style.display = 'none'; }, 500 );

            }, 1);

        };

        function initialize() {

            addDefaultEventListeners();
            localizeStrings();
            loadCachedData();
            hideSplashPage();
            checkLogin()
            window.setTimeout( setGeolocation, 3000 );
            window.setInterval( setGeolocation, 120000 );

        };

        function isMyQuestion() {

            return ( _account[ACCOUNT_COLUMNS.userId] == _selectedQuestion[QUESTION_COLUMNS.userId] );

        };

        function loadAccount() {

            var resource = '/api/account',
                session = getSession( resource );

            ajax( resource, {

                "type": "GET",
                "headers": { "x-session": session },
                "cache": false,
                "async": false,
                "success": function ( data, status ) {

                    _account = window.JSON.parse( data )[0];
                    window.localStorage.setItem( 'account', data );

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : window.alert( 'error: ' + status + ', ' + error );

                }

            } );

        };

        function loadCachedData() {

            var questions = window.localStorage.getItem( 'questions' ),
                userQuestions = window.localStorage.getItem( 'userQuestions' ),
                account = window.localStorage.getItem( 'account' );

            if ( questions ) _questions = window.JSON.parse( questions );
            if ( userQuestions ) _userQuestions = window.JSON.parse( userQuestions );
            if ( account ) _account = window.JSON.parse( account )[0];

            _session.id = window.localStorage.getItem( 'sessionId' );
            _session.key = window.localStorage.getItem( 'sessionKey' );

        };

        function loadData() {

            if ( !_account.length ) loadAccount();

            if ( _account.length ) {

                if( _questions.length ) {
                
                    showQuestions();
                    
                } else {
                
                    loadUserQuestions();
                    loadQuestions();

                };

            };

        };

        function loadQuestion( questionId ) {

            var resource = '/api/questions/' + questionId,
                session = getSession( resource );

            ajax( resource, {

                "type": "POST",
                "headers": { "x-session": session },
                "cache": false,
                "success": function ( data, status ) {

                    setSelectedQuestion( window.JSON.parse( data )[0] );
                    showQuestion();

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : window.alert( 'error: ' + status + ', ' + error );

                }

            } );

        };

        function loadQuestions() {

            var location = _account[ACCOUNT_COLUMNS.locations][0],
                data = 'fromLatitude=' + location[LOCATION_COLUMNS.fromLatitude]
                    + '&fromLongitude=' + location[LOCATION_COLUMNS.fromLongitude]
                    + '&toLatitude=' + location[LOCATION_COLUMNS.toLatitude]
                    + '&toLongitude=' + location[LOCATION_COLUMNS.toLongitude],
                resource = '/api/questions',
                session = getSession( resource );

            ajax( resource, {

                "type": "GET",
                "data": data,
                "headers": { "x-session": session },
                "cache": false,
                "async": false,
                "success": function ( data, status ) {

                    _questions = window.JSON.parse( data );
                    window.localStorage.setItem( 'questions', data );
                    showQuestions();

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : window.alert( 'error: ' + status + ', ' + error );

                }

            } );

        };

        function loadTopUsers() {

            var location = _account[ACCOUNT_COLUMNS.locations][0],
                fromLatitude = location[LOCATION_COLUMNS.fromLatitude],
                latitude = fromLatitude + ( ( location[LOCATION_COLUMNS.toLatitude] - fromLatitude ) / 2 ),
                fromLongitude = location[LOCATION_COLUMNS.fromLongitude],
                longitude = fromLongitude + ( ( location[LOCATION_COLUMNS.toLongitude] - fromLongitude ) / 2 ),
                data = 'latitude=' + latitude
                    + '&longitude=' + longitude
                    + '&interval=' + INTERVAL_COLUMNS.all,
                resource = '/api/users',
                session = getSession( resource );

            ajax( resource, {

                "type": "POST",
                "headers": { "x-session": session },
                "data": data,
                "success": function ( data, status ) {

                    showTopUsers( window.JSON.parse( data )[0] );

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : window.alert( 'error: ' + status + ', ' + error );

                }

            } );

        };

        function loadUser( userId ) {

            var resource = '/api/users/' + userId,
                session = getSession( resource ),
                picture = $( '#user-picture' );

            picture.src = '';

            ajax( resource, {

                "type": "POST",
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    showUser( window.JSON.parse( data )[0] );
                    window.setTimeout( function () { 
                    
                        resource = '/api/users/' + userId + '/picture';
                        var queryString = '?x-session=' + getSession( resource );
                        $( '#user-picture' ).src = resource + queryString;
                    
                    }, 100 );

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : window.alert( 'error: ' + status + ', ' + error );

                }

            } );

        };

        function loadUserQuestions() {

            var data = 'userId=' + _account[ACCOUNT_COLUMNS.userId],
                resource = '/api/questions',
                session = getSession( resource );

            ajax( resource, {

                "type": "GET",
                "data": data,
                "headers": { "x-session": session },
                "cache": false,
                "async": false,
                "success": function ( data, status ) {

                    _userQuestions = window.JSON.parse( data );
                    window.localStorage.setItem( 'userQuestions', data );

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : window.alert( 'error: ' + status + ', ' + error );

                }

            } );

        };

        function localizeStrings() {

            $( '#answer-text' ).setAttribute( 'placeholder', STRINGS.answerLabel );
            $( '#ask-text' ).setAttribute( 'placeholder', STRINGS.questionLabel );
            $( '#cancel-answer-button' ).setAttribute( 'placeholder', STRINGS.cancel );
            $( '#login-username' ).setAttribute( 'placeholder', STRINGS.loginLabel );
            $( '#login-password' ).setAttribute( 'placeholder', STRINGS.passwordLabel );
            $( '#member-since-caption' ).textContent = STRINGS.memberSince;
            $( '#reputation-caption' ).textContent = STRINGS.reputation;
            $( '#selected-notification' ).setAttribute( 'placeholder', STRINGS.checkmark );
            $( '#total-answers-caption' ).textContent = STRINGS.totalAnswers;
            $( '#total-questions-caption' ).textContent = STRINGS.totalQuestions;
            $( '#voted-up-notification' ).setAttribute( 'placeholder', STRINGS.plusOne );

        };

        function locationsClick( event ) {

            var location = event.target.closestByClassName( 'location-item' );

            if ( location && !location.hasClass( 'existing-answer' ) ) {

                saveAnswer( { 
                
                    "name": location.dataset.name,
                    "address": location.dataset.address,
                    "locationId": location.dataset.locationId,
                    "latitude": location.dataset.latitude,
                    "longitude": location.dataset.longitude
                    
                } );

            };

        };

        function login( event ) {

            event.preventDefault();

            var resource = '/logins/login',
                username = document.getElementById( 'login-username' ).value,
                password = document.getElementById( 'login-password' ).value,
                authorization = window.Crypto.util.bytesToBase64( window.Crypto.charenc.UTF8.stringToBytes( username + ':' + password ) );

            document.getElementById( 'login-error' ).innerHTML = '';

            if ( username && password ) {

                ajax( resource, {

                    "type": "POST",
                    "headers": { "x-authorization": authorization },
                    "complete": function ( response, status ) {

                        if ( status != "error" ) {

                            var session = response.getResponseHeader( 'x-session' ).split( ':' );

                            _session.id = session[0];
                            _session.key = session[1];
                            window.localStorage.setItem( 'sessionId', _session.id );
                            window.localStorage.setItem( 'sessionKey', _session.key );

                            loadData();
                            showPage( 'questions-page' );

                        };

                    },
                    "error": function ( response, status, error ) {

                        document.getElementById( 'login-error' ).innerHTML = error;

                    }

                } );

            };

        };

        function logout() {

            window.localStorage.removeItem( 'account' );
            window.localStorage.removeItem( 'questions' );
            window.localStorage.removeItem( 'userQuestions' );
            window.localStorage.removeItem( 'sessionKey' );
            window.localStorage.removeItem( 'sessionId' );
            _account.length = 0;
            _questions.length = 0;
            _userQuestions.length = 0;
            _session.id = '';
            _session.key = '';

            showPage( 'login-page' );

        };

        function onTouchMove( event ) {

            var scroll = event.target.closestByClassName( 'scroll' );

            if ( scroll ) {

                var top = scroll.positionTop,
                    heightDifference = 0 - scroll.offsetHeight + scroll.parentNode.offsetHeight;

                if( ( top >= 0 ) && ( event.touches[0].screenY > _swipeY ) ) { //at top, swiping down

                    event.preventDefault();

                } else if( ( top <= heightDifference ) && ( event.touches[0].screenY < _swipeY ) ) { //at bottom, swiping up

                    event.preventDefault();

                };

            } else {

                event.preventDefault();

            };

        };

        function onTouchStart( event ) {

            _swipeY = event.touches[0].screenY;

        };

        function questionClick( event ) {

            var question = event.target.closestByClassName( 'question-item' );
            if ( question ) showPage( 'question-page', { questionId: question.dataset.id } );

        };

        function questionItemClick( event ) {

            showPage( 'question-map-page' );

        };

        function refresh() {

            _account.length = 0;
            _questions.length = 0;
            _userQuestions.length = 0;

            loadData();
            showPage( 'questions-page' );

        }

        function removeEventListeners( page ) {

            switch( page ) {

                case 'account-page':

                    document.getElementById( 'logout' ).removeEventListener( 'click', logout, false );

                    break;

                case 'add-answer-page':
                    
                    var location = document.getElementById( 'locations' );
                    
                    location.removeEventListener( 'click', locationsClick, false );
                    document.getElementById( 'cancel-answer-button' ).removeEventListener( 'click', hideAddAnswer, false );
                    document.getElementById( 'answer-text' ).removeEventListener( 'keyup', autocompleteLocations, false );

                    if ( document.body.dataset.browser == 'iPhone' ) {

                        location.removeEventListener( 'touchstart', selectItem, false );
                        location.removeEventListener( 'touchend', unselectItem, false );

                    } else {

                        location.removeEventListener( 'mousedown', selectItem, false );
                        location.removeEventListener( 'mouseup', unselectItem, false );
                        location.removeEventListener( 'mouseover', hoverItem, false );
                        location.removeEventListener( 'mouseout', unhoverItem, false );

                    };

                    break;

                case 'answer-page':

                    var backButton = document.getElementById( 'back-button' );
                    backButton.removeEventListener( 'click', goBack, false );
                    backButton.removeEventListener( 'mousedown', selectButton, false );
                    backButton.removeEventListener( 'mousedown', unselectButton, false );

                    break;

                case 'login-page':

                    document.getElementById( 'login-page' ).removeEventListener( 'submit', login, false );

                    break;

                case 'question-page':

                    var answers = document.getElementById( 'answers' ),
                        questionView = document.getElementById( 'question-view' ),
                        backButton = document.getElementById( 'back-button' );

                    answers.removeEventListener( 'click', answerClick, false );
                    questionView.removeEventListener( 'click', questionItemClick, false );
                    document.getElementById( 'question-map' ).removeEventListener( 'click', questionItemClick, false );
                    backButton.removeEventListener( 'click', goBack, false );
                    backButton.removeEventListener( 'mousedown', selectButton, false );
                    backButton.removeEventListener( 'mousedown', unselectButton, false );

                    if ( document.body.dataset.browser == 'iPhone' ) {

                        answers.removeEventListener( 'touchstart', selectItem, false );
                        answers.removeEventListener( 'touchend', unselectItem, false );
                        questionView.removeEventListener( 'touchstart', selectItem, false );
                        questionView.removeEventListener( 'touchend', unselectItem, false );

                    } else {

                        answers.removeEventListener( 'mousedown', selectItem, false );
                        answers.removeEventListener( 'mouseup', unselectItem, false );
                        answers.removeEventListener( 'mouseover', hoverItem, false );
                        answers.removeEventListener( 'mouseout', unhoverItem, false );
                        questionView.removeEventListener( 'mousedown', selectItem, false );
                        questionView.removeEventListener( 'mouseup', unselectItem, false );
                        questionView.removeEventListener( 'mouseover', hoverItem, false );
                        questionView.removeEventListener( 'mouseout', unhoverItem, false );

                    };

                    break;

                case 'question-map-page':

                    var backButton = document.getElementById( 'back-button' );
                    backButton.removeEventListener( 'click', goBack, false );
                    backButton.removeEventListener( 'mousedown', selectButton, false );
                    backButton.removeEventListener( 'mousedown', unselectButton, false );

                case 'questions-page':

                    var questions = document.getElementById( 'questions' );
                    
                    questions.removeEventListener( 'click', questionClick, false );
                    document.getElementById( 'ask' ).removeEventListener( 'submit', saveQuestion, false );

                    if ( document.body.dataset.browser == 'iPhone' ) {

                        questions.removeEventListener( 'touchstart', selectItem, false );
                        questions.removeEventListener( 'touchend', unselectItem, false );

                    } else {

                        questions.removeEventListener( 'mousedown', selectItem, false );
                        questions.removeEventListener( 'mouseup', unselectItem, false );
                        questions.removeEventListener( 'mouseover', hoverItem, false );
                        questions.removeEventListener( 'mouseout', unhoverItem, false );

                    };

                    break;

                case 'user-page':

                    var backButton = document.getElementById( 'back-button' );
                    backButton.removeEventListener( 'click', goBack, false );
                    backButton.removeEventListener( 'mousedown', selectButton, false );
                    backButton.removeEventListener( 'mousedown', unselectButton, false );

                    break;

            };

        };

        function saveAnswer( answer ) {

            var from = new google.maps.LatLng( _selectedQuestion.latitude, _selectedQuestion.longitude ),
                to = new google.maps.LatLng( answer.latitude, answer.longitude ),
                distance = ~ ~google.maps.geometry.spherical.computeDistanceBetween( from, to ),
                reasonId = '1',
                message = _selectedQuestion.questionId
                    + '~' + answer.locationId
                    + '~' + answer.name
                    + '~' + answer.address
                    + '~' + answer.latitude
                    + '~' + answer.longitude
                    + '~' + distance
                    + '~' + reasonId,
                resource = '/messaging/answers',
                session = getSession( resource );

            document.getElementById( 'answer-text' ).value = '';
            hideAddAnswer();
            scrollUp();

            ajax( resource, {

                "type": "POST",
                "data": message,
                "headers": { "x-session": session },
                "cache": false,
                "success": function ( data, status ) {

                    var html ='<li class="list-item list-item-slide new-answer height-zero">'
                            + '<div class="location-name">'
                            + '<span class="marker">&#x2022;</span>'
                            + answer.name
                            + '</div>'
                            + '<div class="location-address">' + answer.address + '</div>'
                            + '<ul class="info">'
                            + '<li class="info-item">' + getDistance( distance ) + '</li>'
                            + '<li class="info-item">' + getAge( new window.Date() ) + '</li>'
                            + '<li class="info-item">' + _account[ACCOUNT_COLUMNS.username] + '</li>'
                            + '</ul>'
                            + '</li>',
                        markers = '&markers=color:gray|size:mid|' + answer.latitude + "," + answer.longitude,
                        questionMap = document.getElementById( 'question-map' );

                    var answers = document.getElementById( 'answers' );
                    answers.insertAdjacentHTML( 'afterBegin', html );
                    questionMap.setAttribute( 'src', questionMap.getAttribute( 'src' ) + markers );
                    window.setTimeout( function () { answers.firstChild.removeClass( 'height-zero' ) }, 500 );

                    var answerCount = document.getElementById( 'question-view' ).childByClassName( 'answer-count' );
                    answerCount.addClass( 'fadeable' ).addClass( 'fade' );
                    window.setTimeout( function () { 
                    
                        var questionId = _selectedQuestion[QUESTION_COLUMNS.questionId],
                            question = _questions.item( questionId ) || _userQuestions.item( questionId );

                        _selectedQuestion[QUESTION_COLUMNS.answerCount] += 1;
                        question[QUESTION_COLUMNS.answerCount] += 1;
                        answerCount.textContent = _selectedQuestion[QUESTION_COLUMNS.answerCount];
                        answerCount.removeClass( 'fade' );
                        window.setTimeout( function () { answerCount.removeClass( 'fadeable' ); }, 1000 );

                    }, 750 );

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : window.alert( 'error: ' + status + ', ' + error );

                }

            } );

        };

        function saveAnswerVote( answerId ) {

            var resource = '/api/answers/' + answerId + '/vote',
                data = 'questionId=' + _selectedQuestion.questionId,
                session = getSession( resource );

            ajax( resource, {

                "type": "GET",
                "data": data,
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    var location = document.getElementById( 'answer-view' ).childByClassName( 'location-name' ),
                        voted = _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId )[ANSWER_COLUMNS.voted],
                        currentVotes = _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId )[ANSWER_COLUMNS.votes],
                        vote = voted ? -1 : 1,
                        newVotes = currentVotes + vote < 0 ? 0 : currentVotes + vote;

                    _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId )[ANSWER_COLUMNS.votes] = newVotes;
                    _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId )[ANSWER_COLUMNS.voted] = !voted;

                    if ( currentVotes == 0 && vote == 1 ) { //add vote box

                        showNotification( 'voted-up-notification' );
                        location.firstChild.insertAdjacentHTML( 'afterEnd', getVotes( newVotes ) );

                    } else if( currentVotes == 1 && vote == -1  ) { //remove vote box

                        location.removeChild( location.childByClassName( 'votes' ) );
                    
                    } else if( currentVotes == 0 && vote == -1  ) { //should never happen, bad data

                        // do nothing

                    } else { //update vote box

                        showNotification( 'voted-up-notification' );
                        location.childByClassName( 'votes' ).innerHTML = getVoteCount( newVotes );

                    };

                    window.setTimeout( function () { loadQuestion( _selectedQuestion.questionId ) }, 100 );

                },
                "error": function ( response, status, error ) {

                    switch( error ) {

                        case 'Unauthorized':

                            showPage( 'login-page' );
                            break;

                        case 'Forbidden':

                            break;

                        default:

                            window.alert( 'error: ' + status + ', ' + error );

                    };

                }

            } );

        };

        function saveAnswerSelect( answerId ) {

            var resource = '/api/answers/' + answerId + '/select',
                data = 'questionId=' + _selectedQuestion.questionId,
                session = getSession( resource );

            ajax( resource, {

                "type": "GET",
                "data": data,
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    var location = document.getElementById( 'answer-view' ).childByClassName( 'location-name' ),
                        questionId = _selectedQuestion.questionId,
                        question = _questions.item( questionId ) || _userQuestions.item( questionId ),
                        selected = window.Math.abs( _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId )[ANSWER_COLUMNS.selected] - 1 ),
                        resolved = selected;

                    _selectedQuestion.resolved = resolved; 
                    question[QUESTION_COLUMNS.resolved] = resolved;
                    _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId )[ANSWER_COLUMNS.selected] = selected;

                    if( selected ) {

                        showNotification( 'selected-notification' );
                        location.lastChild.previousSibling.insertAdjacentHTML( 'afterEnd', addWidthSlide( getSelected( selected ) ) );
                        window.setTimeout( function () { location.childByClassName( 'selected' ).removeClass( 'width-zero' ); }, 50 );

                    } else {

                        window.setTimeout( function () { 
                        
                            location.childByClassName( 'selected' ).addClass( 'width-zero' ); 
                            window.setTimeout( function () { location.removeChild( location.childByClassName( 'selected' ) ); }, 500 );

                        }, 50 );

                    };

                    showToolbar( 'answer-my-question' );
                    window.setTimeout( function () { loadQuestion( _selectedQuestion.questionId ) }, 100 );

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : window.alert( 'error: ' + status + ', ' + error );

                }

            } );

        };

        function saveQuestion( event ) {

            event.preventDefault();

            if ( document.getElementById( 'ask-text' ).value && _currentLocation.latitude ) {

                var questionText = document.getElementById( 'ask-text' ).value,
                    message = _currentLocation.latitude + "~" + _currentLocation.longitude + "~" + questionText,
                    resource = '/messaging/questions',
                    session = getSession( resource );

                ajax( resource, {

                    "type": "POST",
                    "data": message,
                    "headers": { "x-session": session },
                    "cache": false,
                    "success": function ( data, status ) {

                        var html = '';

                        if ( _userQuestions.length == 0 ) {

                            html += getListItemHeader( _account[ACCOUNT_COLUMNS.username] );

                        };

                        html +=
                              '<li class="list-item list-item-slide new-question height-zero">'
                            + '<div class="answer-count-view"><div class="answer-count">0</div></div>'
                            + '<div class="list-item-body">' + document.getElementById( 'ask-text' ).value + '</div>'
                            + '<ul class="info">'
                            + '<li class="info-item">' + getAge( new window.Date() ) + '</li>'
                            + '<li class="info-item">' + _account[ACCOUNT_COLUMNS.username] + '</li>'
                            + '</ul>'
                            + '</li>';

                        if ( _userQuestions.length == 0 ) {

                            html += getListItemHeader( STRINGS.local );

                        };

                        document.getElementById( 'ask-button' ).focus();
                        document.getElementById( 'ask-text' ).value = '';
                        scrollUp();

                        var questions = document.getElementById( 'questions' );

                        if ( _userQuestions.length == 0 ) {

                            questions.insertAdjacentHTML( 'afterBegin', html );

                        } else {

                            questions.firstChild.insertAdjacentHTML( 'afterEnd', html );

                        };

                        window.setTimeout( function () { questions.childNodes[1].removeClass( 'height-zero' ) }, 50 );

                    },
                    "error": function ( response, status, error ) {

                        error == 'Unauthorized'
                            ? showPage( 'login-page' )
                            : window.alert( 'error: ' + status + ', ' + error );

                    }

                } );

            };

        };

        function scrollUp() {

            var page = document.getElementById( 'viewport' ).dataset.page,
                li;

            if ( page == 'questions-page' ) {

                li = document.getElementById( 'questions' ).firstChild;
                if ( li ) li.scrollIntoView();

            } else if ( page == 'question-page' ) {

                li = document.getElementById( 'answers' ).firstChild;
                if ( li ) li.scrollIntoView();

            };

        };

        function selectButton( event ) {

            document.getElementById( 'back-button' ).addClass( 'back-button-selected' );
            document.getElementById( 'back-button-arrow-2' ).addClass( 'back-button-selected' );

        };

        function selectItem( event ) {

            var item = event.target.closestByClassName( 'list-item' );
            if ( item ) item.addClass( 'select' );

        };

        function selectToolbarItem( event ) {

            var item = event.target.closestByClassName( 'toolbar-item' );
            if ( item ) item.addClass( 'toolbar-item-selected' );

        };

        function setGeolocation() {

            var geo = window.navigator.geolocation.watchPosition( function ( position )  {

                _currentLocation.latitude = position.coords.latitude;
                _currentLocation.longitude = position.coords.longitude;
                _currentLocation.accuracy = position.coords.accuracy;

            },
            function () {

                window.alert( STRINGS.geoLocationError );

            },
            { maximumAge: 110000, enableHighAccuracy: true } );

            window.setTimeout( function () { window.navigator.geolocation.clearWatch( geo ) }, 5000 );

        };

        function setSelectedQuestion( value ) {

            _selectedQuestion = value;

            window.Object.defineProperty( _selectedQuestion, 'questionId', {

                get: function () { return this ? this[QUESTION_COLUMNS.questionId] : undefined }

            } );

            window.Object.defineProperty( _selectedQuestion, 'userId', {

                get: function () { return this ? this[QUESTION_COLUMNS.userId] : undefined }

            } );
            
            window.Object.defineProperty( _selectedQuestion, 'resolved', {

                get: function () { return this ? this[QUESTION_COLUMNS.resolved] : undefined },
                set: function ( value ) { this[QUESTION_COLUMNS.resolved] = value }

            } );

            window.Object.defineProperty( _selectedQuestion, 'latitude', {

                get: function () { return this ? this[QUESTION_COLUMNS.latitude] : undefined }

            } );

            window.Object.defineProperty( _selectedQuestion, 'longitude', {

                get: function () { return this ? this[QUESTION_COLUMNS.longitude] : undefined }

            } );

            _selectedQuestion.answered = function( userId ) {

                for ( var index = 0; index < this[QUESTION_COLUMNS.answers].length; index++ ) {

                    if ( userId == this[QUESTION_COLUMNS.answers][index][ANSWER_COLUMNS.userId] ) return true;

                };

            };

        };

        function setView( view ) {

            switch ( view ) {

                case 'fullscreen':

                    document.getElementById( 'view' ).addClass( 'view-fullscreen' );
                    break;

                case 'header':

                    document.getElementById( 'view' ).addClass( 'view-header' );
                    break;

                default:

                    document.getElementById( 'view' ).removeClass( 'view-fullscreen' );
                    document.getElementById( 'view' ).removeClass( 'view-header' );

            };

        };

        function showAddAnswer() {

            document.getElementById( 'locations' ).innerHTML = '';

            _places = new google.maps.places.PlacesService( document.createElement( 'div' ) );
            _searchRequest = {

                location: new google.maps.LatLng( _selectedQuestion.latitude, _selectedQuestion.longitude ),
                radius: LOCATION_RADIUS,
                types: ['establishment']

            };

            autocompleteLocations();
            //document.getElementById( 'answer-text' ).focus();
            addEventListeners( 'add-answer-page' );
            document.getElementById( 'add-answer-page' ).removeClass( 'top-slide' );

        };

        function showAnswer( answerId, letter ) {

            var answer = _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId ),
                html = getAnswerItem( answer, letter ),
                mapCanvas = document.getElementById( 'answer-map-canvas' ),
                staticMap = document.getElementById( 'answer-map' ),
                directionItems = document.getElementById( 'directions' ),
                src = 'http://maps.google.com/maps/api/staticmap?center='
                    + _selectedQuestion.latitude + ',' + _selectedQuestion.longitude
                    + '&size=320x319&maptype=roadmap&sensor=true&style=hue:blue&markers=color:gray|label:' + letter + '|'
                    + answer[ANSWER_COLUMNS.latitude] + ',' + answer[ANSWER_COLUMNS.longitude]
                    + '&markers=color:black|label:|'
                    + _selectedQuestion.latitude + ',' + _selectedQuestion.longitude;

            mapCanvas.removeClass( 'fadeable' ).addClass( 'fade' ).addClass( 'fadeable' );
            directionItems.innerHTML = '';
            document.getElementById( 'answer-page' ).dataset.id = answerId
            document.getElementById( 'answer-view' ).innerHTML = html;

            if( isMyQuestion() ) {

                var currentLocation = new google.maps.LatLng( _currentLocation.latitude, _currentLocation.longitude ),
                    answerLocation = new google.maps.LatLng( answer[ANSWER_COLUMNS.latitude], answer[ANSWER_COLUMNS.longitude] ),
                    options = {

                        zoom: 13,
                        center: currentLocation,
                        mapTypeId: google.maps.MapTypeId.ROADMAP,
                        mapTypeControl: false,
                        styles: [ {

                            featureType: "all",
                            stylers: [ { hue: "#44ADFC" } ]

                        } ]

                    },
                    map = new google.maps.Map( mapCanvas, options ),
                    bounds = new google.maps.LatLngBounds();

                bounds.extend( currentLocation );
                bounds.extend( answerLocation );
                map.fitBounds( bounds );
                mapCanvas.removeClass( 'fade' );

                google.maps.event.addListenerOnce( map, 'tilesloaded', function() {

                    var directionOptions = {

                            origin: currentLocation,
                            destination: answerLocation,
                            travelMode: google.maps.TravelMode.DRIVING,
                            unitSystem: google.maps.UnitSystem.IMPERIAL

                        },
                        directionsDisplayOptions = {

                            polylineOptions: { strokeColor: "black", strokeOpacity: ".5" }

                        },
                        directions = new google.maps.DirectionsService(),
                        directionsDisplay = new google.maps.DirectionsRenderer( directionsDisplayOptions );
            
                    directionsDisplay.setMap( map );
                    directions.route( directionOptions, function( result, status ) {
                
                        if  (status == google.maps.DirectionsStatus.OK ) {

                            directionsDisplay.setDirections( result );

                            for( var index = 0; index < result.routes[0].legs[0].steps.length; index++ ) {

                                var step = '<li class="direction-item">' 
                                        + '<b>' + ( index + 1 ) + '.</b> '
                                        + result.routes[0].legs[0].steps[index].instructions 
                                        + '</li>';
                                directionItems.insertAdjacentHTML( 'beforeEnd', step );

                            };

                        }
                
                    } );

                } );

            } else {

                staticMap.setAttribute( 'src', src );

            };

        };

        function showBackButton( caption, page, width, options ) {

            var button = document.getElementById( 'back-button' );
            button.dataset.page = page;
            button.dataset.options = window.JSON.stringify( options );
            document.getElementById( 'back-button-text' ).textContent = caption;
            button.style.width = width + "px";
            button.style.display = 'block';

        };

        function showNotification( notification ) {

            var element = document.getElementById( notification );
            element.removeClass( 'hide' );
            window.setTimeout( function() { element.removeClass( 'fade' ); }, 50 );
            window.setTimeout( function() { 
            
                element.addClass( 'fade' );  
                window.setTimeout( function() { element.addClass( 'hide' );  } , 500 );
            
            } , 2000 );

        };

        function showPage( page, options ) {

            options = options || {};

            var viewport = document.getElementById( 'viewport' ),
                previousPage = viewport.dataset.page,
                previousOptions = window.JSON.parse( viewport.dataset.options || '{}' );

            if ( viewport.dataset.page != page ) {

                viewport.dataset.page = page;
                viewport.dataset.options = window.JSON.stringify( options );
                addEventListeners( page, previousPage );

                switch ( page ) {

                    case 'account-page':

                        hidePage( previousPage ); 
                        setView( 'normal' );
                        hideBackButton();
                        showToolbar( 'main' );
                        document.getElementById( page ).style.display = 'block';

                        break;

                    case 'answer-page':

                        hidePage( previousPage ); 
                        setView( 'normal' );
                        showBackButton( STRINGS.backButtonQuestion, 'question-page', 64, previousOptions );
                        document.getElementById( 'directions-page' ).addClass( 'top-slide' );
                        document.getElementById( page ).style.display = 'block';

                        if ( isMyQuestion() ) {

                            showToolbar( 'answer-my-question', { "answerId": options.answerId } ); 

                        } else {

                            showToolbar( 'answer', { "answerId": options.answerId } );

                        };

                        if( options.answerId && options.answerLetter ) {

                            showAnswer( options.answerId, options.answerLetter ); 

                        };

                        break;

                    case 'login-page':

                        hidePage( previousPage ); 
                        setView( 'header' );
                        hideBackButton();
                        document.getElementById( page ).style.display = 'block';

                        break;

                    case 'question-page':

                        hidePage( previousPage ); 
                        setView( 'normal' );
                        showBackButton( STRINGS.backButtonQuestions, 'questions-page', 70, previousOptions );
                        document.getElementById( page ).style.display = 'block';

                        if ( options.questionId && ( _selectedQuestion.questionId != options.questionId ) ) {

                            loadQuestion( options.questionId ); 

                        };

                        if ( isMyQuestion() ) {

                            showToolbar( 'my-question' );

                        } else {

                            showToolbar( 'question', { "questionId": options.questionId } );

                        };

                        break;

                    case 'question-map-page':

                        hidePage( previousPage ); 
                        setView( 'normal' );
                        showBackButton( STRINGS.backButtonQuestion, 'question-page', 64, previousOptions );
                        showToolbar( 'main' );
                        document.getElementById( page ).style.display = 'block';
                        showQuestionMapFull();

                        break;

                    case 'top-page':

                        hidePage( previousPage ); 
                        setView( 'normal' );
                        hideBackButton();
                        showToolbar( 'main' );
                        document.getElementById( page ).style.display = 'block';
                        loadTopUsers();

                        break;

                    case 'user-page':

                        hidePage( previousPage ); 
                        setView( 'normal' );

                        if( options.backPage ) {
                        
                            showBackButton( options.backCaption, options.backPage, options.backSize, previousOptions );
                            showToolbar( 'user' );

                        } else {

                            hideBackButton();
                            showToolbar( 'main' );

                        };

                        document.getElementById( page ).style.display = 'block';
                        loadUser( options.userId ); 

                        break;

                    case 'questions-page':
                    default:

                        hidePage( previousPage ); 
                        setView( 'normal' );
                        hideBackButton();
                        showToolbar( 'main' );
                        document.getElementById( 'questions-page' ).style.display = 'block';

                        break;

                };

            };

        };

        function showQuestion() {

            var markers = '', 
                html = '';

            document.getElementById( 'question-view' ).innerHTML = getQuestionItem( _selectedQuestion );

            for ( var index = 0; index < _selectedQuestion[QUESTION_COLUMNS.answers].length; index++ ) {

                var answer = _selectedQuestion[QUESTION_COLUMNS.answers][index],
                    letter = STRINGS.letters.charAt( index );

                markers += "&markers=color:gray|size:mid|label:" + letter + "|"
                    + answer[ANSWER_COLUMNS.latitude] + "," + answer[ANSWER_COLUMNS.longitude];
                html += getAnswerItem( answer, letter );

            };

            document.getElementById( 'answers' ).innerHTML = html;

            var mapUrl = 'http://maps.google.com/maps/api/staticmap?center='
                    + _selectedQuestion.latitude + "," + _selectedQuestion.longitude
                    + "&size=320x150&maptype=roadmap&sensor=true&style=hue:blue&markers=color:black|size:mid|"
                    + _selectedQuestion.latitude + "," + _selectedQuestion.longitude
                    + markers;
            document.getElementById( 'question-map' ).setAttribute( 'src', mapUrl );

        };

        function showQuestionMapFull() {

            var mapUrl = document.getElementById( 'question-map' ).getAttribute( 'src' ),
                start = mapUrl.indexOf( 'size=' ) + 5,
                end = mapUrl.indexOf( '&', start ),
                size = mapUrl.substring( start, end );

            mapUrl = mapUrl.replace( size, '320x372' );
            document.getElementById( 'question-map-full' ).setAttribute( 'src', mapUrl );

        };

        function showQuestions() {

            var html = getUserQuestions();

            for ( var index = 0; index < _questions.length; index++ ) {

                html += getQuestionItem( _questions[index] );

            };

            if ( !html ) html = STRINGS.noQuestions;

            document.getElementById( 'questions' ).innerHTML = html;

        };

        function showToolbar( toolbar, options ) {

            var disabled, 
                button,
                userId;

            switch ( toolbar ) {
                case 'main':

                    document.getElementById( 'toolbar-main' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-answer-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-answer' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-user' ).addClass( 'hide' );

                    $( '#user-button' ).dataset.userId = _account[ACCOUNT_COLUMNS.userId];

                    break;

                case 'answer':

                    document.getElementById( 'toolbar-answer' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-answer-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-main' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-user' ).addClass( 'hide' );

                    disabled = _selectedQuestion.resolved || _selectedQuestion.answered( _account[ACCOUNT_COLUMNS.userId] );

                    button = document.getElementById( 'vote-up-button' );
                    button.disabled = disabled;
                    disabled ? button.addClass( 'disabled' ) : button.removeClass( 'disabled' );

                    disabled = _selectedQuestion.resolved;

                    button = document.getElementById( 'answer-flag-button-1' );
                    button.disabled = disabled;
                    disabled ? button.addClass( 'disabled' ) : button.removeClass( 'disabled' );

                    userId = _selectedQuestion[QUESTION_COLUMNS.answers].item( options.answerId )[ANSWER_COLUMNS.userId];
                    $( '#answer-user-button-1' ).dataset.userId = userId; 

                    break;

                case 'answer-my-question':

                    document.getElementById( 'toolbar-answer-my-question' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-answer' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-main' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-user' ).addClass( 'hide' );

                    disabled = _selectedQuestion[QUESTION_COLUMNS.resolved];

                    button = document.getElementById( 'answer-flag-button-2' );
                    button.disabled = disabled;
                    disabled ? button.addClass( 'disabled' ) : button.removeClass( 'disabled' );

                    userId = _selectedQuestion[QUESTION_COLUMNS.answers].item( options.answerId )[ANSWER_COLUMNS.userId];
                    $( '#answer-user-button-2' ).dataset.userId = userId; 

                    break;

                case 'question':

                    document.getElementById( 'toolbar-question' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-answer' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-answer-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-main' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-user' ).addClass( 'hide' );

                    disabled = _selectedQuestion.answered( _account[ACCOUNT_COLUMNS.userId] );

                    button = document.getElementById( 'add-answer-button' );
                    button.disabled = disabled;
                    disabled ? button.addClass( 'disabled' ) : button.removeClass( 'disabled' );
                    button.dataset.questionId = options.questionId;
                    
                    $( '#question-user-button' ).dataset.userId = _selectedQuestion.userId;
                    $( '#question-flag-button' ).dataset.questionId = options.questionId;

                    break;

                case 'my-question':

                    document.getElementById( 'toolbar-my-question' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-answer' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-answer-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-main' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-user' ).addClass( 'hide' );

                    break;

                case 'user':

                    document.getElementById( 'toolbar-user' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-answer' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-answer-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-main' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-question' ).addClass( 'hide' );

                    break;

            };

        };

        function showTopUsers( topUsers ) {

            var html = topUsers;

            /*for ( var index = 0; index < topUsers.length; index++ ) {

                html += getQuestionItem( _questions[index] );

            };*/

            document.getElementById( 'top-page' ).innerHTML = html;

        };

        function showUser( user ) {

            var displayName = user[USER_COLUMNS.displayName],
                username = user[USER_COLUMNS.username],
                signupDate = new Date( user[USER_COLUMNS.signupDate] ),
                memberSince = STRINGS.dateFormat
                    .replace( "%m", STRINGS.months[signupDate.getMonth()]  )
                    .replace( "%y", signupDate.getFullYear() ),
                html = '',
                index;

            $( '#display-name' ).textContent = displayName;
            $( '#username' ).textContent = username;
            $( '#member-since-value' ).textContent = memberSince;
            $( '#reputation-value' ).textContent = user[USER_COLUMNS.reputation];
            $( '#total-questions-value' ).textContent = user[USER_COLUMNS.totalQuestions];
            $( '#total-answers-value' ).textContent = user[USER_COLUMNS.totalAnswers];
            
            html += getListItemHeader( STRINGS.questionHeader );

            for ( index = 0; index < user[USER_COLUMNS.questions].length; index++ ) {

                html += getQuestionItem( user[USER_COLUMNS.questions][index] );

            };

            $( '#user-questions' ).innerHTML = html;
            html = getListItemHeader( STRINGS.answerHeader );

            for ( index = 0; index < user[USER_COLUMNS.answers].length; index++ ) {

                html += getAnswerItem( user[USER_COLUMNS.answers][index] );

            };

            $( '#user-answers' ).innerHTML = html;

        };

        function toBase64UrlString( base64String ) {

            return base64String.replace( /\+/g, '-' ).replace( /\//g, '_' ).replace( /=/g, '' );

        };

        function toolbarClick( event ) {

            var item = event.target.closestByTagName( 'li' );

            if ( item && !item.disabled ) {

                if ( item.dataset.tab ) {

                    showPage( item.dataset.tab );

                } else {

                    switch ( item.id ) {

                        case 'add-answer-button':

                            showAddAnswer();

                            break;

                        case 'answer-user-button-1':
                        case 'answer-user-button-2':

                            showPage( 'user-page', { 

                                userId: item.dataset.userId, 
                                backCaption: STRINGS.backButtonAnswer, 
                                backPage:'answer-page', 
                                backSize: 57

                            } );

                            break;

                        case 'directions-button':

                            var directions = document.getElementById( 'directions-page' );

                            if( directions.hasClass( 'top-slide' ) ) {

                                directions.removeClass( 'top-slide' );

                            } else {

                                directions.addClass( 'top-slide' );

                            };

                            break;
                            
                        case 'question-user-button':

                            showPage( 'user-page', { 

                                userId: item.dataset.userId, 
                                backCaption: STRINGS.backButtonQuestion, 
                                backPage:'question-page', 
                                backSize: 64 

                            } );

                            break;

                        case 'user-button':

                            showPage( 'user-page', { 

                                userId: item.dataset.userId

                            } );

                            break;

                        case 'select-answer-button':

                            saveAnswerSelect( document.getElementById( 'answer-page' ).dataset.id );
                            break;

                        case 'vote-up-button':

                            saveAnswerVote( document.getElementById( 'answer-page' ).dataset.id );
                            break;

                    };

                };

            };

        };

        function unhoverItem( event ) {

            var item = event.target.closestByClassName( 'list-item' );

            if ( item ) {

                item.removeClass( 'hover' );

            };

        };

        function unselectButton( event ) {

            document.getElementById( 'back-button' ).removeClass( 'back-button-selected' );
            document.getElementById( 'back-button-arrow-2' ).removeClass( 'back-button-selected' );

        };

        function unselectItem( event ) {

            var item = event.target.closestByClassName( 'list-item' );

            if ( item ) {

                item.removeClass( 'select' );

            };

        };

        function unselectToolbarItem( event ) {

            var item = event.target.closestByClassName( 'toolbar-item' );

            if ( item ) {

                item.removeClass( 'toolbar-item-selected' );

            };

        };

        /* Crypto-JS v2.3.0 * http://code.google.com/p/crypto-js/ * Copyright (c) 2011, Jeff Mott. All rights reserved. * http://code.google.com/p/crypto-js/wiki/License */

        if ( typeof Crypto == "undefined" || !Crypto.util ) (function ()
        {
            var i = window.Crypto = {},
        n = i.util =
        {
            rotl: function ( a, c ) { return a << c | a >>> 32 - c },
            rotr: function ( a, c ) { return a << 32 - c | a >>> c },
            endian: function ( a ) { if ( a.constructor == Number ) return n.rotl( a, 8 ) & 16711935 | n.rotl( a, 24 ) & 4278255360; for ( var c = 0; c < a.length; c++ ) a[c] = n.endian( a[c] ); return a },
            randomBytes: function ( a ) { for ( var c = []; a > 0; a-- ) c.push( window.Math.floor( window.Math.random() * 256 ) ); return c },
            bytesToWords: function ( a ) { for ( var c = [], b = 0, d = 0; b < a.length; b++, d += 8 ) c[d >>> 5] |= a[b] << 24 - d % 32; return c },
            wordsToBytes: function ( a ) { for ( var c = [], b = 0; b < a.length * 32; b += 8 ) c.push( a[b >>> 5] >>> 24 - b % 32 & 255 ); return c },
            bytesToHex: function ( a ) { for ( var c = [], b = 0; b < a.length; b++ ) { c.push( ( a[b] >>> 4 ).toString( 16 ) ); c.push( ( a[b] & 15 ).toString( 16 ) ) } return c.join( "" ) },
            hexToBytes: function ( a ) { for ( var c = [], b = 0; b < a.length; b += 2 ) c.push( window.parseInt( a.substr( b, 2 ), 16 ) ); return c },
            bytesToBase64: function ( a ) { if ( typeof btoa == "function" ) return window.btoa( j.bytesToString( a ) ); for ( var c = [], b = 0; b < a.length; b += 3 ) for ( var d = a[b] << 16 | a[b + 1] << 8 | a[b + 2], e = 0; e < 4; e++ ) b * 8 + e * 6 <= a.length * 8 ? c.push( "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt( d >>> 6 * ( 3 - e ) & 63 ) ) : c.push( "=" ); return c.join( "" ) },
            base64ToBytes: function ( a ) { if ( typeof atob == "function" ) return j.stringToBytes( window.atob( a ) ); a = a.replace( /[^A-Z0-9+\/]/ig, "" ); for ( var c = [], b = 0, d = 0; b < a.length; d = ++b % 4 ) d != 0 && c.push( ( "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".indexOf( a.charAt( b - 1 ) ) & window.Math.pow( 2, -2 * d + 8 ) - 1 ) << d * 2 | "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".indexOf( a.charAt( b ) ) >>> 6 - d * 2 ); return c }
        }; i = i.charenc = {}; i.UTF8 = { stringToBytes: function ( a ) { return j.stringToBytes( window.unescape( window.encodeURIComponent( a ) ) ) },
            bytesToString: function ( a ) { return window.decodeURIComponent( window.escape( j.bytesToString( a ) ) ) }
        };

            var j = i.Binary =
        {
            stringToBytes: function ( a ) { for ( var c = [], b = 0; b < a.length; b++ ) c.push( a.charCodeAt( b ) & 255 ); return c },
            bytesToString: function ( a ) { for ( var c = [], b = 0; b < a.length; b++ ) c.push( window.String.fromCharCode( a[b] ) ); return c.join( "" ) }
        }

        } )();

        (function ()
        {
            var i = window.Crypto,
        n = i.util,
        j = i.charenc,
        a = j.UTF8,
        c = j.Binary,
        b = i.SHA1 = function ( d, e ) { var f = n.wordsToBytes( b._sha1( d ) ); return e && e.asBytes ? f : e && e.asString ? c.bytesToString( f ) : n.bytesToHex( f ) };

            b._sha1 = function ( d )
            {
                if ( d.constructor == String ) d = a.stringToBytes( d ); var e = n.bytesToWords( d ), f = d.length * 8; d = []; var k = 1732584193, g = -271733879, l = -1732584194, m = 271733878, o = -1009589776; e[f >> 5] |= 128 << 24 - f % 32; e[( f + 64 >>> 9 << 4 ) + 15] = f; for ( f = 0; f < e.length; f += 16 )
                {
                    for ( var q = k, r = g, s = l, t = m, u = o, h = 0; h < 80; h++ )
                    {
                        if ( h < 16 ) d[h] = e[f +
h]; else { var p = d[h - 3] ^ d[h - 8] ^ d[h - 14] ^ d[h - 16]; d[h] = p << 1 | p >>> 31 } p = ( k << 5 | k >>> 27 ) + o + ( d[h] >>> 0 ) + ( h < 20 ? ( g & l | ~g & m ) + 1518500249 : h < 40 ? ( g ^ l ^ m ) + 1859775393 : h < 60 ? ( g & l | g & m | l & m ) - 1894007588 : ( g ^ l ^ m ) - 899497514 ); o = m; m = l; l = g << 30 | g >>> 2; g = k; k = p
                    } k += q; g += r; l += s; m += t; o += u
                } return [k, g, l, m, o]
            };

            b._blocksize = 16;
            b._digestsize = 20

        } )();

        (function ()
        {

            var i = window.Crypto,
    n = i.util,
    j = i.charenc,
    a = j.UTF8,
    c = j.Binary;

            i.HMAC = function ( b, d, e, f )
            {

                if ( d.constructor == String ) d = a.stringToBytes( d );
                if ( e.constructor == String ) e = a.stringToBytes( e );
                if ( e.length > b._blocksize * 4 ) e = b( e, { asBytes: true } );
                var k = e.slice( 0 ); e = e.slice( 0 );

                for ( var g = 0; g < b._blocksize * 4; g++ )
                {

                    k[g] ^= 92;
                    e[g] ^= 54
                } b = b( k.concat( b( e.concat( d ), { asBytes: true } ) ), { asBytes: true } );

                return f && f.asBytes ? b : f && f.asString ? c.bytesToString( b ) : n.bytesToHex( b )

            }

        } )();

        Array.prototype.item = function ( value, column ) {

            column = column || 0;
            
            for ( var index = 0; index < this.length; index++ ) {

                if ( value == this[index][column] ) return this[index];

            };

        };

        Element.prototype.closestByClassName = function ( className ) {

            return this.className && this.className.split( ' ' ).indexOf( className ) > -1
                ? this
                : ( this.parentNode.closestByClassName && this.parentNode.closestByClassName( className ) );

        };

        Element.prototype.closestByTagName = function ( tagName ) {

            return this.tagName && this.tagName.toUpperCase() == tagName.toUpperCase()
                ? this
                : this.parentNode.closestByTagName && this.parentNode.closestByTagName( tagName );

        };

        Element.prototype.childByClassName = function ( className ) {

            for ( var index = 0; index < this.childNodes.length; index++ ) {

                var child = this.childNodes[index];

                if ( child.nodeType == Node.ELEMENT_NODE ) {

                    if ( child.getAttribute( 'class' ).split( ' ' ).indexOf( className ) > -1 ) {

                        return child;

                    } else {

                        child = child.childByClassName( className );
                        if ( child ) return child;

                    };

                };

            };

        };

        Element.prototype.hasClass = function ( className ) {

            return this.className.split( ' ' ).indexOf( className ) > -1;

        };

        Element.prototype.addClass = function ( className ) {

            if ( !this.hasClass( className ) ) {

                this.className = ( this.className + ' ' + className ).trim();

            };

            return this;

        };

        window.Object.defineProperty( Element.prototype, 'positionTop', {

            get: function () { 
        
                return this.offsetTop - this.parentNode.scrollTop;
            
            }

        } );

        Element.prototype.removeClass = function ( className ) {

            if ( this.hasClass( className ) ) {

                var regEx = new RegExp( '(\\s|^)' + className + '(\\s|$)' );
                this.className = this.className.replace( regEx, ' ' ).trim();

            };

            return this;

        };

        String.prototype.trim = function () {

            var str = this.replace( /^\s\s*/, '' ),
		        ws = /\s/,
		        i = str.length;
                while ( ws.test( str.charAt( --i ) ) );

            return str.slice( 0, i + 1 );

        };

        function $( selector ) {

            switch( selector[0] ) {

                case '#':

                    return document.getElementById( selector.substring( 1 ) );
                    break;

                case '.':

                    return document.getElementsByClassName( selector.substring( 1 ) );
                    break;

                default: //tags

                    return document.getElementsByTagName( selector.substring( 1 ) );

            };

        };

        function ajax( uri, settings ) {

            var ajax = new window.XMLHttpRequest(),
                data = settings.type == 'GET' ? '' : settings.data,
                async = settings.async ? settings.async : false;
            uri = settings.type == 'GET' ? uri + ( settings.data ? '?' + settings.data : '' ) : uri;

            ajax.onreadystatechange = function () {

                if ( ajax.readyState == 4 ) { //response ready

                    ajax.onreadystatechange = null;

                    if ( ajax.status == 200 ) { //success

                        if ( settings.success ) settings.success( ajax.responseText, ajax.statusText );
                        if ( settings.complete ) settings.complete( ajax, ajax.statusText );

                    } else {

                        if ( settings.error ) settings.error( ajax, ajax.status, ajax.statusText );

                    };

                };

            };

            ajax.open( settings.type, uri, async );

            if ( settings.headers ) {

                for ( var header in settings.headers ) {

                    ajax.setRequestHeader( header, settings.headers[header] );

                };

            };

            ajax.send( data );

        };

        function debug( text ) {

            document.getElementById( 'title' ).textContent = text;

        };

        window.setTimeout( initialize, 200 );

    };

} ) ( window );
