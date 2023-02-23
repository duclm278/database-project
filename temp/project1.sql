--2:Students
---4
--a
create view search_student as
select student.id,
   student.first_name,
   student.last_name,
   program.name as program_name,
   program.code as program_code,
   faculty.name as faculty_name
from student,
   program,
   faculty
where student.program_id = program.id
   and program.faculty_id = faculty.id;

create or replace function student_find_student_id (student_id char(8)) returns table(
      studentID char,
      first_name varchar,
      last_name varchar,
      program_name varchar,
      program_code varchar,
      faculty varchar
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_student
where id = student_id;

end;

$$
create or replace function student_find_student_name (student_name varchar(50)) returns table(
      studentID char,
      first_name varchar,
      last_name varchar,
      program_name varchar,
      program_code varchar,
      faculty varchar
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_student
where first_name = student_name
   or last_name = student_name;

end;

$$ --b
create view search_lecturer as
select lecturer.first_name,
   lecturer.last_name,
   lecturer.gender,
   lecturer.email,
   faculty.name,
   specialization.subject_id
from lecturer,
   specialization,
   faculty
where lecturer.faculty_id = faculty.id
   and lecturer.id = specialization.lecturer_id;

create or replace function student_find_lecturer (lecturer_name varchar(50)) returns table(
      first_name char,
      last_name varchar,
      gender char,
      email varchar,
      faculty_name varchar,
      subject_id varchar
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_lecturer
where lecturer_name = first_name
   or lecturer_name = last_name;

end;

$$ --c
create view search_subject as
select subject.id,
   subject.name,
   subject.study_credits,
   subject.tuition_credits,
   subject.final_weight,
   subject.prerequisite_id,
   subject.faculty_id,
   class.id as class_id,
   timetable.weekday,
   timetable.start_time,
   timetable.end_time,
   timetable.location,
   curriculum.program_id
from subject,
   class,
   timetable,
   curriculum
where subject.id = class.subject_id
   and class.id = timetable.class_id
   and curriculum.subject_id = subject.id;

create or replace function student_find_subject (subject_id varchar(7)) returns table(
      id char,
      name varchar,
      study_credits integer,
      tuition_credits integer,
      final_weight numeric,
      prerequisite_id varchar,
      faculty_id varchar,
      class_id varchar,
      weekday char,
      start_time char,
      end_time char,
      location varchar,
      program_id varchar
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_subject
where id = subject_id;

end;

$$ create view search_class as
select class.id,
   class.type,
   class.semester,
   class.current_cap,
   class.max_cap,
   class.subject_id,
   timetable.weekday,
   timetable.start_time,
   timetable.end_time,
   timetable.location,
   lecturer.first_name,
   lecturer.last_name
from lecturer,
   class,
   timetable
where class.lecturer_id = lecturer.id
   and class.id = timetable.class_id
create or replace function student_find_class (class_id varchar(7)) returns table(
      id char,
      type varchar,
      semester char,
      current_cap integer,
      max_cap integer,
      subject_id varchar,
      weekday char,
      start_time char,
      end_time char,
      location varchar,
      first_name varchar,
      last_name varchar
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_subject
where id = class_id;

end;

$$ ---5
--		chưa đúng, chưa hoàn chỉnh
select sub.tuition_credits * p.credit_price + stu.tuition_debt as total_fees
from enrollment e
   inner join class c on e.class_id = c.id
   inner join subject sub on c.subject_id = sub.id
   inner join student stu on e.student_id = stu.id
   inner join program p on stu.program_id = p.id
where e.student_id = '20000002' ---6
   --3
   ---1	giống câu 2??
   ---2
   --a
   create view search_student_2 as
select student.id,
   student.first_name,
   student.last_name,
   program.name as program_name,
   program.code as program_code,
   faculty.name as faculty_name,
   student.cpa_total_study_credits,
   student.credit_debt,
   student.tuition_debt
from student,
   program,
   faculty
where student.program_id = program.id
   and program.faculty_id = faculty.id;

create or replace function lecturer_find_student_id (student_id char(8)) returns table(
      studentID char,
      first_name varchar,
      last_name varchar,
      program_name varchar,
      program_code varchar,
      faculty varchar,
      cpa numeric,
      credit_debt integer,
      tuition_debt integer
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_student
where id = student_id;

end;

$$
create or replace function student_find_student_name (student_name varchar(50)) returns table(
      studentID char,
      first_name varchar,
      last_name varchar,
      program_name varchar,
      program_code varchar,
      faculty varchar,
      cpa numeric,
      credit_debt integer,
      tuition_debt integer
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_student
where first_name = student_name
   or last_name = student_name;

end;

$$ --b
create view search_lecturer_2 as
select lecturer.first_name,
   lecturer.last_name,
   lecturer.gender,
   lecturer.email,
   faculty.name,
   specialization.subject_id,
   lecturer.birthday,
   lecturer.join_date,
   lecturer.phone
from lecturer,
   specialization,
   faculty
where lecturer.faculty_id = faculty.id
   and lecturer.id = specialization.lecturer_id;

create or replace function student_find_lecturer (lecturer_name varchar(50)) returns table(
      first_name char,
      last_name varchar,
      gender char,
      email varchar,
      faculty_name varchar,
      subject_id varchar,
      birthday date,
      join_date date,
      phone varchar
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_lecturer
where lecturer_name = first_name
   or lecturer_name = last_name;

end;

$$ --c
create view search_subject_2 as
select subject.id,
   subject.name,
   subject.study_credits,
   subject.final_weight,
   subject.prerequisite_id,
   subject.faculty_id,
   curriculum.program_id
from subject,
   curriculum
where curriculum.subject_id = subject.id;

create or replace function lecturer_find_subject (subject_id varchar(7)) returns table(
      id char,
      name varchar,
      study_credits integer,
      final_weight numeric,
      prerequisite_id varchar,
      faculty_id varchar,
      program_id varchar
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_subject
where id = subject_id;

end;

$$ create view search_class_2 as
select class.id,
   class.type,
   class.semester,
   class.require_lab,
   class.subject_id,
   timetable.weekday,
   timetable.start_time,
   timetable.end_time,
   timetable.location,
   lecturer.first_name,
   lecturer.last_name
from lecturer,
   class,
   timetable
where class.lecturer_id = lecturer.id
   and class.id = timetable.class_id
create or replace function lecturer_find_class (class_id varchar(7)) returns table(
      id char,
      type varchar,
      semester char,
      require_lab char,
      subject_id varchar,
      weekday char,
      start_time char,
      end_time char,
      location varchar,
      first_name varchar,
      last_name varchar
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_subject
where id = class_id;

end;

$$ ---3
create view search_score as
select enrollment.student_id,
   student.first_name,
   student.last_name,
   enrollment.midterm_score,
   enrollment.final_score
from enrollment,
   student
where enrollment.student_id = student.id
create or replace function view_score (student_id char(8)) returns table(
      studentID char,
      first_name varchar,
      last_name varchar,
      midterm_score integer,
      final_score integer
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_score
where id = student_id;

end;

$$
select student_id,
   midterm_score,
   final_score
from enrollment ---4
   create view search_attendance as
select enrollment.student_id,
   student.first_name,
   student.last_name,
   enrollment.absent_count
from enrollment,
   student
where enrollment.student_id = student.id
create or replace function view_score (student_id char(8)) returns table(
      studentID char,
      first_name varchar,
      last_name varchar,
      absent_count integer
   ) LANGUAGE plpgsql as $$ begin return query
select *
from search_attendance
where id = student_id;

end;

$$
select student_id,
   absent_count
from enrollment ---5	ko biết làm
   --a
select round(
      e.midterm_score * (1 - sub.final_weight) + e.final_score * sub.final_weight as score
   )
from enrollment e
   inner join class c on e.class_id = c.id
   inner join subject sub on sub.id = class.subject_id --b
create or replace function update_attendance(studemid, status, class_id) returns trigger as $$ begin if (TG_OP = 'APPEAR') then
update products
set absent_count = absent_count
where student_id = new.student_id;

elsif (TG_OP = 'ABSENT') then
update products
set absent_count = absent_count + 1
where student_id = new.student_id;

end if;

return new;

end;

$$ language plpgsql;

create trigger update_attendance
after
insert
   or
update
   or delete on enrollment for each row execute procedure update_attendance();
