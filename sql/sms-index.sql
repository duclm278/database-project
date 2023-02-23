-- 2.1.0
EXPLAIN
SELECT c.semester, t.* FROM timetable t
JOIN class c ON c.id = t.class_id;

DROP INDEX IF EXISTS timetable_class_id;
-- Not being used because of full table scan
CREATE INDEX timetable_class_id ON timetable (class_id);

-- 2.1.5
-- Like 2.1.0

-- 2.1.6c.
-- Mapping score to scale 4
-- No need to create index?
EXPLAIN
SELECT * FROM class c
JOIN subject s
ON c.subject_id = s.id
WHERE c.id = '123456';

-- Update score when enrollment is updated
-- ?

-- Return report of all students
-- ?
