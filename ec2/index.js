const SockJS = require('sockjs-client');
const MongodbSingleton = require('./mongob-singleton');
const dotenv = require('dotenv').config();

let sock;
let reconnectInterval = 5000; // 5 seconds delay before reconnecting

function connect() {
    sock = new SockJS('https://www.seismicportal.eu/standing_order');

    sock.onopen = function () {
        console.log('Connected');
    };

    sock.onmessage = function (e) {
        let msg = JSON.parse(e.data);
        console.log('Message received:', msg);
    };

    sock.onclose = function () {
        console.log('Disconnected. Attempting to reconnect in 5 seconds...');
        setTimeout(connect, reconnectInterval);
    };

    sock.onerror = function (error) {
        console.error('Socket encountered error:', error);
        console.log('Closing socket connection');
        sock.close(); // Close the socket connection on error to trigger the reconnection logic
    };
}

//create connection to mongodb
(async () => {
    try {
        var mongodb = MongodbSingleton.getInstance();
        await mongodb.connect();
    } catch (error) {
        console.log("Error: ", error);
    }
})();


// Initial connection to seismicportal websocket upates
connect();

