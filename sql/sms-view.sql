-- Setup
DROP schema IF EXISTS search CASCADE;
CREATE schema search;

DROP schema IF EXISTS student CASCADE;
CREATE schema student;

DROP schema IF EXISTS lecturer CASCADE;
CREATE schema lecturer;

DROP VIEW IF EXISTS student.self_view_info;
CREATE VIEW student.self_view_info AS
    SELECT * FROM student WHERE id = CURRENT_USER;

DROP VIEW IF EXISTS student.self_view_curriculum;
CREATE VIEW student.self_view_curriculum AS
    SELECT * FROM subject WHERE subject.id IN (
        SELECT c.subject_id FROM curriculum c
        WHERE c.program_id = (
            SELECT s.program_id FROM student.self_view_info s WHERE s.id = CURRENT_USER
        )
    );

DROP VIEW IF EXISTS lecturer.self_view_info;
CREATE VIEW lecturer.self_view_info AS
    SELECT * FROM lecturer WHERE id = CURRENT_USER;

DROP VIEW IF EXISTS lecturer.self_view_specializations;
CREATE VIEW lecturer.self_view_specializations AS
    SELECT su.id, su.name
    FROM lecturer l
    JOIN specialization sp ON l.id = sp.lecturer_id
    JOIN subject su ON sp.subject_id = su.id
    WHERE l.id = CURRENT_USER;

DROP VIEW IF EXISTS search.view_search_student;
CREATE VIEW search.view_search_student AS
    SELECT s.id, first_name, last_name, gender, status, email, p.code program_code, p.name program_name, f.name faculty_name
    FROM student s
    JOIN program p ON p.id = s.program_id
    JOIN faculty f ON f.id = p.faculty_id;

DROP VIEW IF EXISTS search.view_search_lecturer;
CREATE VIEW search.view_search_lecturer AS
    SELECT l.id, l.first_name, l.last_name, l.gender, l.status, l.email, f.name faculty_name
    FROM lecturer l
    JOIN faculty f ON f.id = l.faculty_id;

DROP VIEW IF EXISTS search.view_search_lecturer_specialization;
CREATE VIEW search.view_search_lecturer_specialization AS
    SELECT l.id, l.first_name, l.last_name, su.id subject_id, su.name subject_name
    FROM lecturer l
    JOIN specialization sp ON sp.lecturer_id = l.id
    JOIN subject su ON su.id = sp.subject_id;
