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
const redisClient = redis.createClient({
    socket: { host: process.env.AWS_LIGHTSAIL_REDIS_URL, port: 6379, keepAlive: true }
});

// Handle Redis events
redisClient.on('connect', () => logWithTimestamp('✅ Connected to Redis'));
redisClient.on('ready', () => logWithTimestamp('✅ Redis client is ready'));
redisClient.on('error', (err) => logWithTimestamp(`❌ Redis error: ${err}`, true));
redisClient.on('end', () => {
    logWithTimestamp('⚠️ Redis connection closed. Reconnecting...');
    setTimeout(() => redisClient.connect(), reconnectInterval);
});

let sourceSock;
let destinationSock;
let heartbeatInterval;
const earthquakesListLast100 = new EarthquakesList(100);

// Log function with MongoDB logging
async function logWithTimestamp(message, isError = false) {
    const timestamp = new Date().toISOString();
    console.log(`${timestamp} ${message}`);

    if (isError) {
        await logErrorToMongoDB(timestamp, message);
    }
}

// Function to log errors into MongoDB
async function logErrorToMongoDB(timestamp, message) {
    try {
        const mongodbCollection = getCollection("SeismicPortalWebSocket", "Logs");
        await mongodbCollection.insertOne({
            timestamp: new Date(timestamp),
            message: message,
        });
    } catch (error) {
        console.error(`❌ Failed to log error to MongoDB: ${error.message}`);
    }
}

// Function to retrieve MongoDB collection
function getCollection(database, collection) {
    const databaseInstance = MongodbSingleton.getInstance();
    return databaseInstance.db(database).collection(collection);
}

// Connect to the source WebSocket (Seismic Portal)
function connectSource() {
    sourceSock = new SockJS(sourceUrl);

    sourceSock.onopen = () => logWithTimestamp(`🔗 Connected to source WebSocket: ${sourceUrl}`);

    sourceSock.onmessage = async (e) => {
        try {
            const msg = JSON.parse(e.data);
            if (!msg || !msg.data || !msg.data.id) {
                logWithTimestamp('⚠️ Received undefined earthquake data. Skipping.');
                return;
            }

            // Convert timestamps to Date objects
            if (msg.data.properties) {
                if (msg.data.properties.time) msg.data.properties.time = new Date(msg.data.properties.time);
                if (msg.data.properties.lastupdate) msg.data.properties.lastupdate = new Date(msg.data.properties.lastupdate);
            }

            const id = msg.data.id;
            logWithTimestamp(`🌍 Earthquake received: ID ${id} | Region: ${msg.data.properties.flynn_region} | Mag: ${msg.data.properties.mag}`);

            const filter = { "data.id": id };
            const updateData = { $set: msg };
            const options = { upsert: true };

            const result = await mongoUtil.updateDocument("EarthquakesData", "Earthquake", filter, updateData, options);

            if (result.upsertedId) {
                logWithTimestamp(`🆕 New earthquake inserted: ID ${id}`);
            } else if (result.modifiedCount > 0) {
                logWithTimestamp(`✅ Earthquake updated: ID ${id}`);
            } else {
                logWithTimestamp(`⚠️ No changes detected for ID ${id}`);
            }

            earthquakesListLast100.add(id, msg);
            await setKeyValueRedis("last100earthquakes", earthquakesListLast100.toJSONString());

            const dataToSend = { action: "sendMessage", source: "relay-server", message: earthquakesListLast100.toJSONString() };

            if (destinationSock && destinationSock.readyState === WebSocket.OPEN) {
                destinationSock.send(JSON.stringify(dataToSend));
                logWithTimestamp('📤 Data forwarded to destination WebSocket');
            } else {
                logWithTimestamp('❌ Destination WebSocket not connected', true);
            }
        } catch (error) {
            logWithTimestamp(`❌ Source WebSocket processing error: ${error.message}`, true);
        }
    };

    sourceSock.onclose = () => {
        logWithTimestamp('⚠️ Source WebSocket disconnected. Reconnecting...');
        setTimeout(connectSource, reconnectInterval);
    };

    sourceSock.onerror = (error) => {
        logWithTimestamp(`❌ Source WebSocket error: ${error.message}`, true);
        if (sourceSock.readyState !== WebSocket.CLOSED) sourceSock.close();
    };
}

// Connect to the destination WebSocket
function connectDestination() {
    destinationSock = new WebSocket(destinationUrl);

    const dataToSend = { action: "ping", source: "relay-server", message: "ping to keep server alive" };

    destinationSock.on('open', () => {
        logWithTimestamp(`🔗 Connected to destination WebSocket: ${destinationUrl}`);
        clearInterval(heartbeatInterval);
        heartbeatInterval = setInterval(() => {
            if (destinationSock.readyState === WebSocket.OPEN) {
                destinationSock.send(JSON.stringify(dataToSend));
                logWithTimestamp('💓 Sent heartbeat');
            }
        }, 30000);
    });

    destinationSock.on('close', () => {
        logWithTimestamp('⚠️ Destination WebSocket disconnected. Reconnecting...');
        clearInterval(heartbeatInterval);
        setTimeout(connectDestination, reconnectInterval);
    });

    destinationSock.on('error', (error) => {
        logWithTimestamp(`❌ Destination WebSocket error: ${error.message}`, true);
        if (destinationSock.readyState !== WebSocket.CLOSED) destinationSock.close();
    });
}

// Store key-value pair in Redis
async function setKeyValueRedis(key, val) {
    try {
        await redisClient.set(key, val);
        logWithTimestamp('✅ Key set in Redis');
    } catch (error) {
        logWithTimestamp(`❌ Redis set error: ${error}`, true);
    }
}

// Initialize MongoDB & Redis
(async () => {
    try {
        await redisClient.connect();
        const mongodb = MongodbSingleton.getInstance();
        await mongodb.connect();
        const last100Earthquakes = await mongoUtil.getLastXDocuments("EarthquakesData", "Earthquake", 100);
        populateEarthquakesList(last100Earthquakes);
        setKeyValueRedis("last100earthquakes", earthquakesListLast100.toJSONString());
    } catch (error) {
        logWithTimestamp(`❌ MongoDB connection error: ${error}`, true);
    }
})();

// Populate earthquakes list
function populateEarthquakesList(documents) {
    for (let i = documents.length - 1; i >= 0; i--) {
        let doc = documents[i];
        delete doc._id;
        earthquakesListLast100.add(doc.data.id, doc);
    }
}

// Start WebSocket connections
connectSource();
connectDestination();