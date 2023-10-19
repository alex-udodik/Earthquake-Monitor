package com.eq.server;


import org.quartz.*;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RestController;
import java.io.IOException;
import java.net.*;

@SpringBootApplication
@RestController
public class ServerApplication {

	public static void main(String[] args) throws SchedulerException, javax.websocket.DeploymentException, URISyntaxException, IOException {
		SpringApplication.run(ServerApplication.class, args);

	}


}
