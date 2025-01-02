const WebSocket = require('ws');
const SockJS = require('sockjs-client');
const MongodbSingleton = require('./mongob-singleton');
const mongoUtil = require('./mongo-util');
const dotenv = require('dotenv').config();
const EarthquakesList = require('./earthquakes-list');

const reconnectInterval = 2000; // 2 seconds delay before reconnecting
const sourceUrl = 'https://www.seismicportal.eu/standing_order';
const destinationUrl = process.env.AWS_API_GATEWAY_WEBSOCKET;

const redis = require('redis');
const client = redis.createClient({ socket: { host: process.env.AWS_LIGHTSAIL_REDIS_URL, port: 6379 } });

let sourceSock;
let destinationSock;
let heartbeatInterval;

const now = new Date();
const earthquakesList = new EarthquakesList();

// Connect to the source WebSocket using SockJS (SeismicPortal)
function connectSource() {
    sourceSock = new SockJS(sourceUrl);

    sourceSock.onopen = () => {
        console.log(`${now.toISOString()} Connected to source WebSocket: ${sourceUrl}`);
    };

    sourceSock.onmessage = async (e) => {
        const msg = JSON.parse(e.data);
        if (!msg || !msg.data || !msg.data.id) {
            console.log(`${now.toISOString()} Received undefined earthquake data. Skipping.`);
            return;
        }

        const id = msg.data.id;
        console.log(`${now.toISOString()} Earthquake data received with ID ${id}`);
        console.log(`${now.toISOString()} Time: ${msg.data.properties.time}`);
        console.log(`${now.toISOString()} Region: ${msg.data.properties.flynn_region}`);
        console.log(`${now.toISOString()} Magnitude: ${msg.data.properties.mag}`);

        const filter = { "data.id": id };
        const result = await mongoUtil.replaceDocumentOrCreateNew(
            "EarthquakesData",
            "Earthquake",
            msg,
            filter,
            { upsert: true }
        );

        console.log(
            result.modifiedCount === 0
                ? `${now.toISOString()} Earthquake data with ID {${id}} created in MongoDB.`
                : `${now.toISOString()} Document with ID {${id}} updated in MongoDB.`
        );

        earthquakesList.add(id, msg);
        await setKeyValueRedis("last100earthquakes", earthquakesList.toJSONString());

        const dataToSend = {
            action: "sendMessage",
            source: "relay-server",
            message: earthquakesList.toJSONString()
        };

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

// Connect to the destination WebSocket
function connectDestination() {
    destinationSock = new WebSocket(destinationUrl);

    const dataToSend = {
        action: "ping",
        source: "relay-server",
        message: "ping to keep server alive"
    };

    destinationSock.on('open', () => {
        console.log(`${now.toISOString()} Connected to destination WebSocket: ${destinationUrl}`);

        clearInterval(heartbeatInterval);
        heartbeatInterval = setInterval(() => {
            if (destinationSock.readyState === WebSocket.OPEN) {
                destinationSock.send(JSON.stringify(dataToSend));
                console.log(`${now.toISOString()} Sent heartbeat (ping)`);
            }
        }, 30000); // Send every 30 seconds
    });

    destinationSock.on('message', (data) => {
        const message = JSON.parse(data);
        if (message.action === 'pong') {
            console.log(`${now.toISOString()} Received message from server: `, message.message);
        }

        //TODO filter out broadcast messages from websocket that come back through here
    });

    destinationSock.on('close', () => {
        console.log(`${now.toISOString()} Destination WebSocket disconnected. Reconnecting...`);
        clearInterval(heartbeatInterval);
        setTimeout(connectDestination, reconnectInterval);
    });

    destinationSock.on('error', (error) => {
        console.error(`${now.toISOString()} Destination WebSocket encountered error:`, error);
        destinationSock.close(); // Close to trigger reconnection
    });
}

// Set a key/value pair in Redis
async function setKeyValueRedis(key, val) {
    try {
        await client.set(key, val);
        console.log('Key set in Redis successfully');
    } catch (error) {
        console.error('Error setting key/value in Redis:', error);
    }
}

// Initialize MongoDB connection
(async () => {
    try {
        await client.connect()
            .then(() => console.log('Connected to Redis'))
            .catch((err) => console.error('Redis connection error:', err));

        const mongodb = MongodbSingleton.getInstance();
        await mongodb.connect();
        const last100Earthquakes = await mongoUtil.getLastXDocuments("EarthquakesData", "Earthquake", 100);

        populateEarthquakesList(last100Earthquakes);
        setKeyValueRedis("last100earthquakes", earthquakesList.toJSONString());
    } catch (error) {
        console.log(`${now.toISOString()} MongoDB connection error:`, error);
    }
})();

// Populate earthquakes list with initial data
function populateEarthquakesList(documents) {
    documents.forEach((doc) => {
        delete doc._id;
        earthquakesList.add(doc.data.id, doc);
    });
}

// Start both WebSocket connections
connectSource();
connectDestination();