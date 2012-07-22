/// <reference path="/scripts/add-answer.js" />
/// <reference path="/scripts/strings-en.js" />

function updateVersion( event ) {

    window.applicationCache.removeEventListener( 'updateready', updateVersion, false );

    if ( window.applicationCache.status == window.applicationCache.UPDATEREADY ) {

        window.setTimeout( function () {

            showNotification( STRINGS.notification.newVersion, { footer: STRINGS.notification.downloading, size: 'tiny' } );
            window.applicationCache.swapCache();
            window.setTimeout( function () { window.location.reload(); }, 3000 );

        }, 2000 );

    };

};

if ( window.applicationCache ) { window.applicationCache.addEventListener( 'updateready', updateVersion, false ); };

var _hostname = window.location.hostname,
    _currentLocation = {},
    _dimensions = {

        "questionMapWidth": 308,
        "questionMapFullWidth": 320,
        "questionMapFullHeight": 372

    },
    _session = {},
    _account = [],
    _userQuestions = [],
    _questions = [],
    _nearbyQuestions = [],
    _everywhereQuestions = [],
    _scrollAnswers,
    _scrollQuestions,
    _scrollTopUsers,
    _scrollUser,
    _swipeY = 0,
    _userQuestionTimer,
    _questionTimer,
    _geoTimer,
    _instructionsTimer,
    _version = document.getElementsByTagName( 'html' )[0].getAttribute( 'data-version' ),
    ACCOUNT_COLUMNS = {

        "userId": 0,
        "username": 1,
        "displayName": 2,
        "reputation": 3,
        "metricDistances": 4,
        "languageId": 5,
        "tagline": 6,
        "regions": 7,
        "notifications": 8,
        "instructions": 9

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
    API_URL = ( _hostname == '75.144.228.69' ? 'http://75.144.228.69:55555' : 'http://urbanask.com' ),
    BADGE_CLASSES = {

        "silver": 1,
        "gold": 2,
        "diamond": 3,
        "bronze": 4

    },
    BADGE_COLUMNS = {

        "badgeClassId": 0,
        "badge": 1,
        "description": 2,
        "unlimited": 3,
        "badges": 4

    },
    EXPIRATION_DAYS = 14,
    FACEBOOK_COLUMNS = {

        "openGraphId": 0,
        "resolvedOpenGraphId": 0

    },
    FACEBOOK_APP_ID = '267603823260704',
    FACEBOOK_AUTH_URL = 'http://urbanask.com',
    FACEBOOK_LOGIN_URL = 'http://urbanask.com/fb-login.html',
    FACEBOOK_POST_URL = 'http://urbanask.com/fb-login.html',
    FACEBOOK_REDIRECT_URL = 'http://' + ( _hostname == '75.144.228.69' ? '75.144.228.69:55555/urbangab' : 'urbanask.com' ) + '/index.html',
    INSTRUCTION_RATE = 30000,
    INSTRUCTION_TYPES = {

        postQuestion: { id: 0, name: 'postQuestion' },
        viewQuestions: { id: 1, name: 'viewQuestions' },
        viewQuestion: { id: 2, name: 'viewQuestion' },
        addAnswer: { id: 3, name: 'addAnswer' },
        toolbar: { id: 4, name: 'toolbar' }

    },
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
    LOCATION_RADIUS = 50000,
    LOCATION_TYPES = 'establishment',
    NOTIFICATION_COLUMNS = {

        "userNotificationId": 0,
        "notification": 1,
        "objectType": 2,
        "itemId": 3,
        "objectDescription": 4,
        "viewed": 5,
        "timestamp": 6

    },
    QUESTION_ROW_COUNT = 50,
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
        "answers": 15,
        "facebook": 16

    },
    RANDOM_DISTANCE = 600, //feet
    REFRESH_NEW_QUESTION_RATE = 500, // milliseconds
    REFRESH_QUESTION_RATE = 60000, // 60 seconds
    REFRESH_USER_QUESTION_RATE = 30000, //30 seconds
    REGION_COLUMNS = {

        "id": 0,
        "name": 1,
        "level": 2

    },
    REPUTATION_ACTION = {

        "resolvedQuestion": 2,
        "editedQuestion": 2

    },
    REPUTATION_COLUMNS = {

        "reputationId": 0,
        "reputationAction": 1,
        "questionId": 2,
        "question": 3,
        "reputation": 4,
        "timestamp": 5

    },
    ROOT_URL = 'http://urbanask.com',
    SECOND = 1000,
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
    TWITTER_RETURN_URL = ( _hostname == '75.144.228.69' ) ? 'http://75.144.228.69:55555/urbangab' : 'http://urbanask.com',
    URL_NOTHING = 'http://urbanask.com/nothing.html',
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
    VERSION_CHECK_RATE = 4 * 60 * 60 * 1000, //4 hours
    WORLD_REGION_ID = 0,
    _pages = {

        data: [],
        length: function () { return this.data.length },
        last: function () { return this.data[this.data.length - 1] },

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
            refreshed: false,

            load: function () {

                var topUsers = window.getLocalStorage( 'topUsers' ),
                    topUsersTimestamp = window.getLocalStorage( 'topUsersTimestamp' );

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
                window.setLocalStorage( 'topUsers', data );
                window.setLocalStorage( 'topUsersTimestamp', this.timestamp );
                this.refreshed = true;

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

function Page( name, options ) {

    this.name = name;
    this.options = options;

};

function addDefaultEventListeners() {

    var toolbar = document.getElementById( 'toolbar' ),
        refreshButton = document.getElementById( 'refresh-button' ),
        title = document.getElementById( 'title' );

    toolbar.addEventListener( 'click', toolbarClick, false );
    refreshButton.addEventListener( 'click', refresh, false );
    title.addEventListener( 'click', scrollUp, false );

    window.addEventListener( 'orientationchange', orientationChange, false );
    window.addEventListener( 'resize', orientationChange, false );
    //window.addEventListener( 'popstate', browserBack, false );

    if ( window.deviceInfo.mobile ) {

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

    var backButton,
        questions,
        answers;

    removeEventListeners( previousPage );

    switch ( page ) {

        case 'answer-page':

            document.getElementById( 'travel-mode-toolbar' ).addEventListener( 'click', travelModeClick, false );

            backButton = document.getElementById( 'back-button' );
            backButton.addEventListener( 'click', goBack, false );

            if ( window.deviceInfo.phonegap ) {

                document.addEventListener( 'menubutton', onContactButtonClick, false );

            };

            if ( window.deviceInfo.mobile ) {

                backButton.addEventListener( 'touchstart', selectButton, false );
                backButton.addEventListener( 'touchend', unselectButton, false );

            } else {

                backButton.addEventListener( 'mousedown', selectButton, false );
                backButton.addEventListener( 'mouseup', unselectButton, false );

            };

            break;

        case 'login-page':

            var loginButton = document.getElementById( 'login-button' );
            loginButton.addEventListener( 'click', login, false );

            var facebookButton = document.getElementById( 'fb-login' );
            facebookButton.addEventListener( 'click', loginFacebook, false );

            var twitterLogin = document.getElementById( 'twitter-login' );
            twitterLogin.addEventListener( 'click', authorizeTwitter, false );

            var emailButton = document.getElementById( 'create-email-account' );
            emailButton.addEventListener( 'click', showCreateEmailAccount, false );

            window.addEventListener( 'message', authorizeFacebook, false );

            if ( window.deviceInfo.mobile ) {

                loginButton.addEventListener( 'touchstart', selectButton, false );
                loginButton.addEventListener( 'touchend', unselectButton, false );

                facebookButton.addEventListener( 'touchstart', selectButton, false );
                facebookButton.addEventListener( 'touchend', unselectButton, false );

                twitterLogin.addEventListener( 'touchstart', selectButton, false );
                twitterLogin.addEventListener( 'touchend', unselectButton, false );

                emailButton.addEventListener( 'touchstart', selectButton, false );
                emailButton.addEventListener( 'touchend', unselectButton, false );

            } else {

                loginButton.addEventListener( 'mousedown', selectButton, false );
                loginButton.addEventListener( 'mouseup', unselectButton, false );

                facebookButton.addEventListener( 'mousedown', selectButton, false );
                facebookButton.addEventListener( 'mouseup', unselectButton, false );

                twitterLogin.addEventListener( 'mousedown', selectButton, false );
                twitterLogin.addEventListener( 'mouseup', unselectButton, false );

                emailButton.addEventListener( 'mousedown', selectButton, false );
                emailButton.addEventListener( 'mouseup', unselectButton, false );

            };

            break;

        case 'question-page':

            answers = document.getElementById( 'answers' );
            answers.addEventListener( 'click', answerClick, false );

            var questionView = document.getElementById( 'question-view' );
            questionView.addEventListener( 'click', questionItemClick, false );

            backButton = document.getElementById( 'back-button' );
            backButton.addEventListener( 'click', goBack, false );

            document.getElementById( 'question-map' ).addEventListener( 'click', questionItemClick, false );

            if ( window.deviceInfo.phonegap ) {

                document.addEventListener( 'menubutton', onQuestionShareButtonClick, false );

            };

            if ( window.deviceInfo.mobile ) {

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

            if ( window.deviceInfo.mobile ) {

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

            var nearbyQuestions = document.getElementById( 'nearby-questions' );
            nearbyQuestions.addEventListener( 'click', questionClick, false );

            var everywhereQuestions = document.getElementById( 'everywhere-questions' );
            everywhereQuestions.addEventListener( 'click', questionClick, false );

            var askText = document.getElementById( 'ask-text' );
            askText.addEventListener( 'focus', showAskButton, false );
            askText.addEventListener( 'blur', hideAskButton, false );

            var ask = document.getElementById( 'ask' );
            ask.addEventListener( 'submit', saveQuestion, false );

            if ( window.deviceInfo.mobile ) {

                //ask.addEventListener( 'touchstart', selectAskText, false );

            } else {

                userQuestions.addEventListener( 'mouseover', hoverItem, false );
                userQuestions.addEventListener( 'mouseout', unhoverItem, false );

                questions.addEventListener( 'mouseover', hoverItem, false );
                questions.addEventListener( 'mouseout', unhoverItem, false );

                nearbyQuestions.addEventListener( 'mouseover', hoverItem, false );
                nearbyQuestions.addEventListener( 'mouseout', unhoverItem, false );

                everywhereQuestions.addEventListener( 'mouseover', hoverItem, false );
                everywhereQuestions.addEventListener( 'mouseout', unhoverItem, false );

                //ask.addEventListener( 'mousedown', selectAskText, false );

            };

            break;

        case 'top-page':

            var topUsers = document.getElementById( 'top-users' );
            topUsers.addEventListener( 'click', userClick, false );

            var topType = document.getElementById( 'top-type' ),
                topInterval = document.getElementById( 'top-interval' );

            if ( window.deviceInfo.mobile ) {

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

            var notificationItems = document.getElementById( 'user-notifications' );
            notificationItems.addEventListener( 'click', notificationItemClick, false );

            var reputationItems = document.getElementById( 'user-reputations' );
            reputationItems.addEventListener( 'click', reputationItemClick, false );

            questions = document.getElementById( 'users-questions' );
            questions.addEventListener( 'click', questionClick, false );

            answers = document.getElementById( 'user-answers' );
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

            var editAccount = document.getElementById( 'edit-account' );
            editAccount.addEventListener( 'click', showAccountPage, false );

            if ( window.deviceInfo.phonegap ) {

                document.addEventListener( 'menubutton', showAccountPage, false );

            };

            if ( window.deviceInfo.mobile ) {

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

                editAccount.addEventListener( 'touchstart', selectButton, false );
                editAccount.addEventListener( 'touchend', unselectButton, false );

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

                editAccount.addEventListener( 'mousedown', selectButton, false );
                editAccount.addEventListener( 'mouseup', unselectButton, false );

            };

            break;

    };

};

function answerClick( event ) {

    selectItem( event );

    window.setTimeout( function () {

        var answerItem = event.target.closestByClassName( 'answer-item' );

        if ( answerItem ) {

            var question = _pages.last().options.object,
                answerId = answerItem.getDataset( 'id' ),
                answer = question[QUESTION_COLUMNS.answers].item( answerId ),
                select = answerItem.getElementsByClassName( 'select-answer' ),
                voteUp = answerItem.getElementsByClassName( 'vote-up-answer' ),
                voteDown = answerItem.getElementsByClassName( 'vote-down-answer' );

            if ( select.length && !select[0].hasClass( 'hide' ) ) {

                saveAnswerSelect( question, answer, answerItem );

            } else if ( voteUp.length && !voteUp[0].hasClass( 'hide' ) ) {

                saveAnswerUpvote( question, answer, answerItem );

            } else if ( voteDown.length && !voteDown[0].hasClass( 'hide' ) ) {

                saveAnswerDownvote( question, answer, answerItem );

            } else {

                showPage( 
                    'answer-page',
                    {
                        id: answerId,
                        object: answer,
                        question: question,
                        answerLetter: answerItem.getDataset( 'letter' )
                    }
                );

            };

        };

        window.setTimeout( function () { unselectItem( event ); }, 100 );

    }, 100 );

};

function badgeClick( event ) {

    var badge = event.target.closestByClassName( 'badge' );

    if ( badge ) {

        showMessage( badge.getDataset( 'description' ) );

    };

};

function browserBack( event ) {

    if ( !document.getElementById( 'back-button' ).hasClass( 'hide' ) ) {

        event.preventDefault();
        goBack();

    };

};

function checkLogin() {

    if ( window.location.queryString()['oauth_token'] ) {

        loginTwitter( window.location.queryString()['oauth_token'] );

    } else if ( _session.id && _session.key ) {

        startApp();

    } else {

        showPage( 'login-page' );

    };

};

function deleteAnswer( answerId ) {

    var resource = '/api/answers/' + answerId + '/delete',
        session = getSession( resource );

    ajax( API_URL + resource, {

        "type": "GET",
        "headers": { "x-session": session },
        "success": function ( data, status ) {

            //delete answer count from _questions
            //refresh questions-page
            //delete answer from question
            //detete answer count from question
            //refresh question-page
            //go back to question-page


        },
        "error": function ( response, status, error ) {

            error == 'Unauthorized'
                ? logoutApp()
                : showMessage( STRINGS.error.deleteAnswer );

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

function getAnswerItem( answer, question, options ) {

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

        action = '<div class="select-answer width-zero fade hide">' + STRINGS.checkmark + '</div>'
            + '<div class="vote-up-answer width-zero fade hide"></div>'
            + '<div class="vote-down-answer width-zero fade hide"></div>'

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
        case BADGE_CLASSES.bronze:

            emblemClass = 'badge-emblem-bronze';
            break;

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

function getNotificationItem( notifiction ) {

    return '<li class="notification-item list-item" '
        + 'data-id="' + notifiction[NOTIFICATION_COLUMNS.userNotificationId] + '" '
        + 'data-item-id="' + notifiction[NOTIFICATION_COLUMNS.itemId] + '" '
        + 'data-object="' + notifiction[NOTIFICATION_COLUMNS.objectType] + '">'
        + '<div class="notification-body">' + notifiction[NOTIFICATION_COLUMNS.objectDescription] + '</div>'
        + '<ul class="info">'
        + '<li class="info-item">' + notifiction[NOTIFICATION_COLUMNS.notification] + '</li>'
        + '</ul>'
        + '</li>';

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

    if ( !isMyQuestion( question ) ) {

        action = '<div class="vote-up-question width-zero fade hide"></div>'
            + '<div class="vote-down-question width-zero fade hide"></div>'

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

function getRandomLatitude() {

    //.0001894 miles = 1 ft
    //lat: .000002741
    //lon: .0000035736
    //69.1 * ( lat2 - lat1 )
    //53.0 * ( lon2 - lon1 )

    var distance = Math.floor( Math.random() * RANDOM_DISTANCE ) + 1,
        negative = ( Math.floor( Math.random() * 2 ) ? 1 : -1 ),
        latitudeModifier = .000002741;

    return distance * latitudeModifier * negative;

};

function getRandomLongitude() {

    var distance = Math.floor( Math.random() * RANDOM_DISTANCE ) + 1,
        negative = ( Math.floor( Math.random() * 2 ) ? 1 : -1 ),
        longitudeModifier = .0000035736;

    return distance * longitudeModifier * negative;

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

    var resource = '/api/users/' + user[TOP_USER_COLUMNS.userId] + '/icon',
        topScore = topTypeId == TOP_TYPES.reputation ? 'top-score top-reputation' : 'top-score';

    return '<li class="user-item list-item"'
        + 'data-id="' + user[TOP_USER_COLUMNS.userId] + '">'
        + '<div class="user-count">' + count + '</div>'
        + '<img class="user-icon" src="' + API_URL + resource + '?x-session=' + getSession( resource ) + '" />'
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

    _pages.remove(); //remove current page

    var lastIndex = _pages.length() - 1,
        page = _pages.data[lastIndex].name;

    showPage( page, {}, true );

};

function hideAccountPage() {

    var account = document.getElementById( 'account-page' ),
        event = document.createEvent( 'HTMLEvents' );

    event.initEvent( 'close', false, false );
    account.dispatchEvent( event );

};

function hideAddAnswer() {

    var addAnswer = document.getElementById( 'add-answer-page' ),
        event = document.createEvent( 'HTMLEvents' );

    event.initEvent( 'close', false, false );
    addAnswer.dispatchEvent( event );

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

function hideInstructions() {

    var instructions = document.getElementById( 'instructions' ),
        event = document.createEvent( 'HTMLEvents' );

    event.initEvent( 'close', false, false );
    instructions.dispatchEvent( event );

};

function hideQuestionShare() {

    var share = document.getElementById( 'question-share' ),
        event = document.createEvent( 'HTMLEvents' );

    event.initEvent( 'close', false, false );
    share.dispatchEvent( event );

};

function hideVoteDown() {

    var questionVote = document.getElementById( 'question-view' ).getElementsByClassName( 'vote-down-question' )[0],
        answers = document.getElementById( 'answers' ).getElementsByClassName( 'vote-down-answer' );

    if ( questionVote ) { questionVote.addClass( 'fade' ); };

    for ( var index = 0; index < answers.length; index++ ) {

        answers[index].addClass( 'fade' );

    };

    window.setTimeout( function () {

        if ( questionVote ) { questionVote.addClass( 'width-zero' ); };

        for ( var index = 0; index < answers.length; index++ ) {

            answers[index].addClass( 'width-zero' );

        };

    }, 100 );

    window.setTimeout( function () {

        if ( questionVote ) { questionVote.addClass( 'hide' ); };

        for ( var index = 0; index < answers.length; index++ ) {

            answers[index].addClass( 'hide' );

        };

    }, 600 );

};

function hideVoteUp() {

    var questionVote = document.getElementById( 'question-view' ).getElementsByClassName( 'vote-up-question' )[0],
        answers = document.getElementById( 'answers' ).getElementsByClassName( 'vote-up-answer' );

    if ( questionVote ) { questionVote.addClass( 'fade' ); };

    for ( var index = 0; index < answers.length; index++ ) {

        answers[index].addClass( 'fade' );

    };

    window.setTimeout( function () {

        if ( questionVote ) { questionVote.addClass( 'width-zero' ); };

        for ( var index = 0; index < answers.length; index++ ) {

            answers[index].addClass( 'width-zero' );

        };

    }, 100 );

    window.setTimeout( function () {

        if ( questionVote ) { questionVote.addClass( 'hide' ); };

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

    initializeEnvironment();
    initializeDimensions();

    if ( window.location.queryString()['logout'] ) { //for debugging - ?logout=true

        hideSplashPage();
        logoutApp();

    } else {

        initializePhoneGap( function () {

            initializeTrackingCode();
            addDefaultEventListeners();
            initializeInterface();
            initializeVersionCheck();
            loadCachedData();
            hideSplashPage();
            checkLogin()

        } );

    };

};

function initializeBackButton() {

    var button = document.getElementById( 'back-button' );

    if ( _pages.length() > 1 ) {

        var previousIndex = _pages.length() - 2;

        document.getElementById( 'back-button-text' ).textContent = _pages.data[previousIndex].options.caption;
        button.removeClass( 'hide' );

    } else {

        button.addClass( 'hide' );

    };

};

function initializeDimensions() {

    var viewport = document.getElementById( 'viewport' ),
        view = document.getElementById( 'view' ),
        viewportWidth,
        viewportHeight,
        MARGIN = 6,
        BORDER = 1;

    if ( window.deviceInfo.mobile ) {

        viewportWidth = window.innerWidth;
        viewportHeight = window.innerHeight;
        viewport.style.width = viewportWidth + 'px';
        viewport.style.height = viewportHeight + 'px';

    } else {

        document.body.addClass( 'body-desktop' );
        viewport.addClass( 'viewport-desktop' );
        viewportWidth = viewport.clientWidth;
        viewportHeight = viewport.clientHeight;

    };

    var topSlideTop = viewportHeight + 1,
        styles =
            '.top-slide {'
                + 'top: ' + topSlideTop + 'px !important;'
            + '}';
    document.head.insertAdjacentHTML( 'beforeEnd', '<style>' + styles + '</style>' );

    var questionsViewHeight = view.clientHeight - 45;
    document.getElementById( 'questions-view' ).style.height = questionsViewHeight + 'px';

    _dimensions.questionMapWidth = view.clientWidth - ( 2 * MARGIN );
    document.getElementById( 'question-map' ).style.width = _dimensions.questionMapWidth + 'px';

    _dimensions.questionMapFullWidth = view.clientWidth;
    _dimensions.questionMapFullHeight = view.clientHeight;
    document.getElementById( 'question-map-full' ).style.width = _dimensions.questionMapFullWidth + 'px';
    document.getElementById( 'question-map-full' ).style.height = _dimensions.questionMapFullHeight + 'px';

    var topUsersViewHeight = view.clientHeight - 88;
    document.getElementById( 'top-users-view' ).style.height = topUsersViewHeight + 'px';

    var userInfoViewHeight = view.clientHeight - 117;
    document.getElementById( 'user-info-view' ).style.height = userInfoViewHeight + 'px';

    var answerMapCanvasWidth = view.clientWidth - ( 2 * MARGIN );
    document.getElementById( 'answer-map-canvas' ).style.width = answerMapCanvasWidth + 'px';

    var directionsPageWidth = view.clientWidth - ( 2 * MARGIN );
    document.getElementById( 'directions-page' ).style.width = directionsPageWidth + 'px';

    var askTextWidth = view.clientWidth - 78;
    document.getElementById( 'ask-text' ).style.width = askTextWidth + 'px';

    var answerTextWidth = view.clientWidth - 72;
    document.getElementById( 'answer-text' ).style.width = answerTextWidth + 'px';

    var locationsViewHeight = viewportHeight - 45;
    document.getElementById( 'locations-view' ).style.height = locationsViewHeight + 'px';

    var accountPageHeight = view.clientHeight - 54;
    document.getElementById( 'account-view' ).style.height = accountPageHeight + 'px';

};

function initializeEnvironment() {

    window.checkLocalStorage();
    window.previousInnerWidth = window.innerWidth;
    var userAgent = window.navigator.userAgent.toLowerCase();
    window.deviceInfo = {};

    //window.deviceInfo.type - handheld, tablet, desktop
    //window.deviceInfo.brand - ios, android, microsoft, webos, blackberry
    //window.deviceInfo.mode - browser, standalone, webview

    //window.deviceInfo.mobile - window.deviceInfo.type == handheld || window.deviceInfo.type == tablet
    //window.deviceInfo.iscroll - window.deviceInfo.mobile

    if ( /ipad/.test( userAgent ) || ( /android/.test( userAgent ) && !/mobile/.test( userAgent ) ) ) {

        window.deviceInfo.type = 'tablet';

    } else if ( /iphone|ipod|webos|blackberry|android/.test( userAgent ) ) {

        window.deviceInfo.type = 'handheld';

    } else {

        window.deviceInfo.type = 'desktop';

    };

    if ( /iphone|ipod|ipad/.test( userAgent ) ) {

        var safari = /safari/.test( userAgent );

        window.deviceInfo.brand = 'ios';

        if ( window.navigator.standalone ) {

            window.deviceInfo.mode = 'standalone';

        } else if ( safari ) {

            window.deviceInfo.mode = 'browser';

        } else if ( !safari ) {

            window.deviceInfo.mode = 'webview';

        };

    } else if ( /android/.test( userAgent ) ) {

        window.deviceInfo.brand = 'android';
        window.deviceInfo.mode = 'browser';

    } else if ( /webos/.test( userAgent ) ) {

        window.deviceInfo.brand = 'webos';
        window.deviceInfo.mode = 'browser';

    } else if ( /blackberry/.test( userAgent ) ) {

        window.deviceInfo.brand = 'blackberry';
        window.deviceInfo.mode = 'browser';

    } else {

        window.deviceInfo.brand = 'unknown';
        window.deviceInfo.mode = 'browser';

    };

    window.deviceInfo.mobile = ( window.deviceInfo.type == 'handheld' || window.deviceInfo.type == 'tablet' );
    window.deviceInfo.iscroll = window.deviceInfo.mobile;

};

function initializePhoneGap( complete ) {

    if ( window.deviceInfo.brand == 'ios' && window.deviceInfo.mode != 'webview' ) {

        window.deviceInfo.phonegap = false;
        complete();

    } else if ( window.deviceInfo.mobile ) {

        var timer = window.setInterval( function () {

            if ( window.device ) {

                window.clearInterval( timer );
                window.deviceInfo.phonegap = true;
                initializeChildBrowser();
                addEventListeners();

                complete();

            };

        }, 100 );

        window.setTimeout( function () { //failsafe

            if ( !window.device ) { //in webview, not in phonegap or phonegap failed

                window.clearInterval( timer );
                window.deviceInfo.phonegap = false;

                complete();

            };

        }, 5 * SECOND );

    } else {

        window.deviceInfo.phonegap = false;
        complete();

    };

    function initializeChildBrowser() {

        var timer = window.setInterval( function () {

            if ( window.plugins && window.plugins.childBrowser ) {

                window.clearInterval( timer );

                window.plugins.childBrowser.onLocationChange = function ( url ) {

                    if ( url.indexOf( URL_NOTHING ) > -1 ) {

                        if ( url.indexOf( 'oauth_token' ) > -1 ) { //twitter

                            window.plugins.childBrowser.close();
                            loginTwitter( url.substr( url.indexOf( 'oauth_token' ) + 12 ) );

                        } else if ( url.indexOf( 'invite' ) > 1 ) { //fb invite

                            window.plugins.childBrowser.close();

                        } else if ( url.indexOf( 'login' ) > 1 ) {

                            window.plugins.childBrowser.close();
                            window.location.reload();

                        } else {

                            window.plugins.childBrowser.close();

                        };

                    } else if ( url.indexOf( 'intent/tweet/complete' ) > -1 ) { //twitter - after question post

                        window.plugins.childBrowser.close();

                    } else if ( url.indexOf( 'access_token' ) > -1 ) { //android - fb login

                        window.plugins.childBrowser.close();
                        window.location.reload();

                    };

                };

            };

        }, 200 );

        window.setTimeout( function () { //failsafe

            if ( !window.plugins || !window.plugins.childBrowser ) { //child browswer failed

                window.clearInterval( timer );

            };

        }, 5 * SECOND );

    };

    function addEventListeners() {

        document.addEventListener( 'backbutton', goBack, false );

    };

};

function initializeInterface() {

    initializeScrolling();
    localizeStrings();

    document.getElementById( 'top-type' ).setDataset( 'id', TOP_TYPES.reputation );
    document.getElementById( 'top-interval' ).setDataset( 'id', INTERVALS.all );
    document.querySelectorAll( '#top-type .toggle-button[data-id="' + TOP_TYPES.reputation + '"]' )[0].addClass( 'toggle-button-selected' );
    document.querySelectorAll( '#top-interval .toggle-button[data-id="' + INTERVALS.all + '"]' )[0].addClass( 'toggle-button-selected' );

    document.getElementById( 'app-version-user' ).textContent = STRINGS.versionCaption + ' ' + _version;
    document.getElementById( 'app-version-login' ).textContent = STRINGS.versionCaption + ' ' + _version;

    showSocialButtons();
    showExternalFooter();

};

function initializeScrolling() {

    if ( window.deviceInfo.iscroll ) {

        var script = document.createElement( 'script' );
        script.id = 'scrolling';
        script.src = 'scripts/iscroll-lite.min.js';
        document.body.appendChild( script );

        var timer = window.setInterval( function () {

            if ( iScroll ) {

                window.clearInterval( timer );

                if ( !_scrollAnswers ) { //in case timer is called twice

                    _scrollAnswers = new iScroll( 'answers-view' );
                    _scrollQuestions = new iScroll( 'questions-view' );
                    _scrollTopUsers = new iScroll( 'top-users-view' );
                    _scrollUser = new iScroll( 'user-info-view' );

                };

            };

        }, 100 );

    };

};

function roughSizeOfObject( object ) {

    var objectList = [];

    var recurse = function ( value ) {

        var bytes = 0;

        if ( typeof value === 'boolean' ) {
            bytes = 4;
        } else if ( typeof value === 'string' ) {
            bytes = value.length * 2;
        } else if ( typeof value === 'number' ) {
            bytes = 8;
        } else if ( typeof value === 'object'
    && objectList.indexOf( value ) === -1 ) {

            objectList[objectList.length] = value;

            for ( i in value ) {
                bytes += 8; // an assumed existence overhead
                bytes += recurse( value[i] )
            };

        };

        return bytes;

    };

    return recurse( object );

};

function initializeTrackingCode() {

    if ( !window.deviceInfo.mobile ) {

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

function initializeVersionCheck() {

    if ( window.applicationCache ) {

        window.setInterval( function () {

            window.applicationCache.update();

        }, VERSION_CHECK_RATE );

    };

};

function isMe( user ) {

    return ( _account[ACCOUNT_COLUMNS.userId] == user[USER_COLUMNS.userId] );

};

function isMyAnswer( answer ) {

    return ( _account[ACCOUNT_COLUMNS.userId] == answer[ANSWER_COLUMNS.userId] );

};

function isMyQuestion( question ) {

    return ( _account[ACCOUNT_COLUMNS.userId] == question[QUESTION_COLUMNS.userId] );

};

function isScreenWidth( width ) {

    return window.innerWidth > width;

};

function loadAccount( complete ) {

    var resource = '/api/account',
        session = getSession( resource );

    ajax( API_URL + resource, {

        "type": "GET",
        "headers": { "x-session": session },
        "cache": false,
        "async": false,
        "success": function ( data, status ) {

            var count = _account[ACCOUNT_COLUMNS.notifications]
                ? _account[ACCOUNT_COLUMNS.notifications].items( 0, NOTIFICATION_COLUMNS.viewed ).length
                : 0;
            _account = window.JSON.parse( data )[0];
            _account[ACCOUNT_COLUMNS.instructions].unviewed = function () {

                var instuctions = [];

                for ( var index = 0; index < _account[ACCOUNT_COLUMNS.instructions].length; index++ ) {

                    if ( !_account[ACCOUNT_COLUMNS.instructions][index] ) { instuctions.push( index ); };

                };

                return instuctions;

            };

            showNotifications( _account[ACCOUNT_COLUMNS.notifications].length > count );
            if ( complete ) { complete(); };

        },
        "error": function ( response, status, error ) {

            if ( error == 'Unauthorized' ) { logoutApp() };

        }

    } );

};

function loadCachedData() {

    var questions = window.getLocalStorage( 'questions' ),
        userQuestions = window.getLocalStorage( 'userQuestions' ),
        nearbyQuestions = window.getLocalStorage( 'nearby-questions' ),
        everywhereQuestions = window.getLocalStorage( 'everywhere-questions' );

    if ( questions ) _questions = window.JSON.parse( questions );
    if ( userQuestions ) _userQuestions = window.JSON.parse( userQuestions );
    if ( nearbyQuestions ) _nearbyQuestions = window.JSON.parse( nearbyQuestions );
    if ( everywhereQuestions ) _everywhereQuestions = window.JSON.parse( everywhereQuestions );

    var regionId = window.getLocalStorage( 'current-region-id' ),
        regionName = window.getLocalStorage( 'current-region-name' );

    if ( regionId ) {

        _currentLocation.regionId = regionId;
        _currentLocation.regionName = regionName;

    } else {

        _currentLocation.regionId = WORLD_REGION_ID;
        _currentLocation.regionName = STRINGS.topUsers.everywhere;

    };

    var latitude = window.getLocalStorage( 'current-latitude' ),
        longitude = window.getLocalStorage( 'current-longitude' );

    if ( latitude ) {

        _currentLocation.latitude = window.parseFloat( latitude );
        _currentLocation.longitude = window.parseFloat( longitude );

    };

    _session.id = window.getLocalStorage( 'sessionId' );
    _session.key = window.getLocalStorage( 'sessionKey' );

    _cache.load();

};

function loadQuestion( questionId, complete ) {

    var resource = '/api/questions/' + questionId,
        session = getSession( resource );

    ajax( API_URL + resource, {

        "type": "POST",
        "headers": { "x-session": session },
        "cache": false,
        "success": function ( data, status ) {

            var question = initializeQuestionObject( window.JSON.parse( data )[0] );
            showQuestion( question );
            complete( question );

        },
        "error": function ( response, status, error ) {

            error == 'Unauthorized'
                ? logoutApp()
                : showMessage( STRINGS.error.loadQuestion );

        }

    } );

};

function loadQuestions() {

    if ( _account[ACCOUNT_COLUMNS.regions].length ) {

        var region = _account[ACCOUNT_COLUMNS.regions][0],
            data = 'regionId=' + region[REGION_COLUMNS.id],
            resource = '/api/questions',
            session = getSession( resource );

        ajax( API_URL + resource, {

            "type": "GET",
            "data": data,
            "headers": { "x-session": session },
            "cache": false,
            "async": false,
            "success": function ( data, status ) {

                _questions = window.JSON.parse( data );
                window.setLocalStorage( 'questions', data );
                showQuestions( region[REGION_COLUMNS.name], _questions, document.getElementById( 'questions' ) );

            },
            "error": function ( response, status, error ) {

                if ( error == 'Unauthorized' ) { logoutApp() };

            }

        } );

    } else {

        document.getElementById( 'questions' ).addClass( 'hide' );

    };

};

function loadNearbyQuestions() {

    var data = 'latitude=' + _currentLocation.latitude + '&longitude=' + _currentLocation.longitude,
        resource = '/api/questions',
        session = getSession( resource );

    ajax( API_URL + resource, {

        "type": "GET",
        "data": data,
        "headers": { "x-session": session },
        "cache": false,
        "success": function ( data, status ) {

            _nearbyQuestions = window.JSON.parse( data );
            window.setLocalStorage( 'nearby-questions', data );
            showQuestions( STRINGS.questionsNearby, _nearbyQuestions, document.getElementById( 'nearby-questions' ) );

        },
        "error": function ( response, status, error ) {

            if ( error == 'Unauthorized' ) { logoutApp() };

        }

    } );

};

function loadEverywhereQuestions() {

    if ( _nearbyQuestions.length < QUESTION_ROW_COUNT ) {

        var data = 'regionId=' + WORLD_REGION_ID
                + '&count=' + ( QUESTION_ROW_COUNT - _nearbyQuestions.length ),
            resource = '/api/questions',
            session = getSession( resource );

        ajax( API_URL + resource, {

            "type": "GET",
            "data": data,
            "headers": { "x-session": session },
            "cache": false,
            "success": function ( data, status ) {

                _everywhereQuestions = window.JSON.parse( data );
                window.setLocalStorage( 'everywhere-questions', data );
                showQuestions( STRINGS.questionsEverywhere, _everywhereQuestions, document.getElementById( 'everywhere-questions' ) );

            },
            "error": function ( response, status, error ) {

                if ( error == 'Unauthorized' ) { logoutApp() };

            }

        } );

    } else {

        document.getElementById( 'everywhere-questions' ).addClass( 'hide' );

    };

};

function loadTopUsers() {

    showLoading( 'center', 'center' );

    window.setTimeout( function () {

        var data = 'regionId=' + _currentLocation.regionId,
            resource = '/api/top/topUsers',
            session = getSession( resource );

        ajax( API_URL + resource, {

            "type": "GET",
            "headers": { "x-session": session },
            "data": data,
            "success": function ( data, status ) {

                _cache.topUsers.refresh( data );
                showTopUsers( _currentLocation.regionName );
                hideLoading();

            },
            "error": function ( response, status, error ) {

                hideLoading();
                error == 'Unauthorized'
                    ? logoutApp()
                    : showMessage( STRINGS.error.loadTopUsers );

            }

        } );

    }, 10 );

};

function loadUser( userId, complete ) {

    clearUser();

    window.setTimeout( function () {

        var resource = '/api/users/' + userId,
            session = getSession( resource );

        showLoading( 'center', 'center' );

        ajax( API_URL + resource, {

            "type": "POST",
            "headers": { "x-session": session },
            "success": function ( data, status ) {

                var user = window.JSON.parse( data )[0];

                if ( isMe( user ) ) {

                    _account[ACCOUNT_COLUMNS.reputation] = user[USER_COLUMNS.reputation];

                };

                showUser( user );
                complete( user );

            },
            "error": function ( response, status, error ) {

                hideLoading();

                error == 'Unauthorized'
                    ? logoutApp()
                    : showMessage( STRINGS.error.loadUser );

            }

        } );

    }, 10 );

};

function loadUserQuestions() {

    var data = 'userId=' + _account[ACCOUNT_COLUMNS.userId]
            + '&expirationDays=' + EXPIRATION_DAYS,
        resource = '/api/questions',
        session = getSession( resource );

    ajax( API_URL + resource, {

        "type": "GET",
        "data": data,
        "headers": { "x-session": session },
        "cache": false,
        "async": false,
        "success": function ( data, status ) {

            _userQuestions = window.JSON.parse( data );
            window.setLocalStorage( 'userQuestions', data );
            showUserQuestions();

        },
        "error": function ( response, status, error ) {

            if ( error == 'Unauthorized' ) { logoutApp() };

        }

    } );

};

function localizeStrings() {

    $( '#answer-confirm-cancel' ).textContent = STRINGS.cancelButtonCaption;
    $( '#answer-confirm-ok' ).textContent = STRINGS.okButtonCaption;
    $( '#answer-text' ).setAttribute( 'placeholder', STRINGS.answerLabel );
    $( '#ask-text' ).setAttribute( 'placeholder', STRINGS.questionLabel );
    $( '#cancel-answer-button' ).setAttribute( 'placeholder', STRINGS.addAnswer.cancel );
    $( '#contact-call' ).innerHTML = STRINGS.contact.call;
    $( '#contact-website' ).innerHTML = STRINGS.contact.website;
    $( '#contact-map' ).innerHTML = STRINGS.contact.googleMaps;
    $( '#create-email' ).setAttribute( 'placeholder', STRINGS.emailLabel );
    $( '#create-email-account' ).innerHTML = STRINGS.login.createEmailAccount;
    $( '#create-username' ).setAttribute( 'placeholder', STRINGS.usernameLabel );
    $( '#create-password' ).setAttribute( 'placeholder', STRINGS.passwordLabel );
    $( '#edit-account-caption' ).innerHTML = STRINGS.editAccountCaption;
    $( '#edit-username' ).setAttribute( 'placeholder', STRINGS.edit.usernameCaption );
    $( '#edit-tagline' ).setAttribute( 'placeholder', STRINGS.edit.taglineCaption );
    $( '#edit-region-caption' ).innerHTML = STRINGS.edit.regionCaption;
    $( '#fb-login' ).innerHTML = STRINGS.facebook.authenticatingCaption;
    $( '#location-note' ).setAttribute( 'placeholder', STRINGS.optionalNote );
    $( '#login-username' ).setAttribute( 'placeholder', STRINGS.usernameLabel );
    $( '#login-password' ).setAttribute( 'placeholder', STRINGS.passwordLabel );
    $( '#member-since-caption' ).innerHTML = STRINGS.user.memberSince;
    $( '#message-ok-button' ).innerHTML = STRINGS.okButtonCaption;
    $( '#message-cancel-button' ).innerHTML = STRINGS.cancelButtonCaption;
    $( '#post-facebook-cancel' ).textContent = STRINGS.cancelButtonCaption;
    $( '#post-facebook-ok' ).textContent = STRINGS.facebook.postCaption;
    $( '#post-facebook-message' ).setAttribute( 'placeholder', STRINGS.facebook.postFacebookMessageCaption );
    $( '#question-share-facebook' ).textContent = STRINGS.facebook.postQuestionToFacebook;
    $( '#question-share-twitter' ).textContent = STRINGS.facebook.postQuestionToTwitter;
    $( '#reputation-caption' ).textContent = STRINGS.reputation;
    $( '#save-account' ).textContent = STRINGS.createAccount.saveAccount;
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
    $( '#twitter-login' ).innerHTML = STRINGS.login.twitter;
    $( '#user-id-caption' ).textContent = STRINGS.userIdCaption;

};

function login( event ) {

    if ( event ) { event.preventDefault(); };

    var resource = '/logins/login',
        username = document.getElementById( 'login-username' ).value,
        password = document.getElementById( 'login-password' ).value,
        authorization = window.Crypto.util.bytesToBase64( window.Crypto.charenc.UTF8.stringToBytes( username + ':' + password ) );

    deleteFacebookFrame();
    document.getElementById( 'login-error' ).innerHTML = '';
    document.getElementById( 'login-password' ).value = '';
    document.getElementById( 'login-button' ).focus();

    if ( username && password ) {

        ajax( API_URL + resource, {

            "type": "POST",
            "headers": { "x-authorization": authorization },
            "complete": function ( response, status ) {

                if ( status != "error" ) {

                    var session = response.getResponseHeader( 'x-session' ).split( ':' );

                    _session.id = session[0];
                    _session.key = session[1];
                    window.setLocalStorage( 'sessionId', _session.id );
                    window.setLocalStorage( 'sessionKey', _session.key );

                    getGeolocation( function () {

                        startApp();

                    }, { quick: true } );

                };

            },
            "error": function ( response, status, error ) {

                document.getElementById( 'login-error' ).innerHTML = error;

            }

        } );

    };

};

function initializeFacebook( options ) {

    var login = document.getElementById( 'fb-login' );

    login.innerHTML = STRINGS.facebook.authenticatingCaption;
    login.removeAttribute( 'data-facebook-id' );
    login.removeAttribute( 'data-username' );
    login.removeAttribute( 'data-password' );
    login.removeAttribute( 'data-location' );
    login.removeAttribute( 'data-email' );
    login.disabled = true;
    login.addClass( 'fb-login-disabled' );
    if ( options && options.logout ) { login.setDataset( 'facebook-logout', true ) };

    createFacebookFrame( function ( frame ) {

        frame.contentWindow.postMessage( '{"type": "authorize"}', FACEBOOK_AUTH_URL );

    } );

    window.setTimeout( function () {

        setFacebookButtonUnauthorized();

    }, 15 * SECOND );

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

        if ( window.deviceInfo.phonegap ) {

            window.plugins.childBrowser.showWebPage( FACEBOOK_LOGIN_URL + '?button=login&version=' + _version );

        } else {

            window.location.href = FACEBOOK_LOGIN_URL + '?button=login';

        };

    };

};

function authorizeTwitter( event ) {

    event.preventDefault();

    var resource = '/logins/loginTwitter',
        data = '';

    if ( window.deviceInfo.phonegap ) {

        data = 'returnUrl=' + URL_NOTHING;

    } else {

        data = 'returnUrl=' + TWITTER_RETURN_URL + '/index.html';

    };

    ajax( API_URL + resource, {

        "type": "GET",
        "data": data,
        "success": function ( data, status ) {

            if ( window.deviceInfo.phonegap ) {

                window.plugins.childBrowser.showWebPage( window.JSON.parse( data ).url );

            } else {

                window.location.href = window.JSON.parse( data ).url;

            };

        },
        "error": function ( response, status, error ) {

            document.getElementById( 'login-error' ).innerHTML = error;

        }

    } );

};

function loginTwitter( token ) {

    if ( _currentLocation.latitude ) {

        login();

    } else {

        getGeolocation( function () {

            login();

        }, { quick: true } );

    };

    function login() {

        var resource = '/logins/loginTwitter',
            data = 'oauth_token=' + token;

        ajax( API_URL + resource, {

            "type": "GET",
            "data": data,
            "complete": function ( response, status ) {

                if ( status != "error" ) {

                    var session = response.getResponseHeader( 'x-session' ).split( ':' );

                    _session.id = session[0];
                    _session.key = session[1];
                    window.setLocalStorage( 'sessionId', _session.id );
                    window.setLocalStorage( 'sessionKey', _session.key );

                    startApp();
                    window.history.replaceState( '', '', window.location.pathname );

                };

            },
            "error": function ( response, status, error ) {

                showPage( 'login-page', { logout: true } );
                document.getElementById( 'login-error' ).innerHTML = error;

            }

        } );

    };

};

function logoutApp() {

    window.clearInterval( _questionTimer );
    window.clearInterval( _userQuestionTimer );
    window.clearInterval( _geoTimer );

    _questionTimer = undefined;
    _userQuestionTimer = undefined;
    _geoTimer = undefined;

    window.removeLocalStorage( 'account' );
    window.removeLocalStorage( 'questions' );
    window.removeLocalStorage( 'userQuestions' );
    window.removeLocalStorage( 'nearby-questions' );
    window.removeLocalStorage( 'everywhere-questions' );
    window.removeLocalStorage( 'sessionKey' );
    window.removeLocalStorage( 'sessionId' );

    _account.length = 0;
    _questions.length = 0;
    _userQuestions.length = 0;
    _nearbyQuestions.length = 0;
    _everywhereQuestions.length = 0;
    _session.id = '';
    _session.key = '';

    showPage( 'login-page', { logout: true } );

};

function authorizeFacebook( event ) {

    if ( event.origin == ROOT_URL ) {

        var message = window.JSON.parse( event.data ),
            login = document.getElementById( 'fb-login' );

        switch ( message.type ) {
            case 'authorized':

                if ( login.getDataset( 'facebook-logout' ) ) {

                    login.innerHTML = STRINGS.facebook.loginCaption;
                    login.setDataset( 'facebook-id', message.facebookId );
                    login.setDataset( 'username', message.username );
                    login.setDataset( 'password', message.password );
                    login.setDataset( 'location', message.location );
                    login.setDataset( 'email', message.email );

                    login.disabled = false;
                    login.removeClass( 'fb-login-disabled' );
                    login.setDataset( 'facebook-logout', false )

                } else {

                    loadSessionFacebook( 
                        message.facebookId,
                        message.username,
                        message.password,
                        message.location,
                        message.email
                    );

                };

                break;

            case 'unauthorized':

                setFacebookButtonUnauthorized();
                break;

            case 'not-ready':

                window.setTimeout( function () {

                    var frame = document.getElementById( 'fb-frame' ).contentWindow;
                    frame.postMessage( '{"type":"' + message.retry + '"}', FACEBOOK_AUTH_URL );

                }, 200 );

                break;

        };

    };

};

function setFacebookButtonUnauthorized() {

    var login = document.getElementById( 'fb-login' );

    login.innerHTML = STRINGS.facebook.linkCaption;
    login.disabled = false;
    login.removeClass( 'fb-login-disabled' );

};

function deleteFacebookFrame() {

    var frame = document.getElementById( 'fb-frame' );
    if ( frame ) frame.parentNode.removeChild( frame );

};

function createFacebookFrame( complete ) {

    var html = '<iframe id="fb-frame" class="hide" src="' + FACEBOOK_LOGIN_URL + '"></iframe>';
    document.getElementById( 'login-page' ).insertAdjacentHTML( 'beforeEnd', html );

    document.getElementById( 'fb-frame' ).addEventListener( 'load', function () {

        complete( this );

    }, false );

};

function loadSessionFacebook( facebookId, username, password, location, email ) {

    deleteFacebookFrame();

    if ( _currentLocation.latitude ) {

        loadSession();

    } else {

        getGeolocation( function () {

            loadSession();

        }, { quick: true } );

    };

    function loadSession() {

        var resource = '/logins/loginFB',
            data = 'location=' + location
                + '&email=' + email
                + '&accessToken=' + password,
            authorization = window.Crypto.util.bytesToBase64( 
                window.Crypto.charenc.UTF8.stringToBytes( facebookId + ':' + username + ':' + password ) );

        ajax( API_URL + resource, {

            "type": "GET",
            "headers": { "x-authorization": authorization },
            "data": data,
            "complete": function ( response, status ) {

                if ( status != "error" ) {

                    var session = response.getResponseHeader( 'x-session' ).split( ':' ),
                        newAccount = window.JSON.parse( response.responseText ).newAccount;

                    _session.id = session[0];
                    _session.key = session[1];
                    window.setLocalStorage( 'sessionId', _session.id );
                    window.setLocalStorage( 'sessionKey', _session.key );

                    startApp();

                };

            },
            "error": function ( response, status, error ) {

                document.getElementById( 'login-error' ).innerHTML = error;

            }

        } );

    };

};

function notificationItemClick( event ) {

    selectItem( event );

    window.setTimeout( function () {

        var notificationItem = event.target.closestByClassName( 'notification-item' );

        if ( notificationItem ) {

            saveNotificationViewed( notificationItem );

            switch ( notificationItem.getDataset( 'object' ) ) {
                case 'question':

                    showPage( 'question-page', { id: notificationItem.getDataset( 'item-id' ) } );
                    break;

                case 'badge':

                    showMessage( notificationItem.getElementsByClassName( 'notification-body' )[0].textContent );
                    break;

            };

        };

        window.setTimeout( function () { unselectItem( event ); }, 100 );

    }, 100 );

};

function onContactButtonClick() {

    var contact = document.getElementById( 'contact' );

    if ( contact.hasClass( 'hide' ) ) {

        showContact();

    } else {

        hideContact();

    };

};

function onQuestionShareButtonClick() {

    var question = _pages.last().options.object,
        share = document.getElementById( 'question-share' );

    if ( share.hasClass( 'hide' ) ) {

        showQuestionShare( question[QUESTION_COLUMNS.question] );

    } else {

        hideQuestionShare();

    };

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

function orientationChange() {

    if ( window.innerWidth != window.previousInnerWidth ) {

        window.previousInnerWidth = window.innerWidth;
        initializeDimensions();
        updateScrollAnswers();
        updateScrollQuestions();
        updateScrollTopUsers();
        updateScrollUser();

    };

};

function postToFacebook( type, object, options ) {

    var facebookFrame = createFrame();
    addListeners();
    failSafe();

    function onFrameLoad() {

        sendMessage();

    };

    function sendMessage() {

        var message = '';

        switch( type ) {
            case 'post-feed':

                message =
                      '{'
                    + '"type":"' + type + '",'
                    + '"object":"' + object + '",'
                    + '"message":"' + options.message + '"'
                    + '}';
                break;

            case 'post-open-graph':

                switch ( object ) {
                    case 'comment':

                        message =
                              '{'
                            + '"type":"' + type + '",'
                            + '"object":"' + object + '",'
                            + '"questionId":"' + options.questionId + '",'
                            + '"openGraphId":"' + options.openGraphId + '",'
                            + '"comment":"' + options.comment + '"'
                            + '}';
                        break;

                    case 'question':
                    case 'answer':

                        message =
                              '{'
                            + '"type":"' + type + '",'
                            + '"object":"' + object + '",'
                            + '"value":"' + options.value + '",'
                            + '"id":"' + options.id + '"'
                            + '}';
                        break;

                };
                break;

        };

        facebookFrame.contentWindow.postMessage( message, FACEBOOK_POST_URL );

    };

    function onMessage( event ) {

        if ( event.origin == ROOT_URL ) {

            var message = window.JSON.parse( event.data );

            switch ( message.type ) {
                case 'success':

                    removeListeners();
                    deleteFrame();

                    switch ( message.requestMessage && message.requestMessage.type ) {
                        case 'post-feed':

                            break;

                        case 'post-open-graph':

                            switch ( message.requestMessage.object ) {
                                case 'question':
                                case 'answer':

                                    saveOpenGraphQuestionId( message.requestMessage.id, message.id );
                                    break;

                                case 'comment':

                                    saveOpenGraphResolvedId( message.requestMessage.questionId, message.id );
                                    break;

                            };

                            break;

                    };

                    break;

                case 'error':

                    removeListeners();
                    deleteFrame();
                    break;

                case 'not-ready':

                    window.setTimeout( sendMessage, 200 );
                    break;

            };

        };

    };

    function addListeners() {

        window.addEventListener( 'message', onMessage, false );
        facebookFrame.addEventListener( 'load', onFrameLoad, false );

    };

    function removeListeners() {

        window.removeEventListener( 'message', onMessage, false );
        facebookFrame.removeEventListener( 'load', onFrameLoad, false );

    };

    function createFrame() {

        var html = '<iframe id="facebook-frame" class="hide" src="' + FACEBOOK_POST_URL + '"></iframe>';
        document.body.insertAdjacentHTML( 'beforeEnd', html );
        return document.getElementById( 'facebook-frame' );

    };

    function deleteFrame() {

        facebookFrame.parentNode.removeChild( facebookFrame );
        facebookFrame = undefined;

    };

    function failSafe() {

        //frame load or messaging failed
        window.setTimeout( function () {

            if ( facebookFrame ) {

                removeListeners();
                deleteFrame();

            };

        }, 10 * 1000 );

    };

    function saveOpenGraphQuestionId( questionId, openGraphId ) {

        var resource = '/api/questions/' + questionId + '/opengraph/post',
            data = 'openGraphId=' + openGraphId,
            session = getSession( resource );

        ajax( API_URL + resource, {

            "type": "GET",
            "data": data,
            "headers": { "x-session": session },
            "success": function ( data, status ) {


            },
            "error": function ( response, status, error ) {


            }

        } );

    };

    function saveOpenGraphResolvedId( questionId, openGraphId ) {

        var resource = '/api/questions/' + questionId + '/opengraph/resolve',
            data = 'openGraphId=' + openGraphId,
            session = getSession( resource );

        ajax( API_URL + resource, {

            "type": "GET",
            "data": data,
            "headers": { "x-session": session },
            "success": function ( data, status ) {


            },
            "error": function ( response, status, error ) {


            }

        } );

    };

};

function questionClick( event ) {

    selectItem( event );

    window.setTimeout( function () {

        var question = event.target.closestByClassName( 'question-item' );

        if ( question ) {

            switch ( question.closestByTagName( 'ul' ).id ) {

                case 'questions':
                case 'user-questions':
                case 'nearby-questions':
                case 'everywhere-questions':

                    showPage( 'question-page', { id: question.getDataset( 'id' ) } );
                    break;

                case 'users-questions':

                    showPage( 'question-page', { id: question.getDataset( 'id' ) } );
                    break;

            };

        };

        window.setTimeout( function () { unselectItem( event ); }, 100 );

    }, 100 );

};

function questionItemClick( event ) {

    var questionItem = event.target.closestByClassName( 'question-item' );

    if ( questionItem ) {

        var voteUp = questionItem.getElementsByClassName( 'vote-up-question' ),
            voteDown = questionItem.getElementsByClassName( 'vote-down-question' ),
            question = _pages.last().options.object;

        if ( voteUp.length && !voteUp[0].hasClass( 'hide' ) ) {

            saveQuestionUpvote( question );

        } else if ( voteDown.length && !voteDown[0].hasClass( 'hide' ) ) {

            saveQuestionDownvote( question );

        } else {

            showPage( 'question-map-page' );

        };

    } else if ( event.target.id == 'question-map' ) {

        showPage( 'question-map-page' );

    };

};

function refresh() {

    _questions.length = 0;
    _userQuestions.length = 0;
    _nearbyQuestions.length = 0;
    _everywhereQuestions.length = 0;

    loadUserQuestions();
    loadQuestions();
    loadNearbyQuestions();
    loadEverywhereQuestions();

    showPage( 'questions-page' );

    scrollUp();

};

function refreshQuestions() {

    loadQuestions();
    loadNearbyQuestions();
    loadEverywhereQuestions();

    if ( !_questionTimer ) {

        _questionTimer = window.setInterval( function () {

            _questions.length = 0;
            _nearbyQuestions.length = 0;
            _everywhereQuestions.length = 0;

            loadQuestions();
            loadNearbyQuestions();
            loadEverywhereQuestions();

            loadAccount();

        }, REFRESH_QUESTION_RATE );

    };

};

function refreshUserQuestions() {

    loadUserQuestions();

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

    var backButton,
        questions, 
        answers;

    switch ( page ) {

        case 'answer-page':

            document.getElementById( 'travel-mode-toolbar' ).removeEventListener( 'click', travelModeClick, false );

            backButton = document.getElementById( 'back-button' );
            backButton.removeEventListener( 'click', goBack, false );

            if ( window.deviceInfo.phonegap ) {

                document.removeEventListener( 'menubutton', onContactButtonClick, false );

            };

            if ( window.deviceInfo.mobile ) {

                backButton.removeEventListener( 'touchstart', selectButton, false );
                backButton.removeEventListener( 'touchend', unselectButton, false );

            } else {

                backButton.removeEventListener( 'mousedown', selectButton, false );
                backButton.removeEventListener( 'mouseup', unselectButton, false );

            };

            break;

        case 'login-page':

            var loginButton = document.getElementById( 'login-button' );
            loginButton.removeEventListener( 'click', login, false );

            var facebookButton = document.getElementById( 'fb-login' );
            facebookButton.removeEventListener( 'click', loginFacebook, false );

            var twitterLogin = document.getElementById( 'twitter-login' );
            twitterLogin.removeEventListener( 'click', authorizeTwitter, false );

            var emailButton = document.getElementById( 'create-email-account' );
            emailButton.removeEventListener( 'click', showCreateEmailAccount, false );

            window.removeEventListener( 'message', authorizeFacebook, false );

            if ( window.deviceInfo.mobile ) {

                loginButton.removeEventListener( 'touchstart', selectButton, false );
                loginButton.removeEventListener( 'touchend', unselectButton, false );

                facebookButton.removeEventListener( 'touchstart', selectButton, false );
                facebookButton.removeEventListener( 'touchend', unselectButton, false );

                twitterLogin.removeEventListener( 'touchstart', selectButton, false );
                twitterLogin.removeEventListener( 'touchend', unselectButton, false );

                emailButton.removeEventListener( 'touchstart', selectButton, false );
                emailButton.removeEventListener( 'touchend', unselectButton, false );

            } else {

                loginButton.removeEventListener( 'mousedown', selectButton, false );
                loginButton.removeEventListener( 'mouseup', unselectButton, false );

                facebookButton.removeEventListener( 'mousedown', selectButton, false );
                facebookButton.removeEventListener( 'mouseup', unselectButton, false );

                twitterLogin.removeEventListener( 'mousedown', selectButton, false );
                twitterLogin.removeEventListener( 'mouseup', unselectButton, false );

                emailButton.removeEventListener( 'mousedown', selectButton, false );
                emailButton.removeEventListener( 'mouseup', unselectButton, false );

            };

            break;

        case 'question-page':

            backButton = document.getElementById( 'back-button' );
            backButton.removeEventListener( 'click', goBack, false );

            answers = document.getElementById( 'answers' );
            answers.removeEventListener( 'click', answerClick, false );

            var questionView = document.getElementById( 'question-view' );
            questionView.removeEventListener( 'click', questionItemClick, false );

            document.getElementById( 'question-map' ).removeEventListener( 'click', questionItemClick, false );

            if ( window.deviceInfo.phonegap ) {

                document.removeEventListener( 'menubutton', onQuestionShareButtonClick, false );

            };

            if ( window.deviceInfo.mobile ) {

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

            if ( window.deviceInfo.mobile ) {

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

            var nearbyQuestions = document.getElementById( 'nearby-questions' );
            nearbyQuestions.removeEventListener( 'click', questionClick, false );

            var everywhereQuestions = document.getElementById( 'everywhere-questions' );
            everywhereQuestions.removeEventListener( 'click', questionClick, false );

            var askText = document.getElementById( 'ask-text' );
            askText.removeEventListener( 'focus', showAskButton, false );
            askText.removeEventListener( 'blur', hideAskButton, false );

            var ask = document.getElementById( 'ask' );
            ask.removeEventListener( 'submit', saveQuestion, false );

            if ( window.deviceInfo.mobile ) {

                //ask.removeEventListener( 'touchstart', selectAskText, false );

            } else {

                questions.removeEventListener( 'mouseover', hoverItem, false );
                questions.removeEventListener( 'mouseout', unhoverItem, false );

                userQuestions.removeEventListener( 'mouseover', hoverItem, false );
                userQuestions.removeEventListener( 'mouseout', unhoverItem, false );

                nearbyQuestions.removeEventListener( 'mouseover', hoverItem, false );
                nearbyQuestions.removeEventListener( 'mouseout', unhoverItem, false );

                everywhereQuestions.removeEventListener( 'mouseover', hoverItem, false );
                everywhereQuestions.removeEventListener( 'mouseout', unhoverItem, false );

                //ask.removeEventListener( 'mousedown', selectAskText, false );

            };

            break;

        case 'top-page':

            var topUsers = document.getElementById( 'top-users' );
            topUsers.removeEventListener( 'click', userClick, false );

            var topType = document.getElementById( 'top-type' ),
                topInterval = document.getElementById( 'top-interval' );

            if ( window.deviceInfo.mobile ) {

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

            var notificationItems = document.getElementById( 'user-notifications' );
            notificationItems.removeEventListener( 'click', notificationItemClick, false );

            var reputationItems = document.getElementById( 'user-reputations' );
            reputationItems.removeEventListener( 'click', reputationItemClick, false );

            questions = document.getElementById( 'users-questions' );
            questions.removeEventListener( 'click', questionClick, false );

            answers = document.getElementById( 'user-answers' );
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

            var editAccount = document.getElementById( 'edit-account' );
            editAccount.removeEventListener( 'click', showAccountPage, false );

            if ( window.deviceInfo.phonegap ) {

                document.removeEventListener( 'menubutton', showAccountPage, false );

            };

            if ( window.deviceInfo.mobile ) {

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

                editAccount.removeEventListener( 'touchstart', selectButton, false );
                editAccount.removeEventListener( 'touchend', unselectButton, false );

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

                editAccount.removeEventListener( 'mousedown', selectButton, false );
                editAccount.removeEventListener( 'mouseup', unselectButton, false );

            };

            break;

    };

};

function reputationItemClick( event ) {

    selectItem( event );

    window.setTimeout( function () {

        var reputationItem = event.target.closestByClassName( 'reputation-item' );

        if ( reputationItem ) {

            showPage( 'question-page', { id: reputationItem.getDataset( 'id' ) } );

        };

        window.setTimeout( function () { unselectItem( event ); }, 100 );

    }, 100 );

};

function saveAnswerDownvote( question, answer, answerItem ) {

    var resource = '/api/answers/' + answer[ANSWER_COLUMNS.answerId] + '/downvote',
        session = getSession( resource );

    hideVoteDown();

    ajax( API_URL + resource, {

        "type": "GET",
        "headers": { "x-session": session },
        "success": function ( data, status ) {

            var location = answerItem.getElementsByClassName( 'location-name' )[0],
                voteBox = location.getElementsByClassName( 'votes' )[0],
                voted = answer[ANSWER_COLUMNS.voted],
                vote = ( voted == -1 ? 0 : -1 ),
                currentVotes = answer[ANSWER_COLUMNS.votes],
                newVotes = currentVotes - voted + vote; //downvote

            answer[ANSWER_COLUMNS.votes] = newVotes;
            answer[ANSWER_COLUMNS.voted] = vote;

            if ( newVotes == 0 ) { //remove vote box

                if ( voteBox ) { location.removeChild( voteBox ) };

            } else if ( !voteBox ) { //show vote box

                location.firstChild.insertAdjacentHTML( 'afterEnd', getVotes( newVotes ) );

            } else { //update vote box

                var voteElement = document.createElement( 'div' );
                voteElement.innerHTML = getVotes( newVotes );
                voteBox.parentNode.replaceChild( voteElement.firstChild, voteBox );

            };

            if ( voted != -1 ) { //downvote

                showNotification( STRINGS.notificationDownvote, { tight: true } );

            };

            window.setTimeout( function () {

                showQuestion( question );

            }, 100 );

        },
        "error": function ( response, status, error ) {

            switch ( error ) {

                case 'Unauthorized':

                    logoutApp();
                    break;

                case 'Forbidden':
                case 'Precondition Failed':

                    if ( isMyAnswer( answer ) ) {

                        showMessage( STRINGS.error.voteOnOwnAnswer );

                    };

                    break;

                default:

                    showMessage( STRINGS.error.answerVote );

            };

        }

    } );

};

function saveAnswerUpvote( question, answer, answerItem ) {

    var resource = '/api/answers/' + answer[ANSWER_COLUMNS.answerId] + '/upvote',
        session = getSession( resource );

    hideVoteUp();

    ajax( API_URL + resource, {

        "type": "GET",
        "headers": { "x-session": session },
        "success": function ( data, status ) {

            var location = answerItem.getElementsByClassName( 'location-name' )[0],
                voteBox = location.getElementsByClassName( 'votes' )[0],
                voted = answer[ANSWER_COLUMNS.voted],
                vote = ( voted == 1 ? 0 : 1 ),
                currentVotes = answer[ANSWER_COLUMNS.votes],
                newVotes = currentVotes - voted + vote;

            answer[ANSWER_COLUMNS.votes] = newVotes;
            answer[ANSWER_COLUMNS.voted] = vote;

            if ( newVotes == 0 ) { //remove vote box

                if ( voteBox ) { location.removeChild( voteBox ) };

            } else if ( !voteBox ) { //show vote box

                location.firstChild.insertAdjacentHTML( 'afterEnd', getVotes( newVotes ) );

            } else { //update vote box

                var voteElement = document.createElement( 'div' );
                voteElement.innerHTML = getVotes( newVotes );
                voteBox.parentNode.replaceChild( voteElement.firstChild, voteBox );

            };

            if ( voted != 1 ) { //upvote

                showNotification( STRINGS.notificationUpvote, { tight: true } );

            };

            window.setTimeout( function () {

                showQuestion( question );

            }, 100 );

        },
        "error": function ( response, status, error ) {

            switch ( error ) {

                case 'Unauthorized':

                    logoutApp();
                    break;

                case 'Forbidden':
                case 'Precondition Failed':

                    if ( isMyAnswer( answer ) ) {

                        showMessage( STRINGS.error.voteOnOwnAnswer );

                    };

                    break;

                default:

                    showMessage( STRINGS.error.answerVote );

            };

        }

    } );

};

function saveAnswerSelect( question, answer, answerItem ) {

    var resource = '/api/answers/' + answer[ANSWER_COLUMNS.answerId] + '/select',
        data = 'questionId=' + question.questionId,
        session = getSession( resource );

    hideAnswersSelect();

    ajax( API_URL + resource, {

        "type": "GET",
        "data": data,
        "headers": { "x-session": session },
        "success": function ( data, status ) {

            var location = answerItem.getElementsByClassName( 'location-name' )[0],
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

                if( question[QUESTION_COLUMNS.facebook][FACEBOOK_COLUMNS.openGraphId] ) {

                    postToFacebook(
                        'post-open-graph',
                        'comment',
                        {
                            questionId: question.questionId,
                            openGraphId: question[QUESTION_COLUMNS.facebook][FACEBOOK_COLUMNS.openGraphId],
                            comment: STRINGS.facebook.openGraphComment
                                .replace( '%1', answer[ANSWER_COLUMNS.location] )
                                .replace( '%2', answer[ANSWER_COLUMNS.locationAddress] )

                        } 
                    );

                } else {

                    postToFacebook( 'post-open-graph', 'answer', { value: question[QUESTION_COLUMNS.question], id: question.questionId } );

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

                showQuestion( question );
                if ( questionItem ) showUserQuestions();

            }, 100 );

        },
        "error": function ( response, status, error ) {

            if( error == 'Unauthorized' ) { logoutApp(); };

        }

    } );

};

function saveInstructionViewed( type ) {

    var data = 'type=' + type.name,
        resource = '/api/account/instructions/save',
        session = getSession( resource );

    ajax( API_URL + resource, {

        "type": "GET",
        "data": data,
        "headers": { "x-session": session },
        "success": function ( data, status ) {

            _account[ACCOUNT_COLUMNS.instructions][type.id] = 1; //true 

        },
        "error": function ( response, status, error ) {

            if ( error == 'Unauthorized' ) { logoutApp(); };

        }

    } );

};

function saveNotificationViewed( notificationItem ) {

    var notifications = _account[ACCOUNT_COLUMNS.notifications].items( 0, NOTIFICATION_COLUMNS.viewed ),
        itemId = notificationItem.getDataset( 'item-id' ),
        objectType = notificationItem.getDataset( 'object' ),
        resource = '/api/account/save',
        session = getSession( resource );

    for ( var index = 0; index < notifications.length; index++ ) {

        var notification = notifications[index];

        if ( notification[NOTIFICATION_COLUMNS.itemId] == itemId
            && notification[NOTIFICATION_COLUMNS.objectType] == objectType ) {

            var data = 'userNotificationId=' + notification[NOTIFICATION_COLUMNS.userNotificationId];

            ajax( API_URL + resource, {

                "type": "GET",
                "data": data,
                "headers": { "x-session": session },
                "success": function ( data, status ) {

                    notification[NOTIFICATION_COLUMNS.viewed] = 1; //true
                    var notificationItems = document.getElementById( 'user-notifications' ).getElementsByClassName( 'notification-item' );

                    for ( var index = 0; index < notificationItems.length; index++ ) {

                        if ( notificationItems[index].getDataset( 'item-id' ) == itemId
                            && notificationItems[index].getDataset( 'object' ) == objectType ) {

                            notificationItems[index].addClass( 'hide' );

                        };

                    };

                },
                "error": function ( response, status, error ) {

                    if ( error == 'Unauthorized' ) { logoutApp(); };

                }

            } );

        };

    };

    if ( !_account[ACCOUNT_COLUMNS.notifications].items( 0, NOTIFICATION_COLUMNS.viewed ).length ) {

        document.getElementById( 'user-notifications' ).addClass( 'hide' );

    };

    showNotificationBadge();

};

function saveQuestion( event ) {

    event.preventDefault();

    if ( document.getElementById( 'ask-text' ).value.trim() ) {

        if ( _currentLocation.latitude ) {

            var questionText = document.getElementById( 'ask-text' ).value.trim(),
                latitude = _currentLocation.latitude + getRandomLatitude(),
                longitude = _currentLocation.longitude + getRandomLongitude();

            getRegion( { latitude: latitude, longitude: longitude }, function ( region ) {

                var message = latitude + '~' + longitude + '~' + region + '~' + questionText,
                    resource = '/messaging/questions',
                    session = getSession( resource );

                document.getElementById( 'ask-button' ).focus();
                scrollUp();

                ajax( API_URL + resource, {

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
                        question[QUESTION_COLUMNS.latitude] = latitude;
                        question[QUESTION_COLUMNS.longitude] = longitude;
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

                            questions.insertAdjacentHTML( 'afterBegin', html );

                        } else {

                            questions.firstChild.insertAdjacentHTML( 'afterEnd', html );

                        };

                        _userQuestions.unshift( question );
                        window.setTimeout( function () { questions.childNodes[1].removeClass( 'height-zero' ) }, 50 );
                        showNotification( STRINGS.notificationAskQuestion, { footer: STRINGS.notification.questionSaved } );

                        getNewQuestionId( questionText, function ( questionId ) {

                            postToFacebook( 'post-open-graph', 'question', { value: questionText, id: questionId } );

                        } );

                    },
                    "error": function ( response, status, error ) {

                        error == 'Unauthorized'
                            ? logoutApp()
                            : showMessage( STRINGS.error.saveQuestion + ' ( error: ' + status + ', ' + error + ')' );

                    }

                } );

            } );

        } else {

            getGeolocation();
            showMessage( STRINGS.error.geoNotFound );

        };

    };

};

function saveQuestionDownvote( question ) {

    var resource = '/api/questions/' + question[QUESTION_COLUMNS.questionId] + '/downvote',
        session = getSession( resource );

    hideVoteDown();

    ajax( API_URL + resource, {

        "type": "GET",
        "headers": { "x-session": session },
        "success": function ( data, status ) {

            var body = document.getElementById( 'question-view' ).getElementsByClassName( 'question-item-body' )[0],
                voteBox = body.getElementsByClassName( 'votes' )[0],
                voted = question[QUESTION_COLUMNS.voted],
                currentVotes = question[QUESTION_COLUMNS.votes],
                vote = ( voted == -1 ? 0 : -1 ),
                newVotes = currentVotes - voted + vote; //downvote

            question[QUESTION_COLUMNS.votes] = newVotes;
            question[QUESTION_COLUMNS.voted] = vote;

            if ( newVotes == 0 ) { //remove vote box

                if ( voteBox ) { body.removeChild( voteBox ); };

            } else if ( !voteBox ) { //show vote box

                body.insertAdjacentHTML( 'afterBegin', getVotes( newVotes ) );

            } else { //update vote box

                var voteElement = document.createElement( 'div' );
                voteElement.innerHTML = getVotes( newVotes );
                voteBox.parentNode.replaceChild( voteElement.firstChild, voteBox );

            };

            if ( voted != -1 ) { //downvote

                showNotification( STRINGS.notificationDownvote, { tight: true } );

            };

            window.setTimeout( function () {

                showQuestion( question );

            }, 100 );

        },
        "error": function ( response, status, error ) {

            switch ( error ) {

                case 'Unauthorized':

                    logoutApp();
                    break;

                case 'Forbidden':
                case 'Precondition Failed':

                    if ( isMyQuestion( question ) ) {

                        showMessage( STRINGS.error.voteOnOwnQuestion );

                    };

                    break;

                default:

                    showMessage( STRINGS.error.saveQuestionUpvote );

            };

        }

    } );

};

function saveQuestionUpvote( question ) {

    var resource = '/api/questions/' + question[QUESTION_COLUMNS.questionId] + '/upvote',
        session = getSession( resource );

    hideVoteUp();

    ajax( API_URL + resource, {

        "type": "GET",
        "headers": { "x-session": session },
        "success": function ( data, status ) {

            var body = document.getElementById( 'question-view' ).getElementsByClassName( 'question-item-body' )[0],
                voteBox = body.getElementsByClassName( 'votes' )[0],
                voted = question[QUESTION_COLUMNS.voted],
                currentVotes = question[QUESTION_COLUMNS.votes],
                vote = ( voted == 1 ? 0 : 1 ),
                newVotes = currentVotes - voted + vote; //upvote

            question[QUESTION_COLUMNS.votes] = newVotes;
            question[QUESTION_COLUMNS.voted] = vote;

            if ( newVotes == 0 ) { //remove vote box

                if ( voteBox ) { body.removeChild( voteBox ); };

            } else if ( !voteBox ) { //show vote box

                body.insertAdjacentHTML( 'afterBegin', getVotes( newVotes ) );

            } else { //update vote box

                var voteElement = document.createElement( 'div' );
                voteElement.innerHTML = getVotes( newVotes );
                voteBox.parentNode.replaceChild( voteElement.firstChild, voteBox );

            };

            if ( voted != 1 ) { //upvote

                showNotification( STRINGS.notificationUpvote, { tight: true } );

            };

            window.setTimeout( function () {

                showQuestion( question );

            }, 100 );

        },
        "error": function ( response, status, error ) {

            switch ( error ) {

                case 'Unauthorized':

                    logoutApp();
                    break;

                case 'Forbidden':
                case 'Precondition Failed':

                    if ( isMyQuestion( question ) ) {

                        showMessage( STRINGS.error.voteOnOwnQuestion );

                    };

                    break;

                default:

                    showMessage( STRINGS.error.saveQuestionUpvote );

            };

        }

    } );

};

function scrollUp() {

    switch ( document.getElementById( 'viewport' ).getDataset( 'page' ) ) {
        case 'questions-page':

            if ( window.deviceInfo.iscroll ) {

                _scrollQuestions.scrollToElement( document.getElementById( 'questions-view' ), 700 );

            } else {

                document.getElementById( 'questions-view' ).scrollTop = 0;

            };

            getQuestionsTop();

            break;

        case 'question-page':

            if ( window.deviceInfo.iscroll ) {

                _scrollAnswers.scrollToElement( document.getElementById( 'answers-view' ), 700 );

            } else {

                document.getElementById( 'answers-view' ).scrollTop = 0;

            };

            break;

        case 'top-page':

            if ( window.deviceInfo.iscroll ) {

                _scrollTopUsers.scrollToElement( document.getElementById( 'top-users-view' ), 700 );

            } else {

                document.getElementById( 'top-users-view' ).scrollTop = 0;

            };

            break;

        case 'user-page':

            if ( window.deviceInfo.iscroll ) {

                _scrollUser.scrollToElement( document.getElementById( 'user-info-view' ), 700 );

            } else {

                document.getElementById( 'user-info-view' ).scrollTop = 0;

            };

            getUsersTop();

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

function getNewQuestionId( questionText, complete ) {

    window.setTimeout( function () {

        refreshUserQuestions();

        var interval = window.setInterval( function () {

            var question = _userQuestions.item( questionText, QUESTION_COLUMNS.question );

            if ( question ) {

                window.clearInterval( interval );
                complete( question[QUESTION_COLUMNS.questionId] );

            } else {

                refreshUserQuestions();

            };

        }, REFRESH_NEW_QUESTION_RATE );

    }, 5000 );

};

function setQuestionsTop() {

    var questionsView = document.getElementById( 'questions-view' ),
        top = questionsView.getDataset( 'scroll-top' );

    questionsView.scrollTop = top;

};

function getQuestionsTop() {

    var questionsView = document.getElementById( 'questions-view' ),
        top = questionsView.scrollTop;

    questionsView.setDataset( 'scroll-top', top );

};

function resetQuestionsTop() {

    document.getElementById( 'questions-view' ).setDataset( 'scroll-top', 0 );

};

function getRegion( options, complete ) {

    var geocoder = new google.maps.Geocoder(),
        request;

    if ( options.latitude ) {

        request = { 'latLng': new google.maps.LatLng( options.latitude, options.longitude ) };

    } else {

        request = { 'address': options.address };

    };

    geocoder.geocode( request, function ( results, status ) {

        if ( status == google.maps.GeocoderStatus.OK ) {

            var resultIndex,
                types,
                typeIndex;

            //check top-level results
            for ( resultIndex = 0; resultIndex < results.length; resultIndex++ ) {

                types = results[resultIndex].types;

                for ( typeIndex = 0; typeIndex < types.length; typeIndex++ ) {

                    if ( types[typeIndex] == 'locality' ) {

                        complete( results[resultIndex].formatted_address );
                        return;

                    };

                };

            };

            //no result, check addresses
            for ( resultIndex = 0; resultIndex < results.length; resultIndex++ ) {

                var addresses = results[resultIndex].address_components;

                for ( var addressIndex = 0; addressIndex < addresses.length; addressIndex++ ) {

                    types = addresses[addressIndex].types;

                    for ( typeIndex = 0; typeIndex < types.length; typeIndex++ ) {

                        if ( types[typeIndex] == 'locality' ) {

                            complete( addresses[addressIndex].long_name );
                            return;

                        };

                    };

                };

            };

        } else {

            complete();
            return;

        };

    } );

};

function setUsersTop() {

    var usersView = document.getElementById( 'user-info-view' ),
        top = usersView.getDataset( 'scroll-top' );

    usersView.scrollTop = top;

};

function getUsersTop() {

    var usersView = document.getElementById( 'user-info-view' ),
        top = usersView.scrollTop;

    usersView.setDataset( 'scroll-top', top );

};

function resetUsersTop() {

    document.getElementById( 'user-info-view' ).setDataset( 'scroll-top', 0 );

};

function setupGeolocation() {

    window.setTimeout( getGeolocation, 4 * SECOND );
    _geoTimer = window.setInterval( getGeolocation, 5 * 60 * SECOND ); //every 5 minutes

};

function getGeolocation( geoComplete, options ) {

    var geoFunction = ( ( options && options.quick ) ? get : watch );

    geoFunction( function () {

        getRegion( { latitude: _currentLocation.latitude, longitude: _currentLocation.longitude }, function ( region ) {

            loadCurrentRegion( region );

        } );

        if ( geoComplete ) { geoComplete() };

    } );

    function watch( watchComplete ) {

        var geo = window.navigator.geolocation.watchPosition( function ( position ) {

            _currentLocation.latitude = window.parseFloat( position.coords.latitude );
            _currentLocation.longitude = window.parseFloat( position.coords.longitude );
            _currentLocation.accuracy = position.coords.accuracy;

        },
        function ( error ) {

            if ( window.deviceInfo.mode != 'webview' && !_currentLocation.latitude ) {

                showMessage( STRINGS.error.geoLocation );

            };

        },
        { maximumAge: 60000, enableHighAccuracy: true } ); //must be valid within a minute

        window.setTimeout( function () {

            window.setLocalStorage( 'current-latitude', _currentLocation.latitude ),
            window.setLocalStorage( 'current-longitude', _currentLocation.longitude );

            window.navigator.geolocation.clearWatch( geo );
            watchComplete();

        }, 5 * SECOND );

    };

    function get( getComplete ) {

        var geo = window.navigator.geolocation.getCurrentPosition( function ( position ) {

            _currentLocation.latitude = window.parseFloat( position.coords.latitude );
            _currentLocation.longitude = window.parseFloat( position.coords.longitude );
            _currentLocation.accuracy = position.coords.accuracy;

            window.setLocalStorage( 'current-latitude', _currentLocation.latitude ),
            window.setLocalStorage( 'current-longitude', _currentLocation.longitude );

            getComplete();

        },
        function ( error ) {

            if ( window.deviceInfo.mode != 'webview' && !_currentLocation.latitude ) {

                showMessage( STRINGS.error.geoLocation );

            };

            getComplete();

        },
        { maximumAge: 60000, enableHighAccuracy: true } ); //must be valid within a minute

    };

    function loadCurrentRegion( region ) {

        var resource = '/api/lookups/regions',
            data = 'region=' + region,
            session = getSession( resource );

        ajax( API_URL + resource, {

            "type": "GET",
            "headers": { "x-session": session },
            "data": data,
            "success": function ( data, status ) {

                var regionId = window.JSON.parse( data ).regionId;

                if ( regionId ) {

                    _currentLocation.regionId = regionId;
                    _currentLocation.regionName = region;

                    window.setLocalStorage( 'current-region-id', regionId );
                    window.setLocalStorage( 'current-region-name', region );

                };

            },
            "error": function ( response, status, error ) {

                if ( error == 'Unauthorized' ) { logoutApp(); };

            }

        } );

    };

};

function initializeQuestionObject( question ) {

    window.Object.defineProperty( question, 'questionId', {

        get: function () { return this ? this[QUESTION_COLUMNS.questionId] : undefined }

    } );

    window.Object.defineProperty( question, 'userId', {

        get: function () { return this ? this[QUESTION_COLUMNS.userId] : undefined }

    } );

    window.Object.defineProperty( question, 'resolved', {

        get: function () { return this ? this[QUESTION_COLUMNS.resolved] : undefined },
        set: function ( value ) { this[QUESTION_COLUMNS.resolved] = value }

    } );

    window.Object.defineProperty( question, 'latitude', {

        get: function () { return this ? this[QUESTION_COLUMNS.latitude] : undefined }

    } );

    window.Object.defineProperty( question, 'longitude', {

        get: function () { return this ? this[QUESTION_COLUMNS.longitude] : undefined }

    } );

    question.answered = function ( userId ) {

        for ( var index = 0; index < this[QUESTION_COLUMNS.answers].length; index++ ) {

            if ( userId == this[QUESTION_COLUMNS.answers][index][ANSWER_COLUMNS.userId] ) return true;

        };

    };

    return question;

};

function setTravelMode( travelItem ) {

    var travelItems = document.getElementsByClassName( 'travel-mode-item' );

    for ( var index = 0; index < travelItems.length; index++ ) {

        travelItems[index].removeClass( 'travel-mode-selected' );

    };

    travelItem.addClass( 'travel-mode-selected' );

    var answer = _pages.last().options.object;
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

function loadRegions() {

    var region = document.getElementById( 'edit-region' );

    if ( region.length ) {

        setRegion( region );

    } else {

        var resource = '/api/lookups/regions',
            session = getSession( resource );

        ajax( API_URL + resource, {

            "type": "GET",
            "headers": { "x-session": session },
            "success": function ( data, status ) {

                var regions = window.JSON.parse( data ),
                    options = '<option value="-1">' + STRINGS.edit.regionNone + '</option>';

                for ( var index = 0; index < regions.length; index++ ) {

                    options +=
                            '<option value="' + regions[index][REGION_COLUMNS.id] + '">'
                        + '&nbsp;&nbsp;'.repeat( regions[index][REGION_COLUMNS.level] - 1 )
                        + regions[index][REGION_COLUMNS.name]
                        + '</option>';

                };

                region.innerHTML = options;
                setRegion( region );

            },
            "error": function ( response, status, error ) {

                error == 'Unauthorized'
                    ? logoutApp()
                    : showMessage( STRINGS.error.loadRegions );

            }

        } );

    };

};

function setRegion( region ) {

    if ( _account[ACCOUNT_COLUMNS.regions].length ) {

        for ( var index = 0; index < region.options.length; index++ ) {

            if ( region.options[index].value == _account[ACCOUNT_COLUMNS.regions][0][REGION_COLUMNS.id] ) {

                region.selectedIndex = index;

            };

        };

    } else {

        region.selectedIndex = 0;

    };

};

function showAccountPage() {

    var accountPage = document.getElementById( 'account-page' ),
        account = document.getElementById( 'account' ),
        username = document.getElementById( 'edit-username' ),
        tagline = document.getElementById( 'edit-tagline' ),
        region = document.getElementById( 'edit-region' ),
        save = document.getElementById( 'save-edit' ),
        cancel = document.getElementById( 'account-cancel' ),
        inviteButton = document.getElementById( 'invite' ),
        postButton = document.getElementById( 'post' ),
        logoutButton = document.getElementById( 'logout' ),
        scrollAccount;

    if( accountPage.hasClass( 'hide' ) ) {

        username.value = _account[ACCOUNT_COLUMNS.username];
        tagline.value = _account[ACCOUNT_COLUMNS.tagline];
        loadRegions();

        accountPage.removeClass( 'hide' );
        addEventListeners();

        if ( window.deviceInfo.iscroll ) {

            scrollAccount = new iScroll( 'account-scroll' );

        };

    } else {

        close();

    };

    function close() {

        accountPage.addClass( 'hide' );
        removeEventListeners();

        if ( scrollAccount ) {

            scrollAccount.destroy();
            scrollAccount = null;

        };

    };

    function saveAccount( event ) {

        event.preventDefault();

        var resource = '/api/account/save',
            regionId = region.options[region.selectedIndex].value,
            regionName = region.options[region.selectedIndex].text.trim(),
            data = 'username=' + username.value + '&tagline=' + tagline.value + '&regionId=' + regionId,
            session = getSession( resource );

        ajax( API_URL + resource, {

            "type": "GET",
            "data": data,
            "headers": { "x-session": session },
            "success": function ( data, status ) {

                var newRegion = false;

                _account[ACCOUNT_COLUMNS.username] = username.value;
                _account[ACCOUNT_COLUMNS.tagline] = tagline.value;

                if ( regionId == -1 ) {

                    if ( _account[ACCOUNT_COLUMNS.regions].length ) { newRegion = true; };
                    _account[ACCOUNT_COLUMNS.regions] = [];

                } else {

                    if ( !_account[ACCOUNT_COLUMNS.regions].length
                        || ( _account[ACCOUNT_COLUMNS.regions].length
                        && _account[ACCOUNT_COLUMNS.regions][0][REGION_COLUMNS.id] != regionId ) ) {

                        newRegion = true;

                    };

                    _account[ACCOUNT_COLUMNS.regions] = [[regionId, regionName]];

                };

                close();

                if ( newRegion ) {

                    loadQuestions();
                    loadNearbyQuestions();
                    loadEverywhereQuestions();
                    loadTopUsers();

                };

            },
            "error": function ( response, status, error ) {

                close();

            }

        } );

    };

    function inviteFriends( event ) {

        event.preventDefault();

        if( window.deviceInfo.phonegap ) {

            window.plugins.childBrowser.showWebPage( FACEBOOK_LOGIN_URL + '?button=invite&version=' + _version );

        } else {

            window.location.href = FACEBOOK_LOGIN_URL + '?button=invite';

        };

    };

    function postToWall( event ) {

        event.preventDefault();

        close();
        showPostFacebook();

    };

    function logout( event ) {

        event.preventDefault();

        close();
        logoutApp();

    };

    function iScrollFix( event ) {

        event.stopPropagation();

    };

    function addEventListeners() {

        accountPage.addEventListener( 'close', close, false );
        cancel.addEventListener( 'click', close, false );
        window.addEventListener( 'message', authorizeFacebook, false );

        if ( window.deviceInfo.iscroll ) {

            username.addEventListener( 'touchstart', iScrollFix, false );
            tagline.addEventListener( 'touchstart', iScrollFix, false );
            region.addEventListener( 'touchstart', iScrollFix, false );

        };

        save.addEventListener( 'click', saveAccount, false );
        save.addEventListener( 'touchstart', selectButton, false );
        save.addEventListener( 'touchend', unselectButton, false );
        save.addEventListener( 'mousedown', selectButton, false );
        save.addEventListener( 'mouseup', unselectButton, false );

        inviteButton.addEventListener( 'click', inviteFriends, false );
        inviteButton.addEventListener( 'touchstart', selectButton, false );
        inviteButton.addEventListener( 'touchend', unselectButton, false );
        inviteButton.addEventListener( 'mousedown', selectButton, false );
        inviteButton.addEventListener( 'mouseup', unselectButton, false );

        postButton.addEventListener( 'click', postToWall, false );
        postButton.addEventListener( 'touchstart', selectButton, false );
        postButton.addEventListener( 'touchend', unselectButton, false );
        postButton.addEventListener( 'mousedown', selectButton, false );
        postButton.addEventListener( 'mouseup', unselectButton, false );

        logoutButton.addEventListener( 'click', logout, false );
        logoutButton.addEventListener( 'touchstart', selectButton, false );
        logoutButton.addEventListener( 'touchend', unselectButton, false );
        logoutButton.addEventListener( 'mousedown', selectButton, false );
        logoutButton.addEventListener( 'mouseup', unselectButton, false );

    };

    function removeEventListeners() {

        accountPage.removeEventListener( 'close', close, false );
        cancel.removeEventListener( 'click', close, false );
        window.removeEventListener( 'message', authorizeFacebook, false );

        if ( window.deviceInfo.iscroll ) {

            username.removeEventListener( 'touchstart', iScrollFix, false );
            tagline.removeEventListener( 'touchstart', iScrollFix, false );
            region.removeEventListener( 'touchstart', iScrollFix, false );

        };

        save.removeEventListener( 'click', saveAccount, false );
        save.removeEventListener( 'touchstart', selectButton, false );
        save.removeEventListener( 'touchend', unselectButton, false );
        save.removeEventListener( 'mousedown', selectButton, false );
        save.removeEventListener( 'mouseup', unselectButton, false );

        inviteButton.removeEventListener( 'click', inviteFriends, false );
        inviteButton.removeEventListener( 'touchstart', selectButton, false );
        inviteButton.removeEventListener( 'touchend', unselectButton, false );
        inviteButton.removeEventListener( 'mousedown', selectButton, false );
        inviteButton.removeEventListener( 'mouseup', unselectButton, false );

        postButton.removeEventListener( 'click', postToWall, false );
        postButton.removeEventListener( 'touchstart', selectButton, false );
        postButton.removeEventListener( 'touchend', unselectButton, false );
        postButton.removeEventListener( 'mousedown', selectButton, false );
        postButton.removeEventListener( 'mouseup', unselectButton, false );

        logoutButton.removeEventListener( 'click', logout, false );
        logoutButton.removeEventListener( 'touchstart', selectButton, false );
        logoutButton.removeEventListener( 'touchend', unselectButton, false );
        logoutButton.removeEventListener( 'mousedown', selectButton, false );
        logoutButton.removeEventListener( 'mouseup', unselectButton, false );

    };

};

function showAnswer( answer, question, letter ) {

    var answerId = answer[ANSWER_COLUMNS.answerId],
        mapCanvas = document.getElementById( 'answer-map-canvas' ),
        directions = document.getElementById( 'directions-page' ),
        answerView = document.getElementById( 'answer-view' ),
        view = document.getElementById( 'view' ),
        BORDER = 1,
        MARGIN = 6;

    document.getElementById( 'answer-page' ).setDataset( 'id', answerId );
    answerView.innerHTML = getAnswerItem( answer, question, { letter: letter } );

    var mapCanvasTop = answerView.clientHeight + MARGIN + BORDER + BORDER,
        mapCanvasHeight = view.clientHeight - mapCanvasTop - ( MARGIN + MARGIN + BORDER + BORDER );

    mapCanvas.style.top = mapCanvasTop + 'px';
    mapCanvas.style.height = mapCanvasHeight + 'px';

    directions.style.top = mapCanvasTop + 'px';
    directions.style.height = mapCanvasHeight + 'px';

    setTravelMode( document.getElementById( 'travel-mode-drive' ) );

};

function showAnswerMap( answer, travelMode ) {

    var mapCanvas = document.getElementById( 'answer-map-canvas' ),
        currentLatitude = ( _currentLocation.latitude ? _currentLocation.latitude : answer[ANSWER_COLUMNS.latitude] ),
        currentLongitude = ( _currentLocation.longitude ? _currentLocation.longitude : answer[ANSWER_COLUMNS.longitude] ),
        currentLocation = new google.maps.LatLng( currentLatitude, currentLongitude ),
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

function showAnswersSelect( question ) {

    hideVoteDown();
    hideVoteUp();

    var answers = document.getElementById( 'answers' ).getElementsByClassName( 'select-answer' );

    for ( var index = 0; index < answers.length; index++ ) {

        if ( question[QUESTION_COLUMNS.answers][index][ANSWER_COLUMNS.selected] ) {

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

function showContact() {

    var contact = document.getElementById( 'contact' ),
        call = document.getElementById( 'contact-call' ),
        website = document.getElementById( 'contact-website' ),
        map = document.getElementById( 'contact-map' ),
        answer = _pages.last().options.object,
        currentLatitude = ( _currentLocation.latitude ? _currentLocation.latitude : answer[ANSWER_COLUMNS.latitude] ),
        currentLongitude = ( _currentLocation.longitude ? _currentLocation.longitude : answer[ANSWER_COLUMNS.longitude] ),
        url = 'maps.google.com/?saddr='
            + currentLatitude + ',' + currentLongitude
            + '&daddr=' + answer[ANSWER_COLUMNS.latitude] + ',' + answer[ANSWER_COLUMNS.longitude];

    contact.removeClass( 'hide' );
    window.setTimeout( function () { contact.addClass( 'contact-slide' ); }, 20 );
    addListeners();

    map.href = 'maps://' + url;

    if ( answer[ANSWER_COLUMNS.phone] ) {

        call.href = 'tel:' + answer[ANSWER_COLUMNS.phone];

    } else {

        call.href = '';

    };

    if ( answer[ANSWER_COLUMNS.link] ) {

        website.removeClass( 'hide' );

    } else {

        website.addClass( 'hide' );

    };

    function callLocation( event ) {

        close();

    };

    function viewWebsite() {

        close();

        if ( answer[ANSWER_COLUMNS.link] ) {

            if ( window.deviceInfo.phonegap ) {

                window.plugins.childBrowser.showWebPage( answer[ANSWER_COLUMNS.link] );

            } else {

                var a = document.createElement( 'a' );
                a.setAttribute( 'href', answer[ANSWER_COLUMNS.link] );
                a.setAttribute( 'target', '_blank' );
                var event = document.createEvent( 'HTMLEvents' )
                event.initEvent( 'click', true, true );
                a.dispatchEvent( event );

            };

        };

    };

    function showGoogleMaps( event ) {

        close();

        if ( window.deviceInfo.phonegap && window.deviceInfo.brand != 'ios' ) {

            event.preventDefault();
            window.plugins.childBrowser.showWebPage( 'http://' + url );

        } else if ( !window.deviceInfo.phonegap ) {

            event.preventDefault();
            window.open( 'http://' + url );

            //} else {

            //let click happen

        };

    };

    function close() {

        contact.removeClass( 'contact-slide' );
        window.setTimeout( function () { contact.addClass( 'hide' ); }, 600 );

        removeListeners();

    };

    function addListeners() {

        contact.addEventListener( 'close', close, false );

        call.addEventListener( 'click', callLocation, false );
        call.addEventListener( 'touchstart', selectButton, false );
        call.addEventListener( 'touchend', unselectButton, false );
        call.addEventListener( 'mousedown', selectButton, false );
        call.addEventListener( 'mouseup', unselectButton, false );

        if ( answer[ANSWER_COLUMNS.link] ) {

            website.addEventListener( 'click', viewWebsite, false );
            website.addEventListener( 'touchstart', selectButton, false );
            website.addEventListener( 'touchend', unselectButton, false );
            website.addEventListener( 'mousedown', selectButton, false );
            website.addEventListener( 'mouseup', unselectButton, false );

        };

        map.addEventListener( 'click', showGoogleMaps, false );
        map.addEventListener( 'touchstart', selectButton, false );
        map.addEventListener( 'touchend', unselectButton, false );
        map.addEventListener( 'mousedown', selectButton, false );
        map.addEventListener( 'mouseup', unselectButton, false );

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

function showCreateEmailAccount( event ) {

    event.preventDefault();

    var createAccount = document.getElementById( 'create-account-page' ),
        save = document.getElementById( 'save-account' ),
        cancel = document.getElementById( 'create-account-cancel' );

    createAccount.removeClass( 'hide' );
    addEventListeners();

    function saveAccount( event ) {

        event.preventDefault();

        var username = document.getElementById( 'create-username' ).value,
            password = document.getElementById( 'create-password' ).value,
            email = document.getElementById( 'create-email' ).value;

        if ( username && password && email ) {

            var resource = '/logins/login/add',
                data = 'email=' + email,
                authorization = window.Crypto.util.bytesToBase64( 
                    window.Crypto.charenc.UTF8.stringToBytes( username + ':' + password ) );

            ajax( API_URL + resource, {

                "type": "GET",
                "headers": { "x-authorization": authorization },
                "data": data,
                "complete": function ( response, status ) {

                    if ( status != "error" ) {

                        var session = response.getResponseHeader( 'x-session' ).split( ':' ),
                            username = window.JSON.parse( response.responseText ).username;

                        _session.id = session[0];
                        _session.key = session[1];
                        window.setLocalStorage( 'sessionId', _session.id );
                        window.setLocalStorage( 'sessionKey', _session.key );

                        document.getElementById( 'login-username' ).value = username;
                        document.getElementById( 'login-password' ).value = password;

                        close();

                        getGeolocation( function () {

                            startApp();

                        }, { quick: true } );

                    } else {

                        document.getElementById( 'create-error' ).innerHTML = status;

                    };

                },
                "error": function ( response, status, error ) {

                    document.getElementById( 'create-error' ).innerHTML = error;

                }

            } );

        };

    };

    function close() {

        removeEventListeners();
        createAccount.addClass( 'hide' );

    };

    function addEventListeners() {

        save.addEventListener( 'click', saveAccount, false );
        save.addEventListener( 'touchstart', selectButton, false );
        save.addEventListener( 'touchend', unselectButton, false );
        save.addEventListener( 'mousedown', selectButton, false );
        save.addEventListener( 'mouseup', unselectButton, false );

        cancel.addEventListener( 'click', close, false );
        cancel.addEventListener( 'touchstart', selectButton, false );
        cancel.addEventListener( 'touchend', unselectButton, false );
        cancel.addEventListener( 'mousedown', selectButton, false );
        cancel.addEventListener( 'mouseup', unselectButton, false );

    };

    function removeEventListeners() {

        save.removeEventListener( 'click', saveAccount, false );
        save.removeEventListener( 'touchstart', selectButton, false );
        save.removeEventListener( 'touchend', unselectButton, false );
        save.removeEventListener( 'mousedown', selectButton, false );
        save.removeEventListener( 'mouseup', unselectButton, false );

        cancel.removeEventListener( 'click', close, false );
        cancel.removeEventListener( 'touchstart', selectButton, false );
        cancel.removeEventListener( 'touchend', unselectButton, false );
        cancel.removeEventListener( 'mousedown', selectButton, false );
        cancel.removeEventListener( 'mouseup', unselectButton, false );

    };

};

function showEditAccount() {

    document.getElementById( 'edit-account' ).removeClass( 'hide' );

};

function showInstructions() {

    if ( _account[ACCOUNT_COLUMNS.instructions].unviewed().length ) {

        var type = _account[ACCOUNT_COLUMNS.instructions].unviewed()[0];

        switch ( type ) {
            case INSTRUCTION_TYPES.postQuestion.id:

                if ( !document.getElementById( 'questions-page' ).hasClass( 'hide' ) ) {

                    showInstruction( 
                        STRINGS.instructions.postQuestion,
                        { x: 20, y: 50, from: { x: "left", y: "top"} },
                        { x: 20, from: { x: "left", y: "top"} },
                        { timeout: 6 * SECOND }
                    );

                    window.setTimeout( function () {

                        showAskButton();
                        var text = STRINGS.instructions.postQuestionSend;

                        if ( window.deviceInfo.mobile ) {

                            text = text.replace( '%1', STRINGS.instructions.tap );

                        } else {

                            text = text.replace( '%1', STRINGS.instructions.click );

                        };

                        if ( !document.getElementById( 'questions-page' ).hasClass( 'hide' ) ) {

                            showInstruction( 
                                text,
                                { x: 20, y: 50, from: { x: "right", y: "top"} },
                                { x: 20, from: { x: "right", y: "top"} },
                                { timeout: 6 * SECOND }
                            );

                        };

                    }, 8 * SECOND );

                    saveInstructionViewed( INSTRUCTION_TYPES.postQuestion );

                };

                break;

            case INSTRUCTION_TYPES.viewQuestions.id:

                if ( !document.getElementById( 'questions-page' ).hasClass( 'hide' ) ) {

                    showInstruction( 
                        STRINGS.instructions.viewQuestions,
                        { x: 20, y: 10, from: { x: "left", y: "bottom"} },
                        { x: 20, from: { x: "left", y: "top"} },
                        { timeout: 6 * SECOND }
                    );

                    window.setTimeout( function () {

                        if ( !document.getElementById( 'questions-page' ).hasClass( 'hide' ) ) {

                            showInstruction( 
                                STRINGS.instructions.viewMyQuestions,
                                { x: 20, y: 120, from: { x: "left", y: "top"} },
                                { x: 20, from: { x: "left", y: "top"} },
                                { timeout: 6 * SECOND }
                            );

                        };

                        window.setTimeout( function () {

                            if ( !document.getElementById( 'questions-page' ).hasClass( 'hide' ) ) {

                                var text = STRINGS.instructions.viewQuestion;

                                if ( window.deviceInfo.mobile ) {

                                    text = text.replace( '%1', STRINGS.instructions.tap );

                                } else {

                                    text = text.replace( '%1', STRINGS.instructions.click );

                                };

                                showInstruction( 
                                    text,
                                    { x: 20, y: 10, from: { x: "left", y: "bottom"} },
                                    { x: 20, from: { x: "left", y: "top"} },
                                    { timeout: 6 * SECOND }
                                );

                            };

                        }, 8 * SECOND );

                    }, 8 * SECOND );

                    saveInstructionViewed( INSTRUCTION_TYPES.viewQuestions );

                };

                break;

            case INSTRUCTION_TYPES.viewQuestion.id:

                if ( !document.getElementById( 'question-page' ).hasClass( 'hide' ) ) {

                    showInstruction( 
                        STRINGS.instructions.viewQuestionWho,
                        { x: 20, y: 80, from: { x: "right", y: "top"} },
                        { x: 65, from: { x: "right", y: "top"} },
                        { timeout: 6 * SECOND }
                    );

                    window.setTimeout( function () {

                        if ( !document.getElementById( 'question-page' ).hasClass( 'hide' ) ) {

                            showInstruction( 
                                STRINGS.instructions.viewQuestionWhat,
                                { x: 20, y: 80, from: { x: "left", y: "top"} },
                                { x: 125, from: { x: "left", y: "top"} },
                                { timeout: 6 * SECOND }
                            );

                        };

                        window.setTimeout( function () {

                            if ( !document.getElementById( 'question-page' ).hasClass( 'hide' ) ) {

                                showInstruction( 
                                    STRINGS.instructions.viewQuestionWhere,
                                    { x: 20, y: 20, from: { x: "left", y: "top"} },
                                    { x: 125, from: { x: "left", y: "bottom"} },
                                    { timeout: 6 * SECOND }
                                );

                            };

                        }, 8 * SECOND );

                    }, 8 * SECOND );

                    saveInstructionViewed( INSTRUCTION_TYPES.viewQuestion );

                };

                break;

            case INSTRUCTION_TYPES.addAnswer.id:

                if ( !document.getElementById( 'question-page' ).hasClass( 'hide' ) ) {

                    showInstruction( 
                        STRINGS.instructions.viewAnswer,
                        { x: 20, y: 10, from: { x: "left", y: "bottom"} },
                        { x: 20, from: { x: "left", y: "top"} },
                        { timeout: 6 * SECOND }
                    );

                    window.setTimeout( function () {

                        if ( !document.getElementById( 'question-page' ).hasClass( 'hide' ) ) {

                            var text = STRINGS.instructions.addAnswer;

                            if ( window.deviceInfo.mobile ) {

                                text = text.replace( '%1', STRINGS.instructions.tap );

                            } else {

                                text = text.replace( '%1', STRINGS.instructions.click );

                            };

                            showInstruction( 
                                text,
                                { y: 30, from: { x: "center", y: "bottom"} },
                                { x: 5, from: { x: "left", y: "bottom"} },
                                { timeout: 6 * SECOND }
                            );

                        };

                    }, 8 * SECOND );

                    saveInstructionViewed( INSTRUCTION_TYPES.addAnswer );

                };

                break;

            case INSTRUCTION_TYPES.toolbar.id:

                if ( !document.getElementById( 'questions-page' ).hasClass( 'hide' )
                    || !document.getElementById( 'top-page' ).hasClass( 'hide' )
                    || !document.getElementById( 'user-page' ).hasClass( 'hide' ) ) {

                    var text = STRINGS.instructions.toolbarQuestions;

                    if ( window.deviceInfo.mobile ) {

                        text = text.replace( '%1', STRINGS.instructions.tap );

                    } else {

                        text = text.replace( '%1', STRINGS.instructions.click );

                    };

                    showInstruction( 
                        text,
                        { y: 30, from: { x: "center", y: "bottom"} },
                        { x: 53, from: { x: "left", y: "bottom"} },
                        { timeout: 6 * SECOND }
                    );

                    window.setTimeout( function () {

                        var text = STRINGS.instructions.toolbarTop;

                        if ( window.deviceInfo.mobile ) {

                            text = text.replace( '%1', STRINGS.instructions.tap );

                        } else {

                            text = text.replace( '%1', STRINGS.instructions.click );

                        };

                        showInstruction( 
                            text,
                            { y: 30, from: { x: "center", y: "bottom"} },
                            { x: 130, from: { x: "left", y: "bottom"} },
                            { timeout: 6 * SECOND }
                        );

                        window.setTimeout( function () {

                            var text = STRINGS.instructions.toolbarUser;

                            if ( window.deviceInfo.mobile ) {

                                text = text.replace( '%1', STRINGS.instructions.tap );

                            } else {

                                text = text.replace( '%1', STRINGS.instructions.click );

                            };

                            showInstruction( 
                                text,
                                { y: 30, from: { x: "center", y: "bottom"} },
                                { x: 205, from: { x: "left", y: "bottom"} },
                                { timeout: 6 * SECOND }
                            );

                        }, 8 * SECOND );

                    }, 8 * SECOND );

                    saveInstructionViewed( INSTRUCTION_TYPES.toolbar );

                };

                break;

        };

    };

    if ( _account[ACCOUNT_COLUMNS.instructions].unviewed().length ) {

        window.setTimeout( function () {

            showInstructions();

        }, INSTRUCTION_RATE );

    };

};

function showInstruction( text, position, bubble, options ) {

    var instructions = document.getElementById( 'instructions' );
    options = options || {};

    switch ( position.from.y ) {
        case 'top':

            instructions.style.top = position.y + 'px';
            instructions.style.bottom = '';

            break;

        case 'bottom':

            instructions.style.top = '';
            instructions.style.bottom = position.y + 'px';

            break;

    };

    switch ( position.from.x ) {
        case 'left':

            instructions.style.left = position.x + 'px';
            instructions.style.right = '';

            break;

        case 'right':

            instructions.style.left = '';
            instructions.style.right = position.x + 'px';

            break;

        case 'center':

            var view = document.getElementById( 'view' );

            instructions.style.left = ( ( view.clientWidth - 280 ) / 2 ) + 'px';
            instructions.style.right = '';

            break;

    };

    switch ( bubble.from.y ) {
        case 'top':

            instructions.addClass( 'instructions-top' );
            instructions.removeClass( 'instructions-bottom' );

            break;

        case 'bottom':

            instructions.addClass( 'instructions-bottom' );
            instructions.removeClass( 'instructions-top' );

            break;

    };

    var style = '<style id="instruction-styles">'
        + '#instructions::before {'
        + bubble.from.x + ':' + bubble.x + 'px;'
        + '}'
        + '</style>';
    instructions.insertAdjacentHTML( 'afterEnd', style );

    instructions.innerHTML = text;
    instructions.removeClass( 'hide' );
    window.setTimeout( function () { instructions.removeClass( 'fade' ); }, 10 );
    if ( options.timeout ) { window.setTimeout( function () { close(); }, options.timeout ); };
    addEventListeners();

    function close() {

        removeEventListeners();

        if ( !instructions.hasClass( 'fade' ) ) {

            instructions.addClass( 'fade' );
            window.setTimeout( function () {

                instructions.addClass( 'hide' );
                var styles = document.getElementById( 'instruction-styles' );
                styles.parentNode.removeChild( styles );

            }, 1000 );

        };

    };

    function addEventListeners() {

        instructions.addEventListener( 'close', close, false );
        instructions.addEventListener( 'click', close, false );

    };

    function removeEventListeners() {

        instructions.removeEventListener( 'close', close, false );
        instructions.removeEventListener( 'click', close, false );

    };

};

function showLoading( top, left, element ) {

    var loading = document.getElementById( 'loading' ),
        offsetLeft = 0,
        offsetTop = 0;

    if ( element ) {

        offsetLeft = element.offsetLeft;
        offsetTop = element.offsetTop;

    } else {

        element = document.getElementById( 'view' );

    };

    loading.removeClass( 'hide' );

    switch ( top ) {
        case 'center':

            top = Math.round( ( element.clientHeight - loading.clientHeight ) / 2 );
            break;

    };

    switch ( left ) {
        case 'center':

            left = Math.round( ( element.clientWidth - loading.clientWidth ) / 2 );
            break;

    };

    left += offsetLeft;
    top += offsetTop;

    loading.style.top = top + 'px';
    loading.style.left = left + 'px';

};

function showMessage( text, callback ) {

    var message = document.getElementById( 'message' ),
        body = document.getElementById( 'message-body' ),
        okButton = document.getElementById( 'message-ok-button' ),
        cancelButton = document.getElementById( 'message-cancel-button' ),
        view = document.getElementById( 'view' );

    body.innerHTML = text;
    message.removeClass( 'hide' );
    message.style.top = ( ( view.clientHeight - message.clientHeight ) / 2 ) + 'px';
    message.style.left = ( ( view.clientWidth - message.clientWidth ) / 2 ) + 'px';

    if ( callback ) {

        cancelButton.removeClass( 'hide' );

    } else {

        cancelButton.addClass( 'hide' );

    };

    window.setTimeout( function () { message.removeClass( 'fade' ); }, 50 );
    addEventListeners();

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

    function addEventListeners() {

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

    };

};

function showNotification( notice, options ) {

    options = options || {};

    var notification = document.getElementById( 'notification' ),
        body = document.getElementById( 'notification-body' ),
        footer = document.getElementById( 'notification-footer' ),
        view = document.getElementById( 'view' );

    options.tight ? notification.addClass( 'notification-tight' ) : notification.removeClass( 'notification-tight' );

    body.removeClass( 'notification-small' );
    body.removeClass( 'notification-tiny' );

    switch ( options.size ) {
        case 'tiny':

            body.addClass( 'notification-tiny' );
            break;

        case 'small':

            body.addClass( 'notification-small' );
            break;

    };

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

    notification.addEventListener( 'click', close, false );
    notification.removeClass( 'hide' );
    notification.style.top = ( ( view.clientHeight - notification.clientHeight ) / 2 ) + 'px';
    notification.style.left = ( ( view.clientWidth - notification.clientWidth ) / 2 ) + 'px';
    window.setTimeout( function () { notification.removeClass( 'fade' ); }, 50 );
    window.setTimeout( function () { close(); }, 3000 );

    function close() {

        notification.removeEventListener( 'click', close, false );

        if ( !notification.hasClass( 'fade' ) ) {

            notification.addClass( 'fade' );
            window.setTimeout( function () { notification.addClass( 'hide' ); }, 1000 );

        };

    };

};

function showNotifications( newItems ) {

    var notifications = _account[ACCOUNT_COLUMNS.notifications].items( 0, NOTIFICATION_COLUMNS.viewed );

    if ( notifications.length ) {

        var html = getListItemHeader( STRINGS.user.notifications );

        for ( var index = 0; index < notifications.length; index++ ) {

            html += getNotificationItem( notifications[index] );

        };

        document.getElementById( 'user-notifications' ).innerHTML = html;
        document.getElementById( 'user-notifications' ).removeClass( 'hide' );

        if ( newItems && window.deviceInfo.phonegap ) {

            window.navigator.notification.vibrate( SECOND )

        };

    } else {

        document.getElementById( 'user-notifications' ).addClass( 'hide' );

    };

    showNotificationBadge();

};

function showNotificationBadge() {

    var count = _account[ACCOUNT_COLUMNS.notifications].items( 0, NOTIFICATION_COLUMNS.viewed ).length,
        badge = document.getElementById( 'notification-badge' );

    if ( count ) {

        badge.textContent = count;
        badge.removeClass( 'hide' );

    } else {

        badge.addClass( 'hide' );

    };

};

function showPage( page, options, back ) {

    options = options || {};

    var viewport = document.getElementById( 'viewport' ),
        previousPage = viewport.getDataset( 'page' ),
        answer,
        question;

    viewport.setDataset( 'page', page );
    addEventListeners( page, previousPage );
    hideLoading();
    hideInstructions();

    switch ( page ) {

        case 'answer-page':

            if ( back ) {

                options = _pages.last().options;
                answer = options.object;
                question = options.question;

            } else {

                answer = options.object;
                question = options.question;

                _pages.add( 
                    page,
                    {
                        id: options.id,
                        object: answer,
                        question: question,
                        caption: STRINGS.backButtonAnswer,
                        answerLetter: options.answerLetter
                    }
                );

            };

            slidePage( page, previousPage );
            showAnswer( answer, question, options.answerLetter );

            hideContact();
            setView( 'normal' );
            initializeBackButton();
            document.getElementById( 'directions-page' ).addClass( 'top-slide' );
            showToolbar( 'answer', { question: question, answer: answer } );

            break;

        case 'login-page':

            _pages.clear();

            slidePage( page, previousPage );
            setView( 'header' );
            initializeBackButton();
            hideRefreshButton();
            initializeFacebook( options );

            break;

        case 'question-page':

            if ( back ) {

                options = _pages.last().options;
                question = options.object;

                showQuestion( question );
                initializeQuestionPage( question, page, previousPage );

            } else {

                loadQuestion( options.id, function ( question ) {

                    _pages.add( page, { id: options.id, object: question, caption: STRINGS.backButtonQuestion } );
                    initializeQuestionPage( question, page, previousPage );

                } );

            };

            break;

        case 'question-map-page':

            _pages.add( page, {} );

            showQuestionMapFull();

            setView( 'normal' );
            initializeBackButton();
            showToolbar( 'main' );

            slidePage( page, previousPage );

            break;

        case 'top-page':

            showTopUsers( _currentLocation.regionName );

            _pages.replace( page, { caption: STRINGS.backButtonTopUsers } );
            
            hideAccountPage();
            resetQuestionsTop();
            resetUsersTop();
            setView( 'normal' );
            initializeBackButton();
            showToolbar( 'main' );

            slidePage( page, previousPage );
            updateScrollTopUsers();

            break;

        case 'user-page':

            if ( back ) {

                options = _pages.last().options;
                var user = options.object;

                showUser( user );
                initializeUserPage( user, page, previousPage );

            } else {

                loadUser( options.id, function ( user ) {

                    if ( options.top ) {

                        _pages.replace( page, { id: options.id, object: user, caption: STRINGS.backButtonUser } );

                    } else {

                        _pages.add( page, { id: options.id, object: user, caption: STRINGS.backButtonUser } );

                    };

                    initializeUserPage( user, page, previousPage );

                } );

            };

            break;

        case 'questions-page':
        default:

            _pages.replace( page, { caption: STRINGS.backButtonQuestions } )

            slidePage( page, previousPage );

            window.setTimeout( function () {

                hideAccountPage();
                resetUsersTop();
                setQuestionsTop();
                setView( 'normal' );
                initializeBackButton();
                showToolbar( 'main' );
                updateScrollQuestions();

            }, 10 );

            break;

    };

};

function initializeQuestionPage( question, page, previousPage ) {

    getQuestionsTop();
    getUsersTop();
    hideQuestionShare()
    setView( 'normal' );
    initializeBackButton();
    showToolbar( 'question', { question: question } );

    slidePage( page, previousPage );
    updateScrollQuestions();

};

function initializeUserPage( user, page, previousPage ) {

    slidePage( page, previousPage );

    resetQuestionsTop();
    setUsersTop();

    setView( 'normal' );
    showToolbar( 'main' );
    initializeBackButton();

    if ( isMe( user ) ) {

        showEditAccount();

    } else {

        hideEditAccount();
        document.getElementById( 'user-notifications' ).addClass( 'hide' );

    };

};

function showPostFacebook() {

    var postFacebookPage = document.getElementById( 'post-facebook-page' ),
        postFacebook = document.getElementById( 'post-facebook' ),
        message = document.getElementById( 'post-facebook-message' ),
        ok = document.getElementById( 'post-facebook-ok' ),
        cancel = document.getElementById( 'post-facebook-cancel' );

    message.value = '';
    postFacebookPage.removeClass( 'hide' );
    window.setTimeout( function () { postFacebookPage.removeClass( 'fade' ); }, 50 );
    message.focus();

    addListeners();

    function okClick( event ) {

        event.preventDefault();
        ok.focus();
        removeListeners();

        postFacebookPage.addClass( 'fade' );
        window.setTimeout( function () { postFacebookPage.addClass( 'hide' ); }, 1000 );

        postToFacebook( 'post-feed', 'app', { message: message.value } );
        showNotification( STRINGS.notification.postedToFacebook, { size: 'tiny' } );

    };

    function cancelClick( event ) {

        event.preventDefault();
        cancel.focus();
        removeListeners();

        postFacebookPage.addClass( 'fade' );
        window.setTimeout( function () { postFacebookPage.addClass( 'hide' ); }, 1000 );

    };

    function removeListeners() {

        postFacebook.removeEventListener( 'submit', okClick, false );
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

        postFacebook.addEventListener( 'submit', okClick, false );
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

function showQuestion( question ) {

    var markers = '',
        html = '',
        zoom = '',
        MARGIN = 6,
        BORDER = 1,
        view = document.getElementById( 'view' ),
        questionView = document.getElementById( 'question-view' ),
        answersView = document.getElementById( 'answers-view' ),
        answers = document.getElementById( 'answers' ),
        noAnswers = document.getElementById( 'no-answers' ),
        questionMap = document.getElementById( 'question-map' );

    if ( question[QUESTION_COLUMNS.question].length > 25 ) {

        questionView.innerHTML = getQuestionItem( question, { full: true } );
        questionView.removeClass( 'question-view-normal' ).addClass( 'question-view-full' );

    } else {

        questionView.innerHTML = getQuestionItem( question );
        questionView.removeClass( 'question-view-full' ).addClass( 'question-view-normal' );

    };

    window.setTimeout( function () {

        var answersViewTop = questionView.clientHeight + questionMap.clientHeight + ( 3 * MARGIN ) + ( 4 * BORDER ),
            answersViewHeight = view.clientHeight - answersViewTop + MARGIN;

        answersView.style.top = answersViewTop + 'px';
        answersView.style.height = answersViewHeight + 'px';

    }, 10 );

    if ( question[QUESTION_COLUMNS.answers].length ) {

        answers.removeClass( 'hide' );
        noAnswers.addClass( 'hide' );

        for ( var index = 0; index < question[QUESTION_COLUMNS.answers].length; index++ ) {

            var answer = question[QUESTION_COLUMNS.answers][index],
                letter = STRINGS.letters.charAt( index );

            markers += '&markers=color:gray|size:mid|label:' + letter + '|'
                + answer[ANSWER_COLUMNS.latitude] + "," + answer[ANSWER_COLUMNS.longitude];
            html += getAnswerItem( answer, question, { letter: letter } );

        };

    } else {

        if ( isMyQuestion( question ) ) {

            $( '#no-answers' ).innerHTML = STRINGS.answer.noAnswersMyQuestion;

        } else {

            $( '#no-answers' ).innerHTML = STRINGS.answer.noAnswers;

        };

        answers.addClass( 'hide' );
        noAnswers.removeClass( 'hide' );
        zoom = '&zoom=12';

    };

    answers.innerHTML = html;
    updateScrollAnswers();

    var mapUrl = 'http://maps.google.com/maps/api/staticmap?center='
            + question.latitude + ',' + question.longitude
            + '&size=' + _dimensions.questionMapWidth + 'x140'
            + ( window.deviceInfo.mobile ? '&scale=2' : '' )
            + '&maptype=roadmap&sensor=true&style=hue:blue' + zoom + '&markers=color:black|size:mid|'
            + question.latitude + ',' + question.longitude
            + markers;
    questionMap.setAttribute( 'src', mapUrl );

};

function showQuestionMapFull() {

    var mapUrl = document.getElementById( 'question-map' ).getAttribute( 'src' ),
        start = mapUrl.indexOf( 'size=' ) + 5,
        end = mapUrl.indexOf( '&', start ),
        size = mapUrl.substring( start, end );

    mapUrl = mapUrl.replace( size, _dimensions.questionMapFullWidth + 'x' + _dimensions.questionMapFullHeight );
    document.getElementById( 'question-map-full' ).setAttribute( 'src', mapUrl );

};

function showQuestions( header, questions, element ) {

    var html = '';

    if ( questions.length ) {

        html += getListItemHeader( header );

        for ( var index = 0; index < questions.length; index++ ) {

            html += getQuestionItem( questions[index] );

        };

        element.removeClass( 'hide' );

    } else {

        element.addClass( 'hide' );

    };

    element.innerHTML = html;
    updateScrollQuestions();

};

function showQuestionShare( question ) {

    var share = document.getElementById( 'question-share' ),
        facebook = document.getElementById( 'question-share-facebook' ),
        twitter = document.getElementById( 'question-share-twitter' );

    share.removeClass( 'hide' );
    window.setTimeout( function () { share.addClass( 'question-share-slide' ); }, 20 );

    addListeners();

    function postFacebook() {

        close();

        postToFacebook( 'post-feed', 'question', { message: window.encodeURIComponent( question ) } );
        showNotification( STRINGS.notification.postedToFacebook, { size: 'tiny' } );

    };

    function postToTwitter() {

        close();

        var url = 'https://twitter.com/share'
                + '?text=' + window.encodeURIComponent( 'Can you help me find: ' + question + ' @ ' )
                + '&url=' + window.encodeURIComponent( 'http://urbanAsk.com' )
                + '&hashtags=' + window.encodeURIComponent( 'urbanask' );

        if ( window.deviceInfo.phonegap ) {

            window.plugins.childBrowser.showWebPage( url );

        } else {

            var a = document.createElement( 'a' );
            a.setAttribute( 'href', url );
            a.setAttribute( 'target', '_blank' );
            var event = document.createEvent( 'HTMLEvents' )
            event.initEvent( 'click', true, true );
            a.dispatchEvent( event );

        };

    };

    function close() {

        share.removeClass( 'question-share-slide' );
        window.setTimeout( function () { share.addClass( 'hide' ); }, 600 );

        removeListeners();

    };

    function removeListeners() {

        share.removeEventListener( 'close', close, false );

        facebook.removeEventListener( 'click', postFacebook, false );
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

    function addListeners() {

        share.addEventListener( 'close', close, false );

        facebook.addEventListener( 'click', postFacebook, false );
        facebook.addEventListener( 'touchstart', selectButton, false );
        facebook.addEventListener( 'touchend', unselectButton, false );
        facebook.addEventListener( 'mousedown', selectButton, false );
        facebook.addEventListener( 'mouseup', unselectButton, false );

        twitter.addEventListener( 'click', postToTwitter, false );
        twitter.addEventListener( 'touchstart', selectButton, false );
        twitter.addEventListener( 'touchend', unselectButton, false );
        twitter.addEventListener( 'mousedown', selectButton, false );
        twitter.addEventListener( 'mouseup', unselectButton, false );

    };

};

function showSocialButtons() {

    if ( !window.deviceInfo.mobile ) {

        var html =
                    '<div id="social-buttons" class="fadeable fade">'
                + '<div class="fb-like" data-href="http://urbanAsk.com" data-send="true" data-layout="box_count" data-width="50" data-show-faces="true" data-colorscheme="dark"></div>'
                + '<div class="g-plusone-frame"><div class="g-plusone" data-size="tall" data-href="http://urbanAsk.com"></div></div>'
                + '<a href="https://twitter.com/share" class="twitter-share-button" data-url="http://urbanAsk.com" data-text="urbanAsk - The addicting game of helping people find things." data-count="vertical">Tweet</a>'
                + '<div id="fb-root"></div>'
                + '</div>';

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

        }, 4000 );

    };

};

function showExternalFooter() {

    if ( !window.deviceInfo.mobile ) {

        var html = '<div id="external-footer" class="fadeable fade">'
                + STRINGS.externalFooter
                + '<a class="external-footer-link" href="download.html">'
                + '<img class="external-footer-image" src="images/apple.png" alt="apple" />' + STRINGS.iphone + '</a>'
                + '<a class="external-footer-link" href="download.html">'
                + '<img class="external-footer-image" src="images/android.png" alt="android" />' + STRINGS.android + '</a>'
                + '</div>';

        document.getElementById( 'viewport' ).insertAdjacentHTML( 'afterEnd', html );

        window.setTimeout( function () {

            document.getElementById( 'external-footer' ).removeClass( 'fade' );

        }, 4000 );

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
            document.getElementById( 'toolbar-question' ).addClass( 'hide' );

            document.getElementById( 'user-button' ).setDataset( 'user-id', _account[ACCOUNT_COLUMNS.userId] );

            break;

        case 'answer':

            document.getElementById( 'toolbar-answer' ).removeClass( 'hide' );
            document.getElementById( 'toolbar-main' ).addClass( 'hide' );
            document.getElementById( 'toolbar-question' ).addClass( 'hide' );

            if ( isMyQuestion( options.question ) ) {

                document.getElementById( 'select-answer-button' ).removeClass( 'hide' );

            } else {

                document.getElementById( 'select-answer-button' ).addClass( 'hide' );

            };

            //                    if ( isMyAnswer( options.answer ) ) {

            //                        document.getElementById( 'delete-answer-button' ).removeClass( 'hide' );

            //                    } else {

            //                        document.getElementById( 'delete-answer-button' ).addClass( 'hide' );

            //                    };

            document.getElementById( 'answer-user-button' ).setDataset( 'user-id', options.answer[ANSWER_COLUMNS.userId] );

            break;

        case 'question':

            var question = options.question;

            document.getElementById( 'toolbar-question' ).removeClass( 'hide' );
            document.getElementById( 'toolbar-answer' ).addClass( 'hide' );
            document.getElementById( 'toolbar-main' ).addClass( 'hide' );

            if ( isMyQuestion( options.question ) ) {

                document.getElementById( 'select-answers-button' ).removeClass( 'hide' );
                document.getElementById( 'question-share-button' ).removeClass( 'hide' );

                document.getElementById( 'add-answer-button' ).addClass( 'hide' );
                document.getElementById( 'question-user-button' ).addClass( 'hide' );

            } else {

                document.getElementById( 'add-answer-button' ).removeClass( 'hide' );
                document.getElementById( 'question-user-button' ).removeClass( 'hide' );

                document.getElementById( 'select-answers-button' ).addClass( 'hide' );
                document.getElementById( 'question-share-button' ).addClass( 'hide' );

                disabled = question.answered( _account[ACCOUNT_COLUMNS.userId] );
                button = document.getElementById( 'add-answer-button' );
                disabled ? button.addClass( 'disabled' ) : button.removeClass( 'disabled' );
                button.setDataset( 'question-id', question.questionId );

                document.getElementById( 'question-user-button' ).setDataset( 'user-id', question.userId );

            };

            break;

    };

};

function showTopUsers( header ) {

    var noTopUsers = document.getElementById( 'no-top-users' ),
        topUsers = document.getElementById( 'top-users' );

    if ( _cache.topUsers.refreshed ) {

        var topTypeId = window.parseInt( document.getElementById( 'top-type' ).getDataset( 'id' ) ),
            intervalId = window.parseInt( document.getElementById( 'top-interval' ).getDataset( 'id' ) ),
            html = '';

        scrollUp();

        for ( var index = 0, rank = 0; index < _cache.topUsers.length(); index++ ) {

            if ( _cache.topUsers.data[index][TOP_USER_COLUMNS.topTypeId] == topTypeId
                && _cache.topUsers.data[index][TOP_USER_COLUMNS.intervalId] == intervalId ) {

                rank++;
                html += getTopUserItem( topTypeId, _cache.topUsers.data[index], rank );

            };

        };

        if ( html.length ) {

            topUsers.innerHTML = getListItemHeader( header ) + html;

            noTopUsers.addClass( 'hide' );
            topUsers.removeClass( 'hide' );

        } else {

            topUsers.innerHTML = '';

            noTopUsers.innerHTML = STRINGS.topUsers.noTopUsers
                .replace( "%1", STRINGS.topUsers.noTopUsersType[topTypeId - 1] )
                .replace( "%2", STRINGS.topUsers.noTopUsersInterval[intervalId] );
            noTopUsers.removeClass( 'hide' );
            topUsers.addClass( 'hide' );

        };

        updateScrollTopUsers();

        window.setTimeout( function () {

            if ( _cache.topUsers.isExpired() ) { loadTopUsers(); };

        }, 1500 );

    } else {

        noTopUsers.innerHTML = STRINGS.topUsers.loading;
        noTopUsers.removeClass( 'hide' );
        topUsers.addClass( 'hide' );

        loadTopUsers();

    };

};

function showUser( user ) {

    showLoading( 'center', 'center' );

    $( '#username' ).textContent = user[USER_COLUMNS.username];

    var memberSince = document.getElementById( 'member-since' ),
        userIdCaption = document.getElementById( 'user-id-caption' ),
        userIdValue = document.getElementById( 'user-id-value' );

    memberSince.textContent = getMemberSince( user );

    if ( user[USER_COLUMNS.userId] > 143400 && user[USER_COLUMNS.userId] < 147494 ) {

        userIdCaption.addClass( 'hide' );
        userIdValue.addClass( 'hide' );

    } else {

        userIdValue.textContent = user[USER_COLUMNS.userId];

        userIdCaption.removeClass( 'hide' );
        userIdValue.removeClass( 'hide' );

    };

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

    showNotifications();

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

            html += getAnswerItem( user[USER_COLUMNS.answers][index], [], { newItem: false, questionId: true } );

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

    document.getElementById( 'signup-info' ).removeClass( 'hide' );
    $( '#user-reputations' ).removeClass( 'hide' );
    $( '#users-questions' ).removeClass( 'hide' );
    $( '#user-answers' ).removeClass( 'hide' );
    $( '#user-badges' ).removeClass( 'hide' );

    updateScrollUser();
    setUsersTop();

    window.setTimeout( function () {

        var resource = '/api/users/' + user[USER_COLUMNS.userId] + '/picture';
        $( '#user-picture' ).src = API_URL + resource + '?x-session=' + getSession( resource );
        hideLoading();

    }, 50 );

};

function showVoteDown( question ) {

    var questionVote = document.getElementById( 'question-view' ).getElementsByClassName( 'vote-down-question' )[0],
        answers = document.getElementById( 'answers' ).getElementsByClassName( 'vote-down-answer' );

    hideVoteUp();
    hideAnswersSelect();

    if ( questionVote ) {

        if ( question[QUESTION_COLUMNS.voted] < 0 ) {

            questionVote.addClass( 'vote-down-question-selected' );

        } else {

            questionVote.removeClass( 'vote-down-question-selected' );

        };

        questionVote.removeClass( 'hide' );

    };

    for ( var index = 0; index < answers.length; index++ ) {

        if ( question[QUESTION_COLUMNS.answers][index][ANSWER_COLUMNS.voted] < 0 ) {

            answers[index].addClass( 'vote-down-answer-selected' );

        } else {

            answers[index].removeClass( 'vote-down-answer-selected' );

        };

        answers[index].removeClass( 'hide' );

    };

    window.setTimeout( function () {

        if ( questionVote ) { questionVote.removeClass( 'width-zero' ); };

        for ( var index = 0; index < answers.length; index++ ) {

            answers[index].removeClass( 'width-zero' );

        };

    }, 50 );

    window.setTimeout( function () {

        if ( questionVote ) { questionVote.removeClass( 'fade' ); };

        for ( var index = 0; index < answers.length; index++ ) {

            answers[index].removeClass( 'fade' );

        };

    }, 250 );

};

function showVoteUp( question ) {

    var questionVote = document.getElementById( 'question-view' ).getElementsByClassName( 'vote-up-question' )[0],
        answers = document.getElementById( 'answers' ).getElementsByClassName( 'vote-up-answer' );

    hideVoteDown();
    hideAnswersSelect();

    if ( questionVote ) {

        if ( question[QUESTION_COLUMNS.voted] > 0 ) {

            questionVote.addClass( 'vote-up-question-selected' );

        } else {

            questionVote.removeClass( 'vote-up-question-selected' );

        };

        questionVote.removeClass( 'hide' );

    };

    for ( var index = 0; index < answers.length; index++ ) {

        if ( question[QUESTION_COLUMNS.answers][index][ANSWER_COLUMNS.voted] > 0 ) {

            answers[index].addClass( 'vote-up-answer-selected' );

        } else {

            answers[index].removeClass( 'vote-up-answer-selected' );

        };

        answers[index].removeClass( 'hide' );

    };

    window.setTimeout( function () {

        if ( questionVote ) { questionVote.removeClass( 'width-zero' ); };

        for ( var index = 0; index < answers.length; index++ ) {

            answers[index].removeClass( 'width-zero' );

        };

    }, 50 );

    window.setTimeout( function () {

        if ( questionVote ) { questionVote.removeClass( 'fade' ); };

        for ( var index = 0; index < answers.length; index++ ) {

            answers[index].removeClass( 'fade' );

        };

    }, 250 );

};

function startApp() {

    loadAccount( function () {

        setupGeolocation();
        refreshQuestions();
        refreshUserQuestions();
        showRefreshButton();

        if ( window.location.queryString()['question-id'] ) {

            showPage( 'question-page', { id: window.location.queryString()['question-id'] } );
            window.history.replaceState( '', '', window.location.pathname );

        } else {

            showPage( 'questions-page' );

        };

        window.setTimeout( showInstructions, 10 * SECOND );

    } );

};

function toBase64UrlString( base64String ) {

    return base64String.replace( /\+/g, '-' ).replace( /\//g, '_' ).replace( /=/g, '' );

};

function toolbarClick( event ) {

    var item = event.target.closestByTagName( 'li' );

    if ( item && !item.disabled ) {

        var answerItem,
            question;

        switch ( item.id ) {

            case 'add-answer-button':

                question = _pages.last().options.object;

                if ( question.answered( _account[ACCOUNT_COLUMNS.userId] ) ) {

                    showMessage( STRINGS.error.alreadyAnswered );

                } else {

                    showAddAnswer( question );

                };

                break;

            case 'answer-user-button':

                showPage( 'user-page', { id: item.getDataset( 'user-id' ) } );
                break;

            case 'contact-button':

                onContactButtonClick();
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

            case 'question-share-button':

                onQuestionShareButtonClick();
                break;

            case 'questions-button':

                showPage( 'questions-page' );
                scrollUp();
                break;

            case 'question-user-button':

                showPage( 'user-page', { id: item.getDataset( 'user-id' ) } );
                break;

            case 'select-answer-button':

                var answer = _pages.last().options.object;
                question = _pages.last().options.question;
                answerItem = document.getElementById( 'answer-view' ).getElementsByClassName( 'answer-item' )[0];

                saveAnswerSelect( question, answer, answerItem );
                break;

            case 'select-answers-button':

                question = _pages.last().options.object;
                var selects = document.getElementById( 'answers' ).getElementsByClassName( 'select-answer' );

                if ( selects.length == 0 ) {

                    showMessage( STRINGS.error.noAnswersToSelect );

                } else {

                    if ( selects[0].hasClass( 'hide' ) ) {

                        showAnswersSelect( question );

                    } else {

                        hideAnswersSelect();

                    };

                };

                break;

            case 'top-button':

                showPage( 'top-page' );
                break;

            case 'user-button':

                showPage( 'user-page', { id: item.getDataset( 'user-id' ), top: true } );
                scrollUp();
                break;

            case 'vote-down-button':

                question = _pages.last().options.object;
                var voteDownQuestion = document.getElementById( 'question-view' ).getElementsByClassName( 'vote-down-question' )[0],
                    voteDownAnswer = document.getElementById( 'answers' ).getElementsByClassName( 'vote-down-answer' )[0];

                if ( ( voteDownQuestion && voteDownQuestion.hasClass( 'hide' ) )
                    || ( voteDownAnswer && voteDownAnswer.hasClass( 'hide' ) ) ) {

                    showVoteDown( question );

                } else {

                    hideVoteDown();

                };

                break;

            case 'vote-down-answer-button':

                answer = _pages.last().options.object;
                question = _pages.last().options.question;
                answerItem = document.getElementById( 'answer-view' ).getElementsByClassName( 'answer-item' )[0];

                if ( isMyAnswer( answer ) ) {

                    showMessage( STRINGS.error.voteOnOwnAnswer );

                } else {

                    saveAnswerDownvote( question, answer, answerItem );

                };

                break;

            case 'vote-up-answer-button':

                answer = _pages.last().options.object;
                question = _pages.last().options.question;
                answerItem = document.getElementById( 'answer-view' ).getElementsByClassName( 'answer-item' )[0];

                if ( isMyAnswer( answer ) ) {

                    showMessage( STRINGS.error.voteOnOwnAnswer );

                } else {

                    saveAnswerUpvote( question, answer, answerItem );

                };

                break;

            case 'vote-up-button':

                question = _pages.last().options.object;
                var voteUpQuestion = document.getElementById( 'question-view' ).getElementsByClassName( 'vote-up-question' )[0],
                    voteUpAnswer = document.getElementById( 'answers' ).getElementsByClassName( 'vote-up-answer' )[0];

                if ( ( voteUpQuestion && voteUpQuestion.hasClass( 'hide' ) )
                    || ( voteUpAnswer && voteUpAnswer.hasClass( 'hide' ) ) ) {

                    showVoteUp( question );

                } else {

                    hideVoteUp();

                };

                break;

        };

    };

};

function topIntervalClick( event ) {

    event.stopPropagation();

    var toggleButton = event.target.closestByClassName( 'toggle-button' );

    if ( toggleButton && !toggleButton.hasClass( 'toggle-button-selected' ) ) {

        var toggleButtons = document.querySelectorAll( '#top-interval .toggle-button' );

        for ( var index = 0; index < toggleButtons.length; index++ ) {

            toggleButtons[index].removeClass( 'toggle-button-selected' );

        };

        toggleButton.addClass( 'toggle-button-selected' );
        toggleButton.parentNode.setDataset( 'id', toggleButton.getDataset( 'id' ) );
        showTopUsers( _currentLocation.regionName );

    };

};

function topTypeClick( event ) {

    event.stopPropagation();

    var toggleButton = event.target.closestByClassName( 'toggle-button' );

    if ( toggleButton && !toggleButton.hasClass( 'toggle-button-selected' ) ) {

        var toggleButtons = document.querySelectorAll( '#top-type .toggle-button' );

        for ( var index = 0; index < toggleButtons.length; index++ ) {

            toggleButtons[index].removeClass( 'toggle-button-selected' );

        };

        toggleButton.addClass( 'toggle-button-selected' );
        toggleButton.parentNode.setDataset( 'id', toggleButton.getDataset( 'id' ) );
        showTopUsers( _currentLocation.regionName );

    };

};

function totalAnswersClick( event ) {

    var answers = document.getElementById( 'user-answers' ),
        frame = document.getElementById( 'user-info-view' );

    if ( window.deviceInfo.iscroll ) {

        _scrollUser.scrollToElement( answers, 700 );

    } else {

        frame.scrollTop = answers.positionTop - frame.positionTop

    };

};

function totalBadgesClick( event ) {

    var badges = document.getElementById( 'user-badges' ),
        frame = document.getElementById( 'user-info-view' );

    if ( window.deviceInfo.iscroll ) {

        _scrollUser.scrollToElement( badges, 700 );

    } else {

        frame.scrollTop = badges.positionTop - frame.positionTop

    };

};

function travelModeClick( event ) {

    var travelItem = event.target.closestByClassName( 'travel-mode-item' );

    if ( travelItem && !travelItem.hasClass( 'travel-mode-selected' ) ) {

        setTravelMode( travelItem );

    };

};

function totalQuestionsClick( event ) {

    var questions = document.getElementById( 'users-questions' ),
        frame = document.getElementById( 'user-info-view' );

    if ( window.deviceInfo.iscroll ) {

        _scrollUser.scrollToElement( questions, 700 );

    } else {

        frame.scrollTop = questions.positionTop - frame.positionTop

    };

};

function totalReputationClick( event ) {

    var reputation = document.getElementById( 'user-reputations' ),
        frame = document.getElementById( 'user-info-view' );

    if ( window.deviceInfo.iscroll ) {

        _scrollUser.scrollToElement( reputation, 700 );

    } else {

        frame.scrollTop = reputation.positionTop - frame.positionTop;

    };

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

function updateScrollQuestions() {

    if ( window.deviceInfo.iscroll ) {

        setTimeout( function () {

            _scrollQuestions.refresh();

        }, 0 );

    };

};

function updateScrollTopUsers() {

    if ( window.deviceInfo.iscroll ) {

        setTimeout( function () {

            _scrollTopUsers.refresh();

        }, 0 );

    };

};

function updateScrollUser() {

    if ( window.deviceInfo.iscroll ) {

        setTimeout( function () {

            _scrollUser.refresh();

        }, 0 );

    };

};

function updateScrollAnswers() {

    if ( window.deviceInfo.iscroll ) {

        setTimeout( function () {

            _scrollAnswers.refresh();

        }, 0 );

    };

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

            showPage( 'user-page', { id: user.getDataset( 'id' ) } );

        };

        window.setTimeout( function () { unselectItem( event ); }, 100 );

    }, 100 );

};

function userAnswerClick( event ) {

    selectItem( event );

    window.setTimeout( function () {

        var answerItem = event.target.closestByClassName( 'answer-item' );

        if ( answerItem ) {

            showPage( 'question-page', { id: answerItem.getDataset( 'question-id' ) } );

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

Array.prototype.items = function ( value, column ) {

    column = column || 0;

    var items = [];

    for ( var index = 0; index < this.length; index++ ) {

        if ( value == this[index][column] ) {

            items.push( this[index] );

        };

    };

    return items;

};

Element.prototype.getDataset = function ( name ) {

    return this.getAttribute( 'data-' + name );

};

Element.prototype.setDataset = function ( name, value ) {

    this.setAttribute( 'data-' + name, value );
    return this;

};

window.removeLocalStorage = function ( name ) {

    if ( window.hasLocalStorage ) {

        return window.localStorage.removeItem( name );

    };

    return this;

};

window.getLocalStorage = function ( name ) {

    if ( window.hasLocalStorage ) {

        return window.localStorage.getItem( name );

    } else {

        return '';

    };

};

window.setLocalStorage = function ( name, value ) {

    if ( window.hasLocalStorage ) {

        window.localStorage.setItem( name, value );

    };

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

Element.prototype.documentOffsetTop = function () {

    return this.offsetTop + ( this.offsetParent ? this.offsetParent.documentOffsetTop() : 0 );

};

String.prototype.trim = function () {

    var str = this.replace( /^\s\s*/, '' ),
		ws = /\s/,
		i = str.length;
    while ( ws.test( str.charAt( --i ) ) );

    return str.slice( 0, i + 1 );

};

String.prototype.repeat = function ( n ) {

    return Array( n + 1 ).join( this );

};

window.checkLocalStorage = function () {

    try {

        window.localStorage.setItem( 'checkLocalStorage', true );
        window.hasLocalStorage = true;

    } catch ( error ) {

        window.hasLocalStorage = false;

    };

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

    //            if ( !settings.cache ) {

    //                uri += ( uri.indexOf( '?' ) > -1 ? '&' : '?' ) + 'cache-date=' + ( new Date() ).getTime();

    //            };

    ajax.open( settings.type, uri, async );

    if ( settings.headers ) {

        for ( var header in settings.headers ) {

            ajax.setRequestHeader( header, settings.headers[header] );

        };

    };

    //            if ( !settings.cache ) {

    //                ajax.setRequestHeader( 'cache-control', 'no-cache' );

    //            };

    ajax.send( data );

};

String.prototype.jsonEncode = function () {

    return this.replace( /\\/g, '\\\\' )
        .replace( /\"/g, '\\"' )
        .replace( /\//g, '\\/' );

};

String.prototype.htmlEncode = function () {

    return this.replace( /\"/g, '&quot;' );

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

window.setTimeout( initialize, 100 );

