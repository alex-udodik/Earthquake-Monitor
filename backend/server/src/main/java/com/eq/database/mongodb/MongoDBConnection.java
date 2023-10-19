package com.eq.database.mongodb;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import io.github.cdimascio.dotenv.Dotenv;

public class MongoDBConnection {

    private static Dotenv dotenv = Dotenv.configure().load();

    private static String user = dotenv.get("MONGOUSERNAME");
    private static String password =  dotenv.get("MONGOPASSWORD");
    private static String cluster = dotenv.get("MONGOCLUSTER");

    private static String connectionString = (new StringBuilder()
            .append("mongodb+srv://")
            .append(user)
            .append(":")
            .append(password)
            .append("@")
            .append(cluster))
            .append(".mongodb.net/?retryWrites=true&w=majority")
            .toString();

    private static MongoClient mongoClient;

    private MongoDBConnection() { }

    public static MongoClient getInstance() {
        if (mongoClient == null) { mongoClient = MongoClients.create(connectionString); }
        return mongoClient;
    }
}
