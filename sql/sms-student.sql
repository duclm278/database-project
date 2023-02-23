-- 2.2. Students
DROP VIEW IF EXISTS student.self_view_info;
CREATE VIEW student.self_view_info AS
    SELECT * FROM student WHERE id = CURRENT_USER;

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
    SELECT l.id, l.first_name, l.last_name, s.id subject_id, s.name subject_name
    FROM lecturer l
    JOIN specialization sp ON sp.lecturer_id = l.id
    JOIN subject s ON s.id = sp.subject_id;

-- 2.2.1 Viewing data of subjects, classes, and results of themselves.
-- View all subjects of their curriculum
DROP FUNCTION IF EXISTS student.self_view_curriculum;
CREATE OR REPLACE FUNCTION student.self_view_curriculum()
    RETURNS TABLE(
        id VARCHAR(7),
        name VARCHAR(100),
        study_credits NUMERIC,
        tuition_credits NUMERIC,
        final_weight NUMERIC(3, 2),
        prerequisite_id VARCHAR(7),
        faculty_id VARCHAR(8)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY (
        SELECT * FROM subject WHERE subject.id IN (
            SELECT c.subject_id FROM curriculum c
            WHERE c.program_id = (
                SELECT s.program_id FROM student.self_view_info s WHERE s.id = CURRENT_USER
            )
        )
    );
END $$;

-- View their classes in of any semesters
DROP FUNCTION IF EXISTS student.self_view_class_enrolled;
CREATE OR REPLACE FUNCTION student.self_view_class_enrolled(i_semester CHAR(5) DEFAULT NULL)
    RETURNS TABLE(
        id CHAR(6),
        type varchar(8),
        semester CHAR(5),
        require_lab CHAR(1),
        current_cap INTEGER,
        max_cap INTEGER,
        company_id CHAR(9),
        lecturer_id CHAR(12),
        subject_id varchar(7)
    ) LANGUAGE plpgsql
AS $$
BEGIN
    IF i_semester IS NULL THEN
        RETURN QUERY (
            SELECT c.*
            FROM class c
                JOIN enrollment e ON c.id = e.class_id
            WHERE e.student_id = CURRENT_USER
        );
    ELSE
        RETURN QUERY (
            SELECT c.*
            FROM class c
                JOIN enrollment e ON c.id = e.class_id
            WHERE e.student_id = CURRENT_USER
                AND c.semester = i_semester
        );
    END IF;
END $$;

-- View their results in of any semesters
DROP FUNCTION IF EXISTS student.self_view_results;
CREATE OR REPLACE FUNCTION student.self_view_results(i_semester CHAR(5) DEFAULT NULL)
    RETURNS TABLE(
        class_id CHAR(6),
        subject_id VARCHAR(7),
        subject_name VARCHAR(100),
        midterm_score NUMERIC,
        final_score NUMERIC,
        mapping_score NUMERIC
    ) LANGUAGE plpgsql
AS $$
BEGIN
    IF i_semester IS NULL THEN
        RETURN QUERY (
            SELECT e.class_id, c.subject_id, s.name, e.midterm_score, e.final_score, e.mapping_score
            FROM enrollment e
                JOIN class c ON e.class_id = c.id
                JOIN subject s ON c.subject_id = s.id
            WHERE e.student_id = CURRENT_USER
        );
    ELSE
        RETURN QUERY (
            SELECT e.class_id, c.subject_id, s.name, e.midterm_score, e.final_score, e.mapping_score
            FROM enrollment e
                JOIN class c ON e.class_id = c.id
                JOIN subject s ON c.subject_id = s.id
            WHERE e.student_id = CURRENT_USER
                AND c.semester = i_semester
        );
    END IF;
END $$;

-- View their timetable in of a semester
DROP FUNCTION IF EXISTS student.self_view_timetable;
CREATE OR REPLACE FUNCTION student.self_view_timetable(i_semester CHAR(5))
    RETURNS TABLE(
        class_id CHAR(6),
        subject_id VARCHAR(7),
        subject_name VARCHAR(100),
        type VARCHAR(5),
        weekday CHAR(1),
        start_time CHAR(4),
        end_time CHAR(4),
        location VARCHAR(20)
    ) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY (
        SELECT c.id, c.subject_id, s.name, c.type, t.weekday, t.start_time, t.end_time, t.location
        FROM class c
            JOIN subject s ON c.subject_id = s.id
            JOIN timetable t ON c.id = t.class_id
            JOIN enrollment e ON c.id = e.class_id
        WHERE e.student_id = CURRENT_USER
            AND c.semester = i_semester
    );
END $$;

-- 2.2.2. Show the tentative timetable to find suitable opening classes (more info on enrollment).
DROP FUNCTION IF EXISTS student.show_class_info;
CREATE OR REPLACE FUNCTION student.show_class_info(i_class_id CHAR(6) DEFAULT NULL, i_semester CHAR(5) DEFAULT NULL)
    RETURNS TABLE(
        class_id CHAR(6),
        subject_id VARCHAR(7),
        subject_name VARCHAR(100),
        prerequisite_id VARCHAR(7),
        type VARCHAR(5),
        require_lab CHAR(1),
        study_credits NUMERIC,
        tuition_credits NUMERIC,
        current_cap INTEGER,
        max_cap INTEGER,
        weekday CHAR(1),
        start_time CHAR(4),
        end_time CHAR(4),
        location VARCHAR(20)
    ) LANGUAGE plpgsql
AS $$
BEGIN
    IF i_class_id IS NULL THEN
        RETURN QUERY (
            SELECT c.id, c.subject_id, s.name, s.prerequisite_id, c.type, c.require_lab, s.study_credits, s.tuition_credits, c.current_cap, c.max_cap, t.weekday, t.start_time, t.end_time, t.location
            FROM class c
                JOIN subject s ON c.subject_id = s.id
                JOIN timetable t ON c.id = t.class_id
            WHERE c.semester = i_semester
        );
    END IF;

    RETURN QUERY (
        SELECT c.id, c.subject_id, s.name, s.prerequisite_id, c.type, c.require_lab, s.study_credits, s.tuition_credits, c.current_cap, c.max_cap, t.weekday, t.start_time, t.end_time, t.location
        FROM class c
            JOIN subject s ON c.subject_id = s.id
            JOIN timetable t ON c.id = t.class_id
        WHERE c.id = i_class_id
    );
END $$;

-- 2.2.3. Enrolling in classes.
-- 2.2.3a. Showing enrolling information such as time, location, credit, slot availability, and prerequisites.
-- Done in 2.2.2.

-- 2.2.3b. Check for slot availability, class prerequisites and lab requirements.
-- Check for slot availability
DROP FUNCTION IF EXISTS check_slot_availability CASCADE;
CREATE OR REPLACE FUNCTION check_cap()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS(
        SELECT *
        FROM class
        WHERE max_cap = current_cap
            AND id = NEW.class_id
    ) THEN
        RAISE EXCEPTION 'Cannot enroll in class % because it is full', NEW.class_id;
    END IF;

    UPDATE class
    SET current_cap = current_cap + 1
    WHERE id = NEW.class_id;
    RETURN NEW;
END $$;

CREATE OR REPLACE TRIGGER check_cap_trigger
    BEFORE INSERT ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE check_cap();

-- Check for class prerequisites
DROP FUNCTION IF EXISTS check_prerequisite CASCADE;
CREATE OR REPLACE FUNCTION check_prerequisite()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE
    pre_id VARCHAR(7);
BEGIN
    SELECT prerequisite_id
    INTO pre_id
    FROM class c
    JOIN subject s ON c.subject_id = s.id
    WHERE c.id = NEW.class_id;

    -- If new class has prerequisite, check if student has taken it
    IF pre_id IS NOT NULL THEN
        IF NOT EXISTS(
            SELECT *
            FROM enrollment
            WHERE student_id = NEW.student_id
                AND class_id IN (
                    SELECT id
                    FROM class
                    WHERE subject_id = pre_id
                )
        ) THEN
            RAISE EXCEPTION 'Cannot enroll in class % because you have not taken its prerequisite', NEW.class_id;
        END IF;
    END IF;
    RETURN NEW;
END $$;

CREATE OR REPLACE TRIGGER check_prerequisite_trigger
    BEFORE INSERT ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE check_prerequisite();

-- Check for lab requirements
DROP FUNCTION IF EXISTS check_lab CASCADE;
CREATE OR REPLACE FUNCTION check_lab()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE lab_needed char(1);
BEGIN
    SELECT require_lab INTO lab_needed
    FROM class
    WHERE id = NEW.class_id;

    IF lab_needed = 'Y' THEN
        -- Check if exists lab class of same subject_id and semester
        IF EXISTS(
            SELECT *
            FROM enrollment e
                -- Info of expected lab class
                JOIN class lc ON e.class_id = lc.id
                -- Try matching with new class
                JOIN (
                    SELECT c.* FROM class c WHERE c.id = new.class_id
                ) nc ON lc.subject_id = nc.subject_id
                AND lc.semester = nc.semester
            WHERE e.student_id = NEW.student_id
                AND lc.type = 'TN'
        ) THEN
            RETURN NEW;
        ELSE
            RAISE EXCEPTION 'Cannot enroll in class % because you have not taken its lab class first', new.class_id;
        END IF;
    END IF;
    RETURN NEW;
END $$;

CREATE OR REPLACE TRIGGER check_lab_trigger
    BEFORE INSERT ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE check_lab();

-- 2.2.3c. Check for time conflicts.
DROP FUNCTION IF EXISTS check_time_enrolled CASCADE;
CREATE OR REPLACE FUNCTION check_time_enrolled()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE
    new_weekday char(1);
    new_start_time char(4);
    new_end_time char(4);
BEGIN
    SELECT weekday, start_time, end_time
        INTO new_weekday, new_start_time, new_end_time
    FROM timetable
    WHERE class_id = NEW.class_id;

    IF EXISTS(
        SELECT *
        -- All enrolled classes
        FROM full_timetable
        -- In same semester
        WHERE semester = (
            SELECT semester
            FROM class
            WHERE id = NEW.class_id
        )
        -- In class_ids of that student
        AND class_id IN (
            SELECT class_id
            FROM enrollment
            WHERE student_id = NEW.student_id
        )
        -- Check if there is time conflict
        AND weekday = new_weekday
        AND (
            (start_time <= new_start_time AND end_time > new_start_time)
            OR (start_time < new_end_time AND end_time >= new_end_time)
        )
    ) THEN
        RAISE EXCEPTION 'Cannot enroll in class % because you have time conflict', NEW.class_id;
    END IF;
    RETURN NEW;
END $$;

CREATE OR REPLACE TRIGGER check_time_enrolled_trigger
    BEFORE INSERT ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE check_time_enrolled();

-- 2.2.3d. Calculate total studying credits.
-- Trigger to update total studying credits (GPA and CPA)
DROP FUNCTION IF EXISTS credits_trigger_function CASCADE;
CREATE OR REPLACE FUNCTION credits_trigger_function()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE updating_credits NUMERIC;
BEGIN
    SELECT study_credits INTO updating_credits
    FROM subject s
        JOIN class c ON s.id = c.subject_id
    WHERE c.id = NEW.class_id;

    IF (TG_OP = 'INSERT') THEN
        IF NOT EXISTS (
            SELECT A.*
            FROM enrollment A
                JOIN class B ON A.class_id = B.id
                JOIN (
                    SELECT *
                    FROM enrollment A
                        JOIN class B ON A.class_id = B.id
                    WHERE student_id = NEW.student_id
                        AND A.class_id != NEW.class_id
                ) C ON C.subject_id = B.subject_id
            WHERE A.student_id = NEW.student_id
        ) THEN
            UPDATE student
            SET cpa_total_study_credits = cpa_total_study_credits + updating_credits
            WHERE id = NEW.student_id;
        END IF;

        UPDATE student
        SET gpa_total_study_credits = gpa_total_study_credits + updating_credits
        WHERE id = NEW.student_id;
    ELSEIF (TG_OP = 'DELETE') THEN
        IF NOT EXISTS (
            SELECT A.*
            FROM enrollment A
                JOIN class B ON A.class_id = B.id
                JOIN (
                    SELECT *
                    FROM enrollment A
                        JOIN class B ON A.class_id = B.id
                    WHERE student_id = OLD.student_id
                        AND A.class_id != OLD.class_id
                ) C ON C.subject_id = B.subject_id
            WHERE A.student_id = OLD.student_id
        ) THEN
            UPDATE student
            SET cpa_total_study_credits = cpa_total_study_credits - updating_credits
            WHERE id = OLD.student_id;
        END IF;

        UPDATE student
        SET gpa_total_study_credits = gpa_total_study_credits - updating_credits
        WHERE id = OLD.student_id;
    END IF;
    RETURN NEW;
END $$;

CREATE OR REPLACE TRIGGER credits_trigger
    BEFORE INSERT OR DELETE ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE credits_trigger_function();

DROP FUNCTION IF EXISTS student.show_credits_enrolled;
CREATE OR REPLACE FUNCTION student.show_credits_enrolled(i_student_id CHAR(8) DEFAULT NULL)
    RETURNS NUMERIC
    LANGUAGE plpgsql
AS $$
DECLARE show_credits_enrolled NUMERIC;
BEGIN
    IF i_student_id IS NULL THEN
        SELECT gpa_total_study_credits INTO show_credits_enrolled
        FROM student.self_view_info;
    ELSE
        SELECT gpa_total_study_credits INTO show_credits_enrolled
        FROM student
        WHERE id = i_student_id;
    END IF;
    RETURN show_credits_enrolled;
END $$;

-- 2.2.3e. Schedules are automatically identified after students enroll in classes.
-- Done 2.2.2.

-- 2.2.3f. Enroll in classes.
DROP PROCEDURE IF EXISTS student.enroll_class;
CREATE OR REPLACE PROCEDURE student.enroll_class(i_student_id CHAR(8), i_class_id CHAR(6))
    LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO enrollment(student_id, class_id) VALUES(i_student_id, i_class_id);
END $$;

-- 2.2.3g. Enroll class having company_id will automatically enroll in the company class.
DROP FUNCTION IF EXISTS enroll_both CASCADE;
CREATE OR REPLACE FUNCTION enroll_both()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE comp_id char(9);
BEGIN
    SELECT company_id INTO comp_id
    FROM class
    WHERE id = NEW.class_id;

    IF comp_id != 'NULL' THEN
        INSERT INTO enrollment(student_id, class_id)
            VALUES(NEW.student_id, comp_id);
    END IF;
    RETURN NEW;
END $$;

CREATE OR REPLACE TRIGGER company_id_trigger
    BEFORE INSERT ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE enroll_both();

-- 2.2.4. Looking up data related to lecturers, subjects, classes, and other students. Retrieve only essential information, excluding personal ones like address, scores, and student timetable.
-- 2.2.4a. Students: Name, ID, School/Faculty, Program, Contact, etc.
DROP FUNCTION IF EXISTS search.search_student_by_id;
CREATE OR REPLACE FUNCTION search.search_student_by_id(i_student_id CHAR(8))
    RETURNS TABLE (
        id CHAR(8),
        first_name VARCHAR(35),
        last_name VARCHAR(35),
        gender CHAR(1),
        status BOOLEAN,
        email VARCHAR(35),
        program_code VARCHAR(8),
        program_name VARCHAR(100),
        faculty_name VARCHAR(100)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM search.view_search_student v
        WHERE v.id = i_student_id;
END $$;

DROP FUNCTION IF EXISTS search.search_student_by_name;
CREATE OR REPLACE FUNCTION search.search_student_by_name(i_student_name VARCHAR(100))
    RETURNS TABLE (
        id CHAR(8),
        first_name VARCHAR(35),
        last_name VARCHAR(35),
        gender CHAR(1),
        status BOOLEAN,
        email VARCHAR(35),
        program_code VARCHAR(8),
        program_name VARCHAR(100),
        faculty_name VARCHAR(100)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM search.view_search_student v
        WHERE v.first_name || ' ' || v.last_name LIKE '%' || i_student_name || '%';
END $$;

-- 2.2.4b. Lecturers: Name, ID, School/Faculty, Teaching Subjects, Contact, etc.
-- Search general information of lecturer.
DROP FUNCTION IF EXISTS search.search_lecturer_by_id;
CREATE OR REPLACE FUNCTION search.search_lecturer_by_id(i_lecturer_id CHAR(12))
    RETURNS TABLE (
        id CHAR(12),
        first_name VARCHAR(35),
        last_name VARCHAR(35),
        gender CHAR(1),
        status BOOLEAN,
        email VARCHAR(35),
        faculty_name VARCHAR(100)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM search.view_search_lecturer v
        WHERE v.id = i_lecturer_id;
END $$;

DROP FUNCTION IF EXISTS search.search_lecturer_by_name;
CREATE OR REPLACE FUNCTION search.search_lecturer_by_name(i_lecturer_name VARCHAR(100))
    RETURNS TABLE (
        id CHAR(12),
        first_name VARCHAR(35),
        last_name VARCHAR(35),
        gender CHAR(1),
        status BOOLEAN,
        email VARCHAR(35),
        faculty_name VARCHAR(100)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM search.view_search_lecturer v
        WHERE v.first_name || ' ' || v.last_name LIKE '%' || i_lecturer_name || '%';
END $$;

-- Search lecturer's teaching subjects.
DROP FUNCTION IF EXISTS search.search_lecturer_specialization_by_id;
CREATE OR REPLACE FUNCTION search.search_lecturer_specialization_by_id(i_lecturer_id CHAR(12))
    RETURNS TABLE (
        id CHAR(12),
        first_name VARCHAR(35),
        last_name VARCHAR(35),
        subject_id VARCHAR(8),
        subject_name VARCHAR(100)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM search.view_search_lecturer_specialization s
        WHERE s.id = i_lecturer_id;
END $$;

DROP FUNCTION IF EXISTS search.search_lecturer_specialization_by_name;
CREATE OR REPLACE FUNCTION search.search_lecturer_specialization_by_name(i_lecturer_name VARCHAR(100))
    RETURNS TABLE (
        id CHAR(12),
        first_name VARCHAR(35),
        last_name VARCHAR(35),
        subject_id VARCHAR(8),
        subject_name VARCHAR(100)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT s.* FROM search.view_search_lecturer_specialization s
        JOIN search.view_search_lecturer l ON l.id = s.id
        WHERE l.first_name || ' ' || l.last_name LIKE '%' || i_lecturer_name || '%';
END $$;

-- 2.2.4c. Subjects, Classes:  Number of credits, Schedule of classes, etc.
-- Done in 2.2.1.

-- 2.2.5. Getting estimated fees for the current semester. 
-- +) Total Fees = Tuition Credits * Credit Price + Other Fees.
-- +) The Credit Price can vary between programs.
-- +) Other Fees can be Insurance Fees, Previous Debt, etc.
-- +) Tuition Credits ≠ Study Credits.
DROP FUNCTION IF EXISTS student.show_estimated_fees;
CREATE OR REPLACE FUNCTION student.show_estimated_fees(i_student_id char(8) DEFAULT NULL)
    RETURNS TABLE(
        o_total_fees NUMERIC
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    IF i_student_id IS NULL THEN
        RETURN QUERY
            SELECT gpa_total_study_credits * credit_price + tuition_debt
            FROM student.self_view_info s
                JOIN program ON s.program_id = program.id
            WHERE s.id = CURRENT_USER;
    ELSE
        RETURN QUERY
            SELECT gpa_total_study_credits * credit_price + tuition_debt
            FROM student s
                JOIN program ON s.program_id = program.id
            WHERE s.id = i_student_id;
    END IF;
END $$;

-- 2.2.6. Getting reports on Study Credits earned, GPA/CPA.
DROP FUNCTION IF EXISTS student.report_student;
CREATE OR REPLACE FUNCTION student.report_student(i_student_id char(8) DEFAULT NULL)
    RETURNS TABLE(
        o_cpa_total_study_credits NUMERIC,
        o_cpa NUMERIC,
        o_gpa_total_study_credits NUMERIC,
        o_gpa NUMERIC
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    IF i_student_id IS NULL THEN
        RETURN QUERY
            SELECT
                CASE
                    WHEN cpa_total_study_credits = 0 THEN 0
                    ELSE ROUND(cpa_total_study_credits, 1)
                END,
                CASE
                    WHEN cpa_total_study_credits = 0 THEN 0
                    ELSE ROUND(cpa_total_score_product / cpa_total_study_credits, 1)
                END,
                CASE
                    WHEN gpa_total_study_credits = 0 THEN 0
                    ELSE ROUND(gpa_total_study_credits, 1)
                END,
                CASE
                    WHEN gpa_total_study_credits = 0 THEN 0
                    ELSE ROUND(gpa_total_score_product / gpa_total_study_credits, 1)
                END
            FROM student.self_view_info;
    ELSE
        RETURN QUERY
            SELECT
                CASE
                    WHEN cpa_total_study_credits = 0 THEN 0
                    ELSE ROUND(cpa_total_study_credits, 1)
                END,
                CASE
                    WHEN cpa_total_study_credits = 0 THEN 0
                    ELSE ROUND(cpa_total_score_product / cpa_total_study_credits, 1)
                END,
                CASE
                    WHEN gpa_total_study_credits = 0 THEN 0
                    ELSE ROUND(gpa_total_study_credits, 1)
                END,
                CASE
                    WHEN gpa_total_study_credits = 0 THEN 0
                    ELSE ROUND(gpa_total_score_product / gpa_total_study_credits, 1)
                END
            FROM student
            WHERE id = i_student_id;
    END IF;
END $$;
