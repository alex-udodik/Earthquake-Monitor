const MongoDBSingleton = require('./mongob-singleton');
const { MongoError } = require("mongodb");


module.exports = {

    replaceDocumentOrCreateNew: async function (database, collection, document, filter, options) {
        try {
            const mongodbCollection = getCollection(database, collection);
            return await mongodbCollection.replaceOne(filter, document, options);
        } catch (error) {
            console.log(error.message);
        }
    },

    getLastXDocuments: async function (database, collection, lastX) {
        try {
            const mongodbCollection = getCollection(database, collection);

            // Fetch last X documents sorted by `data.properties.time` in descending order
            const documents = await mongodbCollection.find({})
                .sort({ "data.properties.time": -1 }) // Sort by time (newest first)
                .limit(lastX)  // Get the last X documents
                .toArray();

            return documents;
        } catch (error) {
            console.log(error.message);
        }
    }

}

const getCollection = function (database, collection) {
    try {
        const databaseInstance = MongoDBSingleton.getInstance()
        const mongodbDatabase = databaseInstance.db(database);
        return mongodbDatabase.collection(collection);
    } catch (error) {
        console.log(error)
        throw new MongoError(`There was an error fetching the mongo instance.`);
    }
}