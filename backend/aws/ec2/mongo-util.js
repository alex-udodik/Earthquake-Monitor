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
            // Find last 100 inserted documents
            const documents = await mongodbCollection.find({})
                .sort({ _id: -1 }) // Sort by `_id` in descending order
                .limit(100)         // Limit the result to 100 documents
                .toArray();

            //console.log("Last 100 documents:", documents);
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