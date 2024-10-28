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

        //parse the data into a javascript object
        let msg = JSON.parse(e.data);


        console.log(`Earthquake data received with ID ${msg.data.id}`);
        console.log(`Time: ${msg.data.properties.time}`);
        console.log(`Region: ${msg.data.properties.flynn_region}`);
        console.log(`Magnitude: ${msg.data.properties.mag}`);

        let id = msg.data.id;
        let filter = { "data.id": id };

        //here we repalce an exisiting document based on the filter (id) or create a new one if it doesnt exist
        const result = await mongoUtil.replaceDocumentOrCreateNew("EarthquakesData", "Earthquake", msg, filter, { upsert: true });

        //this just informs if there was a creation or replacement.
        console.log(result.modifiedCount == 0 ? `Earthquake data with id {${id}} was created in mongo database.` : `Document with id {${id}} was updated in mongo database.`);
        console.log();
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

