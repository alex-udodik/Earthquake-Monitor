const WebSocket = require('ws');
const SockJS = require('sockjs-client');
const MongodbSingleton = require('./mongob-singleton');
const mongoUtil = require('./mongo-util');
const dotenv = require('dotenv').config();
const EarthquakesList = require('./earthquakes-list');
const Redis = require("ioredis");
const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));

const reconnectInterval = 2000; // 2 seconds delay before reconnecting
const sourceUrl = 'https://www.seismicportal.eu/standing_order';
const destinationUrl = process.env.AWS_API_GATEWAY_WEBSOCKET;

// Initialize Upstash Redis
const redisClient = new Redis(process.env.UPSTASH_REDIS_URL);

// Handle Redis events
redisClient.on('connect', () => logWithTimestamp('✅ Connected to Upstash Redis'));
redisClient.on('error', (err) => logWithTimestamp(`❌ Redis error: ${err}`, true));

let sourceSock;
let destinationSock;
let heartbeatInterval;
const earthquakesListLast100 = new EarthquakesList(100);
const earthquakesListLast1000 = new EarthquakesList(1000);

// Log function with MongoDB logging
async function logWithTimestamp(message, isError = false) {
    const timestamp = new Date().toISOString();
    console.log(`${timestamp} ${message}`);

    if (isError) {
        await logErrorToMongoDB(timestamp, message);
    }
}

// OpenStreetMap API function to fetch location details
async function getLocationInfo(lat, lon) {
    const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}&accept-language=en`;

    try {
        const response = await fetch(url, { headers: { "User-Agent": "earthquake-app" } });
        if (!response.ok) throw new Error(`HTTP Error: ${response.status}`);
        const data = await response.json();

        if (data && data.address) {
            return {
                display_name: data.display_name || "Unknown",
                state: data.address.state || "Unknown",
                country: data.address.country || "Unknown",
                country_code: data.address.country_code || "Unknown"
            };
        }
    } catch (error) {
        console.error(`❌ Error fetching location for ${lat}, ${lon}:`, error.message);
    }

    return { display_name: "Unknown", state: "Unknown", country: "Unknown", country_code: "Unknown" };
}

async function getRegionInfo(country) {
    if (!country || country === "Unknown") return { region: "Unknown", subregion: "Unknown" };

    const url = `https://restcountries.com/v3.1/name/${encodeURIComponent(country)}?fields=region,subregion`;

    try {
        console.log(`🌍 Fetching region for country: ${country}`);
        const response = await fetch(url, { headers: { "User-Agent": "earthquake-app" } });
        if (!response.ok) throw new Error(`HTTP Error: ${response.status}`);

        const data = await response.json();
        if (Array.isArray(data) && data.length > 0) {
            return {
                region: data[0].region || "Unknown",
                subregion: data[0].subregion || "Unknown"
            };
        }
    } catch (error) {
        console.error(`❌ Error fetching region for ${country}:`, error.message);
    }

    return { region: "Unknown", subregion: "Unknown" };
}

// Function to log errors into MongoDB
async function logErrorToMongoDB(timestamp, message) {
    try {
        const mongodbCollection = getCollection("SeismicPortalWebSocket", "Logs");
        await mongodbCollection.insertOne({ timestamp: new Date(timestamp), message: message });
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

            const id = msg.data.id;
            const { lat, lon } = msg.data.properties;

            if (lat && lon) {
                const { display_name, state, country, country_code } = await getLocationInfo(lat, lon);
                msg.data.properties = { ...msg.data.properties, display_name, state, country, country_code };

                const { region, subregion } = country !== "Unknown" ? await getRegionInfo(country) : { region: "Unknown", subregion: "Unknown" };
                msg.data.properties.region = region;
                msg.data.properties.subregion = subregion;
            }

            logWithTimestamp(`🌍 Earthquake received: ID ${id} | Country: ${msg.data.properties.country} | Region: ${msg.data.properties.region} | Mag: ${msg.data.properties.mag}`);

            const filter = { "data.id": id };
            const updateData = { $set: msg };
            const options = { upsert: true };

            await mongoUtil.updateDocument("EarthquakesData", "Earthquake", filter, updateData, options);

            earthquakesListLast100.add(id, msg);
            earthquakesListLast1000.add(id, msg);

            await setKeyValueRedis("last100earthquakes", earthquakesListLast100.toJSONString());
            await setKeyValueRedis("last1000earthquakes", earthquakesListLast1000.toJSONString());

            if (destinationSock && destinationSock.readyState === WebSocket.OPEN) {
                destinationSock.send(JSON.stringify({ action: "sendMessage", source: "relay-server", message: earthquakesListLast100.toJSONString() }));
                logWithTimestamp('📤 Data forwarded to destination WebSocket');
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
    };
}

// Connect to the destination WebSocket
function connectDestination() {
    destinationSock = new WebSocket(destinationUrl);

    destinationSock.on('open', () => {
        logWithTimestamp(`🔗 Connected to destination WebSocket: ${destinationUrl}`);
        heartbeatInterval = setInterval(() => {
            if (destinationSock.readyState === WebSocket.OPEN) {
                destinationSock.send(JSON.stringify({ action: "ping", source: "relay-server", message: "ping to keep server alive" }));
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
    });
}

// Store key-value pair in Upstash Redis
async function setKeyValueRedis(key, val) {
    try {
        await redisClient.set(key, val, 'EX', 3600);
        logWithTimestamp(`✅ Key "${key}" set in Upstash Redis`);
    } catch (error) {
        logWithTimestamp(`❌ Upstash Redis set error: ${error}`, true);
    }
}

// Initialize MongoDB & Redis
(async () => {
    try {
        const mongodb = MongodbSingleton.getInstance();
        await mongodb.connect();
        // Load last 100 and last 1000 earthquakes from MongoDB
        const last100Earthquakes = await mongoUtil.getLastXDocuments("EarthquakesData", "Earthquake", 100);
        const last1000Earthquakes = await mongoUtil.getLastXDocuments("EarthquakesData", "Earthquake", 1000);

        last100Earthquakes.forEach(doc => earthquakesListLast100.add(doc.data.id, doc));
        last1000Earthquakes.forEach(doc => earthquakesListLast1000.add(doc.data.id, doc));

        await setKeyValueRedis("last100earthquakes", earthquakesListLast100.toJSONString());
        await setKeyValueRedis("last1000earthquakes", earthquakesListLast1000.toJSONString());
    } catch (error) {
        logWithTimestamp(`❌ MongoDB connection error: ${error}`, true);
    }
})();

// Start WebSocket connections
connectSource();
connectDestination();
