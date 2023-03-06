-- Note! Restore database from backup before demo!

-- Set up student
DROP OWNED BY "20200164";
DROP USER IF EXISTS "20200164";
CREATE USER "20200164" WITH PASSWORD 'demo';
GRANT USAGE ON SCHEMA public TO "20200164";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "20200164";
GRANT ALL PRIVILEGES ON enrollment to "20200164";
REVOKE SELECT ON student FROM "20200164"; -- Too much info
REVOKE SELECT ON lecturer FROM "20200164"; -- Too much info

GRANT USAGE ON SCHEMA student TO "20200164";
GRANT SELECT ON ALL TABLES IN SCHEMA student TO "20200164";
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA student TO "20200164";

GRANT USAGE ON SCHEMA search TO "20200164";
GRANT SELECT ON ALL TABLES IN SCHEMA search TO "20200164";
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA search TO "20200164";

-- Set up lecturer
DROP OWNED BY "aaaaaaaaaaaa";
DROP USER IF EXISTS "aaaaaaaaaaaa";
CREATE USER "aaaaaaaaaaaa" WITH PASSWORD 'demo';
GRANT USAGE ON SCHEMA public TO "aaaaaaaaaaaa";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "aaaaaaaaaaaa";
GRANT ALL PRIVILEGES ON enrollment to "aaaaaaaaaaaa";
REVOKE SELECT ON student FROM "aaaaaaaaaaaa"; -- Too much info
REVOKE SELECT ON lecturer FROM "aaaaaaaaaaaa"; -- Too much info

GRANT USAGE ON SCHEMA lecturer TO "aaaaaaaaaaaa";
GRANT SELECT ON ALL TABLES IN SCHEMA lecturer TO "aaaaaaaaaaaa";
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA lecturer TO "aaaaaaaaaaaa";

GRANT USAGE ON SCHEMA search TO "aaaaaaaaaaaa";
GRANT SELECT ON ALL TABLES IN SCHEMA search TO "aaaaaaaaaaaa";
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA search TO "aaaaaaaaaaaa";

-- 2.1. Staff (Admin)
-- 2.1.1. Adding students, lecturers, subjects, and classes with the following data.
-- 2.1.1a. Students: Name, ID, School/Faculty, Program, Date of Birth, Address, Contact, etc.
-- Use PROCEDURE add_student() to add student
CALL add_student('20205147', 'Tong Tran Minh', 'Duc', 'M', '2002-09-03', true, '2022-02-04', '67 Le Thanh Nghi', 'duc.ttm205147@sis.hust.edu.vn', '0902112042', '509463');
SELECT * FROM student WHERE id LIKE '20205147';

-- 2.1.1b. Lecturers: Name, ID, School/Faculty, Teaching Subjects, Date of Birth, Address, Contact, etc.
-- Use PROCEDURE add_lecturer() to add lecturer
CALL add_lecturer('aaaaaaaaaaaa', 'Tong Tran Minh', 'Duc', 'M', '2002-09-03', true, '2022-02-04', '67 Le Thanh Nghi', 'duc.ttm205147@sis.hust.edu.vn', '0902112042', 'TCNTT');
SELECT * FROM lecturer WHERE id LIKE 'aaaaaaaaaaaa';

-- 2.1.1c. Subjects: Prerequisites, Number of credits, etc.
-- Use PROCEDURE add_subject() to add subject
CALL add_subject('IT3333', 'Data Structure and Algorithm', 3, 4, 0.7, 'IT2000', 'TCNTT');
SELECT * FROM subject WHERE id LIKE 'IT3333';

-- 2.1.1d. Classes: Time, Location, Slot Availability, Semester, Number of credits, Schedule of classes, etc.
-- Use PROCEDURE add_class() to add class
CALL add_class('555555', 'LT', '20201', 'N', 0, 80, NULL, NULL, 'IT3333');
SELECT * FROM class WHERE id LIKE '555555';

-- 2.1.2. Managing information of students, lecturers, subjects, and classes.
-- NO PROCEDURE! Do this manually!
UPDATE student SET first_name = 'Tong' WHERE id = '20205147';
SELECT * FROM student WHERE id LIKE '20205147';

-- 2.1.3. Creating a tentative timetable for the upcoming semester, i.e creating classes for each subject. A subject can have 0, 1, or many classes open in a semester.
-- Use TRIGGER check timetable conflict BEFORE INSERT
-- Use PROCEDURE add_timetable() to add timetable
CALL add_timetable('555555', '3', '1800', '1900', 'D9-505');
SELECT * FROM timetable WHERE class_id LIKE '555555';

-- 2.1.4. Making changes to the timetable.
-- Use TRIGGER check timetable conflict BEFORE UPDATE
-- NO PROCEDURE! Do this manually!
UPDATE timetable
SET location = 'D9-510'
WHERE class_id = '555555';
SELECT * FROM timetable WHERE class_id LIKE '555555';

