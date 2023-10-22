package com.eq.database.mongodb;

import com.eq.serialized.earthquake.Earthquake;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.ReplaceOptions;
import com.mongodb.client.result.UpdateResult;
import org.bson.Document;
import org.bson.conversions.Bson;

import static com.mongodb.client.model.Filters.eq;

public class MongoUtil {

    public static void replaceDocument(String database, String collection, Document replacement, String id) {
        MongoClient client = MongoDBConnection.getInstance();
        MongoDatabase db = client.getDatabase(database);
        MongoCollection<Document> collections = db.getCollection(collection);

        Bson query = eq("data.id", id);

        ReplaceOptions replaceOptions = new ReplaceOptions().upsert(true);
        UpdateResult result = collections.replaceOne(query, replacement, replaceOptions);

        System.out.println("Modified document count: " + result.getModifiedCount());
        System.out.println("Upserted Mongo id: " + result.getUpsertedId()); // only contains a value when an upsert is performed
    }
}