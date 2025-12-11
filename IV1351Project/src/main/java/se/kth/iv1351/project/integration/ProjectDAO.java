package se.kth.iv1351.project.integration;

import java.sql.*;
import java.util.*;

public class ProjectDAO {
    private Connection connection;
    private static final String URL = "jdbc:postgresql://localhost:5432/iv1351";
    private static final String USER = "postgres";
    private static final String PWD = "qzEvj%8s$Ne4@8";

    public ProjectDAO() throws ProjectDBException {
        try {
            connection = DriverManager.getConnection(URL, USER, PWD);
            connection.setAutoCommit(false);
        } catch (SQLException e) {
            throw new ProjectDBException("Could not connect to DB: " + e.getMessage());
        }
    }
    
    //Transaction Management
    public void startTransaction() throws ProjectDBException {}
    
    public void commit() throws ProjectDBException {
        try { connection.commit(); } catch (SQLException e) { throw new ProjectDBException("Commit failed", e); }
    }
    
    public void rollback() throws ProjectDBException {
        try { connection.rollback(); } catch (SQLException e) { throw new ProjectDBException("Rollback failed", e); }
    }

    //CRUD Operations

    public void lockEmployeeForUpdate(int empId) throws ProjectDBException {
        String sql = "SELECT employee_id FROM employee WHERE employee_id = ? FOR NO KEY UPDATE";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, empId);
            stmt.executeQuery();
        } catch (SQLException e) { throw new ProjectDBException("Lock failed", e); }
    }

    public double getAverageSalary() throws ProjectDBException {
        String sql = "SELECT AVG(salary) FROM employee";
        try (Statement stmt = connection.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) { throw new ProjectDBException("Query failed", e); }
        return 0;
    }

    public List<Map<String, Object>> findPlannedActivities(int courseInstanceId) throws ProjectDBException {
        String sql = "SELECT pa.planned_hours, ta.factor " +
                     "FROM planned_activity pa " +
                     "JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id " +
                     "WHERE pa.course_instance_id = ?";
        List<Map<String, Object>> result = new ArrayList<>();
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, courseInstanceId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("hours", rs.getDouble("planned_hours"));
                row.put("factor", rs.getDouble("factor"));
                result.add(row);
            }
        } catch (SQLException e) { throw new ProjectDBException("Query failed", e); }
        return result;
    }

    public List<Map<String, Object>> findAllocations(int courseInstanceId) throws ProjectDBException {
        String sql = "SELECT wa.allocated_hours, ta.factor, e.salary " +
                     "FROM work_allocation wa " +
                     "JOIN planned_activity pa ON wa.planned_activity_id = pa.planned_activity_id " +
                     "JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id " +
                     "JOIN employee e ON wa.employee_id = e.employee_id " +
                     "WHERE pa.course_instance_id = ?";
        List<Map<String, Object>> result = new ArrayList<>();
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, courseInstanceId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("hours", rs.getDouble("allocated_hours"));
                row.put("factor", rs.getDouble("factor"));
                row.put("salary", rs.getDouble("salary"));
                result.add(row);
            }
        } catch (SQLException e) { throw new ProjectDBException("Query failed", e); }
        return result;
    }

    public Map<String, Object> findCourseInstance(int id, boolean lock) throws ProjectDBException {
        String sql = "SELECT ci.*, cl.hp FROM course_instance ci " +
                     "JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id " +
                     "WHERE course_instance_id = ?" + (lock ? " FOR NO KEY UPDATE" : "");
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("num_students", rs.getInt("num_students"));
                map.put("hp", rs.getDouble("hp"));
                map.put("study_period", rs.getString("study_period"));
                map.put("study_year", rs.getInt("study_year"));
                return map;
            } else {
                throw new ProjectDBException("Course Instance not found: " + id);
            }
        } catch (SQLException e) { throw new ProjectDBException("Query failed", e); }
    }

    public void updateCourseInstanceStudents(int id, int count) throws ProjectDBException {
        try (PreparedStatement stmt = connection.prepareStatement(
                "UPDATE course_instance SET num_students = ? WHERE course_instance_id = ?")) {
            stmt.setInt(1, count);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        } catch (SQLException e) { throw new ProjectDBException("Update failed", e); }
    }

    public void updatePlannedActivityHours(int instanceId, String activityName, double hours) throws ProjectDBException {
        String sql = "UPDATE planned_activity SET planned_hours = ? " +
                     "WHERE course_instance_id = ? AND teaching_activity_id = " +
                     "(SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setDouble(1, hours);
            stmt.setInt(2, instanceId);
            stmt.setString(3, activityName);
            stmt.executeUpdate();
        } catch (SQLException e) { throw new ProjectDBException("Update failed", e); }
    }

    public int countTeacherCoursesInPeriod(int empId, String period, int year) throws ProjectDBException {
        String sql = "SELECT COUNT(DISTINCT ci.course_instance_id) " +
                     "FROM work_allocation wa " +
                     "JOIN planned_activity pa ON wa.planned_activity_id = pa.planned_activity_id " +
                     "JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id " +
                     "WHERE wa.employee_id = ? AND ci.study_period = ? AND ci.study_year = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, empId);
            stmt.setString(2, period);
            stmt.setInt(3, year);
            ResultSet rs = stmt.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) { throw new ProjectDBException("Query failed", e); }
    }

    public boolean isTeacherInCourse(int empId, int instanceId) throws ProjectDBException {
        String sql = "SELECT 1 FROM work_allocation wa " +
                     "JOIN planned_activity pa ON wa.planned_activity_id = pa.planned_activity_id " +
                     "WHERE wa.employee_id = ? AND pa.course_instance_id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, empId);
            stmt.setInt(2, instanceId);
            return stmt.executeQuery().next();
        } catch (SQLException e) { throw new ProjectDBException("Query failed", e); }
    }

    public int findPlannedActivityId(int instanceId, String activityName) throws ProjectDBException {
        String sql = "SELECT planned_activity_id FROM planned_activity pa " +
                     "JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id " +
                     "WHERE pa.course_instance_id = ? AND ta.activity_name = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, instanceId);
            stmt.setString(2, activityName);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
            else throw new ProjectDBException("Activity '" + activityName + "' not planned for this course instance.");
        } catch (SQLException e) { throw new ProjectDBException("Query failed", e); }
    }

    public void createAllocation(int plannedActivityId, int empId, int hours) throws ProjectDBException {
        try (PreparedStatement stmt = connection.prepareStatement(
                "INSERT INTO work_allocation (planned_activity_id, employee_id, allocated_hours) VALUES (?, ?, ?)")) {
            stmt.setInt(1, plannedActivityId);
            stmt.setInt(2, empId);
            stmt.setInt(3, hours);
            stmt.executeUpdate();
        } catch (SQLException e) { throw new ProjectDBException("Insert failed", e); }
    }

    public void deleteAllocation(int allocationId) throws ProjectDBException {
        try (PreparedStatement stmt = connection.prepareStatement(
                "DELETE FROM work_allocation WHERE work_allocation_id = ?")) {
            stmt.setInt(1, allocationId);
            stmt.executeUpdate();
        } catch (SQLException e) { throw new ProjectDBException("Delete failed", e); }
    }
    
    public void createTeachingActivity(String name, double factor) throws ProjectDBException {
        try (PreparedStatement stmt = connection.prepareStatement(
                "INSERT INTO teaching_activity (activity_name, factor) VALUES (?, ?)")) {
            stmt.setString(1, name);
            stmt.setDouble(2, factor);
            stmt.executeUpdate();
        } catch (SQLException e) { throw new ProjectDBException("Insert failed", e); }
    }
}