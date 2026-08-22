package com.pm.patientservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class PatientServiceApplication {

    public static void main(String[] args) {

        SpringApplication.run(PatientServiceApplication.class, args);
    }

    @GetMapping("/")
    public String welcomePage() {
        return "Hi There, Welcome to Patient Service Module!!curl -v localhost:4000/actuator/health";
    }




}
