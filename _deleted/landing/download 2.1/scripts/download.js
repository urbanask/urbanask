var index = 0;    

window.onload = function () {

    window.setInterval(changeScreenShot, 5000);

};

function changeScreenShot() {

    index += 1;
    var className = 'screen-shot-' + ((index % 5) + 1);
    document.getElementById('screen-shot').className = className;

};

