var index = 0;

window.onload = function () {

    window.setInterval(changeScreenShot, 5000);

    document.getElementById('google-store-link').onmouseover = showAndroid;
    document.getElementById('amazon-store-link').onmouseover = showAndroid;
    document.getElementById('google-store-link').onmouseout = showiPhone;
    document.getElementById('amazon-store-link').onmouseout = showiPhone;
    document.getElementById('google-store-qr').onmouseover = showAndroid;
    document.getElementById('amazon-store-qr').onmouseover = showAndroid;
    document.getElementById('google-store-qr').onmouseout = showiPhone;
    document.getElementById('amazon-store-qr').onmouseout = showiPhone;

};

function changeScreenShot() {

    index += 1;
    var className = 'screen-shot-' + ((index % 5) + 1);
    document.getElementById('screen-shot').className = className;

};

function showiPhone() {

    document.getElementById('phone-preview').className = 'iphone';

};

function showAndroid() {

    document.getElementById('phone-preview').className = 'android';

};
