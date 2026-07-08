const MongoDBSingleton = require('./mongob-singleton');

module.exports = {
    updateDocument: async function (database, collection, filter, updateData, options) {
        try {
            const mongodbCollection = this.getCollection(database, collection);
            return await mongodbCollection.updateOne(filter, updateData, options);
        } catch (error) {
            console.log(`❌ MongoDB update error: ${error.message}`);
        }
    },

    getLastXDocuments: async function (database, collection, lastX) {
        try {
            const mongodbCollection = this.getCollection(database, collection);
            return await mongodbCollection.find({})
                .sort({ "data.properties.time": -1 }) // Sort by time (newest first)
                .limit(lastX)
                .toArray();
        } catch (error) {
            console.log(`❌ MongoDB fetch error: ${error.message}`);
        }
    },

    getCollection: function (database, collection) {
        const databaseInstance = MongoDBSingleton.getInstance();
        return databaseInstance.db(database).collection(collection);
    },

    // Error logs have no natural expiry; without this the collection grows
    // unbounded and can exhaust an Atlas free-tier (M0) storage cap.
    ensureLogsTtlIndex: async function (expireAfterSeconds = 14 * 24 * 60 * 60) {
        try {
            const mongodbCollection = this.getCollection("SeismicPortalWebSocket", "Logs");
            await mongodbCollection.createIndex({ timestamp: 1 }, { expireAfterSeconds });
        } catch (error) {
            console.log(`❌ MongoDB TTL index error: ${error.message}`);
        }
    }
}

