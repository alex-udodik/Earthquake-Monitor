const axios = require("axios");
const fs = require("fs-extra");
const path = require("path");

const BASE_URL = "https://earthquake.usgs.gov/fdsnws/event/1/query";
const LIMIT = 20000;
const OUTPUT_DIR = path.join(__dirname, "earthquake_data");
const ORDER_BY = "time-asc";

// Split into decade ranges to avoid 503s
const timeRanges = [
    { start: "1900-01-01", end: "1910-01-01" },
    { start: "1910-01-01", end: "1920-01-01" },
    { start: "1920-01-01", end: "1930-01-01" },
    { start: "1930-01-01", end: "1940-01-01" },
    { start: "1940-01-01", end: "1950-01-01" },
    { start: "1950-01-01", end: "1960-01-01" },
    { start: "1960-01-01", end: "1970-01-01" },
    { start: "1970-01-01", end: "1980-01-01" },
    { start: "1980-01-01", end: "1990-01-01" },
    { start: "1990-01-01", end: "2000-01-01" },
    { start: "2000-01-01", end: "2010-01-01" },
    { start: "2010-01-01", end: "2020-01-01" },
    { start: "2020-01-01", end: "2024-12-31" }
];

async function fetchBatch(start, end, batchNum) {
    const params = {
        format: "geojson",
        starttime: start,
        endtime: end,
        limit: LIMIT,
        offset: 1,
        orderby: ORDER_BY
    };

    console.log(`📡 Fetching ${start} → ${end}...`);
    try {
        const { data } = await axios.get(BASE_URL, { params });

        if (!data?.features?.length) {
            console.log(`⚠️ No data in this window (${start} → ${end})`);
            return false;
        }

        const filename = path.join(OUTPUT_DIR, `earthquakes_batch_${batchNum}.json`);
        await fs.writeJson(filename, data, { spaces: 2 });
        console.log(`✅ Saved ${filename} (${data.features.length} events)`);
        return true;
    } catch (err) {
        console.error(`❌ Error for ${start} → ${end}:`, err.message);
        return false;
    }
}

async function run() {
    await fs.ensureDir(OUTPUT_DIR);
    let batchNum = 1;

    for (const range of timeRanges) {
        const success = await fetchBatch(range.start, range.end, batchNum);
        if (success) batchNum++;
        await new Promise(res => setTimeout(res, 1500)); // polite delay
    }

    console.log("🎉 Done fetching historical earthquake data.");
}

run();
