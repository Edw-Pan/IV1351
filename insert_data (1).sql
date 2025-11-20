INSERT INTO job_title (job_title) VALUES 
('Professor'), ('Lecturer'), ('PhD Student');

INSERT INTO competence (competence_name) VALUES 
('Database Design'), ('Java Programming'), ('Algorithms');

INSERT INTO teaching_activity (activity_name, factor) VALUES 
('Lecture', 3.6), ('Lab', 2.4), ('Seminar', 1.8);

INSERT INTO course_layout (course_code, course_name, hp, min_students, max_students) VALUES 
('IV1351', 'Data Storage Paradigms', 7.5, 50, 250),
('IX1500', 'Discrete Mathematics', 7.5, 50, 150);

INSERT INTO person (personal_number, first_name, last_name, street, zip, city) VALUES 
('19800101-1234', 'Alice', 'Andersson', 'Vägen 1', '12345', 'Stockholm'),
('19900505-5678', 'Bob', 'Bengtsson', 'Gatan 2', '54321', 'Göteborg'),
('19850303-9012', 'Carol', 'Carlsson', 'Gränden 3', '11122', 'Malmö');

INSERT INTO phone (phone_number, person_id) VALUES 
('070-1111111', (SELECT person_id FROM person WHERE personal_number = '19800101-1234')),
('070-2222222', (SELECT person_id FROM person WHERE personal_number = '19900505-5678'));


INSERT INTO department (department_name, manager_id) VALUES 
('Computer Science', NULL);


INSERT INTO employee (salary, department_id, job_title_id, person_id) VALUES 
(
    50000, 
    (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
    (SELECT job_title_id FROM job_title WHERE job_title = 'Professor'),
    (SELECT person_id FROM person WHERE personal_number = '19800101-1234') -- Alice (Manager)
),
(
    35000,
    (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
    (SELECT job_title_id FROM job_title WHERE job_title = 'Lecturer'),
    (SELECT person_id FROM person WHERE personal_number = '19900505-5678') -- Bob (Teacher)
);


UPDATE department 
SET manager_id = (SELECT employee_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE personal_number = '19800101-1234'))
WHERE department_name = 'Computer Science';


INSERT INTO course_instance (study_period, study_year, num_students, course_layout_id) VALUES 
(
    'P1', 2025, 120, 
    (SELECT course_layout_id FROM course_layout WHERE course_code = 'IV1351')
);


INSERT INTO planned_activity (planned_hours, course_instance_id, teaching_activity_id) VALUES 
(
    20.0, 
    (SELECT course_instance_id FROM course_instance WHERE study_period = 'P1' AND study_year = 2025),
    (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Lecture')
);


INSERT INTO work_allocation (planned_activity_id, employee_id) VALUES 
(
    (SELECT planned_activity_id FROM planned_activity 
     WHERE course_instance_id = (SELECT course_instance_id FROM course_instance WHERE study_period = 'P1' AND study_year = 2025)
     AND teaching_activity_id = (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Lecture')
     LIMIT 1),
    (SELECT employee_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE personal_number = '19900505-5678'))
);


INSERT INTO employee_competence (employee_id, competence_id) VALUES 
(
    (SELECT employee_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE personal_number = '19900505-5678')),
    (SELECT competence_id FROM competence WHERE competence_name = 'Database Design')
);