const SockJS = require('sockjs-client');
const MongodbSingleton = require('./mongob-singleton');
const mongoUtil = require('./mongo-util');
const dotenv = require('dotenv').config();

let sock;
let reconnectInterval = 5000; // 5 seconds delay before reconnecting
let url = 'https://www.seismicportal.eu/standing_order'

function connect() {
    sock = new SockJS(url);

    sock.onopen = function () {
        console.log(`Connected to ${url}`);
    };

    sock.onmessage = async function (e) {
        let msg = JSON.parse(e.data);
        console.log(`Earthquake data received with ID ${msg.data.id}`);
        console.log(`Time: ${msg.data.properties.time}`);
        console.log(`Region: ${msg.data.properties.flynn_region}`);
        console.log(`Magnitude: ${msg.data.properties.mag}`);

        let filter = { id: msg.data.id };
        let id = msg.data.id;

        const result = await mongoUtil.replaceDocumentOrCreateNew("EarthquakesData", "Earthquake", filter, msg, { upsert: true });
        console.log(result.upsertedCount > 0 ? `Earthquake data with id {${id}} was created in mongo database.` : `Document with id {${id}} was updated in mongo database.`);

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

