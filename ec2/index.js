const SockJS = require('sockjs-client');
var sock = new SockJS('https://www.seismicportal.eu/standing_order');
sock.onopen = function () {

    console.log('connected');

};

sock.onmessage = function (e) {

    msg = JSON.parse(e.data);

    console.log('message received : ', msg);

};

sock.onclose = function () {

    console.log('disconnected');

};