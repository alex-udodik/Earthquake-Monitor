const axios = require("axios");
const fs = require("fs-extra");
const path = require("path");

const BASE_URL = "https://earthquake.usgs.gov/fdsnws/event/1/query";
const LIMIT = 20000;
const OUTPUT_DIR = path.join(__dirname, "earthquake_data");
const ORDER_BY = "time-asc";

// 📆 Generate 3-month time ranges from yearStart to yearEnd
function generateQuarterRanges(yearStart, yearEnd) {
    const ranges = [];
    for (let year = yearStart; year <= yearEnd; year++) {
        ranges.push({ start: `${year}-01-01`, end: `${year}-04-01` });
        ranges.push({ start: `${year}-04-01`, end: `${year}-07-01` });
        ranges.push({ start: `${year}-07-01`, end: `${year}-10-01` });
        ranges.push({ start: `${year}-10-01`, end: `${year + 1}-01-01` });
    }
    return ranges;
}

const timeRanges = generateQuarterRanges(2025, 2026); // ← adjust year range here

function delay(ms) {
    return new Promise((res) => setTimeout(res, ms));
}

async function fetchBatch(start, end, batchNum) {
    let offset = 1;
    let page = 1;
    let totalSaved = 0;
    let retries = 0;
    const MAX_RETRIES = 5;

    while (true) {
        const params = {
            format: "geojson",
            starttime: start,
            endtime: end,
            limit: LIMIT,
            offset,
            orderby: ORDER_BY
        };

        console.log(`📡 Fetching ${start} → ${end} | page ${page} (offset=${offset})...`);

        try {
            const { data } = await axios.get(BASE_URL, { params });

            if (!data?.features?.length) {
                console.log("⚠️ No more results in this range.");
                break;
            }

            const filename = path.join(
                OUTPUT_DIR,
                `earthquakes_batch_${batchNum}_page_${page}.json`
            );
            await fs.writeJson(filename, data, { spaces: 2 });
            console.log(`✅ Saved ${filename} (${data.features.length} events)`);

            totalSaved += data.features.length;
            retries = 0;

            if (data.features.length < LIMIT) break;

            offset += LIMIT;
            page++;
            await delay(1000); // between pages
        } catch (err) {
            const status = err.response?.status;
            if ((status === 503 || status === 504) && retries < MAX_RETRIES) {
                retries++;
                const wait = 10000 * retries;
                console.warn(`⚠️ ${status} received. Retrying in ${wait / 1000}s...`);
                await delay(wait);
                continue;
            }

            console.error(`❌ Error for ${start} → ${end}, page ${page}:`, err.message);
            break;
        }
    }

    console.log(`📦 Total saved for ${start} → ${end}: ${totalSaved} events\n`);
    return totalSaved > 0;
}

async function run() {
    await fs.ensureDir(OUTPUT_DIR);
    let batchNum = 1;

    for (const range of timeRanges) {
        const success = await fetchBatch(range.start, range.end, batchNum);
        if (success) batchNum++;
        await delay(1000); // wait between chunks
    }

    console.log("🎉 All quarterly chunks fetched.");
}

run();