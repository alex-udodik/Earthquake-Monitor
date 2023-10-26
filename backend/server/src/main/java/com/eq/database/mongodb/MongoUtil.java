package com.eq.database.mongodb;

import com.eq.serialized.earthquake.Earthquake;
import com.mongodb.client.*;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.ReplaceOptions;
import com.mongodb.client.result.UpdateResult;
import org.bson.Document;
import org.bson.conversions.Bson;

import javax.print.Doc;

import java.util.ArrayList;
import java.util.List;

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

    public static List<Document> fetchLastxDocuments(String database, String coll, int x) {

        MongoClient client = MongoDBConnection.getInstance();
        MongoDatabase db = client.getDatabase(database);
        MongoCollection<Document> collection = db.getCollection(coll);

        List<Document> result = new ArrayList<>();

        // Query for the last x documents
        try (MongoCursor<Document> cursor = collection.find()
                .sort(new Document("_id", -1))
                .limit(x)
                .iterator()) {
            while (cursor.hasNext()) {
                Document document = cursor.next();
                result.add(document);
            }
        } finally {
            //mongoClient.close();
        }

        return result;
    }
}