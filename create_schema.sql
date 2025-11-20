CREATE TABLE job_title (
    job_title_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE competence (
    competence_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    competence_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE teaching_activity (
    teaching_activity_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    activity_name VARCHAR(50) NOT NULL UNIQUE,
    factor NUMERIC(3,1) NOT NULL
);

CREATE TABLE course_layout (
    course_layout_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code VARCHAR(10) NOT NULL UNIQUE,
    course_name VARCHAR(255) NOT NULL,
    hp NUMERIC(3,1) NOT NULL,
    min_students INT NOT NULL,
    max_students INT NOT NULL
);

CREATE TABLE person (
    person_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    personal_number VARCHAR(13) NOT NULL UNIQUE,
    first_name VARCHAR(500) NOT NULL,
    last_name VARCHAR(500) NOT NULL,
    street VARCHAR(500) NOT NULL,
    zip VARCHAR(10) NOT NULL,
    city VARCHAR(500) NOT NULL
);


CREATE TABLE phone (
    phone_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    phone_number VARCHAR(500) NOT NULL UNIQUE,
    person_id INT NOT NULL,
    CONSTRAINT fk_phone_person FOREIGN KEY (person_id) REFERENCES person(person_id)
);

CREATE TABLE course_instance (
    course_instance_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    study_period VARCHAR(2) NOT NULL,
    study_year INT NOT NULL,
    num_students INT NOT NULL,
    course_layout_id INT NOT NULL,
    CONSTRAINT fk_ci_layout FOREIGN KEY (course_layout_id) REFERENCES course_layout(course_layout_id)
);

CREATE TABLE planned_activity (
    planned_activity_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    planned_hours NUMERIC(5,1) NOT NULL,
    course_instance_id INT NOT NULL,
    teaching_activity_id INT NOT NULL,
    CONSTRAINT fk_pa_instance FOREIGN KEY (course_instance_id) REFERENCES course_instance(course_instance_id),
    CONSTRAINT fk_pa_activity FOREIGN KEY (teaching_activity_id) REFERENCES teaching_activity(teaching_activity_id)
);


CREATE TABLE department (
    department_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    manager_id INT
);


CREATE TABLE employee (
    employee_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    salary INT NOT NULL,
    department_id INT NOT NULL,
    job_title_id INT NOT NULL,
    person_id INT NOT NULL UNIQUE,
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES department(department_id),
    CONSTRAINT fk_emp_job FOREIGN KEY (job_title_id) REFERENCES job_title(job_title_id),
    CONSTRAINT fk_emp_person FOREIGN KEY (person_id) REFERENCES person(person_id)
);

ALTER TABLE department 
    ADD CONSTRAINT fk_dept_manager FOREIGN KEY (manager_id) REFERENCES employee(employee_id);

-- 4. Remaining Tables (requiring Employee)
CREATE TABLE employee_competence (
    employee_id INT NOT NULL,
    competence_id INT NOT NULL,
    PRIMARY KEY (employee_id, competence_id),
    CONSTRAINT fk_ec_emp FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT fk_ec_comp FOREIGN KEY (competence_id) REFERENCES competence(competence_id)
);

CREATE TABLE work_allocation (
    work_allocation_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    planned_activity_id INT NOT NULL,
    employee_id INT NOT NULL,
    CONSTRAINT fk_wa_activity FOREIGN KEY (planned_activity_id) REFERENCES planned_activity(planned_activity_id),
    CONSTRAINT fk_wa_emp FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);