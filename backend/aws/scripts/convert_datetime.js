require('dotenv').config();
const { MongoClient } = require('mongodb');

// ✅ MongoDB Connection String (Ensure Environment Variables Are Set)
const mongodbURI = `mongodb+srv://${process.env.MONGOUSERNAME}:${process.env.MONGOPASSWORD}@${process.env.MONGOCLUSTER}.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(mongodbURI);

const DB_NAME = "EarthquakesData";
const COLLECTION_NAME = "Earthquake";

// ✅ Function to check if a string is a valid ISO date format
function isISODateString(value) {
    return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/.test(value);
}

// ✅ Function to update MongoDB timestamps (Converts to `Date` format)
async function updateTimestamps() {
    try {
        await client.connect();
        const db = client.db(DB_NAME);
        const collection = db.collection(COLLECTION_NAME);

        // Find documents where "lastupdate" or "time" are stored as strings
        const earthquakes = await collection.find({
            $or: [
                { "data.properties.lastupdate": { $type: "string" } },
                { "data.properties.time": { $type: "string" } }
            ]
        }).toArray();

        const totalDocs = earthquakes.length;
        let updatedCount = 0;

        console.log(`🔍 Processing ${totalDocs} documents...`);

        for (const earthquake of earthquakes) {
            let updateFields = {};

            const lastupdate = earthquake?.data?.properties?.lastupdate;
            const time = earthquake?.data?.properties?.time;

            // Convert "lastupdate" if it's a valid string
            if (isISODateString(lastupdate)) {
                updateFields["data.properties.lastupdate"] = new Date(lastupdate);
            }

            // Convert "time" if it's a valid string
            if (isISODateString(time)) {
                updateFields["data.properties.time"] = new Date(time);
            }

            // Only update if there are changes
            if (Object.keys(updateFields).length > 0) {
                await collection.updateOne(
                    { _id: earthquake._id },
                    { $set: updateFields }
                );

                updatedCount++;
                process.stdout.write(`\r✅ Updated: ${updatedCount}/${totalDocs}`); // Live progress update
            }
        }

        console.log(`\n✅ Done! Converted timestamps in ${updatedCount} records.`);
    } catch (error) {
        console.error("❌ MongoDB Error:", error.message);
    } finally {
        await client.close();
    }
}

// Run the update function (MODIFIES MongoDB)
updateTimestamps();
