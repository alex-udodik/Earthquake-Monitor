package com.eq.server;

import com.eq.util.DataReserve;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class FlutterWebSocketController {


    @MessageMapping("/hello")
    @SendTo("/topic/greetings")
    public static String greeting(String message) throws Exception {
        //Thread.sleep(1000); // simulated delay
        System.out.println(message);
        return DataReserve.DoublyLinkedList.getInstance().toString();
    }
}
