package com.pm.patientservice.exception;

/**
 * PatientNotFoundException
 */
public class PatientNotFoundException extends RuntimeException{

    public PatientNotFoundException(String string) {
       super(string);
    }

}
