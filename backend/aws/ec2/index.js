const WebSocket = require('ws');
const SockJS = require('sockjs-client');
const MongodbSingleton = require('./mongob-singleton');
const mongoUtil = require('./mongo-util');
const dotenv = require('dotenv').config();

const reconnectInterval = 5000; // 5 seconds delay before reconnecting
const sourceUrl = 'https://www.seismicportal.eu/standing_order';
const destinationUrl = process.env.AWS_API_GATEWAY_WEBSOCKET;
const redis = require('redis');

let sourceSock;
let destinationSock;
const now = new Date();


// Connect to the source WebSocket using SockJS (SeismicPortal)
function connectSource() {
    sourceSock = new SockJS(sourceUrl);

    sourceSock.onopen = () => {

        console.log(`${now.toISOString()} Connected to source WebSocket: ${sourceUrl}`);
    };

    sourceSock.onmessage = async (e) => {
        // Parse data received from source WebSocket


        const msg = JSON.parse(e.data);
        if (msg === undefined || msg === null || msg.data === undefined || msg.data === null || msg.data.id === undefined || msg.data.id === null) {
            console.log(`${now.toISOString()} Earthquake data received with ID undefined. Skipping.`);
            return;
        }

        console.log(`${now.toISOString()} Earthquake data received with ID ${msg.data.id}`);
        console.log(`${now.toISOString()} Time: ${msg.data.properties.time}`);
        console.log(`${now.toISOString()} Region: ${msg.data.properties.flynn_region}`);
        console.log(`${now.toISOString()} Magnitude: ${msg.data.properties.mag}`);

        const id = msg.data.id;
        const filter = { "data.id": id };

        // Replace an existing document or create a new one if it doesn't exist
        const result = await mongoUtil.replaceDocumentOrCreateNew("EarthquakesData", "Earthquake", msg, filter, { upsert: true });
        console.log(result.modifiedCount === 0 ? `${now.toISOString()} Earthquake data with ID {${id}} created in MongoDB.` : `${now.toISOString()} Document with ID {${id}} updated in MongoDB.`);

        let dataToSend = {
            action: "sendMessage",
            source: "relay-server",
            message: msg
        }


        // Forward the data to the destination WebSocket if connected
        if (destinationSock && destinationSock.readyState === WebSocket.OPEN) {
            destinationSock.send(JSON.stringify(dataToSend));
            console.log(`${now.toISOString()} Data forwarded to destination WebSocket`);
        } else {
            console.log(`${now.toISOString()} Destination WebSocket is not connected, unable to forward data.`);
        }

        console.log();
    };

    sourceSock.onclose = () => {
        console.log(`${now.toISOString()} Source WebSocket disconnected. Reconnecting...`);
        setTimeout(connectSource, reconnectInterval);
    };

    sourceSock.onerror = (error) => {
        console.error(`${now.toISOString()} Source WebSocket encountered error:`, error);
        sourceSock.close(); // Close to trigger reconnection
    };
}

// Connect to the destination WebSocket using `ws`
function connectDestination() {
    destinationSock = new WebSocket(destinationUrl);

    destinationSock.on('open', () => {
        console.log(`${now.toISOString()} Connected to destination WebSocket: ${destinationUrl}`);
    });

    destinationSock.on('close', () => {
        console.log(`${now.toISOString()} Destination WebSocket disconnected. Reconnecting...`);
        setTimeout(connectDestination, reconnectInterval);
    });

    destinationSock.on('error', (error) => {
        console.error(`${now.toISOString()} Destination WebSocket encountered error:`, error);
        destinationSock.close(); // Close to trigger reconnection
    });
}


// Create a Redis client
const client = redis.createClient({ socket: { host: "52.6.170.93", port: 6379 } });
//password: 'your-redis-auth-token',  // If you have Redis AUTH enabled, otherwise remove this line


// Set a key/value pair in Redis
async function setKeyValue() {
    try {
        await client.set('your_key', 'your_value');
        console.log('Key set successfully');

        // Retrieve the value
        const value = await client.get('your_key');
        console.log(`Retrieved value: ${value}`);
    } catch (error) {
        console.error('Error setting key/value:', error);
    } finally {
        await client.disconnect();
    }
}


// Initialize MongoDB connection
(async () => {
    try {
        const mongodb = MongodbSingleton.getInstance();
        await mongodb.connect();
    } catch (error) {
        console.log(`${now.toISOString()}MongoDB connection error: `, error);
    }
})();

// Connect to the Redis client
client.connect()
    .then(() => console.log('Connected to Redis'))
    .catch((err) => console.error('Redis connection error:', err));

// Start both WebSocket connections
//connectSource();
//connectDestination();
setKeyValue();