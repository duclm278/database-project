import datetime
import psycopg2
import random
from faker import Faker
from helpers import *
from pprint import pprint
from psycopg2.extras import execute_values

# Settings
info = init()
conn = psycopg2.connect(info)
curs = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
fake = Faker()


def main():
    # Create schema
    exec_file("sql/sms-create.sql")

    # Import pre-generated data
    import_data("data/faculty.csv", "faculty")
    import_data("data/program.csv", "program")
    import_data("data/subject.tsv", "subject", sep="\t")
    import_data("data/20212/class.txt", "class", sep="\t")
    import_data("data/20212/timetable.txt", "timetable", sep="\t")
    import_data("data/20221/class.txt", "class", sep="\t")
    import_data("data/20221/timetable.txt", "timetable", sep="\t")

    # Generate lecturers, assign them to classes and update their specialization
    assign_classes(max_subjects=5, max_classes=25)

    # Generate curriculums having subjects from its faculty only
    insert_curriculums(max_subjects=50)

    # Generate students following random program
    insert_students(years=[2020, 2021, 2022], max_students=5000)

    # Generate old enrollments without complex checking
    simple_enrollments(semester=20212, max_subjects=10)

    # Close connection
    curs.close()
    conn.close()


@ timeit
def exec_file(path):
    with open(path, "r", encoding="utf-8") as f:
        curs.execute(f.read())
        conn.commit()


@ timeit
def import_data(path, table, sep=",", null="NULL"):
    with open(path, "r", encoding="utf-8") as f:
        curs.copy_from(f, table, sep=sep, null=null)
        conn.commit()


@ timeit
def select_table(table):
    curs.execute(f"SELECT * FROM {table}")
    pprint(curs.fetchall())


def insert_table(table, rows):
    columns = rows[0].keys()
    query = f"INSERT INTO {table} ({', '.join(columns)}) VALUES %s"
    values = [[value for value in row.values()] for row in rows]
    execute_values(curs, query, values)
    conn.commit()


def generate_lecturer(faculty_id):
    return {
        "id": fake.pystr(min_chars=12, max_chars=12),
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "gender": fake.random_element(elements=("M", "F")),
        "birthday": fake.date_of_birth(minimum_age=35, maximum_age=70),
        "status": fake.random_element(elements=(True, False)),
        "join_date": fake.date_between(start_date="-25y", end_date="today"),
        "address": fake.address(),
        "email": fake.email(),
        "phone": fake.phone_number(),
        "faculty_id": faculty_id
    }


@ timeit
def assign_classes(max_subjects, max_classes):
    print("Assigning classes...")

    curs.execute(
        """
        SELECT class.*, timetable.*, subject.faculty_id
        FROM class
        JOIN timetable ON timetable.class_id = class.id
        JOIN subject ON subject.id = class.subject_id
        """
    )

    # Group classes by faculty
    faculties = {}
    for row in curs.fetchall():
        try:
            faculties[row["faculty_id"]].append(row)
        except KeyError:
            faculties[row["faculty_id"]] = [row]

    # Store object, num of subjects, and num of classes of each lecturer
    # Remove lecturer from list if num of subjects or classes exceeds limit
    lecturers = {}

    # Assign classes for each faculty
    for faculty_id, classes in faculties.items():
        # Get list of lecturers of given faculty
        curs.execute(
            f"SELECT * FROM lecturer WHERE faculty_id = '{faculty_id}'")
        for row in curs.fetchall():
            lecturers[row["id"]] = {
                "object": row,
                "num_classes": 0,
                "num_subjects": 0
            }

        # Assign classes such that no time conflict occurs
        for row in classes:
            # Skip classes with missing time info
            if row["weekday"] is None or row["start_time"] is None or row["end_time"] is None:
                continue

            assigned = False
            while not assigned:
                # Randomize consideration
                choices = list(lecturers.keys())
                random.shuffle(choices)

                # Go through all lecturers in consideration
                for lecturer_id in choices:
                    # Try finding time conflict
                    curs.execute(
                        f"""
                        SELECT *
                        FROM class
                        JOIN timetable ON timetable.class_id = class.id
                        WHERE lecturer_id = '{lecturer_id}'
                        AND weekday = '{row["weekday"]}'
                        AND (
                            (start_time BETWEEN '{row["start_time"]}' AND '{row["end_time"]}')
                            OR (end_time BETWEEN '{row["start_time"]}' AND '{row["end_time"]}')
                        )
                        """
                    )

                    # If conflict found, try next lecturer
                    if curs.fetchall():
                        continue

                    # If no conflict found, assign class to lecturer
                    assigned = True
                    curs.execute(
                        f"UPDATE class SET lecturer_id = '{lecturer_id}' WHERE id = '{row['id']}'")
                    conn.commit()
                    lecturers[lecturer_id]["num_classes"] += 1

                    # Update specialization if this subject is new to lecturer
                    curs.execute(
                        f"SELECT * FROM specialization WHERE lecturer_id = '{lecturer_id}' AND subject_id = '{row['subject_id']}'")
                    if not curs.fetchall():
                        curs.execute(
                            f"INSERT INTO specialization (lecturer_id, subject_id) VALUES ('{lecturer_id}', '{row['subject_id']}')")
                        conn.commit()
                        lecturers[lecturer_id]["num_subjects"] += 1

                    # Remove lecturer from consideration if limit reached
                    if lecturers[lecturer_id]["num_classes"] >= max_classes or lecturers[lecturer_id]["num_subjects"] >= max_subjects:
                        del lecturers[lecturer_id]

                    break

                # If assignment succeeded, break out of loop
                if assigned:
                    break

                # Else, generate new lecturer and try again
                lecturer = generate_lecturer(faculty_id)
                lecturers[lecturer["id"]] = {
                    "object": lecturer,
                    "num_classes": 0,
                    "num_subjects": 0
                }
                insert_table("lecturer", [lecturer])

        # Reset consideration before assigning next faculty
        print(f"- Assigned classes for {faculty_id}")
        lecturers = {}


