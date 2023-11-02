package com.eq.server;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

@Component
public class TransmissionDispatch {

    @Autowired
    private SimpMessagingTemplate simpMessagingTemplate;

    public void send(String route, String message) {
        simpMessagingTemplate.convertAndSend(route, message);
    }
}
