package se.kth.iv1351.project.integration;

public class ProjectDBException extends Exception {
    public ProjectDBException(String msg) { super(msg); }
    public ProjectDBException(String msg, Throwable cause) { super(msg, cause); }
}