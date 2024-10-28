const MongoDBSingleton = require('./mongob-singleton');
const { MongoError } = require("mongodb");


module.exports = {

    replaceDocumentOrCreateNew: async function (database, collection, document, filter, options) {
        try {
            const mongodbCollection = getCollection(database, collection);
            return await mongodbCollection.replaceOne(filter, document, options);
        } catch (error) {
            console.log(error.message);
            throw new MongoError(`Failed to update ${document} from ${database}.${collection}`);
        }
    },
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