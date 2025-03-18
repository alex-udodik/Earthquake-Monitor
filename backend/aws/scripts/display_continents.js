require('dotenv').config();
const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const { MongoClient } = require('mongodb');

const mongodbURI = `mongodb+srv://${process.env.MONGOUSERNAME}:${process.env.MONGOPASSWORD}@${process.env.MONGOCLUSTER}.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(mongodbURI);

const DB_NAME = "EarthquakesData";
const COLLECTION_NAME = "Earthquake";

// Function to get region & subregion using Restcountries API
async function getRegionInfo(country) {
    const url = `https://restcountries.com/v3.1/name/${encodeURIComponent(country)}?fields=region,subregion`;

    try {
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

// Function to fetch and display region & subregion (WITHOUT updating MongoDB)
async function displayEarthquakeRegions() {
    try {
        await client.connect();
        const db = client.db(DB_NAME);
        const collection = db.collection(COLLECTION_NAME);

        // Find earthquakes missing region & subregion data
        const earthquakes = await collection.find({
            "data.properties.region": { $exists: false }
        }).toArray();
        const totalDocs = earthquakes.length;
        let processedCount = 0;

        console.log(`🔍 Processing ${totalDocs} earthquakes missing region data...\n`);

        for (const earthquake of earthquakes) {
            const { country } = earthquake.data.properties;
            if (!country || country === "Unknown") {
                console.log(`⚠️ Skipping: Missing country`);
                continue;
            }

            const { region, subregion } = await getRegionInfo(country);

            // Display results without modifying MongoDB
            console.log(`🌍 ${earthquake.data.id}: ${country}`);
            console.log(`   - Region: ${region}`);
            console.log(`   - Subregion: ${subregion}`);
            console.log("------------------------------------------------");

            processedCount++;
        }

        console.log(`\n✅ Done! Processed ${processedCount} out of ${totalDocs} records.`);
    } catch (error) {
        console.error("❌ MongoDB Error:", error.message);
    } finally {
        await client.close();
    }
}

// Run the test function (DOES NOT modify MongoDB)
displayEarthquakeRegions();