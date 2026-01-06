-- 1. STATIC DATA
INSERT INTO job_title (job_title) VALUES 
('Professor'), ('Associate Professor'), ('Lecturer'), ('PhD Student'), ('TA');

INSERT INTO competence (competence_name) VALUES 
('Database Design'), ('Algorithms'), ('Cybersecurity'), 
('Machine Learning'), ('Web Development');

INSERT INTO teaching_activity (activity_name, factor) VALUES 
('Lecture', 3.6), 
('Lab', 2.4), 
('Seminar', 1.8), 
('Tutorial', 2.4),
('Project Supervision', 1.5),
('Admin', 1.0),
('Exam', 1.0),
('Other', 1.0);

INSERT INTO study_period (period_name) VALUES 
('P1'), ('P2'), ('P3'), ('P4');

-- High Grade Requirement: Store "The Number 4" (Max courses per teacher)
INSERT INTO university_config (config_key, config_value) VALUES 
('max_teacher_load_per_period', '4');

-- 2. DEPARTMENTS
INSERT INTO department (department_name) VALUES 
('Computer Science'), 
('Electrical Engineering'), 
('Mathematics');

-- 3. COURSES (Versioning Enabled: course_code is NOT unique)
INSERT INTO course_layout (course_code, course_name, hp, min_students, max_students) VALUES 
('IV1351', 'Data Storage Paradigms', 7.5, 50, 250),
('IX1500', 'Discrete Mathematics', 7.5, 50, 150),
('IV1000', 'Intro to Programming', 10.0, 100, 300),
('IV2000', 'Advanced AI', 7.5, 20, 60),
('IV3000', 'Cybersecurity Basics', 7.5, 30, 100);

-- 4. PEOPLE
INSERT INTO person (personal_number, first_name, last_name, street, zip, city) VALUES 
('19800101-0001', 'Alice', 'Anderson', 'Main St 1', '10001', 'City A'),
('19810202-0002', 'Bob', 'Brown', 'Main St 2', '10002', 'City A'),
('19820303-0003', 'Charlie', 'Clark', 'Main St 3', '10003', 'City A'),
('19830404-0004', 'David', 'Davis', 'Main St 4', '10004', 'City B'),
('19840505-0005', 'Eve', 'Evans', 'Main St 5', '10005', 'City B'),
('19850606-0006', 'Frank', 'Foster', 'Main St 6', '10006', 'City C'),
('19860707-0007', 'Grace', 'Green', 'Main St 7', '10007', 'City C'),
('19870808-0008', 'Heidi', 'Harris', 'Main St 8', '10008', 'City A');

-- 5. EMPLOYEES
INSERT INTO employee (salary, department_id, job_title_id, person_id) VALUES 
(60000, (SELECT department_id FROM department WHERE department_name='Computer Science'), (SELECT job_title_id FROM job_title WHERE job_title='Professor'), (SELECT person_id FROM person WHERE first_name='Alice')),
(55000, (SELECT department_id FROM department WHERE department_name='Computer Science'), (SELECT job_title_id FROM job_title WHERE job_title='Professor'), (SELECT person_id FROM person WHERE first_name='Bob')),
(42000, (SELECT department_id FROM department WHERE department_name='Computer Science'), (SELECT job_title_id FROM job_title WHERE job_title='Lecturer'), (SELECT person_id FROM person WHERE first_name='Charlie')),
(42000, (SELECT department_id FROM department WHERE department_name='Computer Science'), (SELECT job_title_id FROM job_title WHERE job_title='Lecturer'), (SELECT person_id FROM person WHERE first_name='David')),
(32000, (SELECT department_id FROM department WHERE department_name='Computer Science'), (SELECT job_title_id FROM job_title WHERE job_title='PhD Student'), (SELECT person_id FROM person WHERE first_name='Eve')),
(25000, (SELECT department_id FROM department WHERE department_name='Computer Science'), (SELECT job_title_id FROM job_title WHERE job_title='TA'), (SELECT person_id FROM person WHERE first_name='Frank')),
(58000, (SELECT department_id FROM department WHERE department_name='Mathematics'), (SELECT job_title_id FROM job_title WHERE job_title='Professor'), (SELECT person_id FROM person WHERE first_name='Grace'));

UPDATE department SET manager_id = (SELECT employee_id FROM employee JOIN person ON employee.person_id = person.person_id WHERE first_name='Alice') WHERE department_name='Computer Science';
UPDATE department SET manager_id = (SELECT employee_id FROM employee JOIN person ON employee.person_id = person.person_id WHERE first_name='Grace') WHERE department_name='Mathematics';

-- 6. COURSE INSTANCES (2025)
INSERT INTO course_instance (study_year, num_students, course_layout_id, study_period_id) VALUES 
(2025, 200, (SELECT course_layout_id FROM course_layout WHERE course_code='IV1351' LIMIT 1), (SELECT study_period_id FROM study_period WHERE period_name='P1')),
(2025, 120, (SELECT course_layout_id FROM course_layout WHERE course_code='IX1500' LIMIT 1), (SELECT study_period_id FROM study_period WHERE period_name='P1')),
(2025, 280, (SELECT course_layout_id FROM course_layout WHERE course_code='IV1000' LIMIT 1), (SELECT study_period_id FROM study_period WHERE period_name='P1')),
(2025, 50, (SELECT course_layout_id FROM course_layout WHERE course_code='IV2000' LIMIT 1), (SELECT study_period_id FROM study_period WHERE period_name='P2')),
(2025, 80, (SELECT course_layout_id FROM course_layout WHERE course_code='IV3000' LIMIT 1), (SELECT study_period_id FROM study_period WHERE period_name='P2'));

