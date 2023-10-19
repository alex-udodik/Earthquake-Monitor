package com.eq.server;

import com.eq.serialized.earthquake.Earthquake;
import com.google.gson.Gson;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class WebSocketController {

    @MessageMapping("/live")
    public String sendMessage(String message) {
        System.out.println(message);

        Gson gson = new Gson();
        String jsonString = message;
        Earthquake earthquakeEvent = gson.fromJson(jsonString, Earthquake.class);

        System.out.println("Received Earthquake data");
        System.out.println(earthquakeEvent.getAction());
        System.out.println(earthquakeEvent.getData().getProperties().getFlynn_region());
        return "You said: " + message;
    }

}
