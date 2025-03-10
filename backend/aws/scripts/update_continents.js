require('dotenv').config();
const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const { MongoClient } = require('mongodb');

// ✅ FIXED: Correct MongoDB authentication
const mongodbURI = `mongodb+srv://${process.env.MONGOUSERNAME}:${process.env.MONGOPASSWORD}@${process.env.MONGOCLUSTER}.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(mongodbURI);

const DB_NAME = "EarthquakesData";
const COLLECTION_NAME = "Earthquake";

// Function to get region & subregion using Restcountries API
async function getRegionInfo(country) {
    if (!country || country === "Unknown") {
        return { region: "Unknown", subregion: "Unknown" }; // Ensure "Unknown" values
    }

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

    return { region: "Unknown", subregion: "Unknown" }; // Default if lookup fails
}

// Function to update MongoDB with region & subregion info (Handles "Unknown" cases)
async function updateEarthquakeRegions() {
    try {
        await client.connect();
        const db = client.db(DB_NAME);
        const collection = db.collection(COLLECTION_NAME);

        // Find earthquakes missing region & subregion data
        const earthquakes = await collection.find({
            "data.properties.region": { $exists: false }
        }).toArray();
        const totalDocs = earthquakes.length;
        let updatedCount = 0;

        console.log(`🔍 Processing ${totalDocs} earthquakes...`);

        for (const earthquake of earthquakes) {
            const country = earthquake?.data?.properties?.country || "Unknown"; // Ensure country always has a value

            // Fetch region & subregion (Explicitly set "Unknown" if country is missing)
            const { region, subregion } = await getRegionInfo(country);

            // Update MongoDB with region & subregion
            await collection.updateOne(
                { _id: earthquake._id },
                {
                    $set: {
                        "data.properties.region": region,
                        "data.properties.subregion": subregion
                    }
                }
            );

            updatedCount++;
            process.stdout.write(`\r✅ Updated: ${updatedCount}/${totalDocs}`); // Compact Progress Counter
        }

        console.log(`\n✅ Done! Updated ${updatedCount} records.`);
    } catch (error) {
        console.error("❌ MongoDB Error:", error.message);
    } finally {
        await client.close();
    }
}

// Run the update function (MODIFIES MongoDB)
updateEarthquakeRegions();