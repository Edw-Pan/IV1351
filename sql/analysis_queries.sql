-- Query 1: General Planned Hours
CREATE VIEW View_Planned_Hours AS
SELECT 
    cl.course_code,
    ci.course_instance_id,
    cl.hp,
    ci.study_period,
    ci.study_year, 
    ci.num_students,
    -- Breakdowns with multiplication factor applied
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor END), 0) AS lecture_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor END), 0) AS tutorial_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN pa.planned_hours * ta.factor END), 0) AS lab_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor END), 0) AS seminar_hours,
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Other' THEN pa.planned_hours * ta.factor END), 0) AS other_hours,
    
    -- Derived Attributes formulas
    ROUND((2 * cl.hp + 28 + 0.2 * ci.num_students), 2) AS admin_hours,
    ROUND((32 + 0.725 * ci.num_students), 2) AS exam_hours,
    
    -- Total Hours 
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


-- Query 2: Actual Allocated Hours per Teacher
CREATE VIEW View_Teacher_Allocation AS
SELECT 
    cl.course_code,
    ci.course_instance_id,
    cl.hp,
    ci.study_year,
    p.first_name || ' ' || p.last_name AS teacher_name,
    jt.job_title AS designation,
    -- Breakdowns
    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS lecture_hours,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Lab' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Other' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS other_hours,
    SUM(CASE WHEN ta.activity_name = 'Admin' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS admin_hours,
    SUM(CASE WHEN ta.activity_name = 'Exam' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS exam_hours,
    -- Total
    SUM(wa.allocated_hours * ta.factor) AS total_allocated
FROM work_allocation wa
JOIN employee e ON wa.employee_id = e.employee_id
JOIN person p ON e.person_id = p.person_id
JOIN job_title jt ON e.job_title_id = jt.job_title_id
JOIN planned_activity pa ON wa.planned_activity_id = pa.planned_activity_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
GROUP BY cl.course_code, ci.course_instance_id, cl.hp, ci.study_year, p.first_name, p.last_name, jt.job_title;

-- Query 3: Teacher Load per Period
CREATE VIEW View_Teacher_Load AS
SELECT 
    cl.course_code,
    ci.course_instance_id,
    cl.hp,
    ci.study_period,
    ci.study_year,
    p.first_name || ' ' || p.last_name AS teacher_name,
    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS lecture_hours,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Lab' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Other' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS other_hours,
    SUM(CASE WHEN ta.activity_name = 'Admin' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS admin_hours,
    SUM(CASE WHEN ta.activity_name = 'Exam' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS exam_hours,
    SUM(wa.allocated_hours * ta.factor) AS total_hours
FROM work_allocation wa
JOIN employee e ON wa.employee_id = e.employee_id
JOIN person p ON e.person_id = p.person_id
JOIN planned_activity pa ON wa.planned_activity_id = pa.planned_activity_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
GROUP BY cl.course_code, ci.course_instance_id, cl.hp, ci.study_period, ci.study_year, p.first_name, p.last_name;

-- Query 4: Overloaded Teachers
CREATE VIEW View_Overloaded_Teachers AS
SELECT 
    e.employee_id,
    p.first_name || ' ' || p.last_name AS teacher_name,
    ci.study_period,
    ci.study_year,
    COUNT(DISTINCT ci.course_instance_id) AS num_courses
FROM work_allocation wa
JOIN employee e ON wa.employee_id = e.employee_id
JOIN person p ON e.person_id = p.person_id
JOIN planned_activity pa ON wa.planned_activity_id = pa.planned_activity_id
JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
GROUP BY e.employee_id, p.first_name, p.last_name, ci.study_period, ci.study_year
HAVING COUNT(DISTINCT ci.course_instance_id) > 1;


-- Analyze Query 1
EXPLAIN ANALYZE SELECT * FROM View_Planned_Hours;
