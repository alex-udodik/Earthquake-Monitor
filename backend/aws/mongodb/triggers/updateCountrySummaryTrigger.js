exports = async function (changeEvent) {
  const serviceName = "Earthquake-Cluster"; // default in Atlas
  const dbName = "EarthquakesData";
  const quakeCollection = context.services
    .get(serviceName)
    .db(dbName)
    .collection("Earthquake");
  const summaryCollection = context.services
    .get(serviceName)
    .db(dbName)
    .collection("CountrySummary");

  try {
    // Only process if it's a new insert
    if (changeEvent.operationType !== "insert") return;

    const summary = await quakeCollection
      .aggregate([
        {
          $group: {
            _id: "$data.properties.country_code",
            country: { $first: "$data.properties.country" },
            count: { $sum: 1 },
            avgMag: { $avg: "$data.properties.mag" },
            maxMag: { $max: "$data.properties.mag" },
            avgDepth: { $avg: "$data.properties.depth" },
            mostRecent: { $max: "$data.properties.time" },
          },
        },
        {
          $project: {
            _id: 0,
            country_code: "$_id",
            country: 1,
            count: 1,
            avgMag: { $round: ["$avgMag", 2] },
            maxMag: 1,
            avgDepth: { $round: ["$avgDepth", 2] },
            mostRecent: 1,
          },
        },
      ])
      .toArray();

    // Optional: wipe and rebuild summary collection
    await summaryCollection.deleteMany({});
    if (summary.length > 0) {
      await summaryCollection.insertMany(summary);
    }

    const resultMsg = `Updated ${summary.length} country summaries at ${new Date().toISOString()}`;
    console.log(resultMsg);

    const webhookUrl = context.values.get("CACHE_UPDATE_URL");

    console.log("Webhook URL:", webhookUrl);

    const httpResponse = await context.http.post({
      url: webhookUrl,
      headers: { "Content-Type": ["application/json"] },
      body: JSON.stringify(summary),
    });

    console.log(
      "Webhook response:",
      httpResponse.statusCode,
      httpResponse.body.text(),
    );

    return resultMsg;
  } catch (err) {
    console.error("Error updating country summaries:", err.message);
    return `Error: ${err.message}`;
  }
};