﻿/// <reference path="/scripts/strings-en.js" />

//'use strict';

(function ( /* window */ ) {

    var document = window.document;

    window.onload = function () {

        function updateVersion( event ) {

            window.applicationCache.removeEventListener( 'updateready', updateVersion, false );

            if ( window.applicationCache.status == window.applicationCache.UPDATEREADY ) {

                window.applicationCache.swapCache();
                window.location.reload();

            };

        };

        window.applicationCache.addEventListener( 'updateready', updateVersion, false );

        var _currentLocation = {},
            _session = {},
            _account = [],
            _userQuestions = [],
            _questions = [],
            _selectedQuestion = [],
            _swipeY = 0,
            _places,
            _userQuestionTimer,
            ACCOUNT_COLUMNS = {

                "userId": 0,
                "username": 1,
                "displayName": 2,
                "reputation": 3,
                "metricDistances": 4,
                "languageId": 5,
                "tagline": 6,
                "locations": 7

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
                "note": 8,
                "link": 9,
                "phone": 10,
                "latitude": 11,
                "longitude": 12,
                "distance": 13,
                "timestamp": 14,
                "selected": 15,
                "voted": 16,
                "votes": 17

            },
            BADGE_CLASSES = {

                "silver": 1,
                "gold": 2,
                "diamond": 3

            },
            BADGE_COLUMNS = {

                "badgeClassId": 0,
                "badge": 1,
                "description": 2,
                "unlimited": 3,
                "badges": 4

            },
            FACEBOOK_APP_ID = '267603823260704',
            FACEBOOK_AUTH_URL = 'http://urbanask.com',
            FACEBOOK_LOGIN_URL = 'http://urbanask.com/fb-login.html',
            INTERVALS = {

                "all": 0,
                "day": 1,
                "week": 2,
                "month": 3,
                "year": 4

            },
            LOCATION_COLUMNS = {

                "fromLatitude": 0,
                "fromLongitude": 1,
                "toLatitude": 2,
                "toLongitude": 3

            },
            LOCATION_RADIUS = 25000,
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
                "bounty": 11,
                "voted": 12,
                "votes": 13,
                "answerCount": 14,
                "answers": 15

            },
            REFRESH_QUESTION_RATE = 60000, // 60 seconds
            REFRESH_USER_QUESTION_RATE = 30000, //30 seconds
            REPUTATION_ACTION = {

                "resolvedQuestion": 2,
                "editedQuestion": 2,
                "downvotedAnswer": -3

            },
            REPUTATION_COLUMNS = {

                "reputationId": 0,
                "reputationAction": 1,
                "questionId": 2,
                "question": 3,
                "reputation": 4,
                "timestamp": 5

            },
            TOP_TYPES = {

                "reputation": 1,
                "questions": 2,
                "answers": 3,
                "badges": 4

            },
            TOP_USER_COLUMNS = {

                "regionId": 0,
                "topTypeId": 1,
                "intervalId": 2,
                "userId": 3,
                "username": 4,
                "reputation": 5,
                "totalQuestions": 6,
                "totalAnswers": 7,
                "totalBadges": 8,
                "topScore": 9

            },
            USER_COLUMNS = {

                "userId": 0,
                "username": 1,
                "displayName": 2,
                "reputation": 3,
                "signupDate": 4,
                "tagline": 5,
                "totalQuestions": 6,
                "totalAnswers": 7,
                "totalBadges": 8,
                "badges": 9,
                "questions": 10,
                "answers": 11,
                "reputations": 12

            },
            _pages = {

                data: [],

                add: function ( name, options ) {

                    this.data.push( new Page( name, options ) );

                },

                clear: function () {

                    this.data.length = 0;

                },

                replace: function ( name, options ) {

                    this.clear();
                    this.add( name, options );

                },

                remove: function () {

                    this.data.pop();

                }

            },
            _cache = {
                load: function () {

                    this.topUsers.load();

                },

                topUsers: {

                    duration: 5,
                    timestamp: new window.Date(),
                    data: [],
                    length: function () { return this.data.length },

                    load: function () {

                        var topUsers = window.localStorage.getItem( 'topUsers' ),
                            topUsersTimestamp = window.localStorage.getItem( 'topUsersTimestamp' );

                        if ( topUsers ) {

                            this.data = window.JSON.parse( topUsers );

                            if ( topUsersTimestamp ) {

                                this.timestamp = new window.Date( topUsersTimestamp );

                            } else {

                                this.timestamp.setMinutes( this.timestamp.getMinutes() - this.duration );

                            };

                        } else {

                            this.timestamp.setMinutes( this.timestamp.getMinutes() - this.duration );

                        };

                    },

                    refresh: function ( data ) {

                        this.clear();
                        this.timestamp = new window.Date();
                        this.data = window.JSON.parse( data );
                        window.localStorage.setItem( 'topUsers', data );
                        window.localStorage.setItem( 'topUsersTimestamp', this.timestamp );

                    },

                    isExpired: function () {

                        var expired = new window.Date();
                        expired.setMinutes( expired.getMinutes() - this.duration );

                        return this.timestamp < expired;

                    },

                    clear: function () {

                        this.data.length = 0;

                    }

                }

            };

        function accountClick() {

            showPage( 'account-page' );

        };

        function addDefaultEventListeners() {

            var toolbar = document.getElementById( 'toolbar' ),
                refreshButton = document.getElementById( 'refresh-button' );

            toolbar.addEventListener( 'click', toolbarClick, false );
            refreshButton.addEventListener( 'click', refresh, false );

            if ( hasTouch() ) {

                var viewport = document.getElementById( 'viewport' );
                viewport.addEventListener( 'touchmove', onTouchMove, false );
                viewport.addEventListener( 'touchstart', onTouchStart, false );

                toolbar.addEventListener( 'touchstart', selectToolbarItem, false );
                toolbar.addEventListener( 'touchend', unselectToolbarItem, false );

                refreshButton.addEventListener( 'touchstart', selectButton, false );
                refreshButton.addEventListener( 'touchend', unselectButton, false );

            } else {

                toolbar.addEventListener( 'mousedown', selectToolbarItem, false );
                toolbar.addEventListener( 'mouseup', unselectToolbarItem, false );

                refreshButton.addEventListener( 'mousedown', selectButton, false );
                refreshButton.addEventListener( 'mouseup', unselectButton, false );

            };

        };

        function addEventListeners( page, previousPage ) {

            var backButton, questions;

            removeEventListeners( previousPage );

            switch ( page ) {

                case 'account-page':

                    var save = document.getElementById( 'save-edit' ),
                        inviteButton = document.getElementById( 'invite' ),
                        postButton = document.getElementById( 'post' ),
                        logoutButton = document.getElementById( 'logout' );

                    save.addEventListener( 'click', saveAccount, false );
                    inviteButton.addEventListener( 'click', inviteFriends, false );
                    postButton.addEventListener( 'click', postToWall, false );
                    logoutButton.addEventListener( 'click', logout, false );

                    window.addEventListener( 'message', authorizeFacebook, false );

                    if ( hasTouch() ) {

                        save.addEventListener( 'touchstart', selectButton, false );
                        save.addEventListener( 'touchend', unselectButton, false );

                        inviteButton.addEventListener( 'touchstart', selectButton, false );
                        inviteButton.addEventListener( 'touchend', unselectButton, false );

                        postButton.addEventListener( 'touchstart', selectButton, false );
                        postButton.addEventListener( 'touchend', unselectButton, false );

                        logoutButton.addEventListener( 'touchstart', selectButton, false );
                        logoutButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

                        save.addEventListener( 'mousedown', selectButton, false );
                        save.addEventListener( 'mouseup', unselectButton, false );

                        inviteButton.addEventListener( 'mousedown', selectButton, false );
                        inviteButton.addEventListener( 'mouseup', unselectButton, false );

                        postButton.addEventListener( 'mousedown', selectButton, false );
                        postButton.addEventListener( 'mouseup', unselectButton, false );

                        logoutButton.addEventListener( 'mousedown', selectButton, false );
                        logoutButton.addEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

                case 'add-answer-page':

                    var location = document.getElementById( 'locations' );
                    location.addEventListener( 'click', locationsClick, false );

                    document.getElementById( 'cancel-answer-button' ).addEventListener( 'click', hideAddAnswer, false );

                    var answerText = document.getElementById( 'answer-text' );
                    answerText.addEventListener( 'keyup', autocompleteLocations, false );
                    //answerText.addEventListener( 'focus', keyboardUp, false );
                    //answerText.addEventListener( 'blur', keyboardDown, false );

                    document.getElementById( 'answer' ).addEventListener( 'submit', answerSubmit, false );

                    if ( !hasTouch() ) {

                        location.addEventListener( 'mouseover', hoverItem, false );
                        location.addEventListener( 'mouseout', unhoverItem, false );

                    };

                    break;

                case 'answer-page':

                    document.getElementById( 'travel-mode-toolbar' ).addEventListener( 'click', travelModeClick, false );

                    backButton = document.getElementById( 'back-button' );
                    backButton.addEventListener( 'click', goBack, false );

                    if ( hasTouch() ) {

                        backButton.addEventListener( 'touchstart', selectButton, false );
                        backButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

                        backButton.addEventListener( 'mousedown', selectButton, false );
                        backButton.addEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

                case 'login-page':

                    var loginButton = document.getElementById( 'login-button' );
                    document.getElementById( 'login-page' ).addEventListener( 'submit', login, false );

                    var facebookButton = document.getElementById( 'fb-login' );
                    facebookButton.addEventListener( 'click', loginFacebook, false );

                    window.addEventListener( 'message', authorizeFacebook, false );

                    if ( hasTouch() ) {

                        loginButton.addEventListener( 'touchstart', selectButton, false );
                        loginButton.addEventListener( 'touchend', unselectButton, false );
                        facebookButton.addEventListener( 'touchstart', selectButton, false );
                        facebookButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

                        loginButton.addEventListener( 'mousedown', selectButton, false );
                        loginButton.addEventListener( 'mouseup', unselectButton, false );
                        //                        facebookButton.addEventListener( 'mousedown', selectButton, false );
                        //                        facebookButton.addEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

                case 'question-page':

                    var answers = document.getElementById( 'answers' );
                    answers.addEventListener( 'click', answerClick, false );

                    var questionView = document.getElementById( 'question-view' );
                    questionView.addEventListener( 'click', questionItemClick, false );

                    backButton = document.getElementById( 'back-button' );
                    backButton.addEventListener( 'click', goBack, false );

                    document.getElementById( 'question-map' ).addEventListener( 'click', questionItemClick, false );

                    if ( hasTouch() ) {

                        questionView.addEventListener( 'touchstart', selectItem, false );
                        questionView.addEventListener( 'touchend', unselectItem, false );

                        backButton.addEventListener( 'touchstart', selectButton, false );
                        backButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

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

                    backButton = document.getElementById( 'back-button' );
                    backButton.addEventListener( 'click', goBack, false );

                    if ( hasTouch() ) {

                        backButton.addEventListener( 'touchstart', selectButton, false );
                        backButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

                        backButton.addEventListener( 'mousedown', selectButton, false );
                        backButton.addEventListener( 'mouseup', unselectButton, false );

                    };

                case 'questions-page':

                    var userQuestions = document.getElementById( 'user-questions' );
                    userQuestions.addEventListener( 'click', questionClick, false );

                    questions = document.getElementById( 'questions' );
                    questions.addEventListener( 'click', questionClick, false );

                    var askText = document.getElementById( 'ask-text' );
                    askText.addEventListener( 'focus', showAskButton, false );
                    askText.addEventListener( 'blur', hideAskButton, false );

                    var ask = document.getElementById( 'ask' );
                    ask.addEventListener( 'submit', saveQuestion, false );

                    if ( hasTouch() ) {

                        //ask.addEventListener( 'touchstart', selectAskText, false );

                    } else {

                        userQuestions.addEventListener( 'mouseover', hoverItem, false );
                        userQuestions.addEventListener( 'mouseout', unhoverItem, false );

                        questions.addEventListener( 'mouseover', hoverItem, false );
                        questions.addEventListener( 'mouseout', unhoverItem, false );

                        //ask.addEventListener( 'mousedown', selectAskText, false );

                    };

                    break;

                case 'top-page':

                    var topUsers = document.getElementById( 'top-users' );
                    topUsers.addEventListener( 'click', userClick, false );

                    var topType = document.getElementById( 'top-type' ),
                        topInterval = document.getElementById( 'top-interval' );

                    if ( hasTouch() ) {

                        topType.addEventListener( 'touchstart', topTypeClick, false );
                        topInterval.addEventListener( 'touchstart', topIntervalClick, false );

                    } else {

                        topUsers.addEventListener( 'mouseover', hoverItem, false );
                        topUsers.addEventListener( 'mouseout', unhoverItem, false );

                        topType.addEventListener( 'mousedown', topTypeClick, false );
                        topInterval.addEventListener( 'mousedown', topIntervalClick, false );

                    };

                    break;

                case 'user-page':

                    var reputationItems = document.getElementById( 'user-reputations' );
                    reputationItems.addEventListener( 'click', reputationItemClick, false );

                    questions = document.getElementById( 'users-questions' );
                    questions.addEventListener( 'click', questionClick, false );

                    var answers = document.getElementById( 'user-answers' );
                    answers.addEventListener( 'click', userAnswerClick, false );

                    var badges = document.getElementById( 'user-badges' );
                    badges.addEventListener( 'click', badgeClick, false );

                    var totalReputation = document.getElementById( 'reputation' );
                    totalReputation.addEventListener( 'click', totalReputationClick, false );

                    var totalQuestions = document.getElementById( 'total-questions' );
                    totalQuestions.addEventListener( 'click', totalQuestionsClick, false );

                    var totalAnswers = document.getElementById( 'total-answers' );
                    totalAnswers.addEventListener( 'click', totalAnswersClick, false );

                    var totalBadges = document.getElementById( 'total-badges' );
                    totalBadges.addEventListener( 'click', totalBadgesClick, false );

                    backButton = document.getElementById( 'back-button' );
                    backButton.addEventListener( 'click', goBack, false );

                    document.getElementById( 'edit-account' ).addEventListener( 'click', accountClick, false );
                    document.getElementById( 'user-picture' ).addEventListener( 'click', accountClick, false );

                    if ( hasTouch() ) {

                        totalReputation.addEventListener( 'touchstart', selectElement, false );
                        totalReputation.addEventListener( 'touchend', unselectElement, false );

                        totalQuestions.addEventListener( 'touchstart', selectElement, false );
                        totalQuestions.addEventListener( 'touchend', unselectElement, false );

                        totalAnswers.addEventListener( 'touchstart', selectElement, false );
                        totalAnswers.addEventListener( 'touchend', unselectElement, false );

                        totalBadges.addEventListener( 'touchstart', selectElement, false );
                        totalBadges.addEventListener( 'touchend', unselectElement, false );

                        backButton.addEventListener( 'touchstart', selectButton, false );
                        backButton.addEventListener( 'touchend', unselectButton, false );

                    } else {

                        totalReputation.addEventListener( 'mousedown', selectElement, false );
                        totalReputation.addEventListener( 'mouseup', unselectElement, false );
                        totalReputation.addEventListener( 'mouseover', hoverElement, false );
                        totalReputation.addEventListener( 'mouseout', unhoverElement, false );

                        totalQuestions.addEventListener( 'mousedown', selectElement, false );
                        totalQuestions.addEventListener( 'mouseup', unselectElement, false );
                        totalQuestions.addEventListener( 'mouseover', hoverElement, false );
                        totalQuestions.addEventListener( 'mouseout', unhoverElement, false );

                        totalAnswers.addEventListener( 'mousedown', selectElement, false );
                        totalAnswers.addEventListener( 'mouseup', unselectElement, false );
                        totalAnswers.addEventListener( 'mouseover', hoverElement, false );
                        totalAnswers.addEventListener( 'mouseout', unhoverElement, false );

                        totalBadges.addEventListener( 'mousedown', selectElement, false );
                        totalBadges.addEventListener( 'mouseup', unselectElement, false );
                        totalBadges.addEventListener( 'mouseover', hoverElement, false );
                        totalBadges.addEventListener( 'mouseout', unhoverElement, false );

                        reputationItems.addEventListener( 'mouseover', hoverItem, false );
                        reputationItems.addEventListener( 'mouseout', unhoverItem, false );

                        questions.addEventListener( 'mouseover', hoverItem, false );
                        questions.addEventListener( 'mouseout', unhoverItem, false );

                        backButton.addEventListener( 'mousedown', selectButton, false );
                        backButton.addEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

            };

        };

        function answerClick( event ) {

            selectItem( event );

            window.setTimeout( function () {

                var answerItem = event.target.closestByClassName( 'answer-item' );

                if ( answerItem ) {

                    var select = answerItem.getElementsByClassName( 'select-answer' ),
                        voteUp = answerItem.getElementsByClassName( 'vote-up-answer' ),
                        voteDown = answerItem.getElementsByClassName( 'vote-down-answer' ),
                        flag = answerItem.getElementsByClassName( 'flag-answer' );

                    if ( select.length && !select[0].hasClass( 'hide' ) ) {

                        saveAnswerSelect( _selectedQuestion, answerItem.getDataset( 'id' ) );

                    } else if ( voteUp.length && !voteUp[0].hasClass( 'hide' ) ) {

                        saveAnswerUpvote( _selectedQuestion, answerItem );

                    } else if ( voteDown.length && !voteDown[0].hasClass( 'hide' ) ) {

                        saveAnswerDownvote( _selectedQuestion, answerItem );

                    } else if ( flag.length && !flag[0].hasClass( 'hide' ) ) {

                        saveAnswerFlag( _selectedQuestion, answerItem );

                    } else {

                        showPage( 'answer-page', { answerId: answerItem.getDataset( 'id' ), answerLetter: answerItem.getDataset( 'letter' ) } );

                    };

                };

                window.setTimeout( function () { unselectItem( event ); }, 100 );

            }, 100 );

        };

        function answerSubmit( event ) {

            event.preventDefault();

        };

        function autocompleteLocations() {

            _places.searchRequest.name = document.getElementById( 'answer-text' ).value;
            _places.search( _places.searchRequest, function ( results, status ) {

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
                        + 'data-reference="' + results[index].reference + '" '
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

        function badgeClick( event ) {

            var badge = event.target.closestByClassName( 'badge' );

            if ( badge ) {

                showMessage( badge.getDataset( 'description' ) );

            };

        };

        function checkLogin() {

            if ( _session.id && _session.key ) {

                loadAccount();
                loadUserQuestions();
                loadQuestions();
                setupGeolocation();
                refreshQuestions();
                refreshUserQuestions();

                showPage( 'questions-page' );

            } else {

                showPage( 'login-page' );

            };

        };

        function deleteAnswer( answerId ) {

            var resource = '/api/answers/' + answerId + '/delete',
                session = getSession( resource );

            ajax( resource, {

                "type": "GET",
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    //delete answer count from _questions
                    //refresh questions-page
                    //delete answer from _selectedQuestion
                    //detete answer count from _selectedQuestion
                    //refresh question-page
                    //go back to question-page


                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : showMessage( STRINGS.error.deleteAnswer + ' ( error: ' + status + ', ' + error + ')' );

                }

            } );

        };

        function formatNumber( number ) {

            var x = number.toString().split( '.' ),
	            x1 = x[0],
	            x2 = x.length > 1 ? '.' + x[1] : '',
	            regEx = /(\d+)(\d{3})/;

            while ( regEx.test( x1 ) ) {

                x1 = x1.replace( regEx, '$1' + ',' + '$2' );

            };

            return x1 + x2;

        };

        function clearUser() {

            $( '#user-picture' ).src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVQI12P4DwQACfsD/WMmxY8AAAAASUVORK5CYII=';
            $( '#username' ).textContent = '\u00a0';
            $( '#member-since' ).textContent = '\u00a0';
            $( '#user-id-value' ).textContent = '\u00a0';
            $( '#signup-info' ).addClass( 'hide' );
            $( '#tagline' ).textContent = '\u00a0';
            $( '#reputation-value' ).textContent = '\u00a0';
            $( '#total-questions-value' ).textContent = '\u00a0';
            $( '#total-answers-value' ).textContent = '\u00a0';
            $( '#total-badges-value' ).textContent = '\u00a0';
            $( '#user-reputations' ).addClass( 'hide' );
            $( '#users-questions' ).addClass( 'hide' );
            $( '#user-answers' ).addClass( 'hide' );
            $( '#user-badges' ).addClass( 'hide' );

        };

        function getAge( timestamp ) {

            var age = window.Math.floor( ( new window.Date().getTime() - new window.Date( timestamp ).getTime() ) / 60000 );

            if ( age > 1440 ) {

                age = window.Math.floor( age / 60 / 24 );
                return age == 1 ? age + ' ' + STRINGS.ageDay : age + ' ' + STRINGS.ageDays;

            } else if ( age > 60 ) {

                age = window.Math.floor( age / 60 );
                return age == 1 ? age + ' ' + STRINGS.ageHour : age + ' ' + STRINGS.ageHours;

            } else if ( age > 0 ) {

                return age == 1 ? age + ' ' + STRINGS.ageMinute : age + ' ' + STRINGS.ageMinutes;

            } else { //0

                return STRINGS.ageNow;

            };

        };

        function getAnswerItem( answer, options ) {

            var classes = '',
                action = '',
                note = '',
                contact = '',
                questionId = '';

            if ( options.newItem ) {

                if ( answer[ANSWER_COLUMNS.note] && ( answer[ANSWER_COLUMNS.phone] || answer[ANSWER_COLUMNS.link] ) ) {

                    classes = 'new-answer-tall list-item list-item-slide height-zero';

                } else if ( answer[ANSWER_COLUMNS.note] || answer[ANSWER_COLUMNS.phone] || answer[ANSWER_COLUMNS.link] ) {

                    classes = 'new-answer-medium list-item list-item-slide height-zero';

                } else {

                    classes = 'new-answer-short list-item list-item-slide height-zero';

                };

            } else {

                classes = 'answer-item list-item';

            };

            if ( !options.newItem && options.letter ) {

                if ( isMyQuestion( _selectedQuestion ) ) {

                    action = '<div class="select-answer width-zero fade hide">' + STRINGS.checkmark + '</div>';

                } else {

                    action = '<div class="vote-up-answer width-zero fade hide">' + STRINGS.voteUpCaption + '</div>'
                        + '<div class="vote-down-answer width-zero fade hide">' + STRINGS.voteDownCaption + '</div>'
                        + '<div class="flag-answer width-zero fade hide">' + STRINGS.flagCaption + '</div>';

                };

            };

            if ( answer[ANSWER_COLUMNS.note] ) {

                note = '<div class="note">' + answer[ANSWER_COLUMNS.note] + '</div>';

            };

            if ( answer[ANSWER_COLUMNS.phone] && answer[ANSWER_COLUMNS.link] ) {

                contact = '<div class="location-contact">'
                    + answer[ANSWER_COLUMNS.phone]
                    + ' &#x2022; '
                    + answer[ANSWER_COLUMNS.link]
                    + '</div>';

            } else if ( answer[ANSWER_COLUMNS.phone] || answer[ANSWER_COLUMNS.link] ) {

                contact = '<div class="location-contact">'
                    + answer[ANSWER_COLUMNS.phone]
                    + answer[ANSWER_COLUMNS.link]
                    + '</div>';

            };

            if ( options.questionId ) {

                questionId = 'data-question-id="' + answer[ANSWER_COLUMNS.questionId] + '" ';

            };

            return '<li class="' + classes + '" '
                + 'data-id="' + answer[ANSWER_COLUMNS.answerId] + '" '
                + questionId
                + 'data-letter="' + ( options.letter ? options.letter : '' ) + '">'
                + action
                + '<div class="location-name">'
                + getLetter( options.letter )
                + getVotes( answer[ANSWER_COLUMNS.votes] )
                + getSelected( answer[ANSWER_COLUMNS.selected] )
                + answer[ANSWER_COLUMNS.location]
                + '</div>'
                + '<div class="location-address">' + answer[ANSWER_COLUMNS.locationAddress] + '</div>'
                + contact
                + note
                + '<ul class="info">'
                + '<li class="info-item">' + getDistance( answer[ANSWER_COLUMNS.distance] ) + '</li>'
                + '<li class="info-item">' + answer[ANSWER_COLUMNS.username] + '</li>'
                + '<li class="info-item reputation">' + formatNumber( answer[ANSWER_COLUMNS.reputation] ) + '</li>'
                + '</ul>'
                + '</li>';

        };

        function getBadgeItem( badge ) {

            var badgeClass = badge[BADGE_COLUMNS.badges] ? 'badge' : 'badge badge-unearned',
                emblemClass = '',
                count = '',
                countClass = '';

            switch ( badge[BADGE_COLUMNS.badgeClassId] ) {
                case BADGE_CLASSES.silver:

                    emblemClass = 'badge-emblem-silver';
                    break;

                case BADGE_CLASSES.gold:

                    emblemClass = 'badge-emblem-gold';
                    break;

                case BADGE_CLASSES.diamond:

                    emblemClass = 'badge-emblem-diamond';
                    break;

            };

            if ( badge[BADGE_COLUMNS.unlimited] ) {

                count = badge[BADGE_COLUMNS.badges] ? STRINGS.multiplication + badge[BADGE_COLUMNS.badges] : '';
                countClass = 'badge-count badge-count-number';

            } else {

                count = badge[BADGE_COLUMNS.badges] ? STRINGS.checkmark : '';
                countClass = 'badge-count badge-count-check';

            };

            return '<li class="badge-item">'
                + '<div class="' + badgeClass + '" data-description="'
                + badge[BADGE_COLUMNS.description] + '">'
                + '<span class="badge-emblem ' + emblemClass + '"></span>'
                + '<span class="badge-text">' + badge[BADGE_COLUMNS.badge] + '</span>'
                + '<span class="' + countClass + '">' + count + '</span>'
                + '</div>'
                + '</li>';

        };


        function getDistance( distance ) {

            var useMiles = !_account[ACCOUNT_COLUMNS.metricDistances];

            if ( useMiles ) distance = window.Math.floor( distance * 3.28 ); //meters to feet

            if ( distance > ( useMiles ? 527 : 99 ) ) { // 1/10th

                distance = useMiles ? window.Math.floor( distance / 5280 * 10 ) / 10 : window.Math.floor( distance / 1000 * 10 ) / 10;
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

        function getMemberSince( user ) {

            var signupDate = new Date( user[USER_COLUMNS.signupDate] );

            return STRINGS.dateFormat
                .replace( "%m", STRINGS.months[signupDate.getMonth()] )
                .replace( "%d", signupDate.getDate() )
                .replace( "%y", signupDate.getFullYear() );

        };

        function getNoItems( message ) {

            return '<li class="no-items">' + message + '</li>';

        };

        function getQuestionItem( question, options ) {

            var listClasses = '',
                bodyClass = '',
                count = '',
                resolved = '',
                bounty = '',
                action = '';

            if ( options && options.newItem ) {

                listClasses = 'new-question list-item list-item-slide height-zero';

            } else {

                listClasses = 'question-item list-item';

            };

            if ( options && options.full ) {

                bodyClass = 'question-item-body question-item-body-full';

            } else {

                bodyClass = 'question-item-body question-item-body-normal';

            };

            if ( question[QUESTION_COLUMNS.resolved] ) {

                count = STRINGS.checkmark;
                resolved = ' resolved';

            } else {

                count = question[QUESTION_COLUMNS.answerCount];

            };

            if ( question[QUESTION_COLUMNS.bounty] ) {

                bounty = '<span class="bounty">+' + question[QUESTION_COLUMNS.bounty] + '</span>';

            };

            if ( !isMyQuestion( _selectedQuestion ) ) {

                action = '<div class="vote-up-question width-zero fade hide">' + STRINGS.voteUpCaption + '</div>'
                    + '<div class="flag-question width-zero fade hide">' + STRINGS.flagCaption + '</div>';

            };

            return '<li class="' + listClasses + '" '
                + 'data-id="' + question[QUESTION_COLUMNS.questionId] + '">'
                + action
                + '<div class="answer-count-view' + resolved + '"><div class="answer-count">' + count + '</div></div>'
                + '<div class="' + bodyClass + '">'
                + getVotes( question[QUESTION_COLUMNS.votes] )
                + bounty
                + question[QUESTION_COLUMNS.question]
                + '</div>'
                + '<ul class="info">'
                + '<li class="info-item">' + question[QUESTION_COLUMNS.username] + '</li>'
                + '<li class="info-item reputation">' + formatNumber( question[QUESTION_COLUMNS.reputation] ) + '</li>'
                + '</ul>'
                + '</li>';

        };

        function getReputation() {

            if ( _userQuestions.length ) {

                return _userQuestions[0][QUESTION_COLUMNS.reputation];

            } else {

                return _account[ACCOUNT_COLUMNS.reputation];

            };

        };

        function getReputationItem( reputation, options ) {

            var reputationClass = '',
                reputationAmount = '';

            if ( reputation[REPUTATION_COLUMNS.reputation] > 0 ) {

                reputationClass = 'reputation-add reputation-item-amount';
                reputationAmount = '+' + reputation[REPUTATION_COLUMNS.reputation];

            } else {

                reputationClass = 'reputation-subtract reputation-item-amount';
                reputationAmount = reputation[REPUTATION_COLUMNS.reputation];

            };

            return '<li class="reputation-item list-item" '
                + 'data-id="' + reputation[REPUTATION_COLUMNS.questionId] + '">'
                + '<div class="' + reputationClass + '">' + reputationAmount + '</div>'
                + '<div class="reputation-body">' + reputation[REPUTATION_COLUMNS.question] + '</div>'
                + '<ul class="info">'
                + '<li class="info-item">' + reputation[REPUTATION_COLUMNS.reputationAction] + '</li>'
                + '</ul>'
                + '</li>';

        };

        function getSelected( selected, slide ) {

            if ( slide ) {

                return selected ? '<span class="selected width-slide width-zero">' + STRINGS.checkmark + '</span>' : '';

            } else {

                return selected ? '<span class="selected">' + STRINGS.checkmark + '</span>' : '';

            };

        };

        function getSession( resource ) {

            return _session.id
                ? _session.id + ':' + toBase64UrlString( 
                    window.Crypto.util.bytesToBase64( 
                    window.Crypto.HMAC( window.Crypto.SHA1, resource + _session.id, _session.key, { asBytes: true } ) ) )
                : '';

        };

        function getTopUserItem( topTypeId, user, count ) {

            var resource = '/api/users/' + user[TOP_USER_COLUMNS.userId] + '/picture',
                topScore = topTypeId == TOP_TYPES.reputation ? 'top-score top-reputation' : 'top-score';

            return '<li class="user-item list-item"'
                + 'data-id="' + user[TOP_USER_COLUMNS.userId] + '">'
                + '<div class="user-count">' + count + '</div>'
                + '<img class="user-icon" src="' + resource + '?x-session=' + getSession( resource ) + '" />'
                + '<div class="' + topScore + '">' + formatNumber( user[TOP_USER_COLUMNS.topScore] ) + '</div>'
                + '<div class="username">' + user[TOP_USER_COLUMNS.username] + '</div>'
                + '<ul class="user-info">'
                + '<li class="info-item">' + formatNumber( user[TOP_USER_COLUMNS.reputation] ) + '</li>'
                + '<li class="info-item">' + formatNumber( user[TOP_USER_COLUMNS.totalQuestions] ) + '</li>'
                + '<li class="info-item">' + formatNumber( user[TOP_USER_COLUMNS.totalAnswers] ) + '</li>'
                + '<li class="info-item">' + formatNumber( user[TOP_USER_COLUMNS.totalBadges] ) + '</li>'
                + '</ul>'
                + '</li>';

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

            showPage( event.currentTarget.getDataset( 'page' ), window.JSON.parse( event.currentTarget.getDataset( 'options' ) ) );

        };

        function hasTouch() {

            return ( typeof Touch == "object" );

        }

        function hideAddAnswer() {

            removeEventListeners( 'add-answer-page' );

            var addAnswer = document.getElementById( 'add-answer-page' );
            addAnswer.addClass( 'top-slide' );
            window.setTimeout( function () { addAnswer.addClass( 'hide' ) }, 800 );

        };

        function hideAddressBar() {

            setTimeout( function () { window.scrollTo( 0, 1 ) }, 100 );

        };

        function hideAnswersSelect() {

            var answers = document.getElementById( 'answers' ).getElementsByClassName( 'select-answer' );

            for ( var index = 0; index < answers.length; index++ ) {

                answers[index].addClass( 'fade' );

            };

            if ( answers.length ) {

                window.setTimeout( function () {

                    for ( var index = 0; index < answers.length; index++ ) {

                        answers[index].addClass( 'width-zero' );

                    };

                }, 100 );

                window.setTimeout( function () {

                    for ( var index = 0; index < answers.length; index++ ) {

                        answers[index].addClass( 'hide' );

                    };

                }, 600 );

            };

        };

        function hideContact() {

            var contact = document.getElementById( 'contact' ),
                event = document.createEvent( 'HTMLEvents' );

            event.initEvent( 'close', false, false );
            contact.dispatchEvent( event );

        };

        function hideFlag() {

            var question = document.getElementById( 'question-view' ).getElementsByClassName( 'flag-question' )[0],
                answers = document.getElementById( 'answers' ).getElementsByClassName( 'flag-answer' );

            question.addClass( 'fade' );

            for ( var index = 0; index < answers.length; index++ ) {

                answers[index].addClass( 'fade' );

            };

            window.setTimeout( function () {

                question.addClass( 'width-zero' );

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].addClass( 'width-zero' );

                };

            }, 100 );

            window.setTimeout( function () {

                question.addClass( 'hide' );

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].addClass( 'hide' );

                };

            }, 600 );

        };

        function hideQuestionShare() {

            var share = document.getElementById( 'question-share' ),
                event = document.createEvent( 'HTMLEvents' );

            event.initEvent( 'close', false, false );
            share.dispatchEvent( event );

        };

        function hideVoteDown() {

            var answers = document.getElementById( 'answers' ).getElementsByClassName( 'vote-down-answer' );

            for ( var index = 0; index < answers.length; index++ ) {

                answers[index].addClass( 'fade' );

            };

            window.setTimeout( function () {

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].addClass( 'width-zero' );

                };

            }, 100 );

            window.setTimeout( function () {

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].addClass( 'hide' );

                };

            }, 600 );

        };

        function hideVoteUp() {

            var question = document.getElementById( 'question-view' ).getElementsByClassName( 'vote-up-question' )[0],
                answers = document.getElementById( 'answers' ).getElementsByClassName( 'vote-up-answer' );

            question.addClass( 'fade' );

            for ( var index = 0; index < answers.length; index++ ) {

                answers[index].addClass( 'fade' );

            };

            window.setTimeout( function () {

                question.addClass( 'width-zero' );

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].addClass( 'width-zero' );

                };

            }, 100 );

            window.setTimeout( function () {

                question.addClass( 'hide' );

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].addClass( 'hide' );

                };

            }, 600 );

        };

        function hideAskButton() {

            if ( !document.getElementById( 'ask-text' ).value ) {

                document.getElementById( 'ask-button' ).addClass( 'ask-button-slide' );

            };

        };

        function hideBackButton() {

            document.getElementById( 'back-button' ).addClass( 'hide' );

        };

        function hideEditAccount() {

            document.getElementById( 'edit-account' ).addClass( 'hide' );

        };

        function hideLoading() {

            var loading = document.getElementById( 'loading' );
            loading.addClass( 'hide' );

        };

        function slidePage( currentPageName, previousPageName ) {

            if ( currentPageName != previousPageName ) {

                var previousPage = document.getElementById( previousPageName ),
                    currentPage = document.getElementById( currentPageName ),
                    previousClass = '',
                    currentClass = '';

                //                currentPage.removeClass( 'page-slideable' ).removeClass( 'page-slide-left' ).removeClass( 'page-slide-right' );

                //                switch ( currentPageName ) {
                //                    case 'answer-page':
                //                    case 'question-page':

                //                        currentClass = 'page-slide-right';
                //                        previousClass = 'page-slide-left';

                //                        break;

                //                    case 'questions-page':

                //                        currentClass = 'page-slide-left';
                //                        previousClass = 'page-slide-right';

                //                        break;

                //                    case 'top-page':

                //                        switch ( previousPageName ) {
                //                            case 'questions-page':

                //                                currentClass = 'page-slide-right';
                //                                previousClass = 'page-slide-left';

                //                                break;

                //                            case 'user-page':

                //                                currentClass = 'page-slide-left';
                //                                previousClass = 'page-slide-right';

                //                                break;

                //                        };

                //                        break;

                //                    case 'user-page':

                //                        currentClass = 'page-slide-right';
                //                        previousClass = 'page-slide-left';

                //                        break;

                //                    default:



                if ( previousPage ) previousPage.addClass( 'hide' );
                currentPage.removeClass( 'hide' );

                //                if ( previousPage ) previousPage.style.display = 'none';
                //                currentPage.style.display = 'block';




                //                };

                //                currentPage.addClass( currentClass ).addClass( 'page-slideable' ).removeClass( 'hide' );

                //                window.setTimeout( function () {

                //                    currentPage.removeClass( currentClass );

                //                    if ( previousPageName ) {

                //                        previousPage.addClass( previousClass );
                //                        window.setTimeout( function () { previousPage.addClass( 'hide' ) }, 550 );

                //                    };

                //                }, 10 );

            };

        };

        function hideSplashPage() {

            window.setTimeout( function () {

                var splash = document.getElementById( 'splash' );
                splash.addClass( 'fade' );
                window.setTimeout( function () { splash.addClass( 'hide' ); }, 500 );

            }, 1 );

        };

        function hideRefreshButton() {

            document.getElementById( 'refresh-button' ).addClass( 'hide' );

        };

        function hoverElement( event ) {

            var item = event.target.closestByClassName( 'selectable' );
            if ( item ) item.addClass( 'hover' );

        };

        function hoverItem( event ) {

            var item = event.target.closestByClassName( 'list-item' );

            if ( item ) {

                item.addClass( 'hover' );

            };

        };

        function initialize() {

            if ( isIOSDevice() && !window.navigator.standalone ) {

                hideSplashPage();
                hideAddressBar();
                showPage( 'install-page' );

            } else {

                initializeTrackingCode();
                addDefaultEventListeners();
                initializeInterface();
                localizeStrings();
                loadCachedData();
                hideSplashPage();
                checkLogin()

            };

        };

        function initializeInterface() {

            document.getElementById( 'top-type' ).setDataset( 'id', TOP_TYPES.reputation );
            document.getElementById( 'top-interval' ).setDataset( 'id', INTERVALS.all );
            document.querySelectorAll( '#top-type .toggle-button[data-id="' + TOP_TYPES.reputation + '"]' )[0].addClass( 'toggle-button-selected' );
            document.querySelectorAll( '#top-interval .toggle-button[data-id="' + INTERVALS.all + '"]' )[0].addClass( 'toggle-button-selected' );

            showSocialButtons();

        };

        function initializeTrackingCode() {

            if ( !hasTouch() ) {

                var script = document.createElement( 'script' ),
                    html =
                          'var _gaq = _gaq || [];'
                        + '_gaq.push( ["_setAccount", "UA-23915674-8"] );'
                        + '_gaq.push( ["_trackPageview"] );'
                        + '(function () {'
                        + 'var ga = document.createElement( "script" ); ga.type = "text/javascript"; ga.async = true;'
                        + 'ga.src = ( "https:" == document.location.protocol ? "https://ssl" : "http://www" ) + ".google-analytics.com/ga.js";'
                        + 'var s = document.getElementsByTagName( "script" )[0]; s.parentNode.insertBefore( ga, s );'
                        + '} )();'

                script.appendChild( document.createTextNode( html ) );
                document.head.appendChild( script );

            };

        };

        function inviteFriends( event ) {

            event.preventDefault();
            window.location.href = FACEBOOK_LOGIN_URL + '?button=invite';

        };

        function isIOSDevice() {

            if ( window.navigator.userAgent.indexOf( 'iPhone' ) > -1
                || window.navigator.userAgent.indexOf( 'iPod' ) > -1 ) {

                return true;

            };

        }

        function isMe( user ) {

            return ( _account[ACCOUNT_COLUMNS.userId] == user[USER_COLUMNS.userId] );

        };

        function isMyAnswer( answer ) {

            return ( _account[ACCOUNT_COLUMNS.userId] == answer[ANSWER_COLUMNS.userId] );

        };

        function isMyQuestion( question ) {

            return ( _account[ACCOUNT_COLUMNS.userId] == question[QUESTION_COLUMNS.userId] );

        };

        function keyboardDown( event ) {

            event.target.parentNode.parentNode.removeClass( 'keyboard-up' );

        };

        function keyboardUp( event ) {

            event.target.parentNode.parentNode.addClass( 'keyboard-up' );

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
                        : showMessage( STRINGS.error.loadAccount + ' ( error: ' + status + ', ' + error + ')' );

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

            _cache.load();

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
                        : showMessage( STRINGS.error.loadQuestion + ' ( error: ' + status + ', ' + error + ')' );

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

                    if ( error == 'Unauthorized' ) { showPage( 'login-page' ) };

                }

            } );

        };

        function loadTopUsers() {

            showLoading( 175, 144 );

            window.setTimeout( function () {

                var data = 'regionId=1',
                    resource = '/api/top/topUsers',
                    session = getSession( resource );

                ajax( resource, {

                    "type": "GET",
                    "headers": { "x-session": session },
                    "data": data,
                    "success": function ( data, status ) {

                        _cache.topUsers.refresh( data );
                        showTopUsers();
                        hideLoading();

                    },
                    "error": function ( response, status, error ) {

                        hideLoading();
                        error == 'Unauthorized'
                            ? showPage( 'login-page' )
                            : showMessage( STRINGS.error.loadTopUsers + ' ( error: ' + status + ', ' + error + ')' );

                    }

                } );

            }, 50 );

        };

        function loadUser( userId ) {

            clearUser();

            window.setTimeout( function () {

                var resource = '/api/users/' + userId,
                    session = getSession( resource );

                showLoading( 14, 14 );

                ajax( resource, {

                    "type": "POST",
                    "headers": { "x-session": session },
                    "success": function ( data, status ) {

                        var user = window.JSON.parse( data )[0];

                        if ( _account[ACCOUNT_COLUMNS.userId] == userId ) { //me

                            _account[ACCOUNT_COLUMNS.reputation] = user[USER_COLUMNS.reputation];

                        };

                        showUser( user );
                        window.setTimeout( function () {

                            resource = '/api/users/' + userId + '/picture';
                            $( '#user-picture' ).src = resource + '?x-session=' + getSession( resource );
                            hideLoading();

                        }, 50 );

                    },
                    "error": function ( response, status, error ) {

                        error == 'Unauthorized'
                            ? showPage( 'login-page' )
                            : showMessage( STRINGS.error.loadUser );

                    }

                } );

            }, 50 );

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
                    showUserQuestions();

                },
                "error": function ( response, status, error ) {

                    if ( error == 'Unauthorized' ) { showPage( 'login-page' ) };

                }

            } );

        };

        function localizeStrings() {

            $( '#answer-confirm-cancel' ).textContent = STRINGS.cancelButtonCaption;
            $( '#answer-confirm-ok' ).textContent = STRINGS.okButtonCaption;
            $( '#answer-text' ).setAttribute( 'placeholder', STRINGS.answerLabel );
            $( '#ask-text' ).setAttribute( 'placeholder', STRINGS.questionLabel );
            $( '#cancel-answer-button' ).setAttribute( 'placeholder', STRINGS.addAnswer.cancel );
            $( '#edit-account' ).innerHTML = STRINGS.editAccountCaption;
            $( '#edit-username' ).setAttribute( 'placeholder', STRINGS.edit.usernameCaption );
            $( '#edit-tagline' ).setAttribute( 'placeholder', STRINGS.edit.taglineCaption );
            $( '#fb-login' ).innerHTML = STRINGS.facebook.authenticatingCaption;
            $( '#location-note' ).setAttribute( 'placeholder', STRINGS.optionalNote );
            $( '#login-username' ).setAttribute( 'placeholder', STRINGS.usernameLabel );
            $( '#login-password' ).setAttribute( 'placeholder', STRINGS.passwordLabel );
            $( '#no-questions' ).innerHTML = STRINGS.noQuestions;
            $( '#message-ok-button' ).innerHTML = STRINGS.okButtonCaption;
            $( '#message-cancel-button' ).innerHTML = STRINGS.cancelButtonCaption;
            $( '#question-share-facebook' ).textContent = STRINGS.facebook.postQuestionToFacebook;
            $( '#question-share-twitter' ).textContent = STRINGS.facebook.postQuestionToTwitter;
            $( '#reputation-caption' ).textContent = STRINGS.reputation;
            $( '#top-interval-day' ).textContent = STRINGS.intervalDayCaption;
            $( '#top-interval-week' ).textContent = STRINGS.intervalWeekCaption;
            $( '#top-interval-month' ).textContent = STRINGS.intervalMonthCaption;
            $( '#top-interval-year' ).textContent = STRINGS.intervalYearCaption;
            $( '#top-interval-all' ).textContent = STRINGS.intervalAllCaption;
            $( '#top-type-reputation' ).textContent = STRINGS.topTypeReputationCaption;
            $( '#top-type-questions' ).textContent = STRINGS.topTypeQuestionsCaption;
            $( '#top-type-answers' ).textContent = STRINGS.topTypeAnswersCaption;
            $( '#top-type-badges' ).textContent = STRINGS.topTypeBadgesCaption;
            $( '#total-answers-caption' ).textContent = STRINGS.totalAnswers;
            $( '#total-questions-caption' ).textContent = STRINGS.totalQuestions;
            $( '#total-badges-caption' ).textContent = STRINGS.totalBadges;
            $( '#user-id-caption' ).textContent = STRINGS.userIdCaption;

        };

        function locationsClick( event ) {

            selectItem( event );

            window.setTimeout( function () {

                var location = event.target.closestByClassName( 'location-item' );

                if ( location && !location.hasClass( 'existing-answer' ) ) {

                    showAnswerConfirm( location, _selectedQuestion )

                };

                window.setTimeout( function () { unselectItem( event ); }, 100 );

            }, 100 );

        };

        function login( event ) {

            event.preventDefault();

            var resource = '/logins/login',
                username = document.getElementById( 'login-username' ).value,
                password = document.getElementById( 'login-password' ).value,
                authorization = window.Crypto.util.bytesToBase64( window.Crypto.charenc.UTF8.stringToBytes( username + ':' + password ) );

            deleteFacebookFrame();
            document.getElementById( 'login-error' ).innerHTML = '';
            document.getElementById( 'login-password' ).value = '';
            document.getElementById( 'login-button' ).focus();

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

                            loadAccount();
                            loadUserQuestions();
                            loadQuestions();
                            setupGeolocation();
                            refreshQuestions();
                            refreshUserQuestions();

                            showRefreshButton();
                            showPage( 'questions-page' );

                        };

                    },
                    "error": function ( response, status, error ) {

                        document.getElementById( 'login-error' ).innerHTML = error;

                    }

                } );

            };

        };

        function initializeFacebook() {

            showLoading( 41, 235 );

            var login = document.getElementById( 'fb-login' );
            login.innerHTML = STRINGS.facebook.authenticatingCaption;
            login.removeAttribute( 'data-facebook-id' );
            login.removeAttribute( 'data-username' );
            login.removeAttribute( 'data-password' );
            login.removeAttribute( 'data-location' );
            login.removeAttribute( 'data-email' );
            login.disabled = true;
            login.addClass( 'fb-login-disabled' );

            createFacebookFrame( function () {

                var frame = document.getElementById( 'fb-frame' ).contentWindow;
                frame.postMessage( '{"type": "authorize"}', FACEBOOK_AUTH_URL );

            } );

            window.setTimeout( function () {

                var frame = document.getElementById( 'fb-frame' );

                if ( frame && !login.disabled ) {

                    resetFacebookFrame();

                };

            }, 6000 );

        };

        function loginFacebook( event ) {

            event.preventDefault();

            var login = document.getElementById( 'fb-login' );

            if ( login.getDataset( 'facebook-id' ) ) {

                loadSessionFacebook( 
                    login.getDataset( 'facebook-id' ),
                    login.getDataset( 'username' ),
                    login.getDataset( 'password' ),
                    login.getDataset( 'location' ),
                    login.getDataset( 'email' )
                );

            } else {

                window.localStorage.setItem( 'facebook-login', true );
                window.location.href = FACEBOOK_LOGIN_URL + '?button=login';

            };

        };

        function authorizeFacebook( event ) {

            if ( event.origin == "http://urbanask.com" ) {

                var message = window.JSON.parse( event.data ),
                    login = document.getElementById( 'fb-login' );

                switch ( message.type ) {
                    case 'authorized':

                        if ( window.localStorage.getItem( 'facebook-login' ) ) {

                            window.localStorage.removeItem( 'facebook-login' );
                            loadSessionFacebook( 
                                message.facebookId,
                                message.username,
                                message.password,
                                message.location,
                                message.email );

                        } else {

                            hideLoading();

                            login.innerHTML = STRINGS.facebook.loginCaption;
                            login.setDataset( 'facebook-id', message.facebookId );
                            login.setDataset( 'username', message.username );
                            login.setDataset( 'password', message.password );
                            login.setDataset( 'location', message.location );
                            login.setDataset( 'email', message.email );

                            login.disabled = false;
                            login.removeClass( 'fb-login-disabled' );

                        };

                        break;

                    case 'unauthorized':

                        hideLoading();

                        login.innerHTML = STRINGS.facebook.linkCaption;
                        login.disabled = false;
                        login.removeClass( 'fb-login-disabled' );

                        break;

                    case 'notReady':

                        window.setTimeout( function () {

                            var frame = document.getElementById( 'fb-frame' ).contentWindow;
                            frame.postMessage( '{"type":"' + message.retry + '"}', FACEBOOK_AUTH_URL );

                        }, 200 );

                        break;

                };

            };

        };

        function deleteFacebookFrame() {

            var frame = document.getElementById( 'fb-frame' );
            if ( frame ) frame.parentNode.removeChild( frame );

        };

        function createFacebookFrame( complete ) {

            var html = '<iframe id="fb-frame" class="hide" src="' + FACEBOOK_LOGIN_URL + '"></iframe>'
            document.getElementById( 'login-page' ).insertAdjacentHTML( 'beforeEnd', html );

            document.getElementById( 'fb-frame' ).addEventListener( 'load', function () {

                complete();

            }, false );

        };

        function resetFacebookFrame() {

            var frame = document.getElementById( 'fb-frame' );
            if ( frame ) frame.src = FACEBOOK_LOGIN_URL;

        };

        function loadSessionFacebook( facebookId, username, password, location, email ) {

            var resource = '/logins/loginFB',
                data = 'regionId=1' //sacramento
                    + '&location=' + location
                    + '&email=' + email,
                authorization = window.Crypto.util.bytesToBase64( 
                    window.Crypto.charenc.UTF8.stringToBytes( facebookId + ':' + username + ':' + password ) );

            deleteFacebookFrame();

            ajax( resource, {

                "type": "GET",
                "headers": { "x-authorization": authorization },
                "data": data,
                "complete": function ( response, status ) {

                    if ( status != "error" ) {

                        var session = response.getResponseHeader( 'x-session' ).split( ':' );

                        _session.id = session[0];
                        _session.key = session[1];
                        window.localStorage.setItem( 'sessionId', _session.id );
                        window.localStorage.setItem( 'sessionKey', _session.key );

                        loadAccount();
                        loadUserQuestions();
                        loadQuestions();
                        setupGeolocation();
                        refreshQuestions();
                        refreshUserQuestions();

                        showRefreshButton();
                        showPage( 'questions-page' );

                    };

                },
                "error": function ( response, status, error ) {

                    document.getElementById( 'login-error' ).innerHTML = error;

                }

            } );

        };

        function logout( event ) {

            event.preventDefault();

            window.localStorage.removeItem( 'account' );
            window.localStorage.removeItem( 'questions' );
            window.localStorage.removeItem( 'userQuestions' );
            window.localStorage.removeItem( 'sessionKey' );
            window.localStorage.removeItem( 'sessionId' );
            _account.length = 0;
            _selectedQuestion.length = 0;
            _questions.length = 0;
            _userQuestions.length = 0;
            _session.id = '';
            _session.key = '';

            showPage( 'login-page' );

        };

        function onTouchMove( event ) {

            var scroll = event.target.closestByClassName( 'scroll' );

            if ( scroll ) {

                var top = scroll.positionTop - scroll.parentNode.positionTop,
                    heightDifference = ( 0 - scroll.offsetHeight + scroll.parentNode.offsetHeight );

                if ( scroll.offsetHeight < scroll.parentNode.offsetHeight ) {

                    event.preventDefault();

                };

                //                if ( ( top >= 0 ) && ( event.touches[0].screenY > _swipeY ) ) { //at top, swiping down

                //                    event.preventDefault();
                //                    debug( 't top:' + top + ' diff:' + heightDifference );

                //                } else if ( ( top <= heightDifference ) && ( event.touches[0].screenY < _swipeY ) ) { //at bottom, swiping up

                //                    event.preventDefault();
                //                    debug( 'b top:' + top + ' diff:' + heightDifference );

                //                };

            } else {

                event.preventDefault();

            };

        };

        function onTouchStart( event ) {

            _swipeY = event.touches[0].screenY;

        };

        function Page( name, options ) {

            this.name = name;
            this.options = options;

        };

        function postToWall( event ) {

            event.preventDefault();
            window.location.href = FACEBOOK_LOGIN_URL + '?button=post';

        };

        function questionClick( event ) {

            selectItem( event );

            window.setTimeout( function () {

                var question = event.target.closestByClassName( 'question-item' );

                if ( question ) {

                    switch ( question.closestByTagName( 'ul' ).id ) {

                        case 'questions':
                        case 'user-questions':

                            showPage( 'question-page', {

                                questionId: question.getDataset( 'id' ),
                                backCaption: STRINGS.backButtonQuestions,
                                backPage: 'questions-page'

                            } );

                            break;

                        case 'users-questions':

                            showPage( 'question-page', {

                                questionId: question.getDataset( 'id' ),
                                backCaption: STRINGS.backButtonUser,
                                backPage: 'user-page'

                            } );

                            break;

                    };

                };

                window.setTimeout( function () { unselectItem( event ); }, 100 );

            }, 100 );

        };

        function questionItemClick( event ) {

            var question = event.target.closestByClassName( 'question-item' );

            if ( question ) {

                var flag = question.getElementsByClassName( 'flag-question' ),
                    vote = question.getElementsByClassName( 'vote-up-question' );

                if ( vote.length && !vote[0].hasClass( 'hide' ) ) {

                    saveQuestionUpvote( _selectedQuestion );

                } else if ( flag.length && !flag[0].hasClass( 'hide' ) ) {

                    saveQuestionFlag( _selectedQuestion );

                } else {

                    showPage( 'question-map-page' );

                };

            } else if ( event.target.id == 'question-map' ) {

                showPage( 'question-map-page' );

            };

        };

        function refresh() {

            _selectedQuestion.length = 0;
            _questions.length = 0;
            _userQuestions.length = 0;

            loadUserQuestions();
            loadQuestions();

            showPage( 'questions-page' );

        }

        function refreshQuestions() {

            var timer = window.setInterval( function () {

                _questions.length = 0;
                loadQuestions();

            }, REFRESH_QUESTION_RATE );

        };

        function refreshUserQuestions() {

            if ( !_userQuestionTimer ) {

                _userQuestionTimer = window.setInterval( function () {

                    if ( _userQuestions.length ) {

                        _userQuestions.length = 0;
                        loadUserQuestions();

                    } else {

                        window.clearInterval( _userQuestionTimer );
                        _userQuestionTimer = undefined;

                    };

                }, REFRESH_USER_QUESTION_RATE );

            };

        };

        function removeEventListeners( page ) {

            var backButton, questions;

            switch ( page ) {

                case 'account-page':

                    var save = document.getElementById( 'save-edit' ),
                        postButton = document.getElementById( 'post' ),
                        inviteButton = document.getElementById( 'invite' ),
                        logoutButton = document.getElementById( 'logout' );

                    save.removeEventListener( 'click', saveAccount, false );
                    inviteButton.removeEventListener( 'click', inviteFriends, false );
                    postButton.removeEventListener( 'click', postToWall, false );
                    logoutButton.removeEventListener( 'click', logout, false );

                    window.removeEventListener( 'message', authorizeFacebook, false );

                    if ( hasTouch() ) {

                        save.removeEventListener( 'touchstart', selectButton, false );
                        save.removeEventListener( 'touchend', unselectButton, false );

                        inviteButton.removeEventListener( 'touchstart', selectButton, false );
                        inviteButton.removeEventListener( 'touchend', unselectButton, false );

                        postButton.removeEventListener( 'touchstart', selectButton, false );
                        postButton.removeEventListener( 'touchend', unselectButton, false );

                        logoutButton.removeEventListener( 'touchstart', selectButton, false );
                        logoutButton.removeEventListener( 'touchend', unselectButton, false );

                    } else {

                        save.removeEventListener( 'mousedown', selectButton, false );
                        save.removeEventListener( 'mouseup', unselectButton, false );

                        inviteButton.removeEventListener( 'mousedown', selectButton, false );
                        inviteButton.removeEventListener( 'mouseup', unselectButton, false );

                        postButton.removeEventListener( 'mousedown', selectButton, false );
                        postButton.removeEventListener( 'mouseup', unselectButton, false );

                        logoutButton.removeEventListener( 'mousedown', selectButton, false );
                        logoutButton.removeEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

                case 'add-answer-page':

                    var location = document.getElementById( 'locations' );
                    location.removeEventListener( 'click', locationsClick, false );

                    document.getElementById( 'cancel-answer-button' ).removeEventListener( 'click', hideAddAnswer, false );

                    var answerText = document.getElementById( 'answer-text' );
                    answerText.removeEventListener( 'keyup', autocompleteLocations, false );
                    //answerText.removeEventListener( 'focus', keyboardUp, false );
                    //answerText.removeEventListener( 'blur', keyboardDown, false );

                    document.getElementById( 'answer' ).removeEventListener( 'submit', answerSubmit, false );

                    if ( !hasTouch() ) {

                        location.removeEventListener( 'mouseover', hoverItem, false );
                        location.removeEventListener( 'mouseout', unhoverItem, false );

                    };

                    break;

                case 'answer-page':

                    document.getElementById( 'travel-mode-toolbar' ).removeEventListener( 'click', travelModeClick, false );

                    backButton = document.getElementById( 'back-button' );
                    backButton.removeEventListener( 'click', goBack, false );

                    if ( hasTouch() ) {

                        backButton.removeEventListener( 'touchstart', selectButton, false );
                        backButton.removeEventListener( 'touchend', unselectButton, false );

                    } else {

                        backButton.removeEventListener( 'mousedown', selectButton, false );
                        backButton.removeEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

                case 'login-page':

                    var loginButton = document.getElementById( 'login-button' );
                    document.getElementById( 'login-page' ).removeEventListener( 'submit', login, false );

                    var facebookButton = document.getElementById( 'fb-login' );
                    facebookButton.removeEventListener( 'click', loginFacebook, false );

                    window.removeEventListener( 'message', authorizeFacebook, false );

                    if ( hasTouch() ) {

                        loginButton.removeEventListener( 'touchstart', selectButton, false );
                        loginButton.removeEventListener( 'touchend', unselectButton, false );

                        facebookButton.removeEventListener( 'touchstart', selectButton, false );
                        facebookButton.removeEventListener( 'touchend', unselectButton, false );

                    } else {

                        loginButton.removeEventListener( 'mousedown', selectButton, false );
                        loginButton.removeEventListener( 'mouseup', unselectButton, false );

                        //                        facebookButton.removeEventListener( 'mousedown', selectButton, false );
                        //                        facebookButton.removeEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

                case 'question-page':

                    backButton = document.getElementById( 'back-button' );
                    backButton.removeEventListener( 'click', goBack, false );

                    var answers = document.getElementById( 'answers' );
                    answers.removeEventListener( 'click', answerClick, false );

                    var questionView = document.getElementById( 'question-view' );
                    questionView.removeEventListener( 'click', questionItemClick, false );

                    document.getElementById( 'question-map' ).removeEventListener( 'click', questionItemClick, false );

                    if ( hasTouch() ) {

                        questionView.removeEventListener( 'touchstart', selectItem, false );
                        questionView.removeEventListener( 'touchend', unselectItem, false );

                        backButton.removeEventListener( 'touchstart', selectButton, false );
                        backButton.removeEventListener( 'touchend', unselectButton, false );

                    } else {

                        answers.removeEventListener( 'mouseover', hoverItem, false );
                        answers.removeEventListener( 'mouseout', unhoverItem, false );

                        questionView.removeEventListener( 'mousedown', selectItem, false );
                        questionView.removeEventListener( 'mouseup', unselectItem, false );
                        questionView.removeEventListener( 'mouseover', hoverItem, false );
                        questionView.removeEventListener( 'mouseout', unhoverItem, false );

                        backButton.removeEventListener( 'mousedown', selectButton, false );
                        backButton.removeEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

                case 'question-map-page':

                    backButton = document.getElementById( 'back-button' );
                    backButton.removeEventListener( 'click', goBack, false );

                    if ( hasTouch() ) {

                        backButton.removeEventListener( 'touchstart', selectButton, false );
                        backButton.removeEventListener( 'touchend', unselectButton, false );

                    } else {

                        backButton.removeEventListener( 'mousedown', selectButton, false );
                        backButton.removeEventListener( 'mouseup', unselectButton, false );

                    };

                case 'questions-page':

                    questions = document.getElementById( 'questions' );
                    questions.removeEventListener( 'click', questionClick, false );

                    var userQuestions = document.getElementById( 'user-questions' );
                    userQuestions.removeEventListener( 'click', questionClick, false );

                    var askText = document.getElementById( 'ask-text' );
                    askText.removeEventListener( 'focus', showAskButton, false );
                    askText.removeEventListener( 'blur', hideAskButton, false );

                    var ask = document.getElementById( 'ask' );
                    ask.removeEventListener( 'submit', saveQuestion, false );


                    if ( hasTouch() ) {

                        //ask.removeEventListener( 'touchstart', selectAskText, false );

                    } else {

                        questions.removeEventListener( 'mouseover', hoverItem, false );
                        questions.removeEventListener( 'mouseout', unhoverItem, false );

                        userQuestions.removeEventListener( 'mouseover', hoverItem, false );
                        userQuestions.removeEventListener( 'mouseout', unhoverItem, false );

                        //ask.removeEventListener( 'mousedown', selectAskText, false );

                    };

                    break;

                case 'top-page':

                    var topUsers = document.getElementById( 'top-users' );
                    topUsers.removeEventListener( 'click', userClick, false );

                    var topType = document.getElementById( 'top-type' ),
                        topInterval = document.getElementById( 'top-interval' );

                    if ( hasTouch() ) {

                        topType.removeEventListener( 'touchstart', topTypeClick, false );
                        topInterval.removeEventListener( 'touchstart', topIntervalClick, false );

                    } else {

                        topUsers.removeEventListener( 'mouseover', hoverItem, false );
                        topUsers.removeEventListener( 'mouseout', unhoverItem, false );

                        topType.removeEventListener( 'mousedown', topTypeClick, false );
                        topInterval.removeEventListener( 'mousedown', topIntervalClick, false );

                    };

                    break;

                case 'user-page':

                    var reputationItems = document.getElementById( 'user-reputations' );
                    reputationItems.removeEventListener( 'click', reputationItemClick, false );

                    questions = document.getElementById( 'users-questions' );
                    questions.removeEventListener( 'click', questionClick, false );

                    var answers = document.getElementById( 'user-answers' );
                    answers.removeEventListener( 'click', userAnswerClick, false );

                    var badges = document.getElementById( 'user-badges' );
                    badges.removeEventListener( 'click', badgeClick, false );

                    var totalReputation = document.getElementById( 'reputation' );
                    totalReputation.removeEventListener( 'click', totalReputationClick, false );

                    var totalQuestions = document.getElementById( 'total-questions' );
                    totalQuestions.removeEventListener( 'click', totalQuestionsClick, false );

                    var totalAnswers = document.getElementById( 'total-answers' );
                    totalAnswers.removeEventListener( 'click', totalAnswersClick, false );

                    var totalBadges = document.getElementById( 'total-badges' );
                    totalBadges.removeEventListener( 'click', totalBadgesClick, false );

                    backButton = document.getElementById( 'back-button' );
                    backButton.removeEventListener( 'click', goBack, false );

                    document.getElementById( 'edit-account' ).removeEventListener( 'click', accountClick, false );
                    document.getElementById( 'user-picture' ).removeEventListener( 'click', accountClick, false );

                    if ( hasTouch() ) {

                        totalReputation.removeEventListener( 'touchstart', selectElement, false );
                        totalReputation.removeEventListener( 'touchend', unselectElement, false );

                        totalQuestions.removeEventListener( 'touchstart', selectElement, false );
                        totalQuestions.removeEventListener( 'touchend', unselectElement, false );

                        totalAnswers.removeEventListener( 'touchstart', selectElement, false );
                        totalAnswers.removeEventListener( 'touchend', unselectElement, false );

                        totalBadges.removeEventListener( 'touchstart', selectElement, false );
                        totalBadges.removeEventListener( 'touchend', unselectElement, false );

                        backButton.removeEventListener( 'touchstart', selectButton, false );
                        backButton.removeEventListener( 'touchend', unselectButton, false );

                    } else {

                        totalReputation.removeEventListener( 'mousedown', selectElement, false );
                        totalReputation.removeEventListener( 'mouseup', unselectElement, false );
                        totalReputation.removeEventListener( 'mouseover', hoverElement, false );
                        totalReputation.removeEventListener( 'mouseout', unhoverElement, false );

                        totalQuestions.removeEventListener( 'mousedown', selectElement, false );
                        totalQuestions.removeEventListener( 'mouseup', unselectElement, false );
                        totalQuestions.removeEventListener( 'mouseover', hoverElement, false );
                        totalQuestions.removeEventListener( 'mouseout', unhoverElement, false );

                        totalAnswers.removeEventListener( 'mousedown', selectElement, false );
                        totalAnswers.removeEventListener( 'mouseup', unselectElement, false );
                        totalAnswers.removeEventListener( 'mouseover', hoverElement, false );
                        totalAnswers.removeEventListener( 'mouseout', unhoverElement, false );

                        totalBadges.removeEventListener( 'mousedown', selectElement, false );
                        totalBadges.removeEventListener( 'mouseup', unselectElement, false );
                        totalBadges.removeEventListener( 'mouseover', hoverElement, false );
                        totalBadges.removeEventListener( 'mouseout', unhoverElement, false );

                        reputationItems.removeEventListener( 'mouseover', hoverItem, false );
                        reputationItems.removeEventListener( 'mouseout', unhoverItem, false );

                        questions.removeEventListener( 'mouseover', hoverItem, false );
                        questions.removeEventListener( 'mouseout', unhoverItem, false );

                        backButton.removeEventListener( 'mousedown', selectButton, false );
                        backButton.removeEventListener( 'mouseup', unselectButton, false );

                    };

                    break;

            };

        };

        function reputationItemClick( event ) {

            selectItem( event );

            window.setTimeout( function () {

                var reputationItem = event.target.closestByClassName( 'reputation-item' );

                if ( reputationItem ) {

                    showPage( 'question-page', {

                        questionId: reputationItem.getDataset( 'id' ),
                        backCaption: STRINGS.backButtonUser,
                        backPage: 'user-page'

                    } );

                };

                window.setTimeout( function () { unselectItem( event ); }, 100 );

            }, 100 );

        };

        function saveAccount( event ) {

            event.preventDefault();

            var resource = '/api/account/save',
                username = document.getElementById( 'edit-username' ).value,
                tagline = document.getElementById( 'edit-tagline' ).value,
                data = 'username=' + username + '&tagline=' + tagline,
                session = getSession( resource );

            ajax( resource, {

                "type": "GET",
                "data": data,
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    showPage( 'user-page', { userId: _account[ACCOUNT_COLUMNS.userId] } );

                },
                "error": function ( response, status, error ) {


                }

            } );

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
            hideAddAnswer();
            scrollUp();

            ajax( resource, {

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

                    var questionItem = _questions.item( question.questionId );
                    if ( questionItem ) questionItem[QUESTION_COLUMNS.answerCount] += 1;
                    question[QUESTION_COLUMNS.answers].push( answer );
                    question[QUESTION_COLUMNS.answerCount] += 1;

                    var html = getAnswerItem( answer, { letter: '&#x2022;', newItem: true } ),
                        markers = '&markers=color:gray|size:mid|' + location.latitude + "," + location.longitude,
                        questionMap = document.getElementById( 'question-map' ),
                        answers = document.getElementById( 'answers' ),
                        answerCount = document.getElementById( 'question-view' ).childByClassName( 'answer-count' );

                    //show answer
                    document.getElementById( 'answers-view' ).removeClass( 'hide' );
                    answers.insertAdjacentHTML( 'afterBegin', html );
                    window.setTimeout( function () { answers.firstChild.removeClass( 'height-zero' ) }, 500 );
                    questionMap.setAttribute( 'src', questionMap.getAttribute( 'src' ) + markers );

                    //show answer count
                    answerCount.addClass( 'fadeable' ).addClass( 'fade' );
                    window.setTimeout( function () {

                        answerCount.textContent = question[QUESTION_COLUMNS.answerCount];
                        answerCount.removeClass( 'fade' );
                        window.setTimeout( function () { answerCount.removeClass( 'fadeable' ); }, 1000 );

                    }, 750 );

                    showNotification( STRINGS.notificationAnswerQuestion, { footer: STRINGS.notification.answerSaved } );

                    showToolbar( 'question', { "questionId": question.questionId } );
                    if ( questionItem ) showQuestions();

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : showMessage( STRINGS.error.saveAnswer + ' ( error: ' + status + ', ' + error + ')' );

                }

            } );

        };

        function saveAnswerDownvote( question, answerItem ) {

            var resource = '/api/answers/' + answerItem.getDataset( 'id' ) + '/downvote',
                session = getSession( resource ),
                answer = question[QUESTION_COLUMNS.answers].item( answerItem.getDataset( 'id' ) );

            hideVoteDown();

            ajax( resource, {

                "type": "GET",
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    var location = answerItem.getElementsByClassName( 'location-name' )[0],
                        voteBoxes = location.getElementsByClassName( 'votes' ),
                        voted = answer[ANSWER_COLUMNS.voted],
                        vote = ( voted == -1 ? 0 : -1 ),
                        currentVotes = answer[ANSWER_COLUMNS.votes],
                        newVotes = currentVotes - voted + vote; //downvote

                    answer[ANSWER_COLUMNS.votes] = newVotes;
                    answer[ANSWER_COLUMNS.voted] = vote;

                    if ( newVotes == 0 ) { //remove vote box

                        if ( voteBoxes.length ) { location.removeChild( voteBoxes[0] ) };

                    } else if ( voteBoxes.length == 0 ) { //show vote box

                        location.firstChild.insertAdjacentHTML( 'afterEnd', getVotes( newVotes ) );

                    } else { //update vote box

                        voteBoxes[0].innerHTML = getVoteCount( newVotes );

                    };

                    if ( voted != -1 ) { //downvote

                        //show notification
                        var reputation = STRINGS.notification.minusReputation.replace( "%1", REPUTATION_ACTION.downvotedAnswer );
                        showNotification( STRINGS.notificationDownvote, { tight: true, footer: reputation } );

                    };

                    window.setTimeout( function () {

                        showQuestion();

                    }, 100 );

                },
                "error": function ( response, status, error ) {

                    switch ( error ) {

                        case 'Unauthorized':

                            showPage( 'login-page' );
                            break;

                        case 'Forbidden':
                        case 'Precondition Failed':

                            if ( isMyAnswer( answer ) ) {

                                showMessage( STRINGS.error.voteOnOwnAnswer );

                            } else if ( isMyQuestion( question ) ) {

                                showMessage( STRINGS.error.voteOnOwnQuestion );

                            };

                            break;

                        default:

                            showMessage( STRINGS.error.answerVote + ' ( error: ' + status + ', ' + error + ')' );

                    };

                }

            } );

        };

        function saveAnswerFlag( question, answerItem ) {

            var resource = '/api/answers/' + answerItem.getDataset( 'id' ) + '/flag',
                session = getSession( resource ),
                answer = question[QUESTION_COLUMNS.answers].item( answerItem.getDataset( 'id' ) );

            hideFlag();

            showMessage( STRINGS.flagAnswerConfirmation, function () {

                ajax( resource, {

                    "type": "GET",
                    "headers": { "x-session": session },
                    "success": function ( data, status ) {

                        showNotification( STRINGS.notification.flag, { tight: true } );

                    },
                    "error": function ( response, status, error ) {

                        switch ( error ) {

                            case 'Unauthorized':

                                showPage( 'login-page' );
                                break;

                            case 'Forbidden':
                            case 'Precondition Failed':

                                if ( isMyAnswer( answer ) ) {

                                    showMessage( STRINGS.error.flagOwnAnswer );

                                };

                                break;

                            default:

                                showMessage( STRINGS.error.saveFlag + ' ( error: ' + status + ', ' + error + ')' );

                        };

                    }

                } );

            } );

        };

        function saveAnswerUpvote( question, answerItem ) {

            var resource = '/api/answers/' + answerItem.getDataset( 'id' ) + '/upvote',
                session = getSession( resource ),
                answer = question[QUESTION_COLUMNS.answers].item( answerItem.getDataset( 'id' ) );

            hideVoteUp();

            ajax( resource, {

                "type": "GET",
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    var location = answerItem.getElementsByClassName( 'location-name' )[0],
                        voteBoxes = location.getElementsByClassName( 'votes' ),
                        voted = answer[ANSWER_COLUMNS.voted],
                        vote = ( voted == 1 ? 0 : 1 ),
                        currentVotes = answer[ANSWER_COLUMNS.votes],
                        newVotes = currentVotes - voted + vote; //upvote

                    answer[ANSWER_COLUMNS.votes] = newVotes;
                    answer[ANSWER_COLUMNS.voted] = vote;

                    if ( newVotes == 0 ) { //remove vote box

                        if ( voteBoxes.length ) { location.removeChild( voteBoxes[0] ) };

                    } else if ( voteBoxes.length == 0 ) { //show vote box

                        location.firstChild.insertAdjacentHTML( 'afterEnd', getVotes( newVotes ) );

                    } else { //update vote box

                        voteBoxes[0].innerHTML = getVoteCount( newVotes );

                    };

                    if ( voted != 1 ) { //upvote

                        showNotification( STRINGS.notificationUpvote, { tight: true } );

                    };

                    window.setTimeout( function () {

                        showQuestion();

                    }, 100 );

                },
                "error": function ( response, status, error ) {

                    switch ( error ) {

                        case 'Unauthorized':

                            showPage( 'login-page' );
                            break;

                        case 'Forbidden':
                        case 'Precondition Failed':

                            if ( isMyAnswer( answer ) ) {

                                showMessage( STRINGS.error.voteOnOwnAnswer );

                            } else if ( isMyQuestion( question ) ) {

                                showMessage( STRINGS.error.voteOnOwnQuestion );

                            };

                            break;

                        default:

                            showMessage( STRINGS.error.answerVote + ' ( error: ' + status + ', ' + error + ')' );

                    };

                }

            } );

        };

        function saveAnswerSelect( question, answerId ) {

            var resource = '/api/answers/' + answerId + '/select',
                data = 'questionId=' + question.questionId,
                session = getSession( resource );

            hideAnswersSelect();

            ajax( resource, {

                "type": "GET",
                "data": data,
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    var location = document.getElementById( 'answer-view' ).childByClassName( 'location-name' ),
                        answer = question[QUESTION_COLUMNS.answers].item( answerId ),
                        selected = window.Math.abs( answer[ANSWER_COLUMNS.selected] - 1 ),
                        questionItem = _userQuestions.item( question.questionId );

                    question.resolved = selected;
                    if ( questionItem ) questionItem[QUESTION_COLUMNS.resolved] = selected;

                    var previous = question[QUESTION_COLUMNS.answers].item( 1, [ANSWER_COLUMNS.selected] );
                    if ( previous ) previous[ANSWER_COLUMNS.selected] = 0; //false
                    answer[ANSWER_COLUMNS.selected] = selected;

                    if ( selected ) {

                        var reputation = STRINGS.notificationReputation.replace( "%1", REPUTATION_ACTION.resolvedQuestion );
                        showNotification( STRINGS.checkmark, { footer: reputation } );

                        if ( location ) {

                            location.lastChild.previousSibling.insertAdjacentHTML( 'afterEnd', getSelected( selected, true ) );
                            window.setTimeout( function () {

                                location.childByClassName( 'selected' ).removeClass( 'width-zero' );

                            }, 50 );

                        };

                    } else {

                        window.setTimeout( function () {

                            if ( location ) {

                                location.childByClassName( 'selected' ).addClass( 'width-zero' );
                                window.setTimeout( function () {

                                    location.removeChild( location.childByClassName( 'selected' ) );

                                }, 500 );

                            };

                        }, 50 );

                    };

                    window.setTimeout( function () {

                        showQuestion();
                        if ( questionItem ) showUserQuestions();

                    }, 100 );

                },
                "error": function ( response, status, error ) {

                    error == 'Unauthorized'
                        ? showPage( 'login-page' )
                        : showMessage( STRINGS.error.answerSelect + ' ( error: ' + status + ', ' + error + ')' );

                }

            } );

        };

        function saveQuestion( event ) {

            event.preventDefault();

            if ( document.getElementById( 'ask-text' ).value.trim() && _currentLocation.latitude ) {

                var questionText = document.getElementById( 'ask-text' ).value.trim(),
                    message = _currentLocation.latitude + "~" + _currentLocation.longitude + "~" + questionText,
                    resource = '/messaging/questions',
                    session = getSession( resource );

                document.getElementById( 'ask-button' ).focus();
                scrollUp();

                ajax( resource, {

                    "type": "POST",
                    "data": message,
                    "headers": { "x-session": session },
                    "cache": false,
                    "success": function ( data, status ) {

                        var html = '',
                            questions = document.getElementById( 'user-questions' ),
                            question = [];

                        question[QUESTION_COLUMNS.questionId] = 0;
                        question[QUESTION_COLUMNS.userId] = _account[ACCOUNT_COLUMNS.userId];
                        question[QUESTION_COLUMNS.username] = _account[ACCOUNT_COLUMNS.username];
                        question[QUESTION_COLUMNS.reputation] = formatNumber( getReputation() );
                        question[QUESTION_COLUMNS.question] = questionText;
                        question[QUESTION_COLUMNS.link] = '';
                        question[QUESTION_COLUMNS.latitude] = _currentLocation.latitude;
                        question[QUESTION_COLUMNS.longitude] = _currentLocation.longitude;
                        question[QUESTION_COLUMNS.timestamp] = new window.Date();
                        question[QUESTION_COLUMNS.resolved] = 0;
                        question[QUESTION_COLUMNS.expired] = 0;
                        question[QUESTION_COLUMNS.bounty] = 0;
                        question[QUESTION_COLUMNS.answerCount] = 0;
                        question[QUESTION_COLUMNS.answers] = [];

                        if ( _userQuestions.length == 0 ) {

                            html += getListItemHeader( _account[ACCOUNT_COLUMNS.username] );

                        };

                        html += getQuestionItem( question, { newItem: true } );
                        document.getElementById( 'ask-text' ).value = '';
                        hideAskButton();

                        if ( _userQuestions.length == 0 ) {

                            document.getElementById( 'no-questions' ).addClass( 'hide' );
                            questions.insertAdjacentHTML( 'afterBegin', html );

                        } else {

                            questions.firstChild.insertAdjacentHTML( 'afterEnd', html );

                        };

                        _userQuestions.unshift( question );
                        window.setTimeout( function () { questions.childNodes[1].removeClass( 'height-zero' ) }, 50 );

                        showNotification( STRINGS.notificationAskQuestion, { footer: STRINGS.notification.questionSaved } );

                        refreshUserQuestions();

                    },
                    "error": function ( response, status, error ) {

                        error == 'Unauthorized'
                            ? showPage( 'login-page' )
                            : showMessage( STRINGS.error.saveQuestion + ' ( error: ' + status + ', ' + error + ')' );

                    }

                } );

            };

        };

        function saveQuestionFlag( question ) {

            var resource = '/api/questions/' + question[QUESTION_COLUMNS.questionId] + '/flag',
                session = getSession( resource );

            hideFlag();

            showMessage( STRINGS.flagQuestionConfirmation, function () {

                ajax( resource, {

                    "type": "GET",
                    "headers": { "x-session": session },
                    "success": function ( data, status ) {

                        showNotification( STRINGS.notification.flag, { tight: true } );

                    },
                    "error": function ( response, status, error ) {

                        switch ( error ) {

                            case 'Unauthorized':

                                showPage( 'login-page' );
                                break;

                            case 'Forbidden':
                            case 'Precondition Failed':

                                if ( isMyQuestion( question ) ) {

                                    showMessage( STRINGS.error.flagOwnQuestion );

                                };

                                break;

                            default:

                                showMessage( STRINGS.error.saveFlag + ' ( error: ' + status + ', ' + error + ')' );

                        };

                    }

                } );

            } );

        };

        function saveQuestionUpvote( question ) {

            var resource = '/api/questions/' + question[QUESTION_COLUMNS.questionId] + '/upvote',
                session = getSession( resource );

            hideVoteUp();

            ajax( resource, {

                "type": "GET",
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    var body = document.getElementById( 'question-view' ).childByClassName( 'question-item-body' ),
                        voted = question[QUESTION_COLUMNS.voted],
                        currentVotes = question[QUESTION_COLUMNS.votes],
                        vote = voted ? -1 : 1,
                        newVotes = currentVotes + vote < 0 ? 0 : currentVotes + vote,
                        reputation = '';

                    question[QUESTION_COLUMNS.votes] = newVotes;
                    question[QUESTION_COLUMNS.voted] = !voted;

                    if ( currentVotes == 0 && vote == 1 ) { //add vote box

                        showNotification( STRINGS.notificationUpvote, { tight: true } );

                        body.insertAdjacentHTML( 'afterBegin', getVotes( newVotes ) );

                    } else if ( currentVotes == 1 && vote == -1 ) { //remove vote box

                        body.removeChild( body.childByClassName( 'votes' ) );

                    } else if ( currentVotes == 0 && vote == -1 ) { //should never happen, bad data

                        // do nothing

                    } else { //update vote box

                        showNotification( STRINGS.notificationUpvote, { tight: true } );

                        body.childByClassName( 'votes' ).innerHTML = getVoteCount( newVotes );

                    };

                    window.setTimeout( function () {

                        showQuestion();

                    }, 100 );

                },
                "error": function ( response, status, error ) {

                    switch ( error ) {

                        case 'Unauthorized':

                            showPage( 'login-page' );
                            break;

                        case 'Forbidden':
                        case 'Precondition Failed':

                            if ( isMyQuestion( question ) ) {

                                showMessage( STRINGS.error.voteOnOwnQuestion, STRINGS.okButtonCaption );

                            };

                            break;

                        default:

                            showMessage( STRINGS.error.saveQuestionUpvote + ' ( error: ' + status + ', ' + error + ')' );

                    };

                }

            } );

        };

        function scrollUp() {

            switch ( document.getElementById( 'viewport' ).getDataset( 'page' ) ) {
                case 'questions-page':

                    document.getElementById( 'questions-view' ).scrollTop = 0;
                    break;

                case 'question-page':

                    document.getElementById( 'answers-view' ).scrollTop = 0;
                    break;

                case 'user-page':

                    document.getElementById( 'user-page' ).scrollTop = 0;
                    break;

            };

        };

        function selectAskText( event ) {

            event.preventDefault();
            document.getElementById( 'ask-text' ).focus();

        };

        function selectButton( event ) {

            this.addClass( 'button-selected' );

            if ( this.id == 'back-button' ) {

                document.getElementById( 'back-button-gradient' ).addClass( 'button-selected' );

            };

        };

        function selectItem( event ) {

            var item = event.target.closestByClassName( 'list-item' );

            if ( item ) {

                item.addClass( 'select' )

            };

        };

        function selectElement( event ) {

            var item = event.target.closestByClassName( 'selectable' );
            if ( item ) item.addClass( 'select' );

        };

        function selectToolbarItem( event ) {

            var item = event.target.closestByClassName( 'toolbar-item' );
            if ( item ) item.addClass( 'toolbar-item-selected' );

        };

        function setupGeolocation() {

            window.setTimeout( setGeolocation, 3000 );
            window.setInterval( setGeolocation, 120000 ); //every 2 minutes

        }

        function setGeolocation() {

            if ( _session.id ) { //logged in

                var geo = window.navigator.geolocation.watchPosition( function ( position ) {

                    _currentLocation.latitude = position.coords.latitude;
                    _currentLocation.longitude = position.coords.longitude;
                    _currentLocation.accuracy = position.coords.accuracy;

                },
                function () {

                    showMessage( STRINGS.error.geoLocation );

                },
                { maximumAge: 60000, enableHighAccuracy: true } ); //must be valid within a minute

                window.setTimeout( function () { window.navigator.geolocation.clearWatch( geo ) }, 5000 );

            };

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

            _selectedQuestion.answered = function ( userId ) {

                for ( var index = 0; index < this[QUESTION_COLUMNS.answers].length; index++ ) {

                    if ( userId == this[QUESTION_COLUMNS.answers][index][ANSWER_COLUMNS.userId] ) return true;

                };

            };

        };

        function setTravelMode( travelItem ) {

            var travelItems = document.getElementsByClassName( 'travel-mode-item' );

            for ( var index = 0; index < travelItems.length; index++ ) {

                travelItems[index].removeClass( 'travel-mode-selected' );

            };

            travelItem.addClass( 'travel-mode-selected' );

            var answerItem = document.getElementById( 'answer-view' ).getElementsByClassName( 'answer-item' )[0],
                answer = _selectedQuestion[QUESTION_COLUMNS.answers].item( answerItem.getDataset( 'id' ) );
            showAnswerMap( answer, travelItem.getDataset( 'travel-mode' ) );

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

        function showAccountPage() {

            document.getElementById( 'edit-username' ).value = _account[ACCOUNT_COLUMNS.username];
            document.getElementById( 'edit-tagline' ).value = _account[ACCOUNT_COLUMNS.tagline];

        };

        function showAddAnswer( question ) {

            _places = new google.maps.places.PlacesService( document.createElement( 'div' ) );
            _places.searchRequest = {

                location: new google.maps.LatLng( question.latitude, question.longitude ),
                radius: LOCATION_RADIUS,
                types: ['establishment']

            };

            addEventListeners( 'add-answer-page' );
            document.getElementById( 'answer-text' ).value = '';

            autocompleteLocations();

            var addAnswer = document.getElementById( 'add-answer-page' );
            addAnswer.removeClass( 'hide' );
            window.setTimeout( function () { addAnswer.removeClass( 'top-slide' ); }, 50 );

            if ( !hasTouch() ) {

                document.getElementById( 'answer-text' ).focus();

            };

        };

        function showAnswer( question, answerId, letter ) {

            var answer = question[QUESTION_COLUMNS.answers].item( answerId ),
                map = document.getElementById( 'answer-map' ),
                mapCanvas = document.getElementById( 'answer-map-canvas' ),
                directions = document.getElementById( 'directions-page' );

            //            staticMap = document.getElementById( 'answer-map' );
            //            src = 'http://maps.google.com/maps/api/staticmap?center='
            //                    + _selectedQuestion.latitude + ',' + _selectedQuestion.longitude
            //                    + '&size=320x319&maptype=roadmap&sensor=true&style=hue:blue&zoom=12&markers=color:gray|label:' + letter + '|'
            //                    + answer[ANSWER_COLUMNS.latitude] + ',' + answer[ANSWER_COLUMNS.longitude]
            //                    + '&markers=color:black|label:|'
            //                    + _selectedQuestion.latitude + ',' + _selectedQuestion.longitude;
            //            //staticMap.setAttribute( 'src', src );

            document.getElementById( 'answer-page' ).setDataset( 'id', answerId );
            document.getElementById( 'answer-view' ).innerHTML = getAnswerItem( answer, { letter: letter } );

            if ( answer[ANSWER_COLUMNS.note] && ( answer[ANSWER_COLUMNS.phone] || answer[ANSWER_COLUMNS.link] ) ) {

                map.removeClass( 'answer-map-medium' ).removeClass( 'answer-map-tall' ).addClass( 'answer-map-short' );
                mapCanvas.removeClass( 'answer-map-canvas-medium' ).removeClass( 'answer-map-canvas-tall' ).addClass( 'answer-map-canvas-short' );
                directions.removeClass( 'directions-page-medium' ).removeClass( 'directions-page-tall' ).addClass( 'directions-page-short' );

            } else if ( answer[ANSWER_COLUMNS.note] || answer[ANSWER_COLUMNS.phone] || answer[ANSWER_COLUMNS.link] ) {

                map.removeClass( 'answer-map-short' ).removeClass( 'answer-map-tall' ).addClass( 'answer-map-medium' );
                mapCanvas.removeClass( 'answer-map-canvas-short' ).removeClass( 'answer-map-canvas-tall' ).addClass( 'answer-map-canvas-medium' );
                directions.removeClass( 'directions-page-short' ).removeClass( 'directions-page-tall' ).addClass( 'directions-page-medium' );

            } else {

                map.removeClass( 'answer-map-short' ).removeClass( 'answer-map-medium' ).addClass( 'answer-map-tall' );
                mapCanvas.removeClass( 'answer-map-canvas-short' ).removeClass( 'answer-map-canvas-medium' ).addClass( 'answer-map-canvas-tall' );
                directions.removeClass( 'directions-page-short' ).removeClass( 'directions-page-medium' ).addClass( 'directions-page-tall' );

            };

            setTravelMode( document.getElementById( 'travel-mode-drive' ) );

        };

        function showAnswerMap( answer, travelMode ) {

            var mapCanvas = document.getElementById( 'answer-map-canvas' ),
                currentLocation = new google.maps.LatLng( _currentLocation.latitude, _currentLocation.longitude ),
                answerLocation = new google.maps.LatLng( answer[ANSWER_COLUMNS.latitude], answer[ANSWER_COLUMNS.longitude] ),
                options = {

                    zoom: 13,
                    center: currentLocation,
                    mapTypeId: google.maps.MapTypeId.ROADMAP,
                    mapTypeControl: false,
                    styles: [{

                        featureType: "all",
                        stylers: [{ hue: "#44ADFC"}]

                    }]

                },
                bounds = new google.maps.LatLngBounds(),
                map = new google.maps.Map( mapCanvas, options );

            mapCanvas.removeClass( 'fadeable' ).addClass( 'fade' ).addClass( 'fadeable' );
            bounds.extend( currentLocation );
            bounds.extend( answerLocation );
            map.fitBounds( bounds );
            window.setTimeout( function () { mapCanvas.removeClass( 'fade' ); }, 100 );

            google.maps.event.addListenerOnce( map, 'tilesloaded', function () {

                var directionItems = document.getElementById( 'directions' ),
                    directionOptions = {

                        origin: currentLocation,
                        destination: answerLocation,
                        travelMode: travelMode,
                        unitSystem: google.maps.UnitSystem.IMPERIAL

                    },
                    directions = new google.maps.DirectionsService();

                directionItems.innerHTML = '';

                directions.route( directionOptions, function ( result, status ) {

                    if ( status == google.maps.DirectionsStatus.OK ) {

                        var directionsDisplayOptions = { polylineOptions: { strokeColor: "black", strokeOpacity: ".5"} },
                            directionsDisplay = new google.maps.DirectionsRenderer( directionsDisplayOptions );

                        directionsDisplay.setMap( null );
                        directionsDisplay.setMap( map );
                        directionsDisplay.setDirections( result );

                        for ( var index = 0; index < result.routes[0].legs[0].steps.length; index++ ) {

                            var step = '<li class="direction-item">'
                                    + '<b>' + ( index + 1 ) + '.</b> '
                                    + result.routes[0].legs[0].steps[index].instructions
                                    + '</li>';
                            directionItems.insertAdjacentHTML( 'beforeEnd', step );

                        };

                    };

                } );

            } );

        };

        function showAnswerConfirm( locationItem, question ) {

            var answerConfirm = document.getElementById( 'answer-confirm' ),
                answerText = document.getElementById( 'answer-text' ),
                location = document.getElementById( 'answer-confirm-location' ),
                map = document.getElementById( 'answer-confirm-map' ),
                ok = document.getElementById( 'answer-confirm-ok' ),
                cancel = document.getElementById( 'answer-confirm-cancel' ),
                note = document.getElementById( 'location-note' ),
                mapUrl = 'http://maps.google.com/maps/api/staticmap?center='
                    + question.latitude + ',' + question.longitude
                    + '&size=260x150&maptype=roadmap&sensor=true&style=hue:blue&markers=color:black|size:mid|'
                    + question.latitude + ',' + question.longitude
                    + '&markers=color:gray|size:mid|' + locationItem.getDataset( 'latitude' ) + "," + locationItem.getDataset( 'longitude' );

            answerText.disabled = true;

            if ( location.firstChild ) location.removeChild( location.firstChild );
            location.appendChild( locationItem.cloneNode( true ).removeClass( 'select' ).removeClass( 'hover' ).addClass( 'confirm-item' ) );
            note.value = '';
            map.setAttribute( 'src', mapUrl );

            answerConfirm.removeClass( 'hide' );
            window.setTimeout( function () { answerConfirm.removeClass( 'fade' ); }, 50 );

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

            function okClick( event ) {

                event.preventDefault();
                ok.focus();

                removeListeners();

                answerConfirm.addClass( 'fade' );
                window.setTimeout( function () { answerConfirm.addClass( 'hide' ); }, 1000 );

                answerText.disabled = false;

                _places.getDetails( { reference: locationItem.getDataset( 'reference' ) }, function ( place, status ) {

                    if ( status == google.maps.places.PlacesServiceStatus.OK ) {

                        saveAnswer( 
                            question, {
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
                removeListeners();

                answerConfirm.addClass( 'fade' );
                window.setTimeout( function () { answerConfirm.addClass( 'hide' ); }, 1000 );

                answerText.disabled = false;
                answerText.focus();

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

        };

        function showAnswersSelect() {

            var answers = document.getElementById( 'answers' ).getElementsByClassName( 'select-answer' );

            for ( var index = 0; index < answers.length; index++ ) {

                if ( answers[index].parentNode.getElementsByClassName( 'selected' ).length ) {

                    answers[index].addClass( 'select-answer-selected' );

                } else {

                    answers[index].removeClass( 'select-answer-selected' );

                };

                answers[index].removeClass( 'hide' );

            };

            window.setTimeout( function () {

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].removeClass( 'width-zero' );

                };

            }, 50 );

            window.setTimeout( function () {

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].removeClass( 'fade' );

                };

            }, 250 );

        };

        function showAskButton() {

            document.getElementById( 'ask-button' ).removeClass( 'ask-button-slide' );

        };

        function showBackButton( caption, page, options ) {

            var button = document.getElementById( 'back-button' );
            button.setDataset( 'page', page );
            button.setDataset( 'options', window.JSON.stringify( options ) );
            document.getElementById( 'back-button-text' ).textContent = caption;
            button.removeClass( 'hide' );

        };

        function showContact() {

            var contact = document.getElementById( 'contact' ),
                call = document.getElementById( 'contact-call' ),
                website = document.getElementById( 'contact-website' ),
                map = document.getElementById( 'contact-map' );

            contact.removeClass( 'hide' );
            window.setTimeout( function () { contact.addClass( 'contact-slide' ); }, 20 );

            contact.addEventListener( 'close', close, false );

            call.addEventListener( 'click', callLocation, false );
            call.addEventListener( 'touchstart', selectButton, false );
            call.addEventListener( 'touchend', unselectButton, false );
            call.addEventListener( 'mousedown', selectButton, false );
            call.addEventListener( 'mouseup', unselectButton, false );

            website.addEventListener( 'click', viewWebsite, false );
            website.addEventListener( 'touchstart', selectButton, false );
            website.addEventListener( 'touchend', unselectButton, false );
            website.addEventListener( 'mousedown', selectButton, false );
            website.addEventListener( 'mouseup', unselectButton, false );

            map.addEventListener( 'click', showGoogleMaps, false );
            map.addEventListener( 'touchstart', selectButton, false );
            map.addEventListener( 'touchend', unselectButton, false );
            map.addEventListener( 'mousedown', selectButton, false );
            map.addEventListener( 'mouseup', unselectButton, false );

            function callLocation() {

                close();

                var answerId = document.getElementById( 'answer-page' ).getDataset( 'id' ),
                    answer = _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId );

                if ( answer[ANSWER_COLUMNS.phone] ) {

                    window.open( 'tel:' + answer[ANSWER_COLUMNS.phone], '_top' );

                };

            };

            function viewWebsite() {

                close();

                var answerId = document.getElementById( 'answer-page' ).getDataset( 'id' ),
                    answer = _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId );

                if ( answer[ANSWER_COLUMNS.link] ) {

                    var a = document.createElement( 'a' );
                    a.setAttribute( 'href', answer[ANSWER_COLUMNS.link] );
                    a.setAttribute( 'target', '_blank' );
                    var event = document.createEvent( 'HTMLEvents' )
                    event.initEvent( 'click', true, true );
                    a.dispatchEvent( event );

                };

            };

            function showGoogleMaps() {

                close();

                var answerId = document.getElementById( 'answer-page' ).getDataset( 'id' ),
                    answer = _selectedQuestion[QUESTION_COLUMNS.answers].item( answerId ),
                    url = 'http://maps.google.com/?saddr='
                        + _currentLocation.latitude + ',' + _currentLocation.longitude
                        + '&daddr=' + answer[ANSWER_COLUMNS.latitude] + ',' + answer[ANSWER_COLUMNS.longitude];

                window.open( url );

            };

            function close() {

                contact.removeClass( 'contact-slide' );
                window.setTimeout( function () { contact.addClass( 'hide' ); }, 600 );

                removeListeners();

            };

            function removeListeners() {

                contact.removeEventListener( 'close', close, false );

                call.removeEventListener( 'click', callLocation, false );
                call.removeEventListener( 'touchstart', selectButton, false );
                call.removeEventListener( 'touchend', unselectButton, false );
                call.removeEventListener( 'mousedown', selectButton, false );
                call.removeEventListener( 'mouseup', unselectButton, false );

                website.removeEventListener( 'click', viewWebsite, false );
                website.removeEventListener( 'touchstart', selectButton, false );
                website.removeEventListener( 'touchend', unselectButton, false );
                website.removeEventListener( 'mousedown', selectButton, false );
                website.removeEventListener( 'mouseup', unselectButton, false );

                map.removeEventListener( 'click', showGoogleMaps, false );
                map.removeEventListener( 'touchstart', selectButton, false );
                map.removeEventListener( 'touchend', unselectButton, false );
                map.removeEventListener( 'mousedown', selectButton, false );
                map.removeEventListener( 'mouseup', unselectButton, false );

            };

        };

        function showEditAccount() {

            document.getElementById( 'edit-account' ).removeClass( 'hide' );

        };

        function showFlag() {

            var question = document.getElementById( 'question-view' ).getElementsByClassName( 'flag-question' )[0],
                answers = document.getElementById( 'answers' ).getElementsByClassName( 'flag-answer' );

            hideVoteUp();
            hideVoteDown();
            question.removeClass( 'hide' );

            for ( var index = 0; index < answers.length; index++ ) {

                answers[index].removeClass( 'hide' );

            };

            window.setTimeout( function () {

                question.removeClass( 'width-zero' );

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].removeClass( 'width-zero' );

                };

            }, 50 );

            window.setTimeout( function () {

                question.removeClass( 'fade' );

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].removeClass( 'fade' );

                };

            }, 250 );

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

        };

        function showLoading( top, left ) {

            var loading = document.getElementById( 'loading' );
            loading.style.top = top + 'px';
            loading.style.left = left + 'px';
            loading.removeClass( 'hide' );

        };

        function showMessage( text, callback ) {

            var message = document.getElementById( 'message' ),
                body = document.getElementById( 'message-body' ),
                okButton = document.getElementById( 'message-ok-button' ),
                cancelButton = document.getElementById( 'message-cancel-button' );

            body.innerHTML = text;

            if ( callback ) {

                cancelButton.removeClass( 'hide' );

            } else {

                cancelButton.addClass( 'hide' );

            };

            message.removeClass( 'hide' );
            window.setTimeout( function () { message.removeClass( 'fade' ); }, 50 );

            okButton.addEventListener( 'click', ok, false );
            okButton.addEventListener( 'touchstart', selectButton, false );
            okButton.addEventListener( 'touchend', unselectButton, false );
            okButton.addEventListener( 'mousedown', selectButton, false );
            okButton.addEventListener( 'mouseup', unselectButton, false );
            cancelButton.addEventListener( 'click', cancel, false );
            cancelButton.addEventListener( 'touchstart', selectButton, false );
            cancelButton.addEventListener( 'touchend', unselectButton, false );
            cancelButton.addEventListener( 'mousedown', selectButton, false );
            cancelButton.addEventListener( 'mouseup', unselectButton, false );

            function ok() {

                removeEventListeners();

                if ( callback ) callback();

                message.addClass( 'fade' );
                window.setTimeout( function () { message.addClass( 'hide' ); }, 1000 );

            };

            function cancel() {

                removeEventListeners();

                message.addClass( 'fade' );
                window.setTimeout( function () { message.addClass( 'hide' ); }, 1000 );

            };

            function removeEventListeners() {

                okButton.removeEventListener( 'click', ok, false );
                okButton.removeEventListener( 'touchstart', selectButton, false );
                okButton.removeEventListener( 'touchend', unselectButton, false );
                okButton.removeEventListener( 'mousedown', selectButton, false );
                okButton.removeEventListener( 'mouseup', unselectButton, false );
                cancelButton.removeEventListener( 'click', cancel, false );
                cancelButton.removeEventListener( 'touchstart', selectButton, false );
                cancelButton.removeEventListener( 'touchend', unselectButton, false );
                cancelButton.removeEventListener( 'mousedown', selectButton, false );
                cancelButton.removeEventListener( 'mouseup', unselectButton, false );

            };

        };

        function showNotification( notice, options ) {

            options = options || {};

            var notification = document.getElementById( 'notification' ),
                body = document.getElementById( 'notification-body' ),
                footer = document.getElementById( 'notification-footer' );

            options.tight ? notification.addClass( 'notification-tight' ) : notification.removeClass( 'notification-tight' );
            options.small ? notification.addClass( 'notification-small' ) : notification.removeClass( 'notification-small' );
            body.innerHTML = notice;

            if ( options.footer ) {

                notification.removeClass( 'notification-no-footer' );
                footer.innerHTML = options.footer;
                footer.removeClass( 'hide' );

            } else {

                notification.addClass( 'notification-no-footer' );
                footer.innerHTML = '';
                footer.addClass( 'hide' );

            };

            notification.removeClass( 'hide' );
            window.setTimeout( function () { notification.removeClass( 'fade' ); }, 50 );
            window.setTimeout( function () {

                notification.addClass( 'fade' );
                window.setTimeout( function () { notification.addClass( 'hide' ); }, 1000 );

            }, 3000 );

        };

        function showPage( page, options ) {

            options = options || {};

            var viewport = document.getElementById( 'viewport' ),
                previousPage = viewport.getDataset( 'page' ),
                previousOptions = window.JSON.parse( viewport.getDataset( 'options' ) || '{}' );

            viewport.setDataset( 'page', page );
            viewport.setDataset( 'options', window.JSON.stringify( options ) );
            addEventListeners( page, previousPage );
            hideLoading();

            switch ( page ) {

                case 'account-page':

                    slidePage( page, previousPage );
                    setView( 'normal' );
                    hideBackButton();
                    showToolbar( 'main' );
                    showAccountPage();

                    break;

                case 'answer-page':

                    hideContact();
                    slidePage( page, previousPage );
                    setView( 'normal' );
                    showBackButton( STRINGS.backButtonQuestion, 'question-page', previousOptions );
                    document.getElementById( 'directions-page' ).addClass( 'top-slide' );
                    showToolbar( 'answer', { "answerId": options.answerId } );

                    if ( options.answerId && options.answerLetter ) {

                        showAnswer( _selectedQuestion, options.answerId, options.answerLetter );

                    };

                    break;

                case 'install-page':

                    slidePage( page, previousPage );
                    setView( 'fullscreen' );
                    hideBackButton();
                    showInstallPage();

                    break;

                case 'login-page':

                    slidePage( page, previousPage );
                    setView( 'header' );
                    hideBackButton();
                    hideRefreshButton();
                    initializeFacebook();

                    break;

                case 'question-page':

                    hideQuestionShare()
                    slidePage( page, previousPage );
                    setView( 'normal' );
                    showBackButton( options.backCaption, options.backPage, previousOptions );

                    if ( options.questionId && ( _selectedQuestion.questionId != options.questionId ) ) {

                        loadQuestion( options.questionId );

                    };

                    if ( isMyQuestion( _selectedQuestion ) ) {

                        showToolbar( 'my-question' );

                    } else {

                        showToolbar( 'question', { "questionId": options.questionId } );

                    };

                    break;

                case 'question-map-page':

                    slidePage( page, previousPage );
                    setView( 'normal' );
                    showBackButton( STRINGS.backButtonQuestion, 'question-page', previousOptions );
                    showToolbar( 'main' );
                    showQuestionMapFull();

                    break;

                case 'top-page':

                    slidePage( page, previousPage );
                    setView( 'normal' );
                    hideBackButton();
                    showToolbar( 'main' );
                    showTopUsers();

                    break;

                case 'user-page':

                    slidePage( page, previousPage );
                    setView( 'normal' );
                    showToolbar( 'main' );

                    if ( options.backPage ) {

                        showBackButton( options.backCaption, options.backPage, previousOptions );
                        hideEditAccount();

                    } else { //my user page

                        hideBackButton();
                        showEditAccount();

                    };

                    loadUser( options.userId );

                    break;

                case 'questions-page':
                default:

                    _pages.replace( page, { backCaption: STRINGS.backButtonQuestions, backPage: page } )

                    slidePage( page, previousPage );
                    setView( 'normal' );
                    hideBackButton();
                    showToolbar( 'main' );

                    break;

            };

        };

        function showQuestion() {

            var markers = '',
                html = '',
                zoom = '',
                questionView = document.getElementById( 'question-view' ),
                answersView = document.getElementById( 'answers-view' );

            if ( _selectedQuestion[QUESTION_COLUMNS.question].length > 25 ) {

                questionView.innerHTML = getQuestionItem( _selectedQuestion, { full: true } );
                questionView.removeClass( 'question-view-normal' ).addClass( 'question-view-full' );
                answersView.removeClass( 'answers-view-normal' ).addClass( 'answers-view-full' );

            } else {

                questionView.innerHTML = getQuestionItem( _selectedQuestion );
                questionView.removeClass( 'question-view-full' ).addClass( 'question-view-normal' );
                answersView.removeClass( 'answers-view-full' ).addClass( 'answers-view-normal' );

            };

            if ( _selectedQuestion[QUESTION_COLUMNS.answers].length ) {

                answersView.removeClass( 'hide' );

                for ( var index = 0; index < _selectedQuestion[QUESTION_COLUMNS.answers].length; index++ ) {

                    var answer = _selectedQuestion[QUESTION_COLUMNS.answers][index],
                        letter = STRINGS.letters.charAt( index );

                    markers += '&markers=color:gray|size:mid|label:' + letter + '|'
                        + answer[ANSWER_COLUMNS.latitude] + "," + answer[ANSWER_COLUMNS.longitude];
                    html += getAnswerItem( answer, { letter: letter } );

                };

            } else {

                answersView.addClass( 'hide' );
                zoom = '&zoom=12';

            };

            document.getElementById( 'answers' ).innerHTML = html;

            var mapUrl = 'http://maps.google.com/maps/api/staticmap?center='
                    + _selectedQuestion.latitude + ',' + _selectedQuestion.longitude
                    + '&size=308x140&maptype=roadmap&sensor=true&style=hue:blue' + zoom + '&markers=color:black|size:mid|'
                    + _selectedQuestion.latitude + ',' + _selectedQuestion.longitude
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

            var html = '',
                questions = document.getElementById( 'questions' );

            if ( _questions.length ) {

                html += getListItemHeader( STRINGS.local );

                for ( var index = 0; index < _questions.length; index++ ) {

                    html += getQuestionItem( _questions[index] );

                };

                questions.removeClass( 'hide' );

            } else {

                questions.addClass( 'hide' );

            };

            questions.innerHTML = html;

            if ( _questions.length || _userQuestions.length ) {

                document.getElementById( 'no-questions' ).addClass( 'hide' );

            } else {

                document.getElementById( 'no-questions' ).removeClass( 'hide' );

            };

        };

        function showQuestionShare( question ) {

            var share = document.getElementById( 'question-share' ),
                facebook = document.getElementById( 'question-share-facebook' ),
                twitter = document.getElementById( 'question-share-twitter' );

            share.removeClass( 'hide' );
            window.setTimeout( function () { share.addClass( 'question-share-slide' ); }, 20 );

            share.addEventListener( 'close', close, false );

            facebook.addEventListener( 'click', postToFacebook, false );
            facebook.addEventListener( 'touchstart', selectButton, false );
            facebook.addEventListener( 'touchend', unselectButton, false );
            facebook.addEventListener( 'mousedown', selectButton, false );
            facebook.addEventListener( 'mouseup', unselectButton, false );

            twitter.addEventListener( 'click', postToTwitter, false );
            twitter.addEventListener( 'touchstart', selectButton, false );
            twitter.addEventListener( 'touchend', unselectButton, false );
            twitter.addEventListener( 'mousedown', selectButton, false );
            twitter.addEventListener( 'mouseup', unselectButton, false );

            function postToFacebook() {

                close();

                var query = '?button=post-question&question=' + window.encodeURIComponent( question );
                window.location.href = FACEBOOK_LOGIN_URL + query;

            };

            function postToTwitter() {

                close();

                var url = 'https://twitter.com/share'
                        + '?text=' + window.encodeURIComponent( 'Can you help me find: ' + question + ' @ ' )
                        + '&url=' + window.encodeURIComponent( 'http://urbanAsk.com' )
                        + '&hashtags=' + window.encodeURIComponent( 'urbanask' ),
                    a = document.createElement( 'a' );

                a.setAttribute( 'href', url );
                a.setAttribute( 'target', '_blank' );
                var event = document.createEvent( 'HTMLEvents' )
                event.initEvent( 'click', true, true );
                a.dispatchEvent( event );

            };

            function close() {

                share.removeClass( 'question-share-slide' );
                window.setTimeout( function () { share.addClass( 'hide' ); }, 600 );

                removeListeners();

            };

            function removeListeners() {

                share.removeEventListener( 'close', close, false );

                facebook.removeEventListener( 'click', postToFacebook, false );
                facebook.removeEventListener( 'touchstart', selectButton, false );
                facebook.removeEventListener( 'touchend', unselectButton, false );
                facebook.removeEventListener( 'mousedown', selectButton, false );
                facebook.removeEventListener( 'mouseup', unselectButton, false );

                twitter.removeEventListener( 'click', postToTwitter, false );
                twitter.removeEventListener( 'touchstart', selectButton, false );
                twitter.removeEventListener( 'touchend', unselectButton, false );
                twitter.removeEventListener( 'mousedown', selectButton, false );
                twitter.removeEventListener( 'mouseup', unselectButton, false );

            };

        };

        function showSocialButtons() {

            if ( !hasTouch() ) {

                var html =
                          '<div id="social-buttons" class="fadeable fade">'
                        + '<div class="fb-like" data-href="http://urbanAsk.com" data-send="true" data-layout="box_count" data-width="50" data-show-faces="true" data-colorscheme="dark"></div>'
                        + '<div class="g-plusone-frame"><div class="g-plusone" data-size="tall" data-href="http://urbanAsk.com"></div></div>'
                        + '<a href="https://twitter.com/share" class="twitter-share-button" data-url="http://urbanAsk.com" data-text="urbanAsk - The addicting game of helping people find things." data-count="vertical">Tweet</a>'
                        + '<div id="fb-root"></div>'
                        + '</div>'

                document.getElementById( 'viewport' ).insertAdjacentHTML( 'beforeEnd', html );

                var script = document.createElement( 'script' );
                script.async = true;
                script.src = document.location.protocol + '//connect.facebook.net/en_US/all.js#xfbml=1&appId=267603823260704';
                document.getElementById( 'fb-root' ).appendChild( script );

                script = document.createElement( 'script' );
                script.async = true;
                script.src = document.location.protocol + '//platform.twitter.com/widgets.js';
                document.getElementById( 'social-buttons' ).appendChild( script );

                script = document.createElement( 'script' );
                script.async = true;
                script.src = document.location.protocol + '//apis.google.com/js/plusone.js';
                document.getElementById( 'social-buttons' ).appendChild( script );

                window.setTimeout( function () {

                    document.getElementById( 'social-buttons' ).removeClass( 'fade' );

                }, 2000 );

            };

        };

        function showUserQuestions() {

            var html = '',
                userQuestions = document.getElementById( 'user-questions' );

            if ( _userQuestions.length ) {

                html += getListItemHeader( _account[ACCOUNT_COLUMNS.username] );

                for ( var index = 0; index < _userQuestions.length; index++ ) {

                    html += getQuestionItem( _userQuestions[index] );

                };

                userQuestions.removeClass( 'hide' );

            } else {

                userQuestions.addClass( 'hide' );

            };

            userQuestions.innerHTML = html;

            if ( _questions.length || _userQuestions.length ) {

                document.getElementById( 'no-questions' ).addClass( 'hide' );

            } else {

                document.getElementById( 'no-questions' ).removeClass( 'hide' );

            };

        };

        function showRefreshButton() {

            document.getElementById( 'refresh-button' ).removeClass( 'hide' );

        };

        function showToolbar( toolbar, options ) {

            var disabled,
                button;

            switch ( toolbar ) {
                case 'main':

                    document.getElementById( 'toolbar-main' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-answer' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-question' ).addClass( 'hide' );

                    $( '#user-button' ).setDataset( 'user-id', _account[ACCOUNT_COLUMNS.userId] );

                    break;

                case 'answer':

                    var answer = _selectedQuestion[QUESTION_COLUMNS.answers].item( options.answerId );

                    document.getElementById( 'toolbar-answer' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-main' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-my-question' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-question' ).addClass( 'hide' );

                    if ( isMyQuestion( _selectedQuestion ) ) {

                        document.getElementById( 'select-answer-button' ).removeClass( 'hide' );
                        document.getElementById( 'vote-down-answer-button' ).addClass( 'hide' );
                        document.getElementById( 'vote-up-answer-button' ).addClass( 'hide' );

                    } else {

                        document.getElementById( 'select-answer-button' ).addClass( 'hide' );
                        document.getElementById( 'vote-down-answer-button' ).removeClass( 'hide' );
                        document.getElementById( 'vote-up-answer-button' ).removeClass( 'hide' );

                    };

                    //                    if ( isMyAnswer( answer ) ) {

                    //                        document.getElementById( 'delete-answer-button' ).removeClass( 'hide' );

                    //                    } else {

                    //                        document.getElementById( 'delete-answer-button' ).addClass( 'hide' );

                    //                    };

                    $( '#answer-user-button' ).setDataset( 'user-id', answer[ANSWER_COLUMNS.userId] );

                    break;

                case 'question':

                    document.getElementById( 'toolbar-question' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-answer' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-main' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-my-question' ).addClass( 'hide' );

                    disabled = _selectedQuestion.answered( _account[ACCOUNT_COLUMNS.userId] );

                    button = document.getElementById( 'add-answer-button' );
                    disabled ? button.addClass( 'disabled' ) : button.removeClass( 'disabled' );
                    button.setDataset( 'question-id', options.questionId );

                    $( '#question-user-button' ).setDataset( 'user-id', _selectedQuestion.userId );
                    $( '#flag-button' ).setDataset( 'question-id', options.questionId );

                    break;

                case 'my-question':

                    document.getElementById( 'toolbar-my-question' ).removeClass( 'hide' );

                    document.getElementById( 'toolbar-answer' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-main' ).addClass( 'hide' );
                    document.getElementById( 'toolbar-question' ).addClass( 'hide' );

                    break;

            };

        };

        function showTopUsers() {

            window.setTimeout( function () {

                var topTypeId = window.parseInt( document.getElementById( 'top-type' ).getDataset( 'id' ) ),
                    intervalId = window.parseInt( document.getElementById( 'top-interval' ).getDataset( 'id' ) ),
                    topUsers = document.getElementById( 'top-users' ),
                    html = '';

                for ( var index = 0, rank = 0; index < _cache.topUsers.length(); index++ ) {

                    if ( _cache.topUsers.data[index][TOP_USER_COLUMNS.topTypeId] == topTypeId
                        && _cache.topUsers.data[index][TOP_USER_COLUMNS.intervalId] == intervalId ) {

                        rank++;
                        html += getTopUserItem( topTypeId, _cache.topUsers.data[index], rank );

                    };

                };

                topUsers.innerHTML = html;
                var noTopUsers = document.getElementById( 'no-top-users' );

                if ( html.length ) {

                    noTopUsers.addClass( 'hide' );
                    topUsers.removeClass( 'hide' );

                } else {

                    noTopUsers.innerHTML = STRINGS.noTopUsers
                        .replace( "%1", STRINGS.noTopUsersType[topTypeId - 1] )
                        .replace( "%2", STRINGS.noTopUsersInterval[intervalId] );
                    noTopUsers.removeClass( 'hide' );
                    topUsers.addClass( 'hide' );

                };

                window.setTimeout( function () {

                    if ( _cache.topUsers.isExpired() ) { loadTopUsers(); };

                }, 1500 );

            }, 10 );

        };

        function showUser( user ) {

            $( '#username' ).textContent = user[USER_COLUMNS.username];
            $( '#member-since' ).textContent = getMemberSince( user );
            $( '#user-id-value' ).textContent = user[USER_COLUMNS.userId];
            $( '#tagline' ).textContent = user[USER_COLUMNS.tagline];

            var reputationValue = $( '#reputation-value' );
            reputationValue.textContent = formatNumber( user[USER_COLUMNS.reputation] );
            reputationValue.className = 'reputation-value-' + user[USER_COLUMNS.reputation].toString().length;

            $( '#total-questions-value' ).textContent = formatNumber( user[USER_COLUMNS.totalQuestions] );
            $( '#total-answers-value' ).textContent = formatNumber( user[USER_COLUMNS.totalAnswers] );
            $( '#total-badges-value' ).textContent = formatNumber( user[USER_COLUMNS.totalBadges] );

            $( '#total-questions-caption' ).textContent =
                user[USER_COLUMNS.totalQuestions] == 1
                ? STRINGS.totalQuestionsOne
                : STRINGS.totalQuestions;
            $( '#total-answers-caption' ).textContent =
                user[USER_COLUMNS.totalAnswers] == 1
                ? STRINGS.totalAnswersOne
                : STRINGS.totalAnswers;
            $( '#total-badges-caption' ).textContent =
                user[USER_COLUMNS.totalBadges] == 1
                ? STRINGS.totalBadgesOne
                : STRINGS.totalBadges;

            var html = getListItemHeader( STRINGS.reputation );

            if ( user[USER_COLUMNS.reputations].length ) {

                for ( var index = 0; index < user[USER_COLUMNS.reputations].length; index++ ) {

                    html += getReputationItem( user[USER_COLUMNS.reputations][index] );

                };

            } else {

                html += getNoItems( isMe( user )
                    ? STRINGS.user.noReputationMe
                    : STRINGS.user.noReputationUser.replace( '%1', user[USER_COLUMNS.username] ) );

            };

            $( '#user-reputations' ).innerHTML = html;
            html = getListItemHeader( STRINGS.questionHeader );

            if ( user[USER_COLUMNS.questions].length ) {

                for ( index = 0; index < user[USER_COLUMNS.questions].length; index++ ) {

                    html += getQuestionItem( user[USER_COLUMNS.questions][index] );

                };

            } else {

                html += getNoItems( isMe( user )
                    ? STRINGS.user.noQuestionsMe
                    : STRINGS.user.noQuestionsUser.replace( '%1', user[USER_COLUMNS.username] ) );

            };

            $( '#users-questions' ).innerHTML = html;

            html = getListItemHeader( STRINGS.answerHeader );

            if ( user[USER_COLUMNS.answers].length ) {

                for ( index = 0; index < user[USER_COLUMNS.answers].length; index++ ) {

                    html += getAnswerItem( user[USER_COLUMNS.answers][index], { newItem: false, questionId: true } );

                };

            } else {

                html += getNoItems( isMe( user )
                    ? STRINGS.user.noAnswersMe
                    : STRINGS.user.noAnswersUser.replace( '%1', user[USER_COLUMNS.username] ) );

            };

            $( '#user-answers' ).innerHTML = html;

            html = getListItemHeader( STRINGS.headerBadges );

            if ( user[USER_COLUMNS.badges].length ) {

                for ( index = 0; index < user[USER_COLUMNS.badges].length; index++ ) {

                    html += getBadgeItem( user[USER_COLUMNS.badges][index] );

                };

            } else {

                html += getNoItems( isMe( user )
                    ? STRINGS.user.noBadgesMe
                    : STRINGS.user.noBadgesUser.replace( '%1', user[USER_COLUMNS.username] ) );

            };

            $( '#user-badges' ).innerHTML = html;

            $( '#signup-info' ).removeClass( 'hide' );
            $( '#user-reputations' ).removeClass( 'hide' );
            $( '#users-questions' ).removeClass( 'hide' );
            $( '#user-answers' ).removeClass( 'hide' );
            $( '#user-badges' ).removeClass( 'hide' );

        };

        function showVoteDown() {

            var answers = document.getElementById( 'answers' ).getElementsByClassName( 'vote-down-answer' );

            hideVoteUp();
            hideFlag();

            for ( var index = 0; index < answers.length; index++ ) {

                answers[index].removeClass( 'hide' );

            };

            window.setTimeout( function () {

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].removeClass( 'width-zero' );

                };

            }, 50 );

            window.setTimeout( function () {

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].removeClass( 'fade' );

                };

            }, 250 );

        };

        function showVoteUp() {

            var question = document.getElementById( 'question-view' ).getElementsByClassName( 'vote-up-question' )[0],
                answers = document.getElementById( 'answers' ).getElementsByClassName( 'vote-up-answer' );

            hideVoteDown();
            hideFlag();
            question.removeClass( 'hide' );

            for ( var index = 0; index < answers.length; index++ ) {

                //                if ( answers[index].parentNode.getElementsByClassName( 'selected' ).length ) {

                //                    answers[index].addClass( 'vote-up-answer-selected' );

                //                } else {

                //                    answers[index].removeClass( 'vote-up-answer-selected' );

                //                };

                answers[index].removeClass( 'hide' );

            };

            window.setTimeout( function () {

                question.removeClass( 'width-zero' );

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].removeClass( 'width-zero' );

                };

            }, 50 );

            window.setTimeout( function () {

                question.removeClass( 'fade' );

                for ( var index = 0; index < answers.length; index++ ) {

                    answers[index].removeClass( 'fade' );

                };

            }, 250 );

        };

        function titleClick( event ) {

            //showPage( 'questions-page' );
            //scrollUp();

        };

        function toBase64UrlString( base64String ) {

            return base64String.replace( /\+/g, '-' ).replace( /\//g, '_' ).replace( /=/g, '' );

        };

        function toolbarClick( event ) {

            var item = event.target.closestByTagName( 'li' );

            if ( item && !item.disabled ) {

                if ( item.getDataset( 'tab' ) ) {

                    showPage( item.getDataset( 'tab' ) );

                } else {

                    var answerItem;

                    switch ( item.id ) {

                        case 'add-answer-button':

                            if ( _selectedQuestion.answered( _account[ACCOUNT_COLUMNS.userId] ) ) {

                                showMessage( STRINGS.error.alreadyAnswered );

                            } else {

                                showAddAnswer( _selectedQuestion );

                            };

                            break;

                        case 'answer-user-button':

                            showPage( 'user-page', {

                                userId: item.getDataset( 'user-id' ),
                                backCaption: STRINGS.backButtonAnswer,
                                backPage: 'answer-page'

                            } );

                            break;

                        case 'contact-button':

                            var contact = document.getElementById( 'contact' );

                            if ( contact.hasClass( 'hide' ) ) {

                                showContact();

                            } else {

                                hideContact();

                            };

                            break;

                        case 'delete-answer-button':

                            deleteAnswer();
                            break;

                        case 'directions-button':

                            var directions = document.getElementById( 'directions-page' );

                            if ( directions.hasClass( 'top-slide' ) ) {

                                directions.removeClass( 'top-slide' );

                            } else {

                                directions.addClass( 'top-slide' );

                            };

                            break;

                        case 'flag-button':

                            var flag = document.getElementById( 'question-view' ).getElementsByClassName( 'flag-question' )[0];

                            if ( flag.hasClass( 'hide' ) ) {

                                showFlag();

                            } else {

                                hideFlag();

                            };

                            break;

                        case 'question-share-button':

                            var share = document.getElementById( 'question-share' );

                            if ( share.hasClass( 'hide' ) ) {

                                showQuestionShare( _selectedQuestion[QUESTION_COLUMNS.question] );

                            } else {

                                hideQuestionShare();

                            };

                            break;

                        case 'question-user-button':

                            showPage( 'user-page', {

                                userId: item.getDataset( 'user-id' ),
                                backCaption: STRINGS.backButtonQuestion,
                                backPage: 'question-page'

                            } );

                            break;

                        case 'select-answer-button':

                            saveAnswerSelect( _selectedQuestion, document.getElementById( 'answer-page' ).getDataset( 'id' ) );
                            break;

                        case 'select-answers-button':

                            var selects = document.getElementById( 'answers' ).getElementsByClassName( 'select-answer' );

                            if ( selects.length == 0 ) {

                                showMessage( STRINGS.error.noAnswersToSelect );

                            } else if ( selects.length == 1 ) {

                                saveAnswerSelect( _selectedQuestion, selects[0].parentNode.getDataset( 'id' ) );

                            } else if ( selects.length > 1 ) {

                                if ( selects[0].hasClass( 'hide' ) ) {

                                    showAnswersSelect();

                                } else {

                                    hideAnswersSelect();

                                };

                            };

                            break;

                        case 'user-button':

                            showPage( 'user-page', { userId: item.getDataset( 'user-id' ) } );
                            break;

                        case 'vote-down-button':

                            var voteDown = document.getElementById( 'answers' ).getElementsByClassName( 'vote-down-answer' );

                            if ( voteDown.length && voteDown[0].hasClass( 'hide' ) ) {

                                showVoteDown();

                            } else {

                                hideVoteDown();

                            };

                            break;

                        case 'vote-down-answer-button':

                            answerItem = document.getElementById( 'answer-view' ).getElementsByClassName( 'answer-item' )[0];
                            saveAnswerDownvote( _selectedQuestion, answerItem );
                            break;

                        case 'vote-up-answer-button':

                            answerItem = document.getElementById( 'answer-view' ).getElementsByClassName( 'answer-item' )[0];
                            saveAnswerUpvote( _selectedQuestion, answerItem );
                            break;

                        case 'vote-up-button':

                            var voteUp = document.getElementById( 'question-view' ).getElementsByClassName( 'vote-up-question' )[0];

                            if ( voteUp.hasClass( 'hide' ) ) {

                                showVoteUp();

                            } else {

                                hideVoteUp();

                            };

                            break;

                    };

                };

            };

        };

        function topIntervalClick( event ) {

            var toggleButton = event.target.closestByClassName( 'toggle-button' );

            if ( toggleButton && !toggleButton.hasClass( 'toggle-button-selected' ) ) {

                var toggleButtons = document.querySelectorAll( '#top-interval .toggle-button' );

                for ( var index = 0; index < toggleButtons.length; index++ ) {

                    toggleButtons[index].removeClass( 'toggle-button-selected' );

                };

                toggleButton.addClass( 'toggle-button-selected' );
                toggleButton.parentNode.setDataset( 'id', toggleButton.getDataset( 'id' ) );
                showTopUsers();

            };

        };

        function topTypeClick( event ) {

            var toggleButton = event.target.closestByClassName( 'toggle-button' );

            if ( toggleButton && !toggleButton.hasClass( 'toggle-button-selected' ) ) {

                var toggleButtons = document.querySelectorAll( '#top-type .toggle-button' );

                for ( var index = 0; index < toggleButtons.length; index++ ) {

                    toggleButtons[index].removeClass( 'toggle-button-selected' );

                };

                toggleButton.addClass( 'toggle-button-selected' );
                toggleButton.parentNode.setDataset( 'id', toggleButton.getDataset( 'id' ) );
                showTopUsers();

            };

        };

        function totalAnswersClick( event ) {

            document.getElementById( 'user-answers' ).scrollIntoView();

        };

        function totalBadgesClick( event ) {

            document.getElementById( 'user-badges' ).scrollIntoView();

        };

        function travelModeClick( event ) {

            var travelItem = event.target.closestByClassName( 'travel-mode-item' );

            if ( travelItem && !travelItem.hasClass( 'travel-mode-selected' ) ) {

                setTravelMode( travelItem );

            };

        };

        function totalQuestionsClick( event ) {

            document.getElementById( 'users-questions' ).scrollIntoView();

        };

        function totalReputationClick( event ) {

            document.getElementById( 'user-reputations' ).scrollIntoView();

        };

        function unhoverElement( event ) {

            var item = event.target.closestByClassName( 'selectable' );
            if ( item ) item.removeClass( 'hover' );

        };

        function unhoverItem( event ) {

            var item = event.target.closestByClassName( 'list-item' );

            if ( item ) {

                item.removeClass( 'hover' );

            };

        };

        function unselectButton( event ) {

            this.removeClass( 'button-selected' );

            if ( this.id == 'back-button' ) {

                document.getElementById( 'back-button-gradient' ).removeClass( 'button-selected' );

            };

        };

        function unselectItem( event ) {

            var item = event.target.closestByClassName( 'list-item' );

            if ( item ) {

                item.removeClass( 'select' );

            };

        };

        function unselectElement( event ) {

            var item = event.target.closestByClassName( 'selectable' );
            if ( item ) item.removeClass( 'select' );

        };

        function unselectToolbarItem( event ) {

            var item = event.target.closestByClassName( 'toolbar-item' );

            if ( item ) {

                item.removeClass( 'toolbar-item-selected' );

            };

        };

        function userClick( event ) {

            selectItem( event );

            window.setTimeout( function () {

                var user = event.target.closestByClassName( 'user-item' );

                if ( user ) {

                    showPage( 'user-page', {

                        userId: user.getDataset( 'id' ),
                        backCaption: STRINGS.backButtonTopUsers,
                        backPage: 'top-page'

                    } );

                };

                window.setTimeout( function () { unselectItem( event ); }, 100 );

            }, 100 );

        };

        function userAnswerClick( event ) {

            selectItem( event );

            window.setTimeout( function () {

                var answerItem = event.target.closestByClassName( 'answer-item' );

                if ( answerItem ) {

                    showPage( 'question-page', {

                        questionId: answerItem.getDataset( 'question-id' ),
                        backCaption: STRINGS.backButtonUser,
                        backPage: 'user-page'

                    } );

                };

                window.setTimeout( function () { unselectItem( event ); }, 100 );

            }, 100 );

        };

        Array.prototype.item = function ( value, column ) {

            column = column || 0;

            for ( var index = 0; index < this.length; index++ ) {

                if ( value == this[index][column] ) return this[index];

            };

        };

        Element.prototype.getDataset = function ( name ) {

            return this.getAttribute( 'data-' + name );

        };

        Element.prototype.setDataset = function ( name, value ) {

            this.setAttribute( 'data-' + name, value );
            return this;

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

        Element.prototype.removeClass = function ( className ) {

            if ( this.hasClass( className ) ) {

                var regEx = new RegExp( '(\\s|^)' + className + '(\\s|$)' );
                this.className = this.className.replace( regEx, ' ' ).trim();

            };

            return this;

        };

        window.Object.defineProperty( Element.prototype, 'positionTop', {

            get: function () {

                return this.offsetTop - this.parentNode.scrollTop;

            }

        } );

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

        String.prototype.trim = function () {

            var str = this.replace( /^\s\s*/, '' ),
		        ws = /\s/,
		        i = str.length;
            while ( ws.test( str.charAt( --i ) ) );

            return str.slice( 0, i + 1 );

        };

        function $( selector ) {

            switch ( selector[0] ) {

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

        function debug( text, append ) {

            if ( append ) {

                document.getElementById( 'title' ).textContent += text;

            } else {

                document.getElementById( 'title' ).textContent = text;

            };

        };

        /* Crypto-JS v2.3.0 * http://code.google.com/p/crypto-js/ * Copyright (c) 2011, Jeff Mott. All rights reserved. * http://code.google.com/p/crypto-js/wiki/License */
        ("undefined" == typeof Crypto || !Crypto.util ) && function () {
            var d = window.Crypto = {}, m = d.util = { rotl: function ( b, c ) { return b << c | b >>> 32 - c }, rotr: function ( b, c ) { return b << 32 - c | b >>> c }, endian: function ( b ) { if ( b.constructor == Number ) return m.rotl( b, 8 ) & 16711935 | m.rotl( b, 24 ) & 4278255360; for ( var c = 0; c < b.length; c++ ) b[c] = m.endian( b[c] ); return b }, randomBytes: function ( b ) { for ( var c = []; 0 < b; b-- ) c.push( window.Math.floor( 256 * window.Math.random() ) ); return c }, bytesToWords: function ( b ) {
                for ( var c = [], a = 0, j = 0; a < b.length; a++, j += 8 ) c[j >>>
5] |= b[a] << 24 - j % 32; return c
            }, wordsToBytes: function ( b ) { for ( var c = [], a = 0; a < 32 * b.length; a += 8 ) c.push( b[a >>> 5] >>> 24 - a % 32 & 255 ); return c }, bytesToHex: function ( b ) { for ( var c = [], a = 0; a < b.length; a++ ) c.push( ( b[a] >>> 4 ).toString( 16 ) ), c.push( ( b[a] & 15 ).toString( 16 ) ); return c.join( "" ) }, hexToBytes: function ( b ) { for ( var c = [], a = 0; a < b.length; a += 2 ) c.push( window.parseInt( b.substr( a, 2 ), 16 ) ); return c }, bytesToBase64: function ( b ) {
                if ( "function" == typeof btoa ) return window.btoa( f.bytesToString( b ) ); for ( var c = [], a = 0; a < b.length; a += 3 ) for ( var j =
b[a] << 16 | b[a + 1] << 8 | b[a + 2], e = 0; 4 > e; e++ ) 8 * a + 6 * e <= 8 * b.length ? c.push( "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt( j >>> 6 * ( 3 - e ) & 63 ) ) : c.push( "=" ); return c.join( "" )
            }, base64ToBytes: function ( b ) {
                if ( "function" == typeof atob ) return f.stringToBytes( window.atob( b ) ); for ( var b = b.replace( /[^A-Z0-9+\/]/ig, "" ), c = [], a = 0, j = 0; a < b.length; j = ++a % 4 ) 0 != j && c.push( ( "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".indexOf( b.charAt( a - 1 ) ) & window.Math.pow( 2, -2 * j + 8 ) - 1 ) << 2 * j | "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".indexOf( b.charAt( a ) ) >>>
6 - 2 * j ); return c
            }
            }, d = d.charenc = {}; d.UTF8 = { stringToBytes: function ( b ) { return f.stringToBytes( window.unescape( window.encodeURIComponent( b ) ) ) }, bytesToString: function ( b ) { return window.decodeURIComponent( window.escape( f.bytesToString( b ) ) ) } }; var f = d.Binary = { stringToBytes: function ( b ) { for ( var c = [], a = 0; a < b.length; a++ ) c.push( b.charCodeAt( a ) & 255 ); return c }, bytesToString: function ( b ) { for ( var c = [], a = 0; a < b.length; a++ ) c.push( window.String.fromCharCode( b[a] ) ); return c.join( "" ) } }
        } ();
        (function () {
            var d = window.Crypto, m = d.util, f = d.charenc, b = f.UTF8, c = f.Binary, a = d.SHA1 = function ( b, e ) { var h = m.wordsToBytes( a._sha1( b ) ); return e && e.asBytes ? h : e && e.asString ? c.bytesToString( h ) : m.bytesToHex( h ) }; a._sha1 = function ( a ) {
                a.constructor == String && ( a = b.stringToBytes( a ) ); var c = m.bytesToWords( a ), h = 8 * a.length, a = [], d = 1732584193, g = -271733879, k = -1732584194, l = 271733878, f = -1009589776; c[h >> 5] |= 128 << 24 - h % 32; c[( h + 64 >>> 9 << 4 ) + 15] = h; for ( h = 0; h < c.length; h += 16 ) {
                    for ( var o = d, p = g, q = k, r = l, s = f, i = 0; 80 > i; i++ ) {
                        if ( 16 > i ) a[i] = c[h +
i]; else { var n = a[i - 3] ^ a[i - 8] ^ a[i - 14] ^ a[i - 16]; a[i] = n << 1 | n >>> 31 } n = ( d << 5 | d >>> 27 ) + f + ( a[i] >>> 0 ) + ( 20 > i ? ( g & k | ~g & l ) + 1518500249 : 40 > i ? ( g ^ k ^ l ) + 1859775393 : 60 > i ? ( g & k | g & l | k & l ) - 1894007588 : ( g ^ k ^ l ) - 899497514 ); f = l; l = k; k = g << 30 | g >>> 2; g = d; d = n
                    } d += o; g += p; k += q; l += r; f += s
                } return [d, g, k, l, f]
            }; a._blocksize = 16; a._digestsize = 20
        } )();
        (function () { var d = window.Crypto, m = d.util, f = d.charenc, b = f.UTF8, c = f.Binary; d.HMAC = function ( a, d, e, h ) { d.constructor == String && ( d = b.stringToBytes( d ) ); e.constructor == String && ( e = b.stringToBytes( e ) ); e.length > 4 * a._blocksize && ( e = a( e, { asBytes: !0 } ) ); for ( var f = e.slice( 0 ), e = e.slice( 0 ), g = 0; g < 4 * a._blocksize; g++ ) f[g] ^= 92, e[g] ^= 54; a = a( f.concat( a( e.concat( d ), { asBytes: !0 } ) ), { asBytes: !0 } ); return h && h.asBytes ? a : h && h.asString ? c.bytesToString( a ) : m.bytesToHex( a ) } } )();


        window.setTimeout( initialize, 200 );

    };

} )( /* window */ );