@ timeit
def insert_curriculums(max_subjects):
    # Generate one curriculum for each program
    print("Inserting curriculums...")

    # Get list of programs
    curs.execute("SELECT * FROM program")
    for program in curs.fetchall():
        program_id = program["id"]
        program_code = program["code"]
        faculty_id = program["faculty_id"]

        # Get list of subjects of given faculty
        curs.execute(
            f"SELECT id FROM subject WHERE faculty_id = '{faculty_id}'")
        subject_ids = [row["id"] for row in curs.fetchall()]

        # Sample subjects to form curriculum and use set to remove duplicates
        try:
            subject_ids = set(random.sample(subject_ids, max_subjects))
        except ValueError:
            subject_ids = set(subject_ids)

        # Add missing prerequisite subjects to curriculum, skip if None
        for subject_id in subject_ids.copy():
            curs.execute(
                f"SELECT prerequisite_id FROM subject WHERE id = '{subject_id}'")
            prerequisite_id = curs.fetchone()["prerequisite_id"]
            if prerequisite_id is not None:
                subject_ids.add(prerequisite_id)

        # Convert set back to sorted list
        subject_ids = sorted(list(subject_ids))

        # Insert subjects into curriculum
        for subject_id in subject_ids:
            curs.execute(
                f"INSERT INTO curriculum (program_id, subject_id) VALUES ('{program_id}', '{subject_id}')")
            conn.commit()

        print(f"- Inserted curriculum for {program_code}")


@ timeit
def insert_students(years, max_students):
    print("Inserting students...")

    # Cap number of students at 9999
    max_students = min(max_students, 9999)

    for year in years:
        for i in range(max_students):
            student_id = str(year) + str(i).zfill(4)
            student = generate_student(year, student_id)
            insert_table("student", [student])

        print(f"- Inserted students for {year}")


def generate_student(year, student_id):
    # Get list of programs
    curs.execute("SELECT id FROM program")
    program_ids = [row["id"] for row in curs.fetchall()]

    # Random birth year offset 2 years from given year
    # Give given year more weight to be chosen more often
    birth_year = random.choices([year - 2, year - 1, year], [5, 5, 90])[0]

    return {
        "id": student_id,
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "gender": fake.random_element(elements=("M", "F")),
        "birthday": fake.date_between(start_date=datetime.date(birth_year, 1, 1), end_date=datetime.date(birth_year, 12, 31)),
        "status": fake.random_element(elements=(True, False)),
        "join_date": fake.date_between(start_date=datetime.date(year, 9, 1), end_date=datetime.date(year, 10, 31)),
        "address": fake.address(),
        "email": fake.email(),
        "phone": fake.phone_number(),
        "cpa_total_score_product": 0,
        "cpa_total_study_credits": 0,
        "gpa_total_score_product": 0,
        "gpa_total_study_credits": 0,
        "credit_debt": 0,
        "tuition_debt": 0,
        "program_id": fake.random_element(elements=program_ids)
    }


