package com.eq.server;

import com.eq.database.mongodb.MongoDBConnection;
import com.eq.database.mongodb.MongoUtil;
import com.eq.enums.Constants;
import com.eq.serialized.earthquake.Earthquake;
import com.eq.util.DataReserve;
import com.google.gson.GsonBuilder;
import com.mongodb.client.MongoClient;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.bson.Document;
import org.springframework.web.bind.annotation.RestController;
import com.google.gson.Gson;

import java.util.ArrayList;

@SpringBootApplication
@RestController
public class ServerApplication {

	public static void main(String[] args)  {
		SpringApplication.run(ServerApplication.class, args);
		preStart();
	}

	private static void preStart() {

		MongoClient mongodb = MongoDBConnection.getInstance();

		ArrayList<Document> eqDocs = (ArrayList<Document>) MongoUtil.fetchLastxDocuments(Constants.MongoConstants.DATABASE_EARTHQUAKESDATA,
				Constants.MongoConstants.COLLECTION_EARTHQUAKE, 100);

		ArrayList<Earthquake> earthquakes = new ArrayList<>();

		for (Document doc : eqDocs) {
			Gson gson = new GsonBuilder().create();
			String jsonString = doc.toJson();
			earthquakes.add(gson.fromJson(jsonString, Earthquake.class));
		}

		for (Earthquake eq : earthquakes) {
			DataReserve.DoublyLinkedList.getInstance().add(eq);
		}
	}
}
