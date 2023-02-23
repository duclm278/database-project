-- Setup
DROP schema IF EXISTS search CASCADE;
CREATE schema search;

DROP schema IF EXISTS student CASCADE;
CREATE schema student;

DROP schema IF EXISTS lecturer CASCADE;
CREATE schema lecturer;

-- 2.1. Staff (Admin)
DROP VIEW IF EXISTS full_timetable;
CREATE VIEW full_timetable AS
    SELECT c.semester, t.* FROM timetable t
    JOIN class c ON c.id = t.class_id;

-- 2.1.1. Adding students, lecturers, subjects, and classes with the following data.
-- 2.1.1a. Students: Name, ID, School/Faculty, Program, Date of Birth, Address, Contact, etc.
-- Use PROCEDURE add_student() to add student
DROP PROCEDURE IF EXISTS add_student;
CREATE OR REPLACE PROCEDURE add_student(
        i_id CHAR(8),
        i_first_name VARCHAR(35),
        i_last_name VARCHAR(35),
        i_gender CHAR(1),
        i_birthday DATE,
        i_status BOOLEAN,
        i_join_date DATE,
        i_address VARCHAR(70),
        i_email VARCHAR(35),
        i_phone VARCHAR(25),
        i_program_id CHAR(6)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO student(id, first_name, last_name, gender, birthday, status, join_date, address, email, phone, program_id)
        VALUES (i_id, i_first_name, i_last_name, i_gender, i_birthday, i_status, i_join_date, i_address, i_email, i_phone, i_program_id);
END $$;

-- 2.1.1b. Lecturers: Name, ID, School/Faculty, Teaching Subjects, Date of Birth, Address, Contact, etc.
-- Use PROCEDURE add_lecturer() to add lecturer
DROP PROCEDURE IF EXISTS add_lecturer;
CREATE OR REPLACE PROCEDURE add_lecturer(
        i_id CHAR(12),
        i_first_name VARCHAR(35),
        i_last_name VARCHAR(35),
        i_gender CHAR(1),
        i_birthday DATE,
        i_status BOOLEAN,
        i_join_date DATE,
        i_address VARCHAR(70),
        i_email VARCHAR(35),
        i_phone VARCHAR(25),
        i_faculty_id VARCHAR(8)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO lecturer(id, first_name, last_name, gender, birthday, status, join_date, address, email, phone, faculty_id)
        VALUES (i_id, i_first_name, i_last_name, i_gender, i_birthday, i_status, i_join_date, i_address, i_email, i_phone, i_faculty_id);
END $$;

-- 2.1.1c. Subjects: Prerequisites, Number of credits, etc.
-- Use PROCEDURE add_subject() to add subject
DROP PROCEDURE IF EXISTS add_subject;
CREATE OR REPLACE PROCEDURE add_subject(
        i_id VARCHAR(7),
        i_name VARCHAR(100),
        i_study_credits NUMERIC,
        i_tuition_credits NUMERIC,
        i_final_weight NUMERIC(3, 2),
        i_prerequisite_id VARCHAR(7),
        i_faculty_id VARCHAR(8)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO subject(id, name, study_credits, tuition_credits, final_weight, prerequisite_id, faculty_id)
        VALUES (i_id, i_name, i_study_credits, i_tuition_credits, i_final_weight, i_prerequisite_id, i_faculty_id);
END $$;

-- 2.1.1d. Classes: Time, Location, Slot Availability, Semester, Number of credits, Schedule of classes, etc.
-- Use PROCEDURE add_class() to add class
DROP PROCEDURE IF EXISTS add_class;
CREATE OR REPLACE PROCEDURE add_class(
        i_id CHAR(6),
        i_type VARCHAR(8),
        i_semester CHAR(5),
        i_require_lab CHAR(1),
        i_current_cap INTEGER,
        i_max_cap INTEGER,
        i_company_id CHAR(9),
        i_lecturer_id CHAR(12),
        i_subject_id VARCHAR(7)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO class(id, type, semester, require_lab, current_cap, max_cap, company_id, lecturer_id, subject_id)
        VALUES (i_id, i_type, i_semester, i_require_lab, i_current_cap, i_max_cap, i_company_id, i_lecturer_id, i_subject_id);
END $$;

-- 2.1.2. Managing information of students, lecturers, subjects, and classes.
-- NO PROCEDURE! Do this manually!

-- 2.1.3. Creating a tentative timetable for the upcoming semester, i.e creating classes for each subject. A subject can have 0, 1, or many classes open in a semester.
-- Use TRIGGER check timetable conflict BEFORE INSERT
-- Use PROCEDURE add_timetable() to add timetable
DROP FUNCTION IF EXISTS check_timetable_conflict CASCADE;
CREATE OR REPLACE FUNCTION check_timetable_conflict()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF EXISTS(
            SELECT *
            FROM full_timetable t
            WHERE t.semester = (
                SELECT semester
                FROM class
                WHERE NEW.class_id = class.id
            )
            AND NEW.location = t.location
            AND NEW.weekday = t.weekday
            AND (
                (
                    NEW.end_time > t.start_time
                    AND NEW.end_time <= t.end_time
                )
                OR (
                    NEW.start_time >= t.start_time
                    AND NEW.start_time < t.end_time
                )
            )
        ) THEN
            RAISE EXCEPTION 'Cannot execute. Timetable conflict found.';
        ELSE
            RETURN NEW;
        END IF;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF EXISTS(
            SELECT *
            FROM full_timetable t
            WHERE t.semester = (
                SELECT semester
                FROM class
                WHERE NEW.class_id = class.id
            )
                AND NEW.location = t.location
                AND NEW.weekday = t.weekday
                AND (
                    (
                        NEW.end_time > t.start_time
                        AND NEW.end_time <= t.end_time
                    )
                    OR (
                        NEW.start_time >= t.start_time
                        AND NEW.start_time < t.end_time
                    )
                )
                AND NEW.class_id != t.class_id
        ) THEN
            RAISE EXCEPTION 'Cannot execute. Timetable conflict found.';
        ELSE
            RETURN NEW;
        END IF;
    END IF;
END $$;

CREATE OR REPLACE TRIGGER timetable_conflict_trigger
    BEFORE INSERT OR UPDATE ON timetable
    FOR EACH ROW
    EXECUTE PROCEDURE check_timetable_conflict();

DROP PROCEDURE IF EXISTS add_timetable;
CREATE OR REPLACE PROCEDURE add_timetable(
        i_class_id CHAR(6),
        i_weekday CHAR(1),
        i_start_time CHAR(4),
        i_end_time CHAR(4),
        i_location VARCHAR(25)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO timetable(class_id, weekday, start_time, end_time, location)
        VALUES (i_class_id, i_weekday, i_start_time, i_end_time, i_location);
END $$;

-- 2.1.4. Making changes to the timetable.
-- NO PROCEDURE! Do this manually!

-- 2.1.5. Assigning lecturers to classes based on the timetable.
-- Use TRIGGER check teaching conflict BEFORE UPDATE
-- Use PROCEDURE assign_lecturer() to assign lecturer to class
DROP FUNCTION IF EXISTS check_teaching_conflict CASCADE;
CREATE OR REPLACE FUNCTION check_teaching_conflict()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE
    assigned_semester CHAR(5);
BEGIN
    SELECT semester INTO assigned_semester
    FROM class
    WHERE id = NEW.id;

    -- Join to get timetable of OLD and NEW class
    -- If timetable info unchanged, return normally
    IF EXISTS(
        SELECT a.weekday, a.start_time, a.end_time, a.location
        FROM (
            -- Timetable of NEW class
            SELECT t.*
            FROM timetable t
            WHERE t.class_id = NEW.id
        ) a
        JOIN (
            -- Timetable of OLD class
            SELECT t.*
            FROM timetable t
            WHERE t.class_id = OLD.id
        ) b ON (
            a.weekday = b.weekday
            AND a.start_time = b.start_time
            AND a.end_time = b.end_time
            AND a.location = b.location
        )
    ) THEN
        RETURN NEW;
    END IF;

    IF EXISTS(
        SELECT a.*
        FROM (
            -- Timetable of class being assigned
            SELECT t.*
            FROM timetable t
            WHERE t.class_id = OLD.id
        ) a
        JOIN (
            -- Schedule of lecturer being assigned
            SELECT t.*
            FROM timetable t
            JOIN class c ON t.class_id = c.id
            WHERE c.lecturer_id = NEW.lecturer_id
            AND c.semester = assigned_semester
        ) b ON (
            b.end_time > a.start_time
            AND b.end_time <= a.end_time
        )
        OR (
            b.start_time >= a.start_time
            AND b.start_time < a.end_time
        )
        WHERE a.weekday = b.weekday
    ) THEN
        RAISE EXCEPTION 'Cannot execute. Teaching conflict found.';
    ELSE
        RETURN NEW;
    END IF;
END $$;

CREATE OR REPLACE TRIGGER teaching_conflict_trigger
    BEFORE UPDATE ON class
    FOR EACH ROW
    EXECUTE PROCEDURE check_teaching_conflict();

DROP PROCEDURE IF EXISTS assign_lecturer;
CREATE OR REPLACE PROCEDURE assign_lecturer(i_lecturer_id CHAR(12), i_class_id CHAR(6))
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE class
    SET lecturer_id = i_lecturer_id
    WHERE id = i_class_id;
END $$;

-- 2.1.6. Assigning students to classes.
-- Reset GPA of all active students. Run at beginning of each semester.
-- Use PROCEDURE reset_gpa() to reset GPA of all active students
DROP PROCEDURE IF EXISTS reset_gpa;
CREATE OR REPLACE PROCEDURE reset_gpa()
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE student
    SET gpa_total_score_product = 0,
        gpa_total_study_credits = 0
    WHERE status = TRUE;
END $$;

-- 2.1.6a. Classes having a number of enrolled students fewer than [X], used for canceling classes with low enrollment.
-- Use FUNCTION report_enrolled() to return report of all classes
DROP FUNCTION IF EXISTS report_enrolled;
CREATE OR REPLACE FUNCTION report_enrolled(i_semester CHAR(5) DEFAULT NULL)
    RETURNS TABLE (
        id CHAR(6),
        type VARCHAR(8),
        semester CHAR(5),
        require_lab CHAR(1),
        current_cap INTEGER,
        max_cap INTEGER,
        company_id CHAR(9),
        lecturer_id CHAR(12),
        subject_id VARCHAR(7),
        class_status TEXT
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    IF i_semester IS NULL THEN
        RETURN QUERY (
            SELECT *,
                CASE
                    WHEN c.current_cap = c.max_cap
                        THEN 'Full'
                    WHEN c.current_cap <= 5
                        THEN 'Not enough students'
                    WHEN c.current_cap > 5 AND c.current_cap <= 19
                        THEN 'In consideration'
                    WHEN c.current_cap >= 20 AND c.current_cap <= c.max_cap
                        THEN 'Enough students'
                END AS class_status
            FROM class c
        );
    ELSE
        RETURN QUERY (
            SELECT *,
                CASE
                    WHEN c.current_cap = c.max_cap
                        THEN 'Full'
                    WHEN c.current_cap <= 5
                        THEN 'Not enough students'
                    WHEN c.current_cap > 5 AND c.current_cap <= 19
                        THEN 'In consideration'
                    WHEN c.current_cap >= 20 AND c.current_cap <= c.max_cap
                        THEN 'Enough students'
                END AS class_status
            FROM class c
            WHERE c.semester = i_semester
        );
    END IF;
END $$;

-- 2.1.6b. Students with credit debt from unfinished (failed) subjects in the range [A, B], used for sending warnings.
-- Use FUNCTION report_credit_debt() to return report of all students
DROP FUNCTION IF EXISTS report_credit_debt;
CREATE OR REPLACE FUNCTION report_credit_debt()
    RETURNS TABLE(
        id CHAR(8),
        first_name VARCHAR(35),
        last_name VARCHAR(35),
        status BOOLEAN,
        credit_debt NUMERIC,
        warning_level TEXT
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.first_name, s.last_name, s.status, s.credit_debt,
        CASE
            WHEN s.credit_debt > 0 AND s.credit_debt < 5
                THEN 'Warning level 1'
            WHEN s.credit_debt > 4 AND s.credit_debt < 10
                THEN 'Warning level 2'
            WHEN s.credit_debt > 9 AND s.credit_debt < 13
                THEN 'Warning level 3'
            WHEN s.credit_debt > 12
                THEN 'Expelled'
            ELSE 'No warning'
        END AS warning_level
    FROM student s;
END $$;

-- 2.1.6c. Students qualified for semester scholarships with GPA ≥ [G]
-- Use TRIGGER convert_score_trigger to convert score to scale 4
-- Use FUNCTION report_scholarship() to return report of all students
-- Mapping score to scale 4
DROP FUNCTION IF EXISTS convert_score CASCADE;
CREATE OR REPLACE FUNCTION convert_score()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE score_4 NUMERIC;
BEGIN
    SELECT
        CASE
            WHEN cs.score >= 4.0 AND cs.score <= 4.9
                THEN 1
            WHEN cs.score >= 5.0 AND cs.score <= 5.4
                THEN 1.5
            WHEN cs.score >= 5.5 AND cs.score <= 6.4
                THEN 2
            WHEN cs.score >= 6.5 AND cs.score <= 6.9
                THEN 2.5
            WHEN cs.score >= 7.0 AND cs.score <= 7.9
                THEN 3
            WHEN cs.score >= 8.0 AND cs.score <= 8.4
                THEN 3.5
            WHEN cs.score >= 8.5
                THEN 4
            ELSE 0
        END AS converted_score INTO score_4
    FROM (
        -- Get final weight to calculate score of being updated enrollment
        SELECT
            NEW.midterm_score * (1 - s.final_weight) + NEW.final_score * s.final_weight
                AS score
        FROM class c
            JOIN subject s ON c.subject_id = s.id
        WHERE c.id = OLD.class_id
    ) cs;

    UPDATE enrollment
    SET mapping_score = score_4
    WHERE student_id = NEW.student_id
        AND class_id = NEW.class_id;
    RETURN NEW;
END $$;

CREATE OR REPLACE TRIGGER convert_score_trigger
    AFTER UPDATE ON enrollment
    FOR EACH ROW
        WHEN (pg_trigger_depth() < 1)
    EXECUTE PROCEDURE convert_score();

-- Update score when enrollment is updated
DROP FUNCTION IF EXISTS update_score_trigger_function CASCADE;
CREATE OR REPLACE FUNCTION update_score_trigger_function()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE
    num_credits NUMERIC;
    old_score NUMERIC;
BEGIN
    SELECT study_credits INTO num_credits
    FROM subject s
        JOIN class c ON s.id = c.subject_id
    WHERE c.id = NEW.class_id;

    IF EXISTS(
        SELECT *
        FROM class A
        JOIN (
            SELECT *
            FROM enrollment A
                JOIN class B ON A.class_id = B.id
            WHERE A.student_id = OLD.student_id
                AND A.class_id != OLD.class_id
        ) B ON A.subject_id = B.subject_id
        WHERE A.id = OLD.class_id
    ) THEN
        SELECT B.mapping_score INTO old_score
        FROM (
            SELECT *
            FROM enrollment A
                JOIN class B ON A.class_id = B.id
            WHERE A.student_id = OLD.student_id
                AND A.class_id != OLD.class_id
        ) B
        JOIN class A ON A.subject_id = B.subject_id
        WHERE A.id = OLD.class_id;

        IF NEW.mapping_score > old_score THEN
            UPDATE student
            SET cpa_total_score_product = cpa_total_score_product + (NEW.mapping_score - old_score) * num_credits
            WHERE id = OLD.student_id;
        END IF;
    ELSE
        UPDATE student
        SET cpa_total_score_product = cpa_total_score_product + NEW.mapping_score * num_credits
        WHERE id = OLD.student_id;
    END IF;

    UPDATE student
    SET gpa_total_score_product = gpa_total_score_product + NEW.mapping_score * num_credits
    WHERE id = OLD.student_id;

    RETURN NEW;
END $$;

CREATE OR REPLACE TRIGGER update_score_trigger
    BEFORE UPDATE OF mapping_score ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE update_score_trigger_function();

-- Return report of all students
DROP FUNCTION IF EXISTS report_scholarship;
CREATE OR REPLACE FUNCTION report_scholarship()
    RETURNS TABLE(
        o_id CHAR(8),
        o_first_name VARCHAR(35),
        o_last_name VARCHAR(35),
        o_gpa NUMERIC,
        o_scholarship_status TEXT
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY (
        SELECT s.id, s.first_name, s.last_name, g.gpa,
            CASE
                WHEN g.gpa >= 3.8
                    THEN 'Scholarship A'
                WHEN g.gpa >= 3.6 AND g.gpa < 3.8
                    THEN 'Scholarship B'
                WHEN s.gpa_total_study_credits < 15
                    THEN 'Not enough credits'
                ELSE 'Enough credits, but not qualified'
            END AS scholarship_status
        FROM student s
        JOIN (
            -- Get GPA of each student
            SELECT id, ROUND(gpa_total_score_product / gpa_total_study_credits, 1) gpa 
            FROM student
            WHERE status = TRUE
                AND gpa_total_study_credits > 0
        ) g ON s.id = g.id
    );
END $$;
