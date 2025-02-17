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
const redisClient = redis.createClient({ socket: { host: process.env.AWS_LIGHTSAIL_REDIS_URL, port: 6379, keepAlive: true } });

// Handle Redis client events
redisClient.on('connect', () => {
    logWithTimestamp('Connected to Redis');
});

redisClient.on('ready', () => {
    logWithTimestamp('Redis client is ready');
});

redisClient.on('error', (err) => {
    logWithTimestamp(console.error('Redis client error:', err));
});

redisClient.on('end', () => {
    logWithTimestamp('Redis connection closed. Attempting to reconnect...');
    setTimeout(() => client.connect(), reconnectInterval);
});

let sourceSock;
let destinationSock;
let heartbeatInterval;

const earthquakesList = new EarthquakesList();

// Log current timestamp in ISO format for each event
function logWithTimestamp(message) {
    const now = new Date();  // Get the current timestamp each time you log
    console.log(`${now.toISOString()} ${message}`);
}

// Connect to the source WebSocket using SockJS (SeismicPortal)
function connectSource() {
    sourceSock = new SockJS(sourceUrl);

    sourceSock.onopen = () => {
        logWithTimestamp(`Connected to source WebSocket: ${sourceUrl}`);
    };

    sourceSock.onmessage = async (e) => {
        const msg = JSON.parse(e.data);
        if (!msg || !msg.data || !msg.data.id) {
            logWithTimestamp('Received undefined earthquake data. Skipping.');
            return;
        }

        // Convert string timestamps to MongoDB Date objects
        if (msg.data.properties) {
            if (msg.data.properties.time) {
                msg.data.properties.time = new Date(msg.data.properties.time);
            }
            if (msg.data.properties.lastupdate) {
                msg.data.properties.lastupdate = new Date(msg.data.properties.lastupdate);
            }
        }

        const id = msg.data.id;
        logWithTimestamp(`Earthquake data received with ID ${id}`);
        logWithTimestamp(`Time: ${msg.data.properties.time}`);
        logWithTimestamp(`Region: ${msg.data.properties.flynn_region}`);
        logWithTimestamp(`Magnitude: ${msg.data.properties.mag}`);

        const filter = { "data.id": id };
        const result = await mongoUtil.replaceDocumentOrCreateNew(
            "EarthquakesData",
            "Earthquake",
            msg,
            filter,
            { upsert: true }
        );

        logWithTimestamp(
            result.modifiedCount === 0
                ? `Earthquake data with ID {${id}} created in MongoDB.`
                : `Document with ID {${id}} updated in MongoDB.`
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
            logWithTimestamp('Data forwarded to destination WebSocket');
        } else {
            logWithTimestamp('Destination WebSocket is not connected, unable to forward data.');
        }
    };


    sourceSock.onclose = () => {
        logWithTimestamp('Source WebSocket disconnected. Reconnecting...');
        setTimeout(connectSource, reconnectInterval);
    };

    sourceSock.onerror = (error) => {
        console.error(`${new Date().toISOString()} Source WebSocket encountered error:`, error);
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
        logWithTimestamp(`Connected to destination WebSocket: ${destinationUrl}`);

        clearInterval(heartbeatInterval);
        heartbeatInterval = setInterval(() => {
            if (destinationSock.readyState === WebSocket.OPEN) {
                destinationSock.send(JSON.stringify(dataToSend));
                logWithTimestamp('Sent heartbeat (ping)');
            }
        }, 30000); // Send every 30 seconds
    });

    destinationSock.on('message', (data) => {
        const message = JSON.parse(data);
        if (message.action === 'ping') {
            logWithTimestamp(`Received message from server: ${message.message}`);
        }

        //TODO filter out broadcast messages from websocket that come back through here
    });

    destinationSock.on('close', () => {
        logWithTimestamp('Destination WebSocket disconnected. Reconnecting...');
        clearInterval(heartbeatInterval);
        setTimeout(connectDestination, reconnectInterval);
    });

    destinationSock.on('error', (error) => {
        console.error(`${new Date().toISOString()} Destination WebSocket encountered error:`, error);
        destinationSock.close(); // Close to trigger reconnection
    });
}

// Set a key/value pair in Redis
async function setKeyValueRedis(key, val) {
    try {
        await redisClient.set(key, val);
        logWithTimestamp('Key set in Redis successfully');
    } catch (error) {
        console.error('Error setting key/value in Redis:', error);
    }
}

// Initialize MongoDB connection
(async () => {
    try {
        await redisClient.connect()
            .then(() => logWithTimestamp('Connected to Redis asynchronously'))
            .catch((err) => console.error('Redis connection error:', err));

        const mongodb = MongodbSingleton.getInstance();
        await mongodb.connect();
        const last100Earthquakes = await mongoUtil.getLastXDocuments("EarthquakesData", "Earthquake", 100);

        populateEarthquakesList(last100Earthquakes);
        setKeyValueRedis("last100earthquakes", earthquakesList.toJSONString());
    } catch (error) {
        logWithTimestamp(`MongoDB connection error: ${error}`);
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