-- 2.1.5. Assigning lecturers to classes based on the timetable.
-- Use TRIGGER check teaching conflict BEFORE UPDATE
-- Use PROCEDURE assign_lecturer() to assign lecturer to class
CALL assign_lecturer('aaaaaaaaaaaa', '555555');
SELECT * FROM class WHERE lecturer_id LIKE 'aaaaaaaaaaaa';
-- Test teaching conflict TRIGGER
CALL add_class('666666', 'LT', '20201', 'N', 0, 80, NULL, NULL, 'IT3333');
CALL add_timetable('666666', '3', '1830', '1930', 'D9-505');
CALL assign_lecturer('aaaaaaaaaaaa', '666666');

-- 2.1.6. Assigning students to classes.
-- Reset GPA of all active students. Run at beginning of each semester.
-- Use PROCEDURE reset_gpa() to reset GPA of all active students
CALL reset_gpa();

-- 2.1.6a. Classes having a number of enrolled students fewer than [X], used for canceling classes with low enrollment.
-- Use FUNCTION report_enrolled() to return report of all classes
SELECT * FROM report_enrolled();
SELECT * FROM report_enrolled('20212');
UPDATE class SET current_cap = max_cap / 2 WHERE id = '134090';
SELECT * FROM report_enrolled('20212');

-- 2.1.6b. Students with credit debt from unfinished (failed) subjects in the range [A, B], used for sending warnings.
-- Use FUNCTION report_credit_debt() to return report of all students
SELECT * FROM report_credit_debt();

-- 2.1.6c. Students qualified for semester scholarships with GPA ≥ [G]
-- Use FUNCTION report_scholarship() to return report of all students
CALL student.enroll_class('20200164', '135387'); -- enroll_class() in 2.2.3f.
CALL student.enroll_class('20200164', '135404');
CALL student.enroll_class('20200164', '135406');
CALL student.enroll_class('20200164', '135409');
CALL student.enroll_class('20200164', '135410');
CALL student.enroll_class('20200164', '135411');
CALL student.enroll_class('20200164', '135469');
CALL student.enroll_class('20200164', '722873');
UPDATE enrollment SET midterm_score = 10, final_score = 10 WHERE student_id = '20200164'
    AND class_id IN ('135387', '135404', '135406', '135409', '135410', '135411', '135469', '722873');
SELECT e.*, t.*, c.semester, s.study_credits
    FROM enrollment e
    LEFT JOIN timetable t ON e.class_id = t.class_id
    LEFT JOIN class c ON e.class_id = c.id
    LEFT JOIN subject s ON c.subject_id = s.id
    WHERE student_id = '20200164';
SELECT * FROM student WHERE id = '20200164';
SELECT * FROM report_scholarship();

-- Demo student 20200164
-- 2.2.1 Viewing data of subjects, classes, and results of themselves.
-- View all subjects of their curriculum
-- Use FUNCTION self_view_curriculum() to return subjects of student
SELECT * FROM student.self_view_curriculum();

-- View their classes in of any semesters
-- Use FUNCTION self_view_class_enrolled() to return enrolled of any semesters
SELECT * FROM student.self_view_class_enrolled(); -- All semesters
SELECT * FROM student.self_view_class_enrolled('20221');

-- View their results in of any semesters
-- Use FUNCTION self_view_results() to return results of any semesters
SELECT * FROM student.self_view_results(); -- All semesters
SELECT * FROM student.self_view_results('20221');

-- View their timetable in of a semester
-- Use FUNCTION self_view_timetable() to return timetable of a semester
SELECT * FROM student.self_view_timetable('20221');

-- 2.2.2. View the tentative timetable to find suitable opening classes (more info on enrollment).
-- Use FUNCTION show_class_info() to return class info
SELECT * FROM student.show_class_info(NULL, '20221'); -- All classes in 20221
SELECT * FROM student.show_class_info('136302');

-- 2.2.3. Enrolling in classes.
-- 2.2.3a. Showing enrolling information such as time, location, credit, slot availability, and prerequisites.
-- Done in 2.2.2.

-- 2.2.3b. Check for slot availability, class prerequisites and lab requirements.
-- Use TRIGGER check_cap_trigger BEFORE INSERT ON enrollment
-- Use TRIGGER check_prerequisite_trigger BEFORE INSERT ON enrollment
-- Use TRIGGER check_lab_trigger BEFORE INSERT ON enrollment

-- 2.2.3c. Check for time conflicts.
-- Use TRIGGER check_time_enrolled BEFORE INSERT ON enrollment

-- 2.2.3d. Calculate total studying credits.
-- Use TRIGGER credits_trigger BEFORE INSERT ON enrollment
-- Use FUNCTION show_credits_enrolled() to return enrolled credits of current student
SELECT * FROM student.show_credits_enrolled(); -- As 20200164
SELECT * FROM student.show_credits_enrolled('20200164'); -- As admin

-- 2.2.3e. Schedules are automatically identified after students enroll in classes.
-- Done 2.2.2.

