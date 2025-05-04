require('dotenv').config();
const { MongoClient } = require('mongodb');

// === MongoDB connection ===
const mongodbURI = `mongodb+srv://${process.env.MONGOUSERNAME}:${process.env.MONGOPASSWORD}@${process.env.MONGOCLUSTER}.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(mongodbURI);

const DB_NAME = "EarthquakesData";
const quakeCollectionName = "Earthquake";
const timeSeriesCollectionName = "CountryTimeSeries";

// === Date Utilities ===
function addDays(date, days) {
    const copy = new Date(date);
    copy.setUTCDate(copy.getUTCDate() + days);
    return copy;
}

function addWeeks(date, weeks) {
    return addDays(date, weeks * 7);
}

function addMonths(date, months) {
    const copy = new Date(date);
    copy.setUTCMonth(copy.getUTCMonth() + months);
    copy.setUTCDate(1);
    return copy;
}

function addYears(date, years) {
    const copy = new Date(date);
    copy.setUTCFullYear(copy.getUTCFullYear() + years);
    copy.setUTCMonth(0);
    copy.setUTCDate(1);
    return copy;
}

function getTimeRange(unit, start) {
    let end;
    switch (unit) {
        case "daily": end = addDays(start, 1); break;
        case "weekly": end = addWeeks(start, 1); break;
        case "monthly": end = addMonths(start, 1); break;
        case "yearly": end = addYears(start, 1); break;
        default: throw new Error("Invalid unit: " + unit);
    }
    return { start, end };
}

// === Aggregation per time bucket ===
async function generateSnapshot(db, unit, start, end) {
    const quakeCollection = db.collection(quakeCollectionName);
    const timeSeriesCollection = db.collection(timeSeriesCollectionName);

    const results = await quakeCollection.aggregate([
        {
            $match: {
                "data.properties.time": { $gte: start, $lt: end }
            }
        },
        {
            $group: {
                _id: {
                    country_code: "$data.properties.country_code",
                    state: "$data.properties.state"
                },
                country: { $first: "$data.properties.country" },
                state: { $first: "$data.properties.state" },
                count: { $sum: 1 },
                avgMag: { $avg: "$data.properties.mag" },
                maxMag: { $max: "$data.properties.mag" },
                minMag: { $min: "$data.properties.mag" },
                avgDepth: { $avg: "$data.properties.depth" }
            }
        },
        {
            $project: {
                _id: 0,
                country_code: "$_id.country_code",
                country: 1,
                state: 1,
                interval: unit,
                timestamp: start,
                count: 1,
                avgMag: { $round: ["$avgMag", 2] },
                maxMag: 1,
                minMag: 1,
                avgDepth: { $round: ["$avgDepth", 2] }
            }
        }
    ]).toArray();

    for (const doc of results) {
        await timeSeriesCollection.updateOne(
            {
                country_code: doc.country_code,
                state: doc.state,
                interval: doc.interval,
                timestamp: doc.timestamp
            },
            { $set: doc },
            { upsert: true }
        );
    }

    if (results.length > 0) {
        const ts = start.toISOString().split("T")[0];
        console.log(`✅ ${unit.padEnd(7)} ${ts} → ${results.length} snapshot(s)`);
    }
}

// === Main Runner ===
(async function main() {
    try {
        await client.connect();
        const db = client.db(DB_NAME);
        const quakeCollection = db.collection(quakeCollectionName);

        // Find min/max dates
        const extremes = await quakeCollection.aggregate([
            {
                $group: {
                    _id: null,
                    min: { $min: "$data.properties.time" },
                    max: { $max: "$data.properties.time" }
                }
            }
        ]).toArray();

        if (!extremes.length) {
            console.log("⚠️ No data found.");
            return;
        }

        const minDate = new Date(extremes[0].min);
        const maxDate = new Date(extremes[0].max);
        console.log(`📆 Date range: ${minDate.toISOString()} → ${maxDate.toISOString()}`);

        const units = ["daily", "weekly", "monthly", "yearly"];

        for (const unit of units) {
            console.log(`\n⏳ Generating ${unit} snapshots...`);
            let current = new Date(minDate);
            // Normalize time start
            switch (unit) {
                case "daily":
                case "weekly":
                    current.setUTCHours(0, 0, 0, 0);
                    break;
                case "monthly":
                    current = new Date(Date.UTC(current.getUTCFullYear(), current.getUTCMonth(), 1));
                    break;
                case "yearly":
                    current = new Date(Date.UTC(current.getUTCFullYear(), 0, 1));
                    break;
            }

            while (current < maxDate) {
                const { start, end } = getTimeRange(unit, current);
                await generateSnapshot(db, unit, start, end);
                current = end;
            }
        }

        console.log("\n🎉 All historical state-level intervals generated.");
    } catch (err) {
        console.error("❌ Error:", err.message);
    } finally {
        await client.close();
    }
})();//