@ timeit
def simple_enrollments(semester, max_subjects):
    print("Inserting enrollments...")
    year = semester // 10

    # Get list of students joined program
    curs.execute(
        f"SELECT student.*, faculty_id FROM student JOIN program ON student.program_id = program.id WHERE student.join_date <= '{year}-12-31'")
    students = curs.fetchall()

    # Get list of classes joined with subjects
    curs.execute(
        f"SELECT class.*, study_credits, final_weight, prerequisite_id, faculty_id FROM class JOIN subject ON class.subject_id = subject.id WHERE class.semester = '{semester}'")
    classes = curs.fetchall()

    for student in students:
        selected_classes = []
        selected_subjects = []

        # Get list of classes having same faculty as student
        filtered_classes = [
            row for row in classes if row["faculty_id"] == student["faculty_id"]]

        while len(selected_subjects) < max_subjects:
            # Get random class from filtered list
            selected_class = fake.random_element(elements=filtered_classes)

            # Check if class having prerequisite subject
            if selected_class["prerequisite_id"] is not None:
                if selected_class["prerequisite_id"] not in selected_subjects:
                    try:
                        prerequisite_class = next(
                            row for row in classes if row["subject_id"] == selected_class["prerequisite_id"] and row["semester"] == semester)
                        selected_classes.append(prerequisite_class)
                    except StopIteration:
                        continue

            # Check if class requiring company lab class
            if selected_class["require_lab"] == "Y":
                if not any(row["subject_id"] == selected_class["subject_id"] for row in selected_classes):
                    try:
                        lab_class = next(
                            row for row in classes if row["subject_id"] == selected_class["subject_id"] and row["type"] == "TN")
                    except StopIteration:
                        continue
                    selected_classes.append(lab_class)

            # If subject already selected, skip
            if selected_class["subject_id"] in selected_subjects:
                continue

            selected_classes.append(selected_class)
            selected_subjects.append(selected_class["subject_id"])

            # Init enrollment
            midterm_score = random.randint(0, 10)
            final_score = random.randint(0, 10)
            total_score = midterm_score * \
                (1 - selected_class["final_weight"]) + \
                final_score * selected_class["final_weight"]
            absent_count = random.randint(0, 8)

            # 0-3.9: 0.0, 4-4.9: 1.0, 5-5.4: 1.5, 5.5-6.4: 2.0, 6.5-6.9: 2.5, 7-7.9: 3.0, 8-8.4: 3.5, 8.5-10: 4.0
            mapping_score = 0
            if total_score <= 3.9:
                mapping_score = 0.0
            elif total_score <= 4.9:
                mapping_score = 1.0
            elif total_score <= 5.4:
                mapping_score = 1.5
            elif total_score <= 6.4:
                mapping_score = 2.0
            elif total_score <= 6.9:
                mapping_score = 2.5
            elif total_score <= 7.9:
                mapping_score = 3.0
            elif total_score <= 8.4:
                mapping_score = 3.5
            else:
                mapping_score = 4.0

            # Insert enrollment
            curs.execute(
                f"INSERT INTO enrollment (student_id, class_id, midterm_score, final_score, mapping_score, absent_count) VALUES ('{student['id']}', '{selected_class['id']}', {midterm_score}, {final_score}, {mapping_score}, {absent_count})")
            conn.commit()

            if mapping_score == 0:
                curs.execute(
                    f"UPDATE student SET credit_debt = credit_debt + {selected_class['study_credits']} WHERE id = '{student['id']}'")
                conn.commit()

            curs.execute(
                f"UPDATE student SET cpa_total_score_product = cpa_total_score_product + {mapping_score * float(selected_class['study_credits'])}, cpa_total_study_credits = cpa_total_study_credits + {selected_class['study_credits']} WHERE id = '{student['id']}'")
            conn.commit()

            # Remove class from filtered list
            filtered_classes.remove(selected_class)

    print(f"- Inserted enrollments for {semester}")


if __name__ == '__main__':
    main()
