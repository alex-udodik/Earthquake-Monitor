exports = async function (changeEvent) {
    if (changeEvent.operationType !== "insert") {
        return { status: "Skipped: Not an insert operation." };
    }

    const serviceName = "Earthquake-Cluster";
    const dbName = "EarthquakesData";
    const quake = changeEvent.fullDocument;

    const quakeTime = new Date(quake.data.properties.time);
    const countryCode = (quake.data.properties.country_code || "unknown").toLowerCase();
    const country = quake.data.properties.country || "Unknown";
    const state = quake.data.properties.state || "Unknown";
    const mag = quake.data.properties.mag;
    const depth = quake.data.properties.depth;

    const timeSeriesCollection = context.services.get(serviceName)
        .db(dbName)
        .collection("CountryTimeSeries");

    const AWS_GATEWAY_URL = context.values.get("COUNTRY_TIME_SERIES_CACHE_UPDATE_URL"); // Set in Atlas Trigger Values

    const intervals = {
        daily: new Date(Date.UTC(quakeTime.getUTCFullYear(), quakeTime.getUTCMonth(), quakeTime.getUTCDate())),
        weekly: new Date(Date.UTC(quakeTime.getUTCFullYear(), quakeTime.getUTCMonth(), quakeTime.getUTCDate() - quakeTime.getUTCDay())),
        monthly: new Date(Date.UTC(quakeTime.getUTCFullYear(), quakeTime.getUTCMonth(), 1)),
        yearly: new Date(Date.UTC(quakeTime.getUTCFullYear(), 0, 1))
    };

    try {
        await Promise.all(Object.entries(intervals).map(async ([interval, timestamp]) => {
            const filter = {
                country_code: countryCode,
                state,
                interval,
                timestamp
            };

            const existingDoc = await timeSeriesCollection.findOne(filter);

            if (existingDoc) {
                const newCount = existingDoc.count + 1;
                const newAvgMag = ((existingDoc.avgMag * existingDoc.count) + mag) / newCount;
                const newAvgDepth = ((existingDoc.avgDepth * existingDoc.count) + depth) / newCount;

                await timeSeriesCollection.updateOne(filter, {
                    $set: {
                        avgMag: Math.round(newAvgMag * 100) / 100,
                        avgDepth: Math.round(newAvgDepth * 100) / 100
                    },
                    $inc: { count: 1 },
                    $max: { maxMag: mag },
                    $min: { minMag: mag }
                });
            } else {
                await timeSeriesCollection.insertOne({
                    country,
                    country_code: countryCode,
                    state,
                    interval,
                    timestamp,
                    count: 1,
                    avgMag: mag,
                    maxMag: mag,
                    minMag: mag,
                    avgDepth: depth
                });
            }

            // ✅ Fetch updated document
            const updatedDoc = await timeSeriesCollection.findOne(filter);

            // ✅ Send it to AWS HTTP API Gateway
            const response = await context.http.post({
                url: AWS_GATEWAY_URL,
                headers: {
                    'Content-Type': ['application/json']
                },
                body: JSON.stringify(updatedDoc)
            });

            if (response.statusCode !== 200) {
                console.warn(`⚠️ Failed to send to AWS for interval ${interval}`, response.statusCode);
            } else {
                console.log(`✅ Sent ${interval} doc to AWS Gateway`);
            }
        }));

        return { status: "Success: Updated and pushed to AWS API Gateway." };
    } catch (err) {
        console.error("❌ Error:", err.message);
        return { error: err.message };
    }
};