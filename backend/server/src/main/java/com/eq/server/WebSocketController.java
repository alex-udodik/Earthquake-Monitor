package com.eq.server;

import com.eq.database.mongodb.MongoDBConnection;
import com.eq.database.mongodb.MongoUtil;
import com.eq.enums.Constants;
import com.eq.serialized.earthquake.Earthquake;
import com.eq.serialized.earthquake.Util;
import com.google.gson.Gson;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/server/live")
public class WebSocketController {

    @PostMapping("/receive")
    public ResponseEntity<String> insertIntoMongoDB(@RequestBody Earthquake earthquakeEvent) throws Exception {

        System.out.println("Incoming Earthquake event to /server/live/receive");
        System.out.println(earthquakeEvent.getAction() + " with id: " + earthquakeEvent.getData().getId());
        System.out.println(earthquakeEvent.getData().getProperties().getFlynn_region());
        System.out.println("Magnitude: " + earthquakeEvent.getData().getProperties().getMag());
        System.out.println("Time: " + earthquakeEvent.getData().getProperties().getTime());

        String json = Util.ConvertToJSON(earthquakeEvent);
        Document document = Document.parse(json);

        MongoUtil.replaceDocument(Constants.MongoConstants.DATABASE_EARTHQUAKESDATA,
                Constants.MongoConstants.COLLECTION_EARTHQUAKE,
                document,
                earthquakeEvent.getData().getId());

        String response = "Request data received: " + earthquakeEvent.getAction();
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @MessageMapping("/clientLogs")
    public void displayClientLogs(String message) {
        System.out.println("LOG from websocket client: " + message);
    }
}
