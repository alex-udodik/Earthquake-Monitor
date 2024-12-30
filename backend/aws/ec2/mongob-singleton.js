const { MongoClient } = require('mongodb');
const dotenv = require('dotenv').config();

var MongoDBSingleton = (function () {

    var instance;
    var count = 0;
    function createInstance() {
        const mongodbURI = `mongodb+srv://${process.env.MONGOUSERNAME}:${process.env.MONGOPASSWORD}@${process.env.MONGOCLUSTER}.mongodb.net/?retryWrites=true&w=majority`;
        var object = new MongoClient(mongodbURI);
        count += 1;
        return object;
    }

    return {
        getInstance: function () {
            if (!instance) {
                instance = createInstance();
            }
            return instance;
        }
    };
})();

module.exports = MongoDBSingleton;