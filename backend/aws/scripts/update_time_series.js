require('dotenv').config();
const { MongoClient } = require('mongodb');
const { Redis } = require('@upstash/redis');

const mongoUri = `mongodb+srv://${process.env.MONGOUSERNAME}:${process.env.MONGOPASSWORD}@${process.env.MONGOCLUSTER}.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(mongoUri);

const redis = new Redis({
    url: 'https://selected-bull-34594.upstash.io',   // e.g., https://selected-bull-34594.upstash.io
    token: process.env.UPSTASH_TOKEN
});

const DB_NAME = "EarthquakesData";
const COLLECTION_NAME = "CountryTimeSeries";

async function deleteOldStateKeys() {
    try {
        console.log("🧹 Checking for old country_state_interval keys...");

        const allKeys = await redis.keys('*');
        const intervals = ['daily', 'weekly', 'monthly', 'yearly'];

        const keysToDelete = allKeys.filter(key => {
            const parts = key.split('_');
            const last = parts[parts.length - 1];
            return intervals.includes(last) && parts.length >= 3;
        });

        if (keysToDelete.length === 0) {
            console.log("✅ No old keys found.");
            return;
        }

        console.log(`🚮 Deleting ${keysToDelete.length} old keys...`);

        for (const key of keysToDelete) {
            await redis.del(key);
            console.log(`🗑️ Deleted: ${key}`);
        }

        console.log("✅ Old country_state_interval keys removed.");
    } catch (err) {
        console.error("❌ Error deleting old keys:", err.message);
    }
}



async function main() {
    try {
        await client.connect();
        const db = client.db(DB_NAME);
        const collection = db.collection(COLLECTION_NAME);

        const docs = await collection.find({}).toArray();
        console.log(`📦 Found ${docs.length} documents in CountryTimeSeries...`);

        // Group by country + interval
        const grouped = {};
        for (const doc of docs) {
            const country_code = (doc.country_code || "unknown").toLowerCase();
            const interval = (doc.interval || "unknown").toLowerCase();
            const key = `${country_code}_${interval}`;

            if (!grouped[key]) grouped[key] = [];
            grouped[key].push(doc);
        }

        // Sort and insert into Redis
        for (const [key, docArray] of Object.entries(grouped)) {
            docArray.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
            await redis.set(key, docArray);
            console.log(`✅ Cached ${key} (${docArray.length} docs)`);
        }

        console.log("🎯 Country-level interval cache complete.");
    } catch (err) {
        console.error("❌ Error:", err.message);
    } finally {
        await client.close();
    }
}
//deleteOldStateKeys();
main();
