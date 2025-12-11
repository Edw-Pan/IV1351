package se.kth.iv1351.project.controller;

import se.kth.iv1351.project.integration.ProjectDAO;
import se.kth.iv1351.project.integration.ProjectDBException;
import se.kth.iv1351.project.model.CourseCostDTO;
import java.util.List;
import java.util.Map;

public class Controller {
    private final ProjectDAO projectDb;

    public Controller() throws ProjectDBException {
        this.projectDb = new ProjectDAO();
    }

    
    public CourseCostDTO computeCourseCost(int courseInstanceId) throws ProjectDBException {
        try {
            projectDb.startTransaction();
            
            double avgSalary = projectDb.getAverageSalary();
            
            // Planned Activities and Planned Cost
            // Formula: Sum(Hours * Factor) * (AvgSalary / 160)  we are assuming a 160-hour month
            List<Map<String, Object>> plannedActs = projectDb.findPlannedActivities(courseInstanceId);
            double plannedHoursTotal = 0;
            for (Map<String, Object> row : plannedActs) {
                double hours = ((Number) row.get("hours")).doubleValue();
                double factor = ((Number) row.get("factor")).doubleValue();
                plannedHoursTotal += (hours * factor);
            }
            double plannedCost = plannedHoursTotal * (avgSalary / 160.0);

            // Actual Allocations and Actual Cost
            // Formula: Sum(Hours * Factor * (TeacherSalary / 160))
            List<Map<String, Object>> allocations = projectDb.findAllocations(courseInstanceId);
            double actualCost = 0;
            for (Map<String, Object> row : allocations) {
                double hours = ((Number) row.get("hours")).doubleValue();
                double factor = ((Number) row.get("factor")).doubleValue();
                double salary = ((Number) row.get("salary")).doubleValue();
                
                actualCost += (hours * factor) * (salary / 160.0);
            }

            projectDb.commit();
            return new CourseCostDTO(plannedCost, actualCost);
        } catch (Exception e) {
            projectDb.rollback();
            throw e;
        }
    }

    
     //Update students and Recalculate derived Admin/Exam hours.
     
    public void increaseStudentCount(int courseInstanceId, int increase) throws ProjectDBException {
        try {
            projectDb.startTransaction();
            
            
            Map<String, Object> course = projectDb.findCourseInstance(courseInstanceId, true); 
            int currentStudents = (int) course.get("num_students");
            int newCount = currentStudents + increase;
            double hp = ((Number) course.get("hp")).doubleValue();
            
            
            projectDb.updateCourseInstanceStudents(courseInstanceId, newCount);
            
            // Exam = 32 + 0.725 * Students
            // Admin = 2 * HP + 28 + 0.2 * Students
            
            double examHours = 32 + 0.725 * newCount;
            double adminHours = (2 * hp) + 28 + 0.2 * newCount;
            
            projectDb.updatePlannedActivityHours(courseInstanceId, "Exam", examHours);
            projectDb.updatePlannedActivityHours(courseInstanceId, "Admin", adminHours);
            
            projectDb.commit();
        } catch (Exception e) {
            projectDb.rollback();
            throw e;
        }
    }

    //Allocate Teacher.
      
      
     
    public void allocateTeacher(int courseInstanceId, int employeeId, String activityName, int hours) throws ProjectDBException {
        try {
            projectDb.startTransaction();

            projectDb.lockEmployeeForUpdate(employeeId);
            
            // Max 4 courses
            Map<String, Object> course = projectDb.findCourseInstance(courseInstanceId, false);
            String period = (String) course.get("study_period");
            int year = (int) course.get("study_year");
            
            int courseCount = projectDb.countTeacherCoursesInPeriod(employeeId, period, year);
            
            // Check if already in course
            boolean alreadyInCourse = projectDb.isTeacherInCourse(employeeId, courseInstanceId);
            
            if (!alreadyInCourse && courseCount >= 4) {
                throw new ProjectDBException("Constraint Violation: Teacher already has " + courseCount + " courses in period " + period);
            }
            
            // Allocation
            int plannedActivityId = projectDb.findPlannedActivityId(courseInstanceId, activityName);
            projectDb.createAllocation(plannedActivityId, employeeId, hours);
            
            projectDb.commit();
        } catch (Exception e) {
            projectDb.rollback();
            throw e;
        }
    }

    public void deallocateTeacher(int allocationId) throws ProjectDBException {
        try {
            projectDb.startTransaction();
            projectDb.deleteAllocation(allocationId);
            projectDb.commit();
        } catch (Exception e) {
            projectDb.rollback();
            throw e;
        }
    }
    
    // Add activity.
     
    public void createNewActivity(String name, double factor) throws ProjectDBException {
         try {
            projectDb.startTransaction();
            projectDb.createTeachingActivity(name, factor);
            projectDb.commit();
        } catch (Exception e) {
            projectDb.rollback();
            throw e;
        }
    }
}