-- 7. PLANNED ACTIVITIES (2025)
-- IV1351 (P1)
INSERT INTO planned_activity (planned_hours, course_instance_id, teaching_activity_id) VALUES 
(20, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IV1351' AND period_name='P1' AND study_year=2025 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lecture')),
(60, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IV1351' AND period_name='P1' AND study_year=2025 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lab')),
(10, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IV1351' AND period_name='P1' AND study_year=2025 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Seminar')),
(50, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IV1351' AND period_name='P1' AND study_year=2025 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Admin')),
(40, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IV1351' AND period_name='P1' AND study_year=2025 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Exam'));

-- IX1500 (P1)
INSERT INTO planned_activity (planned_hours, course_instance_id, teaching_activity_id) VALUES 
(30, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IX1500' AND period_name='P1' AND study_year=2025 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lecture')),
(30, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IX1500' AND period_name='P1' AND study_year=2025 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Tutorial'));

-- IV1000 (P1)
INSERT INTO planned_activity (planned_hours, course_instance_id, teaching_activity_id) VALUES 
(40, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IV1000' AND period_name='P1' AND study_year=2025 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lecture')),
(100, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IV1000' AND period_name='P1' AND study_year=2025 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lab'));

-- 8. WORK ALLOCATIONS (2025)
-- Charlie on IV1351 (Lecture)
INSERT INTO work_allocation (planned_activity_id, employee_id, allocated_hours) VALUES 
((SELECT planned_activity_id FROM planned_activity JOIN course_instance USING(course_instance_id) JOIN course_layout USING(course_layout_id) JOIN teaching_activity USING(teaching_activity_id) WHERE course_code='IV1351' AND activity_name='Lecture' AND study_year=2025 LIMIT 1), (SELECT employee_id FROM employee JOIN person USING(person_id) WHERE first_name='Charlie'), 20);

-- Charlie on IX1500 (Lecture)
INSERT INTO work_allocation (planned_activity_id, employee_id, allocated_hours) VALUES 
((SELECT planned_activity_id FROM planned_activity JOIN course_instance USING(course_instance_id) JOIN course_layout USING(course_layout_id) JOIN teaching_activity USING(teaching_activity_id) WHERE course_code='IX1500' AND activity_name='Lecture' AND study_year=2025 LIMIT 1), (SELECT employee_id FROM employee JOIN person USING(person_id) WHERE first_name='Charlie'), 30);

-- Charlie on IV1000 (Lecture)
INSERT INTO work_allocation (planned_activity_id, employee_id, allocated_hours) VALUES 
((SELECT planned_activity_id FROM planned_activity JOIN course_instance USING(course_instance_id) JOIN course_layout USING(course_layout_id) JOIN teaching_activity USING(teaching_activity_id) WHERE course_code='IV1000' AND activity_name='Lecture' AND study_year=2025 LIMIT 1), (SELECT employee_id FROM employee JOIN person USING(person_id) WHERE first_name='Charlie'), 20);

-- Bob on IV1351 (Labs)
INSERT INTO work_allocation (planned_activity_id, employee_id, allocated_hours) VALUES 
((SELECT planned_activity_id FROM planned_activity JOIN course_instance USING(course_instance_id) JOIN course_layout USING(course_layout_id) JOIN teaching_activity USING(teaching_activity_id) WHERE course_code='IV1351' AND activity_name='Lab' AND study_year=2025 LIMIT 1), (SELECT employee_id FROM employee JOIN person USING(person_id) WHERE first_name='Bob'), 60);

-- Alice on IV1351 (Admin & Exam)
INSERT INTO work_allocation (planned_activity_id, employee_id, allocated_hours) VALUES 
((SELECT planned_activity_id FROM planned_activity JOIN course_instance USING(course_instance_id) JOIN course_layout USING(course_layout_id) JOIN teaching_activity USING(teaching_activity_id) WHERE course_code='IV1351' AND activity_name='Admin' AND study_year=2025 LIMIT 1), (SELECT employee_id FROM employee JOIN person USING(person_id) WHERE first_name='Alice'), 50),
((SELECT planned_activity_id FROM planned_activity JOIN course_instance USING(course_instance_id) JOIN course_layout USING(course_layout_id) JOIN teaching_activity USING(teaching_activity_id) WHERE course_code='IV1351' AND activity_name='Exam' AND study_year=2025 LIMIT 1), (SELECT employee_id FROM employee JOIN person USING(person_id) WHERE first_name='Alice'), 40);

-- (2024)
INSERT INTO course_instance (study_year, num_students, course_layout_id, study_period_id) VALUES 
(2024, 180, (SELECT course_layout_id FROM course_layout WHERE course_code='IV1351' LIMIT 1), (SELECT study_period_id FROM study_period WHERE period_name='P1'));

--(2024)
INSERT INTO planned_activity (planned_hours, course_instance_id, teaching_activity_id) VALUES 
(20, (SELECT course_instance_id FROM course_instance JOIN course_layout USING(course_layout_id) JOIN study_period USING(study_period_id) WHERE course_code='IV1351' AND period_name='P1' AND study_year=2024 LIMIT 1), (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lecture'));

-- (2024)
INSERT INTO work_allocation (planned_activity_id, employee_id, allocated_hours) VALUES 
((SELECT planned_activity_id FROM planned_activity JOIN course_instance USING(course_instance_id) JOIN course_layout USING(course_layout_id) JOIN teaching_activity USING(teaching_activity_id) JOIN study_period USING(study_period_id) WHERE course_code='IV1351' AND period_name='P1' AND study_year=2024 AND activity_name='Lecture' LIMIT 1), (SELECT employee_id FROM employee JOIN person USING(person_id) WHERE first_name='Charlie'), 20);