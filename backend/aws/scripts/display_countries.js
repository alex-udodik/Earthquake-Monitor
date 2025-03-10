require('dotenv').config();
const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const { MongoClient } = require('mongodb');

// MongoDB connection
const mongodbURI = `mongodb+srv://${process.env.MONGOUSERNAME}:${process.env.MONGOPASSWORD}@${process.env.MONGOCLUSTER}.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(mongodbURI);

const DB_NAME = "EarthquakesData"; // Change if needed
const COLLECTION_NAME = "Earthquake"; // Change if needed

// OpenStreetMap API function (Free & doesn't need API Key)
async function getLocationInfo(lat, lon) {
    const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}&accept-language=en`;

    try {
        const response = await fetch(url, { headers: { "User-Agent": "earthquake-app" } });
        if (!response.ok) throw new Error(`HTTP Error: ${response.status}`);
        const data = await response.json();

        if (data && data.address) {
            const display_name = data.display_name || "unknown";
            const country = data.address.country || "Unknown";
            const country_code = data.address.country_code || "Unknown";
            const state = data.address.state || "unknown";

            return { display_name, state, country, country_code };
        }
    } catch (error) {
        console.error(`❌ Error fetching location for ${lat}, ${lon}:`, error.message);
    }

    return { display_name: "Unknown", state: "Unknown", country: "Unknown", country_code: "Unknown" };
}

// Function to fetch and display earthquake locations
async function displayEarthquakeLocations() {
    try {
        await client.connect();
        const db = client.db(DB_NAME);
        const collection = db.collection(COLLECTION_NAME);

        // Get earthquakes missing country/continent
        const earthquakes = await collection.find({ "data.properties.country": { $exists: false } }).toArray();

        console.log(`🔍 Found ${earthquakes.length} earthquakes missing country/continent data`);

        for (const earthquake of earthquakes) {
            const { lat, lon } = earthquake.data.properties;
            if (!lat || !lon) continue; // Skip if no coordinates

            const { display_name, state, country, country_code } = await getLocationInfo(lat, lon);
            console.log(`🌍 Earthquake at (${lat}, ${lon}) → Country: ${country}, State: ${state}, Country-Code: ${country_code}, Display Name: ${display_name}`);

        }

        console.log("✅ Location lookup complete!");
    } catch (error) {
        console.error("❌ MongoDB Error:", error.message);
    } finally {
        await client.close();
    }
}

// Run the display function
displayEarthquakeLocations();