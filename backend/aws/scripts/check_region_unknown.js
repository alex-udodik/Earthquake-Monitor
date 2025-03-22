require('dotenv').config();
const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const { MongoClient } = require('mongodb');

const mongodbURI = `mongodb+srv://${process.env.MONGOUSERNAME}:${process.env.MONGOPASSWORD}@${process.env.MONGOCLUSTER}.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(mongodbURI);

const DB_NAME = "EarthquakesData";
const COLLECTION_NAME = "Earthquake";

// Get region & subregion using country name
async function getRegionInfo(country) {
    if (!country || country === "Unknown") {
        return { region: "Unknown", subregion: "Unknown" };
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
        console.error(`❌ Error fetching region info for ${country}:`, error.message);
    }

    return { region: "Unknown", subregion: "Unknown" };
}

// Main function
async function updateMissingRegionInfo() {
    try {
        await client.connect();
        const db = client.db(DB_NAME);
        const collection = db.collection(COLLECTION_NAME);

        // Find earthquakes where region or subregion is "Unknown"
        const earthquakes = await collection.find({
            $or: [
                { "data.properties.region": "Unknown" },
                { "data.properties.subregion": "Unknown" }
            ]
        }).toArray();

        const totalDocs = earthquakes.length;
        let updatedCount = 0;

        console.log(`🔍 Found ${totalDocs} records with unknown region/subregion\n`);

        for (const earthquake of earthquakes) {
            const country = earthquake?.data?.properties?.country || "Unknown";
            const { region, subregion } = await getRegionInfo(country);

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
            process.stdout.write(`\r✅ Updated ${updatedCount}/${totalDocs}`);
        }

        console.log(`\n🎉 Done! ${updatedCount} documents updated.`);
    } catch (err) {
        console.error("❌ MongoDB Error:", err.message);
    } finally {
        await client.close();
    }
}

updateMissingRegionInfo();