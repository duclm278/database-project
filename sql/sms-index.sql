-- Create necessary indexes for searching
-- Create indexes for char
-- Do not create indexes for large varchar
-- Do not create indexes for fully joining
-- Do not create indexes for table having few rows

-- 2.1.0.
-- Before indexes: Seq scan, hash join
EXPLAIN
SELECT c.semester, t.* FROM timetable t
JOIN class c ON c.id = t.class_id;

-- Not used due to full table scan
DROP INDEX IF EXISTS timetable_class_id;
CREATE INDEX timetable_class_id ON timetable (class_id);

-- 2.1.5.
-- Sub query of join
-- Fast as pk_timetable is used: Index only scan
EXPLAIN
SELECT t.*
FROM timetable t
WHERE t.class_id = '134090';

-- Join 2 sub queries
-- Fast as one row is returned for each sub query
EXPLAIN
SELECT a.weekday, a.start_time, a.end_time, a.location
FROM (
    -- Timetable of NEW class
    SELECT t.*
    FROM timetable t
    WHERE t.class_id = '134090'
) a
JOIN (
    -- Timetable of OLD class
    SELECT t.*
    FROM timetable t
    WHERE t.class_id = '134091'
) b ON (
    a.weekday = b.weekday
    AND a.start_time = b.start_time
    AND a.end_time = b.end_time
    AND a.location = b.location
);

-- Another sub query
-- Before indexes: Seq scan on class
EXPLAIN
SELECT t.*
FROM timetable t
JOIN class c ON t.class_id = c.id
WHERE c.semester = '20212'
AND c.lecturer_id = 'aaaaaaaaaaaa';

-- Faster as class_lecturer_id is used: Bitmap index scan
-- Then filter by semester
DROP INDEX IF EXISTS class_lecturer_id;
CREATE INDEX class_lecturer_id ON class (lecturer_id);

-- A lot of other queries involve semesters.
EXPLAIN
SELECT c.* FROM class c
WHERE c.semester = '20212';

DROP INDEX IF EXISTS class_semester;
CREATE INDEX class_semester ON class (semester);

-- 2.1.6c.
-- Mapping score to scale 4
-- No need to create index
EXPLAIN
SELECT * FROM class c
JOIN subject s
ON c.subject_id = s.id
WHERE c.id = '123456';

-- 2.2. Students
-- For filtering 'TN' type
DROP INDEX IF EXISTS class_type;
CREATE INDEX class_type ON class (type);

-- self_view_info doesn't need indexes!
-- Only store one record per user!

-- Create indexes for id of searching views.
-- Name is large varchar and searching with '%' so skip!
SELECT * FROM search.view_search_student v
WHERE v.first_name || ' ' || v.last_name LIKE '%' || i_student_name || '%';

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

-- 2.3. Lecturers
-- self_view_info doesn't need indexes!
-- Only store one record per user!

-- Conclusions
-- Searching and joining are quite efficient as the system works mainly with primary keys.
-- Triggers and custom views are very powerful as the system needs complex checking and restrictions.
-- Future range searching might need more indexes.
-- Eg: Report on absent_count > [X] only, not on all data.

-- Insights gained from this project
-- See how triggers and custom views are applied.
-- Make use of variables and triggers for quicker querying.
-- ERD process helps a lot with the design of the database.
-- Many entities and relations are involved.