-- 2.2.3f. Enroll in classes.
-- Use PROCEDURE enroll_class() to enroll in classes
-- CALL enroll_class(CURRENT_USER, '...');

-- 2.2.3g. Enroll class having company_id will automatically enroll in the company class.
-- TODO: Integrate to enroll_class() procedure
-- USE PROCEDURE enroll_both() to enroll in both classes
-- CALL enroll_both(CURRENT_USER, '...');

-- 2.2.4. Looking up data related to lecturers, subjects, classes, and other students. Retrieve only essential information, excluding personal ones like address, scores, and student timetable.
-- 2.2.4a. Students: Name, ID, School/Faculty, Program, Contact, etc.
-- Use FUNCTION search_student_by_id() to return student by id
-- Use FUNCTION search_student_by_name() to return student by name
SELECT * FROM search.search_student_by_id('20200164');
SELECT * FROM search.search_student_by_name('Robinson');

-- 2.2.4b. Lecturers: Name, ID, School/Faculty, Teaching Subjects, Contact, etc.
-- Search general information of lecturer.
-- Use FUNCTION search_lecturer_by_id() to return lecturer by id
-- Use FUNCTION search_lecturer_by_name() to return lecturer by name
SELECT * FROM search.search_lecturer_by_id('aaaaaaaaaaaa');
SELECT * FROM search.search_lecturer_by_name('Robinson');

-- Search lecturer's teaching subjects.
-- Use FUNCTION search_lecturer_specialization_by_id() to return lecturer's teaching subjects by id
-- Use FUNCTION search_lecturer_specialization_by_name() to return lecturer's teaching subjects by name
SELECT * FROM search.search_lecturer_specialization_by_id('aaaaaaaaaaaa');
SELECT * FROM search.search_lecturer_specialization_by_name('Robinson');

-- 2.2.4c. Subjects, Classes:  Number of credits, Schedule of classes, etc.
-- Done in 2.2.1.

-- 2.2.5. Getting estimated fees for the current semester. 
-- +) Total Fees = Tuition Credits * Credit Price + Other Fees.
-- +) The Credit Price can vary between programs.
-- +) Other Fees can be Insurance Fees, Previous Debt, etc.
-- +) Tuition Credits ≠ Study Credits.
-- Use FUNCTION show_estimated_fees() to return estimated fees of current student
SELECT * FROM student.show_estimated_fees(); -- As 20200164
SELECT * FROM student.show_estimated_fees('20200164'); -- As admin

-- 2.2.6. Getting reports on Study Credits earned, GPA/CPA.
-- Use FUNCTION report_student() to return report of current student
SELECT * FROM student.report_student(); -- As 20200164
SELECT * FROM student.report_student('20200164'); -- As admin

-- Demo lecturer aaaaaaaaaaaa
-- 2.3.1. Viewing data of all teaching subjects, classes, and results of themselves.
-- View all subjects of their specializations
-- Use FUNCTION self_view_specializations() to return specializations of lecturer
SELECT * FROM lecturer.self_view_specializations();
-- View all classes of their teachings of any semesters
-- Use FUNCTION self_view_class_assigned() to return assigned of lecturer
SELECT * FROM lecturer.self_view_class_assigned();
SELECT * FROM lecturer.self_view_class_assigned('20201');

-- 2.3.2. Looking up data related to students, subjects, classes, and other lecturers. Retrieve only essential information, excluding personal ones like address, scores, and student timetable.
-- 2.3.2a. Students: Name, ID, School/Faculty, Program, Contact, etc.
-- Done in 2.2.4a.

-- 2.3.2b. Lecturers: Name, ID, School/Faculty, Teaching Subjects, Contact, etc.
-- Done in 2.2.4b.

-- 2.3.2c. Subjects, Classes:  Number of credits, Schedule of classes, etc.
-- Done in 2.2.1.

-- 2.3.3. Recording student academic performance.
-- Use PROCEDURE update_grade() to update grade of student
CALL lecturer.update_grade('20205147', '133729', 7, 8);
SELECT * FROM enrollment WHERE student_id = '20205147' AND class_id = '133729';

-- 2.2.4. Tracking student attendance.
-- Use PROCEDURE mark_absence() to mark absence of student
CALL lecturer.mark_absence('20205147', '133729');
SELECT * FROM enrollment WHERE student_id = '20205147' AND class_id = '133729';
-- Use PROCEDURE undo_absence() to undo absence of student
CALL lecturer.undo_absence('20205147', '133729');
SELECT * FROM enrollment WHERE student_id = '20205147' AND class_id = '133729';

-- 2.2.5a. Getting reports on exam grade distribution (statistics)
-- Use FUNCTION report_grade_distribution() to return grade distribution of class
SELECT * FROM lecturer.report_grade_distribution('133729');

-- 2.2.5b. Getting reports on student attendance up to today
-- Use FUNCTION report_attendance() to return attendance of class
SELECT * FROM lecturer.report_attendance('133729');
