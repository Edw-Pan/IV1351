-- Optimazation q1
CREATE MATERIALIZED VIEW Mat_View_Planned_Hours AS
SELECT 
    cl.course_code,
    ci.course_instance_id,
    cl.hp,
    ci.study_period,
    ci.study_year, 
    ci.num_students,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor END), 0) AS lecture_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor END), 0) AS tutorial_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN pa.planned_hours * ta.factor END), 0) AS lab_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor END), 0) AS seminar_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Other' THEN pa.planned_hours * ta.factor END), 0) AS other_hours,
    ROUND((2 * cl.hp + 28 + 0.2 * ci.num_students), 2) AS admin_hours,
    ROUND((32 + 0.725 * ci.num_students), 2) AS exam_hours,
    ROUND(
        COALESCE(SUM(
            CASE 
                WHEN ta.activity_name NOT IN ('Admin', 'Exam') 
                THEN pa.planned_hours * ta.factor 
                ELSE 0 
            END
        ), 0) + 
        (2 * cl.hp + 28 + 0.2 * ci.num_students) + 
        (32 + 0.725 * ci.num_students)
    , 2) AS total_hours
FROM course_instance ci
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
LEFT JOIN planned_activity pa ON ci.course_instance_id = pa.course_instance_id
LEFT JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
GROUP BY cl.course_code, ci.course_instance_id, cl.hp, ci.study_period, ci.study_year, ci.num_students;



-- Optimazation q4
CREATE INDEX idx_work_allocation_employee ON work_allocation(employee_id);
CREATE INDEX idx_work_allocation_activity ON work_allocation(planned_activity_id);
CREATE INDEX idx_planned_activity_instance ON planned_activity(course_instance_id);
CREATE INDEX idx_course_instance_period_year ON course_instance(study_period, study_year);