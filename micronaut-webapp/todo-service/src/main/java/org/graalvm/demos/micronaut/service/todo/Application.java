package org.graalvm.demos.micronaut.service.todo;

import io.micronaut.runtime.Micronaut;

public class Application {

    public static void main(String[] args) {
        System.out.println("JMX on host:port " + System.getProperty("java.rmi.server.hostname") +":"
                + System.getProperty("com.sun.management.jmxremote.port"));
        Micronaut.run(Application.class);
    }
}