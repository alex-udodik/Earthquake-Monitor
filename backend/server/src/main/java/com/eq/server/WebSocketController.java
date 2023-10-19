package com.eq.server;

import com.eq.database.mongodb.MongoDBConnection;
import com.eq.enums.Constants;
import com.eq.serialized.earthquake.Earthquake;
import com.google.gson.Gson;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class WebSocketController {

    @MessageMapping("/live")
    public void insertIntoMongoDB(String message) {

        Gson gson = new Gson();
        String jsonString = message;
        Earthquake earthquakeEvent = gson.fromJson(jsonString, Earthquake.class);

        System.out.println("Received Earthquake data");
        System.out.println(earthquakeEvent.getAction());
        System.out.println(earthquakeEvent.getData().getProperties().getFlynn_region());

        MongoClient mongoClient = MongoDBConnection.getInstance();
        MongoDatabase database = mongoClient.getDatabase(Constants.MongoConstants.DATABASE_EARTHQUAKESDATA);
        MongoCollection<Document> collection = database.getCollection(Constants.MongoConstants.COLLECTION_EARTHQUAKE);

        Document document = Document.parse(message);
        collection.insertOne(document);
    }
}
