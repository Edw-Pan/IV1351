package se.kth.iv1351.project.startup;

import se.kth.iv1351.project.controller.Controller;
import se.kth.iv1351.project.view.BlockingInterpreter;
import se.kth.iv1351.project.integration.ProjectDBException;

public class Main {
    public static void main(String[] args) {
        try {
            Controller controller = new Controller();
            new BlockingInterpreter(controller).handleCmds();
        } catch (ProjectDBException e) {
            System.err.println("Could not connect to the database.");
            e.printStackTrace();
        }
    }
}