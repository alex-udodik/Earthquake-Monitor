package com.eq.server.listeners;

import com.eq.server.events.ServerEvent;
import org.springframework.stereotype.Component;

@Component
public class EventListener {

    @org.springframework.context.event.EventListener
    public void onEventOccurred(ServerEvent event) {
        // Prepare the data to broadcast
        // Convert your data to a JSON string
        String jsonData = event.getPayload();
        //broadcastMessage(jsonData);
    }
}
