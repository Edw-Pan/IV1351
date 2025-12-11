package se.kth.iv1351.project.view;

import java.util.Scanner;
import se.kth.iv1351.project.controller.Controller;
import se.kth.iv1351.project.model.CourseCostDTO;

public class BlockingInterpreter {
    private final Controller controller;
    private final Scanner scanner = new Scanner(System.in);
    private boolean keepReceivingCmds = false;

    public BlockingInterpreter(Controller controller) {
        this.controller = controller;
    }

    public void handleCmds() {
        keepReceivingCmds = true;
        System.out.println("Started. Commands: COST, STUDENT, ALLOC, DEALLOC, NEW_ACT, QUIT");
        
        while (keepReceivingCmds) {
            try {
                System.out.print("> ");
                String cmd = scanner.next().toUpperCase();
                
                switch (cmd) {
                    case "COST":
                        System.out.print("Course Instance ID: ");
                        int courseId = scanner.nextInt();
                        CourseCostDTO cost = controller.computeCourseCost(courseId);
                        System.out.println("Planned Cost: " + cost.getPlannedCost() + " kr");
                        System.out.println("Actual Cost:  " + cost.getActualCost() + " kr");
                        break;
                        
                    case "STUDENT":
                        System.out.print("Course Instance ID: ");
                        int cId = scanner.nextInt();
                        System.out.print("Increase count by: ");
                        int increase = scanner.nextInt();
                        controller.increaseStudentCount(cId, increase);
                        System.out.println("Students updated.");
                        break;
                        
                    case "ALLOC":
                        System.out.print("Course Instance ID: ");
                        int instId = scanner.nextInt();
                        System.out.print("Employee ID: ");
                        int empId = scanner.nextInt();
                        System.out.print("Activity (Lecture/Lab/etc): ");
                        String act = scanner.next();
                        System.out.print("Hours: ");
                        int hours = scanner.nextInt();
                        controller.allocateTeacher(instId, empId, act, hours);
                        System.out.println("Allocation successful.");
                        break;

                    case "DEALLOC":
                        System.out.print("Allocation ID: ");
                        int allocId = scanner.nextInt();
                        controller.deallocateTeacher(allocId);
                        System.out.println("Deallocation successful.");
                        break;

                    case "NEW_ACT":
                        System.out.print("Activity Name: ");
                        String actName = scanner.next();
                        System.out.print("Factor: ");
                        double factor = scanner.nextDouble();
                        controller.createNewActivity(actName, factor);
                        System.out.println("Activity created.");
                        break;
                        
                    case "QUIT":
                        keepReceivingCmds = false;
                        break;
                        
                    default:
                        System.out.println("Unknown command.");
                }
            } catch (Exception e) {
                System.out.println("Operation failed: " + e.getMessage());
                scanner.nextLine();
            }
        }
    }
}