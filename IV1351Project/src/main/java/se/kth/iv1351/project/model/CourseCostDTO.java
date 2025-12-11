package se.kth.iv1351.project.model;

public class CourseCostDTO {
    private final double plannedCost;
    private final double actualCost;

    public CourseCostDTO(double plannedCost, double actualCost) {
        this.plannedCost = plannedCost;
        this.actualCost = actualCost;
    }

    public double getPlannedCost() { return plannedCost; }
    public double getActualCost() { return actualCost; }
}