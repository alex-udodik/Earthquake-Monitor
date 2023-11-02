package com.eq.server.controllers;

import com.eq.util.DataReserve;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class FlutterWebSocketController {

    @MessageMapping("/hello")
    @SendTo("/topic/greetings")
    public String greeting(String message) throws Exception {
        return DataReserve.DoublyLinkedList.getInstance().getJson();
    }

}
