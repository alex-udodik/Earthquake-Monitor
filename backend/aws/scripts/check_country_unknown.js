require('dotenv').config();
const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const { MongoClient } = require('mongodb');

// MongoDB connection
const mongodbURI = `mongodb+srv://${process.env.MONGOUSERNAME}:${process.env.MONGOPASSWORD}@${process.env.MONGOCLUSTER}.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(mongodbURI);

const DB_NAME = "EarthquakesData";
const COLLECTION_NAME = "Earthquake";

// Function to get location info from OpenStreetMap API
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

// Function to update MongoDB records
async function updateEarthquakeLocations() {
    try {
        await client.connect();
        const db = client.db(DB_NAME);
        const collection = db.collection(COLLECTION_NAME);

        // Find all earthquakes where location fields are "Unknown"
        const earthquakes = await collection.find({
            $or: [
                { "data.properties.display_name": "Unknown" },
                { "data.properties.state": "Unknown" },
                { "data.properties.country": "Unknown" },
                { "data.properties.country_code": "Unknown" }
            ]
        }).toArray();

        const totalDocs = earthquakes.length;
        let updatedCount = 0;

        console.log(`🔍 Found ${totalDocs} earthquakes missing location data\n`);

        for (const earthquake of earthquakes) {
            const { lat, lon } = earthquake.data.properties;
            if (!lat || !lon) {
                console.log(`⚠️ Skipping record with missing coordinates`);
                continue;
            }

            const { display_name, state, country, country_code } = await getLocationInfo(lat, lon);

            const updateFields = {
                "data.properties.display_name": display_name,
                "data.properties.state": state,
                "data.properties.country": country,
                "data.properties.country_code": country_code
            };

            await collection.updateOne(
                { _id: earthquake._id },
                { $set: updateFields }
            );

            updatedCount++;
            console.log(`🛠️  Updating ${updatedCount} out of ${totalDocs} total docs...`);
        }

        console.log(`\n✅ Update complete! ${updatedCount} out of ${totalDocs} documents were updated.`);
    } catch (error) {
        console.error("❌ MongoDB Error:", error.message);
    } finally {
        await client.close();
    }
}

// Run the update function
updateEarthquakeLocations();