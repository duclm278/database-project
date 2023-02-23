-- GPA reports
CREATE OR REPLACE FUNCTION credits_trigger_function()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE add_credits numeric;
BEGIN
    SELECT calculate_credits_func(NEW.class_id) INTO add_credits;
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
    ) THEN (
        UPDATE student
        SET cpa_total_study_credits = cpa_total_study_credits + add_credits
        WHERE id = NEW.student_id;
    )
    END IF;

    UPDATE student
    SET gpa_total_study_credits = gpa_total_study_credits + add_credits
    WHERE id = NEW.student_id;
    RETURN NEW;
END $$;

DROP FUNCTION credits_trigger_function()
CREATE TRIGGER credits_trigger
    BEFORE INSERT ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE credits_trigger_function();

DROP TRIGGER credits_trigger ON enrollment
CREATE OR REPLACE FUNCTION calculate_credits_func(class_id char(6))
    RETURNS NUMERIC
    LANGUAGE plpgsql
AS $$
DECLARE total_credits numeric;
BEGIN
    SELECT A.study_credits INTO total_credits
    FROM subject A
        JOIN class B ON A.id = B.subject_id
    WHERE B.id = class_id;
    RETURN total_credits;
END $$;

SELECT calculate_credits_func('133725') DROP FUNCTION calculate_credits_func(char(6)) -- trigger function to calculate gpa and cpa






CREATE OR REPLACE FUNCTION score_trigger_function() RETURNS TRIGGER language plpgsql AS $$
DECLARE add_product1 numeric;

add_product2 numeric;

enroll_hist boolean;

BEGIN
SELECT calculate_product_func(NEW.midterm_score, NEW.final_score, NEW.class_id) INTO add_product1;

SELECT check_enroll_history(NEW.student_id, NEW.class_id) INTO enroll_hist;

IF enroll_hist = TRUE THEN
SELECT calculate_product_func(B.midterm_score, B.final_score, B.class_id) INTO add_product2
FROM (
        SELECT A.subject_id
        FROM class A
        WHERE A.id = NEW.class_id
    ) A
    JOIN (
        SELECT A.midterm_score,
            A.final_score,
            A.class_id,
            B.subject_id
        FROM enrollment A
            JOIN class B ON A.class_id = B.id
        WHERE A.student_id = NEW.student_id
    ) B ON B.subject_id = A.subject_id;

IF add_product1 > add_product2 THEN
UPDATE student
SET cpa_total_score_product = cpa_total_score_product + add_product1 - add_product2
WHERE id = NEW.student_id;

END IF;

ELSE
UPDATE student
SET cpa_total_score_product = cpa_total_score_product + add_product1
WHERE id = NEW.student_id;

END IF;

UPDATE student
SET gpa_total_score_product = gpa_total_score_product + add_product1
WHERE id = NEW.student_id;

RETURN NEW;

END $$;

DROP FUNCTION score_trigger_function -- cpa and gpa trigger
CREATE TRIGGER score_trigger before
INSERT
    OR
UPDATE ON enrollment FOR each ROW EXECUTE PROCEDURE score_trigger_function();

DROP TRIGGER score_trigger ON enrollment -- check whether a student enrolled this subject before
CREATE OR REPLACE FUNCTION check_enroll_history(std_id char(8), class_id char(6)) RETURNS boolean language plpgsql AS $$ BEGIN IF EXISTS (
        SELECT *
        FROM (
                SELECT A.subject_id
                FROM class A
                WHERE A.id = class_id
            ) A
            JOIN (
                SELECT B.subject_id
                FROM enrollment A
                    JOIN class B ON A.class_id = B.id
                WHERE A.student_id = std_id
            ) B ON B.subject_id = A.subject_id
    ) THEN RETURN TRUE;

END IF;

RETURN false;

END $$;

DROP FUNCTION check_enroll_history -- function to convert grade to grade in scale of 4
CREATE OR REPLACE FUNCTION calculate_product_func(
        mid_score integer,
        fin_score integer,
        class_id char(6)
    ) RETURNS numeric language plpgsql AS $$
DECLARE total_product numeric;

BEGIN
SELECT A.study_credits * CASE
        WHEN A.score >= 4.0
        AND A.score <= 4.9 THEN 1
        WHEN A.score >= 5.0
        AND A.score <= 5.4 THEN 1.5
        WHEN A.score >= 5.5
        AND A.score <= 6.4 THEN 2
        WHEN A.score >= 6.5
        AND A.score <= 6.9 THEN 2.5
        WHEN A.score >= 7.0
        AND A.score <= 7.9 THEN 3
        WHEN A.score >= 8.0
        AND A.score <= 8.4 THEN 3.5
        WHEN A.score >= 8.5
        AND A.score <= 10 THEN 4
        ELSE 0
    END AS exchange_score INTO total_product
FROM(
        SELECT (
                mid_score *(1 - C.final_weight) + fin_score * C.final_weight
            ) score,
            C.study_credits
        FROM class B
            JOIN subject C ON B.subject_id = C.id
        WHERE B.id = class_id
    ) A;

RETURN total_product;

END $$;
