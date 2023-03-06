-- 2.3.1. Viewing data of all teaching subjects, classes, and results of themselves.
-- View all subjects of their specializations
-- Done as a view: lecturer.self_view_specializations

-- View all classes of their teachings of any semesters
DROP FUNCTION IF EXISTS lecturer.self_view_class_assigned;
CREATE OR REPLACE FUNCTION lecturer.self_view_class_assigned(i_semester VARCHAR(5) DEFAULT NULL)
    RETURNS TABLE(
        class_id CHAR(6),
        subject_id VARCHAR(7),
        subject_name VARCHAR(50),
        semester CHAR(5),
        max_cap INTEGER
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    IF i_semester IS NOT NULL THEN
        RETURN QUERY
            SELECT c.id, s.id, s.name, c.semester, c.max_cap
            FROM class c
            JOIN lecturer.self_view_info l ON c.lecturer_id = l.id
            JOIN subject s ON c.subject_id = s.id
            WHERE c.semester = i_semester;
    ELSE
        RETURN QUERY
            SELECT c.id, s.id, s.name, c.semester, c.max_cap
            FROM class c
            JOIN lecturer.self_view_info l ON c.lecturer_id = l.id
            JOIN subject s ON c.subject_id = s.id;
    END IF;
END $$;

-- 2.3.2. Looking up data related to students, subjects, classes, and other lecturers. Retrieve only essential information, excluding personal ones like address, scores, and student timetable.
-- 2.3.2a. Students: Name, ID, School/Faculty, Program, Contact, etc.
-- Done in 2.2.4a.

-- 2.3.2b. Lecturers: Name, ID, School/Faculty, Teaching Subjects, Contact, etc.
-- Done in 2.2.4b.

-- 2.3.2c. Subjects, Classes:  Number of credits, Schedule of classes, etc.
-- Done in 2.2.1.

-- 2.3.3. Recording student academic performance.
DROP PROCEDURE IF EXISTS lecturer.update_grade;
CREATE OR REPLACE PROCEDURE lecturer.update_grade(
        i_student_id CHAR(8),
        i_class_id CHAR(6),
        i_midterm_score NUMERIC,
        i_final_score NUMERIC
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE enrollment
    SET midterm_score = i_midterm_score,
        final_score = i_final_score
    WHERE student_id = i_student_id
        AND class_id = i_class_id;
END $$;

-- 2.2.4. Tracking student attendance.
-- Mark student absence
DROP PROCEDURE IF EXISTS lecturer.mark_absence;
CREATE OR REPLACE PROCEDURE lecturer.mark_absence(
        i_student_id CHAR(8),
        i_class_id CHAR(6)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE enrollment
    SET absent_count = absent_count + 1
    WHERE student_id = i_student_id
        AND class_id = i_class_id;
END $$;

-- Undo student absence
DROP PROCEDURE IF EXISTS lecturer.undo_absence;
CREATE OR REPLACE PROCEDURE lecturer.undo_absence(
        i_student_id CHAR(8),
        i_class_id CHAR(6)
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE enrollment
    SET absent_count = absent_count - 1
    WHERE student_id = i_student_id
        AND class_id = i_class_id;
END $$;

-- 2.2.5a. Getting reports on exam grade distribution (statistics)
DROP FUNCTION IF EXISTS lecturer.report_grade_distribution;
CREATE OR REPLACE FUNCTION lecturer.report_grade_distribution(i_class_id CHAR(6))
    RETURNS TABLE(
        mapping_score NUMERIC,
        count BIGINT
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT e.mapping_score, COUNT(e.mapping_score) AS count
        FROM enrollment e
        WHERE e.class_id = i_class_id
        GROUP BY e.mapping_score
        ORDER BY e.mapping_score DESC;
END $$;

-- 2.2.5b. Getting reports on student attendance up to today
DROP FUNCTION IF EXISTS lecturer.report_attendance;
CREATE OR REPLACE FUNCTION lecturer.report_attendance(i_class_id CHAR(6))
    RETURNS TABLE(
        student_id CHAR(8),
        absent_count INTEGER
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT e.student_id, e.absent_count
        FROM enrollment e
        WHERE e.class_id = i_class_id;
END $$;
