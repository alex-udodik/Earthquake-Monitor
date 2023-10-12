package com.eq.server;

import com.eq.scheduling.SimpleJob;
import org.quartz.*;
import org.quartz.impl.StdSchedulerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

import static org.quartz.SimpleScheduleBuilder.simpleSchedule;

@SpringBootApplication
@RestController
public class ServerApplication {

	public static void main(String[] args) throws SchedulerException {
		SpringApplication.run(ServerApplication.class, args);
		onStartup();
	}

	private static void onStartup() throws SchedulerException {
		JobDetail job = JobBuilder.newJob(SimpleJob.class)
				.usingJobData("param", "value") // add a parameter
				.build();

		SchedulerFactory schedulerFactory = new StdSchedulerFactory();
		Scheduler scheduler = schedulerFactory.getScheduler();

		Trigger trigger = TriggerBuilder.newTrigger()
				.startNow()
				.withSchedule(simpleSchedule()
						.withIntervalInMinutes(1)
						.repeatForever())
				.build();
		scheduler.start();
		scheduler.scheduleJob(job, trigger);
	}

	@GetMapping
	public String rootAPI() {
		return "Earthquake Monitor";
	}

}
