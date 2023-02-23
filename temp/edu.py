#Lưu ý trước khi chạy chương trình này:
#1. Nhớ đổi lại password ở dòng '' tương ứng với password pgAdmin trong máy người dùng
#2. Đầu tiên, bạn phải tạo database "education" trong pgAdmin
#2. Sau đó, bạn xóa dấu "#" trước lệnh create_table(), Delete_data() và Insert_data() các dòng dưới cùng để tạo database. Khi chạy chương trình 
#   này nếu báo lỗi bạn hãy chạy lại, nguyên nhân vì trong database có check xem dữ liệu có trùng nhau không,
#   nếu trùng thì báo lỗi. Mà database chúng mình random nên có thể trùng nhau
#3. Sau khi chạy ổn định, bạn hãy điền "#" trước lệnh create_table(), Delete_data() và Insert_data() để không phải tạo lại database
#4. Các chức năng đều thực hiện khi "Nhập đúng", nhập sai sẽ bị out chương trình và báo lỗi

import psycopg2
import random

conn = psycopg2.connect(database="education", user="postgres",
                        password="cbh16020308", host="127.0.0.1", port="5432")

cur = conn.cursor()

global slsv
slsv = 250


def create_table():
    sql_query = '''create table users(
        Ho varchar(20) not NULL,
        Ten varchar(10) not NULL,
        username varchar(20) not NULL,
        password varchar(20) not NULL,
        vai_tro varchar(10) not NULL,
        primary key(username)
    );
    create table teacher(
        Ho_giang_vien varchar(20) not NULL,
        Ten_giang_vien varchar(10) not NULL,
        Ma_giang_vien varchar(10) not NULL,
        Nam_sinh int check(Nam_sinh >= 1920 and Nam_sinh <= 2000),
        So_dien_thoai varchar(11),
        Gmail varchar(30),
        Hoc_phan_giang_day varchar(50),
        user_name varchar(20) not NULL,
        primary key(Ma_giang_vien)
    );
    create table student(
        MSSV int check(MSSV >= 20200000 and MSSV < 20210000),
        Ho_sinh_vien varchar(20) not NULL,
        Ten_sinh_vien varchar(10) not NULL,
        GPA float check(GPA >= 0 and GPA <= 4),
        Ngay_sinh varchar(10),
        Gioi_tinh varchar(1),
        So_dien_thoai varchar(11),
        Gmail varchar(30),
        So_tien_hien_tai int check(So_tien_hien_tai >= 0),
        user_name varchar(20) not NULL,
        Hoc_phi_can_dong int,
        primary key(MSSV)
    );
    create table course(
        Ma_hoc_phan varchar(8) not NULL,
        Ten_hoc_phan varchar(40) not NULL,
        Trong_so float check(Trong_so > 0 and Trong_so < 1),
        So_tin_hoc_phan int check(So_tin_hoc_phan >= 0),
        So_tin_hoc_phi float check(So_tin_hoc_phi > 0),
        So_luong_dang_ky int,
        primary key(Ma_hoc_phan)
    );
    create table course_class(
        Ma_hoc_phan varchar(8) not NULL,
        Ten_hoc_phan varchar(40) not NULL,
        Ma_lop varchar(6) not NULL,
        Ho_giang_vien varchar(20) not NULL,
        Ten_giang_vien varchar(10) not NULL,
        Tiet_bat_dau int check(Tiet_bat_dau > 0 and Tiet_bat_dau < 12),
        Tiet_ket_thuc int check(Tiet_ket_thuc > 1 and Tiet_ket_thuc < 13),
        Thu int check(Thu > 1 and Thu < 7),
        So_luong_sinh_vien int check(So_luong_sinh_vien >= 0 and So_luong_sinh_vien < 251),
        Ma_giang_vien varchar(10),
        primary key(Ma_lop),
        foreign key(Ma_hoc_phan) references course(Ma_hoc_phan),
        check(Tiet_ket_thuc > Tiet_bat_dau)
    );
    create table Diem(
        MSSV int not NULL check(MSSV >= 20200000 and MSSV < 20210000),
        Ma_hoc_phan varchar(8) not NULL,
        Ten_hoc_phan varchar(40) not NULL,
        Diem_GK float check(Diem_GK >= 0 and Diem_GK <= 10),
        Diem_CK float check(Diem_CK >= 0 and Diem_CK <= 10),
        Diem_tong_ket_so float check(Diem_tong_ket_so >= 0 and Diem_tong_ket_so <= 10),
        Diem_tong_ket_thang_4 float check(Diem_tong_ket_thang_4 >= 0 and Diem_tong_ket_thang_4 <= 4),
        foreign key(Ma_hoc_phan) references course(Ma_hoc_phan),
        foreign key(MSSV) references student(MSSV)
    );
    create table student_class(
        Ma_hoc_phan varchar(8) not NULL,
        Ten_hoc_phan varchar(40) not NULL,
        Ma_lop varchar(6) not NULL,
        MSSV int check(MSSV >= 20200000 and MSSV < 20210000),
        Ho_sinh_vien varchar(20),
        Ten_sinh_vien varchar(10),
        Diem_GK float check(Diem_GK >= 0 and Diem_GK <= 10),
        Diem_CK float check(Diem_CK >= 0 and Diem_CK <= 10),
        foreign key(MSSV) references student(MSSV),
        foreign key(Ma_hoc_phan) references course(Ma_hoc_phan),
        foreign key(Ma_lop) references course_class(Ma_lop)
    );
    create table Dang_ky(
        Ma_hoc_phan varchar(8) not NULL,
        MSSV int not NULL check(MSSV >= 20200000 and MSSV < 20210000),
        Ma_lop varchar(6),
        foreign key(Ma_hoc_phan) references course(Ma_hoc_phan),
        foreign key(MSSV) references student(MSSV)
    );
    alter table teacher add constraint teacher_fk3 foreign	key(Hoc_phan_giang_day) references course(Ma_hoc_phan);
    '''
    cur.execute(sql_query)
    conn.commit()


def Delete_data():
    sql_query = "delete from users"
    cur.execute(sql_query)
    conn.commit()

    sql_query = "delete from teacher"
    cur.execute(sql_query)
    conn.commit()

    sql_query = "delete from student"
    cur.execute(sql_query)
    conn.commit()

    sql_query = "delete from course"
    cur.execute(sql_query)
    conn.commit()

    sql_query = "delete from course_class"
    cur.execute(sql_query)
    conn.commit()

    sql_query = "delete from Diem"
    cur.execute(sql_query)
    conn.commit()

    sql_query = "delete from Dang_ky"
    cur.execute(sql_query)
    conn.commit()

    sql_query = "delete from student_class"
    cur.execute(sql_query)
    conn.commit()


def Insert_data():

    Ho = ['Nguyen', 'Le', 'Hoang', 'Tran',
          'Dinh', 'Ha', 'Pham', 'Phan', 'Ho', 'Vu']
    Ten = ['Nam', 'Long', 'Hoang', 'Hieu',
           'Nguyet', 'Anh', 'Son', 'Duc', 'Yen', 'Quynh']
    vien = ['IT', 'MI', 'MIL', 'SSH', 'JP']
    Mon_hoc = ['CNTT', 'Giai tich', 'Quan su', 'Triet', 'Tieng nhat']
    sex = ['M', 'F']
    c = 0
    d = 0
    for i in range(250):
        ten = Ten[random.randint(0, 9)]
        ho = Ho[random.randint(0, 9)]
        username = ten+str(random.randint(1000, 9999))
        sql_query = "insert into users values(%s,%s,%s,'12345','Student')"
        sql_insert = (ho, ten, username)
        cur.execute(sql_query, sql_insert)
        conn.commit()

    for h in range(50):
        a = random.randint(0, 4)
        b = random.randint(1, 3)
        ten = Ten[random.randint(0, 9)]
        ho = Ho[random.randint(0, 9)]
        username = ten+str(random.randint(1000, 9999))
        sql_query = "insert into users values(%s,%s,%s,'12345','Teacher')"
        sql_insert = (ho, ten, username)
        cur.execute(sql_query, sql_insert)
        conn.commit()

    for j in range(5):
        for m in range(2):
            sql_query = "insert into course values(%s,%s,%s,%s,%s,0)"
            sql_insert = (vien[j]+'11'+str(m+1)+'0', Mon_hoc[j]+' '+str(m+1), float(
                random.randint(5, 9))/10, random.randint(2, 3), random.randint(2, 4))
            cur.execute(sql_query, sql_insert)
            conn.commit()

    sql_query = "SELECT * from users"
    cur.execute(sql_query)
    records = cur.fetchall()
    MSSV = 20200000

    for record in records:
        a = c % 5
        b = d % 2+1
        Ma_hoc_phan = vien[a]+'11'+str(b)+'0'
        Nam_sinh = random.randint(1920, 2000)
        sdt = str(random.randint(84960000000, 84969999999))
        gt = sex[random.randint(0, 1)]
        Mail = record[2]+'@gmail.com'
        MSSV = MSSV+1
        Tien = random.randint(1, 10)*1000000
        Ma_giang_vien = Ma_hoc_phan + \
            str(random.randint(10, 88)+random.randint(10, 100)//9)
        if record[4] == 'Teacher':
            sql_query = "insert into teacher values(%s,%s,%s,%s,%s,%s,%s,%s)"
            sql_insert = (record[0], record[1], Ma_giang_vien,
                          Nam_sinh, sdt, Mail, Ma_hoc_phan, record[2])
            cur.execute(sql_query, sql_insert)
            conn.commit()

        if record[4] == 'Student':
            sql_query = "insert into student values(%s,%s,%s,0,%s,%s,%s,%s,%s,%s)"
            sql_insert = (MSSV, record[0], record[1], str(
                random.randint(1998, 2003)), gt, sdt, Mail, Tien, record[2])
            cur.execute(sql_query, sql_insert)
            conn.commit()
        c = c+1
        d = d+1


def Register():
    global slsv
    while True:
        k = 0
        Ho = input("Nhap Ho: ")
        Ten = input("Nhap Ten: ")
        User_name = input("User name: ")
        Password = input("PassWord: ")
        Vai_tro = input("Vai tro: ")

        sql_query = "SELECT * from users"
        cur.execute(sql_query)
        records = cur.fetchall()
        for record in records:
            if record[2] == User_name:
                k = k+1
                print("Tai khoan da ton tai")
                break

        if Vai_tro not in ["Student", "Teacher", "Admin"]:
            k = k+1
            print("Khong ton tai vai tro nay!!")

        if k == 0:
            print("Register successful")
            sql_query = "INSERT INTO users VALUES(%s, %s, %s, %s, %s)"
            sql_insert = (Ho, Ten, User_name, Password, Vai_tro)
            cur.execute(sql_query, sql_insert)
            conn.commit()
            if Vai_tro == "Student":
                slsv = slsv+1
                mssv = slsv+20200000
                sql_query = "INSERT INTO student(mssv,ho_sinh_vien,ten_sinh_vien,gpa,so_tien_hien_tai,user_name) VALUES(%s, %s, %s, 0, 0,%s)"
                sql_insert = (mssv, Ho, Ten, User_name)
                cur.execute(sql_query, sql_insert)
                conn.commit()

            if Vai_tro == "Teacher":
                j = 0
                ma_hp = input("Nhap ma hoc phan ban giang day: ")
                while True:
                    ma_gv = input("Nhap ma giang vien: ")
                    sql_query = "SELECT ma_giang_vien FROM teacher"
                    cur.execute(sql_query)
                    records = cur.fetchall()
                    for record in records:
                        if record[0] == ma_gv:
                            j = 1

                    if j == 1:
                        print("Da ton tai ma giang vien nay!!")

                    else:
                        sql_query = "INSERT INTO teacher(ho_giang_vien,ten_giang_vien,ma_giang_vien,hoc_phan_giang_day,user_name) VALUES(%s, %s, %s, %s,%s)"
                        sql_insert = (Ho, Ten, ma_gv, ma_hp, User_name)
                        cur.execute(sql_query, sql_insert)
                        conn.commit()
                        break

        exit = int(input("Ban co muon tiep tuc Dang ky khong(Yes:1 , No:0): "))
        if exit == 0:
            print("Ban da thoat Dang ky")
            break


def Login():
    while True:
        k = 0
        global user_name
        user_name = input("User Name: ")
        pass_word = input("PassWord: ")
        sql_query = "SELECT * from users"
        cur.execute(sql_query)
        records = cur.fetchall()
        for record in records:
            if record[2] == user_name:
                if record[3] == pass_word:
                    k = k+1
                    print("Login successful")
                    if record[4] == "Student":
                        Student_view()
                    elif record[4] == "Teacher":
                        Teacher_view()
                    else:
                        Admin_view()
                else:
                    print("Mat khau sai!!")
                    break
        if k == 0:
            print("Khong ton tai tai khoan")

        exit = int(input("Ban co muon tiep tuc login khong(Yes:1 , No:0): "))
        if exit == 0:
            print("Ban da thoat dang nhap")
            break


def Print_student_info():
    global user_name
    sql_query = "SELECT * FROM student WHERE user_name = %s"
    sql_insert = (user_name,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    print("+----------------------------------------------------------------------------------------------------------------------------------------------------------+")
    print("|    {:<8}| {:<12} |  {:<15}|  {:<5}|  {:<10}| {:<10} |  {:<15}|         {:<13}| {:<16} | {:<12} |".format(
        "MSSV", "Ho_sinh_vien", "Ten_sinh_vien", "GPA", "Nam_sinh", "Gioi_tinh", "So_dien_thoai", "Mail", "So_tien_hien_tai", "user_name"))
    print("|------------+--------------+-----------------+-------+------------+------------+-----------------+----------------------+------------------+--------------|")

    print("|  {:<10}|      {:<8}|      {:<11}|  {:<5}|    {:<8}|     {:<7}|   {:<14}| {:<20} |     {:<13}| {:<12} |".format(
        record[0], record[1], record[2], record[3], record[4], record[5], record[6], record[7], record[8], record[9]))
    print("+----------------------------------------------------------------------------------------------------------------------------------------------------------+")


def Edit_student_info():
    global user_name
    global New_user_name
    Print_student_info()
    while True:
        print("\n---------------Edit Info Menu----------------")
        print("1. Sua thong tin ca nhan")
        print("2. Sua thong tin tai khoan")
        print("3. Thoat")
        print("---------------------------------------------")

        a = int(input("Nhap chuc nang ban muon chon: "))
        if a == 1:
            col = input("Nhap thong tin muon thay doi: ")
            info = input("Nhap thong tin chinh sua: ")
            sql_query = "UPDATE student SET " + col + " = %s WHERE user_name = %s"
            sql_insert = (info, user_name)
            cur.execute(sql_query, sql_insert)
            conn.commit()
            if col == "Ho_sinh_vien":
                sql_query = "UPDATE users SET ho = %s WHERE username = %s"
                sql_insert = (info, user_name)
                cur.execute(sql_query, sql_insert)
                conn.commit()
            if col == "Ten_sinh_vien":
                sql_query = "UPDATE users SET ten = %s WHERE username = %s"
                sql_insert = (info, user_name)
                cur.execute(sql_query, sql_insert)
                conn.commit()
            print("Thay doi thanh cong!!")
            Print_student_info()

        if a == 2:
            edit_user()
            sql_query = "UPDATE student SET user_name = %s WHERE user_name = %s"
            sql_insert = (New_user_name, user_name)
            cur.execute(sql_query, sql_insert)
            conn.commit()
            user_name = New_user_name

        if a == 3:
            print("Ban da thoat")
            break


def Class_info():
    ma_lop = input("Nhap ma lop: ")
    sql_query = "SELECT * from student_class where Ma_lop=%s"
    sql_insert = (ma_lop,)
    cur.execute(sql_query, sql_insert)
    records = cur.fetchall()

    print("------------Danh sach sinh vien------------\n")
    print("+-----------------------------------------+")
    print("|   {:<7}| {:<12} | {:<13} |".format(
        "MSSV", "Ho_sinh_vien", "Ten_sinh_vien"))

    for record in records:
        print("|----------+--------------+---------------|")
        print("| {:<8} |      {:<8}|     {:<10}|".format(
            record[3], record[4], record[5]))
    print("+-----------------------------------------+")

    sql_query = "SELECT Ten_giang_vien, Ho_giang_vien from teacher where Ma_giang_vien=(Select Ma_giang_vien from course_class where Ma_lop=%s)"
    sql_insert = (ma_lop,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    print("Ten giang vien: "+record[1]+' '+record[0])


def Hoc_phi(MSSV):
    sql_query = "SELECT So_tien_hien_tai from student where MSSV=%s"
    sql_insert = (MSSV,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    s = int(record[0])
    print("So tien trong tai khoan la: " + str(record[0]))

    sql_query = "SELECT Hoc_phi_can_dong from student where MSSV=%s"
    sql_insert = (MSSV,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    Hoc_phi = int(record[0])

    while True:
        k = 0
        print("\n---------------Money_menu------------------")
        print("1. Nap tien")
        print("2. Xem hoc phi")
        print("3. Nap hoc phi")
        print("4. Thoat")
        print("---------------------------------------------")

        a = int(input("Nhap chuc nang ban muon chon: "))
        if a == 1:
            Tien = int(input("Nhap so tien ban muon nap: "))
            s = s+Tien
            sql_query = "Update student SET So_tien_hien_tai=%s where user_name=%s"
            sql_insert = (s, user_name)
            cur.execute(sql_query, sql_insert)
            conn.commit()
            print("Nap tien thanh cong")

            sql_query = "SELECT So_tien_hien_tai from student where MSSV=%s"
            sql_insert = (MSSV,)
            cur.execute(sql_query, sql_insert)
            record = cur.fetchone()
            s = int(record[0])
            print("So tien trong tai khoan hien tai la: " + str(record[0]))

        if a == 2:
            sql_query = "Select Ma_lop,Ma_hoc_phan,Ten_hoc_phan from course_class where Ma_lop in (SELECT Ma_lop from student_class where MSSV=%s)"
            sql_insert = (MSSV,)
            cur.execute(sql_query, sql_insert)
            records = cur.fetchall()
            print("------------------------------------------Học phí--------------------------------------------\n")
            print(
                "+--------------------------------------------------------------------------------------------+")
            print("| {:<6} | {:<11} | {:<12} |  {:<14} | {:<15} | {:<15} |".format(
                "Ma_lop", "Ma_hoc_phan", "Ten_hoc_phan", "So_tin_hoc_phan", "So_tin_hoc_phi", "Hoc_phi_tung_hp"))

            for record in records:
                sql_query = "Select So_tin_hoc_phan,So_tin_hoc_phi from course where Ma_hoc_phan = %s "
                sql_insert = (record[1],)
                cur.execute(sql_query, sql_insert)
                row = cur.fetchone()
                Tin_hoc_phan = float(row[0])
                Tin_hoc_phi = float(row[1])
                Hoc_phi_hp = Tin_hoc_phi*680000
                print(
                    "|--------+-------------+--------------+------------------+-----------------+-----------------|")
                print("| {:<6} |   {:<10}|  {:<12}|        {:<10}|       {:<10}|    {:<11}  |".format(
                    record[0], record[1], record[2], Tin_hoc_phan, Tin_hoc_phi, Hoc_phi_hp))
            print(
                "+--------------------------------------------------------------------------------------------+")
            print("Hoc phi can dong la: ", Hoc_phi)
        if a == 3:
            while True:
                Nap = input("Nhap so tien ban muon dong hoc phi: ")
                if int(Nap) > 0:
                    break
                print("So tien nhap sai, vui long nhap lai !")

            s = s-int(Nap)
            Hoc_phi = Hoc_phi-int(Nap)
            print("Hoc phi can dong: ", Hoc_phi)
            print("So tien con lai trong tai khoan: ", s)
            sql_query = "Update student SET So_tien_hien_tai=%s, Hoc_phi_can_dong=%s where MSSV=%s"
            sql_insert = (s, Hoc_phi, MSSV)
            cur.execute(sql_query, sql_insert)
            conn.commit()

        if a == 4:
            print("Ban da thoat")
            break


def TKB(MSSV):
    sql_query = "Select Ma_lop,Ma_hoc_phan,Ten_hoc_phan,Thu,Tiet_bat_dau,Tiet_ket_thuc from course_class where Ma_lop in (SELECT Ma_lop from student_class where MSSV=%s)"
    sql_insert = (MSSV,)
    cur.execute(sql_query, sql_insert)
    records = cur.fetchall()
    print("-------------------------------------TKB--------------------------------------\n")
    print("+----------------------------------------------------------------------------+")
    print("| {:<6} | {:<11} | {:<12} |  {:<3}  | {:<12} | {:<13} |".format(
        "Ma_lop", "Ma_hoc_phan", "Ten_hoc_phan", "Thu", "Tiet_bat_dau", "Tiet_ket_thuc"))

    for record in records:
        print(
            "|--------+-------------+--------------+-------+--------------+---------------|")
        print("| {:<6} |   {:<10}|  {:<12}|   {:<4}|       {:<7}|       {:<8}|".format(
            record[0], record[1], record[2], record[3], record[4], record[5]))
    print("+----------------------------------------------------------------------------+")


def Add_Course_Register(course, MSSV):
    sql_query = "Select So_luong_dang_ky from course where ma_hoc_phan=%s"
    sql_insert = (course,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    a = int(record[0])
    a = a+1
    sql_query = "UPDATE course SET So_luong_dang_ky = %s Where Ma_hoc_phan=%s"
    sql_insert = (a, course)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    sql_query = "INSERT INTO Dang_ky VALUES (%s, %s, '0')"
    sql_insert = (course, MSSV)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Add Successful")


def Add_Class_Register(ma_lop, ma_hp, ten_hp, MSSV):
    global user_name
    sql_query = "SELECT * from student where user_name=%s"
    sql_insert = (user_name, )
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()

    sql_query = "INSERT INTO student_class VALUES (%s, %s, %s, %s, %s,%s,0,0)"
    sql_insert = (ma_hp, ten_hp, ma_lop, record[0], record[1], record[2])
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Successfully")
    sql_query = "SELECT So_luong_sinh_vien from course_class where Ma_lop=%s"
    sql_insert = (ma_lop,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    a = int(record[0])
    a = a+1
    sql_query = "UPDATE course_class SET So_luong_sinh_vien = %s Where Ma_lop=%s"
    sql_insert = (a, ma_lop)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    sql_query = "UPDATE Dang_ky SET Ma_lop=%s WHERE MSSV=%s and Ma_hoc_phan=%s"
    sql_insert = (ma_lop, MSSV, ma_hp)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Add Successful")


def Add_Score_Table(Ma_hp, Ten_hp, MSSV):
    sql_query = "INSERT INTO Diem VALUES (%s,%s,%s,0,0,0,0) "
    sql_insert = (MSSV, Ma_hp, Ten_hp)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Add Successful")


def Delete_course_register(course, MSSV):
    sql_query = "Select So_luong_dang_ky from course where ma_hoc_phan=%s"
    sql_insert = (course,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    a = int(record[0])
    a = a-1
    sql_query = "UPDATE course SET So_luong_dang_ky = %s Where Ma_hoc_phan=%s"
    sql_insert = (a, course)
    cur.execute(sql_query, sql_insert)
    conn.commit()

    sql_query = "DELETE FROM Dang_ky WHERE ma_hoc_phan=%s and MSSV=%s"
    sql_insert = (course, MSSV)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Delete Successful")


def Delete_class_register(ma_lop, MSSV):
    sql_query = "SELECT So_luong_sinh_vien from course_class where Ma_lop=%s"
    sql_insert = (ma_lop,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    a = int(record[0])
    a = a-1
    sql_query = "UPDATE course_class SET So_luong_sinh_vien = %s Where Ma_lop=%s"
    sql_insert = (a, ma_lop)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    sql_query = "UPDATE Dang_ky SET Ma_lop='0' where ma_lop=%s and MSSV=%s"
    sql_insert = (ma_lop, MSSV)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Delete Successful")


def Cap_nhat_hoc_phi(MSSV):
    Hoc_phi = 0
    sql_query = "Select So_tin_hoc_phi from course where Ma_hoc_phan in (SELECT Ma_hoc_phan from course_class where Ma_lop in (SELECT Ma_lop from student_class where MSSV=%s))"
    sql_insert = (MSSV,)
    cur.execute(sql_query, sql_insert)
    records = cur.fetchall()
    for record in records:
        Hoc_phi = Hoc_phi+680000*int(record[0])
    sql_query = "Update student SET Hoc_phi_can_dong=%s where MSSV=%s"
    sql_insert = (Hoc_phi, MSSV)
    cur.execute(sql_query, sql_insert)
    conn.commit()


def print_course_class_register(MSSV):
    Tong_tin = 0
    sql_query = "SELECT * FROM course where Ma_hoc_phan in (Select Ma_hoc_phan from Dang_ky where MSSV=%s)"
    sql_insert = (MSSV,)
    cur.execute(sql_query, sql_insert)
    records = cur.fetchall()

    print("----------------------------Dang ky hoc phan-------------------------------")
    print("\n+-------------------------------------------------------------------------+")
    print("|   {:<14}|   {:<17}|  {:<18}|   {:<10}|".format(
        "Ma_hoc_phan", "Ten_hoc_phan", "So_tin_hoc_phan", "Ma_lop"))

    for record in records:
        sql_query = "SELECT Ma_lop from Dang_ky where Ma_hoc_phan=%s and MSSV=%s"
        sql_insert = (record[0], MSSV)
        cur.execute(sql_query, sql_insert)
        row = cur.fetchone()
        print("|-----------------+--------------------+--------------------+-------------|")
        print("|     {:<12}|     {:<15}|         {:<11}|   {:<10}|".format(
            record[0], record[1], record[3], row[0]))
        Tong_tin = Tong_tin+int(record[3])
    print("+-------------------------------------------------------------------------+")

    return Tong_tin


def Dang_ky(MSSV):
    while True:
        print("\n---------------Student Menu------------------")
        print("1. Xem tkb cac hoc phan")
        print("2. Dang ky hoc phan")
        print("3. Dang ky lop")
        print("4. Huy dang ky lop")
        print("5. Huy dang ky hoc phan")
        print("6. Thoat")
        print("---------------------------------------------")

        a = int(input("Nhap chuc nang ban muon chon: "))

        if a == 1:
            sql_query = "SELECT * FROM course_class"
            cur.execute(sql_query)
            records = cur.fetchall()

            print("---------------------------------------------TKB Hoc phan--------------------------------------------------\n")
            print("+---------------------------------------------------------------------------------------------------------+")

            print("| {:<11} | {:<13} | {:<6} |  {:<15}|  {:<15}|  {:<5}|  {:<20}|".format(
                "Ma_hoc_phan", "Ten_hoc_phan", "Ma_lop",  "Tiet_bat_dau", "Tiet_ket_thuc", "Thu", "So_luong_sinh_vien"))

            for record in records:
                print(
                    "|-------------+---------------+--------+-----------------+-----------------+-------+----------------------|")
                print("|  {:<11}|  {:<13}| {:<6} |        {:<8} |        {:<8} |   {:<4}|           {:<11}|".format(
                    record[0], record[1], record[2], record[5], record[6], record[7], record[8]))
            print("+---------------------------------------------------------------------------------------------------------+")

        if a == 2:
            while True:
                Tong_tin = print_course_class_register(MSSV)
                print("Tong so tin da dang ky: ", Tong_tin)
                k = 0
                HP = input("Nhap ma hoc phan ban muon dang ky: ")
                sql_query = "Select Ma_hoc_phan from course"
                cur.execute(sql_query)
                records = cur.fetchall()
                for record in records:
                    if record[0] == HP:
                        k = 1
                if k == 0:
                    print("Ma hoc phan khong ton tai")

                if k == 1:
                    sql_query = "Select So_tin_hoc_phan from course where ma_hoc_phan =%s"
                    sql_insert = (HP,)
                    cur.execute(sql_query, sql_insert)
                    record = cur.fetchone()
                    So_tin = int(record[0])
                    if (Tong_tin + So_tin) > 24:
                        print("Vuot qua gioi han so tin dang ky!!")
                    else:
                        sql_query = "Select Ma_hoc_phan from Dang_ky where MSSV=%s"
                        sql_insert=(MSSV,)
                        cur.execute(sql_query,sql_insert)
                        rows = cur.fetchall()
                        for row in rows:
                            if row[0] == HP:
                                k = 2
                        if k == 2:
                            print("Ban da dang ky ma hoc phan nay roi!!")
                        else:
                            print("Ban da dang ky hoc phan thanh cong.")
                            Add_Course_Register(HP, MSSV)
                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 3:
            while True:
                Tong_tin = print_course_class_register(MSSV)
                sql_query = "Select sum(So_tin_hoc_phan) from course where Ma_hoc_phan in(Select Ma_hoc_phan from Dang_ky where MSSV=%s and Ma_lop='0')"
                sql_insert = (MSSV,)
                cur.execute(sql_query, sql_insert)
                record = cur.fetchone()
                if record[0] is None:
                    So_tin_chua_dk=0
                else:
                    So_tin_chua_dk = int(record[0])
                So_tin_da_dk_lop = Tong_tin-So_tin_chua_dk
                print("So tin da dang ky lop: ", So_tin_da_dk_lop)
                k = 0
                ma_lop = input("Nhap ma lop ban muon dang ky: ")
                sql_query = "Select * from course_class"
                cur.execute(sql_query)
                records = cur.fetchall()
                for record in records:
                    if record[2] == ma_lop:
                        k = 1

                if k == 0:
                    print("Ma lop khong ton tai")

                if k == 1:
                    j = 0
                    sql_query = "Select * from course_class where Ma_lop =%s"
                    sql_insert = (ma_lop,)
                    cur.execute(sql_query, sql_insert)
                    record = cur.fetchone()
                    Ma_hp = record[0]
                    Ten_hp = record[1]
                    sql_query = "Select * from Dang_ky where MSSV=%s"
                    sql_insert = (MSSV,)
                    cur.execute(sql_query, sql_insert)
                    rows = cur.fetchall()
                    for row in rows:
                        if row[0] == Ma_hp:
                            j = 1
                            if row[2] != '0':
                                j = 2
                                break
                    if j == 0:
                        print("Ban chua dang ky ma hoc phan cua lop nay")
                    elif j == 2:
                        print("Ban da dang ky lop cua hoc phan nay roi")
                    else:
                        if int(record[8]) >= 50:
                            print("Lop da day!!!")
                        else:
                            print("Ban da dang ky lop thanh cong.")
                            Add_Class_Register(ma_lop, Ma_hp, Ten_hp, MSSV)
                            Add_Score_Table(Ma_hp, Ten_hp, MSSV)
                            Cap_nhat_hoc_phi(MSSV)
                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 4:
            while True:
                Tong_tin = print_course_class_register(MSSV)
                sql_query = "Select sum(So_tin_hoc_phan) from course where Ma_hoc_phan in(Select Ma_hoc_phan from Dang_ky where MSSV=%s and Ma_lop='0')"
                sql_insert = (MSSV,)
                cur.execute(sql_query, sql_insert)
                record = cur.fetchone()  
                if record[0] is None:
                    So_tin_chua_dk=0
                else:
                    So_tin_chua_dk = int(record[0])
                So_tin_da_dk_lop = Tong_tin-So_tin_chua_dk
                print("So tin da dang ky lop: ", So_tin_da_dk_lop)
                k = 0
                ma_lop = input("Nhap ma lop ban muon huy: ")
                sql_query = "SELECT ma_lop from Dang_ky where MSSV = %s"
                sql_insert = (MSSV,)
                cur.execute(sql_query, sql_insert)
                records = cur.fetchall()
                for record in records:
                    if record[0] == ma_lop:
                        k = 1

                if k == 0:
                    print("Ban khong dang ky lop nay")

                if k == 1:
                    sql_query = "DELETE from student_class where Ma_lop =%s and MSSV=%s"
                    sql_insert = (ma_lop, MSSV)
                    cur.execute(sql_query, sql_insert)
                    conn.commit()
                    Delete_class_register(ma_lop, MSSV)
                    Cap_nhat_hoc_phi(MSSV)

                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 5:
            while True:
                Tong_tin = print_course_class_register(MSSV)
                print("Tong so tin da dang ky: ", Tong_tin)
                k = 0
                ma_hp = input("Nhap ma hoc phan ban muon huy: ")
                sql_query = "SELECT ma_hoc_phan from course "
                cur.execute(sql_query)
                records = cur.fetchall()
                for record in records:
                    if record[0] == ma_hp:
                        k = 1

                if k == 0:
                    print("Khong ton tai ma hoc phan nay")

                if k == 1:
                    Delete_course_register(ma_hp, MSSV)

                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 6:
            print("Ban da thoat")
            break


def Student_view():
    global user_name
    sql_query = "SELECT MSSV from student where user_name=%s"
    sql_insert = (user_name,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    MSSV = int(record[0])
    while True:

        print("\n---------------Student Menu------------------")
        print("1. Sua thong tin ca nhan")
        print("2. Dang ky lop")
        print("3. Xem thong tin lop")
        print("4. Thong tin hoc phi")
        print("5. Thoi khoa bieu")
        print("6. Thoat")
        print("---------------------------------------------")

        a = int(input("Nhap chuc nang ban muon chon: "))
        if a == 1:
            Edit_student_info()

        if a == 2:
            Dang_ky(MSSV)

        if a == 3:
            Class_info()

        if a == 4:
            Hoc_phi(MSSV)

        if a == 5:
            TKB(MSSV)

        if a == 6:
            print("Ban da thoat")
            break


def update_gpa(MSSV):
    Tong = 0
    So_tin = 0
    sql_query = "Select Ma_hoc_phan, diem_tong_ket_thang_4 from Diem where MSSV=%s"
    sql_insert = (MSSV,)
    cur.execute(sql_query, sql_insert)
    records = cur.fetchall()
    for record in records:
        sql_query = "Select So_tin_hoc_phan from course where Ma_hoc_phan=%s"
        sql_insert = (record[0],)
        cur.execute(sql_query, sql_insert)
        row = cur.fetchone()
        Tong = Tong + float(record[1])*float(row[0])
        So_tin = So_tin+int(row[0])
    gpa = Tong/float(So_tin)

    sql_query = "UPDATE student SET gpa=%s where MSSV=%s"
    sql_insert = (gpa, MSSV)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Update gpa successful")


def update_tong_ket(MSSV, ma_lop):
    sql_query = "SELECT diem_gk, diem_ck from Diem where MSSV=%s and Ma_hoc_phan=(SELECT Ma_hoc_phan FROM course_class where ma_lop=%s)"
    sql_insert = (MSSV, ma_lop)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    diem_gk = float(record[0])
    diem_ck = float(record[1])
    sql_query = "SELECT Trong_so from course where Ma_hoc_phan=(SELECT Ma_hoc_phan FROM course_class where ma_lop=%s)"
    sql_insert = (ma_lop,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    Trong_so = float(record[0])
    Tong_ket = diem_gk*(1-Trong_so) + diem_ck*Trong_so
    sql_query = "UPDATE Diem SET diem_tong_ket_so=%s where MSSV=%s and Ma_hoc_phan=(SELECT Ma_hoc_phan FROM course_class where ma_lop=%s)"
    sql_insert = (Tong_ket, MSSV, ma_lop)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Update TKS Successful")
    if Tong_ket <= 10 and Tong_ket >= 8.5:
        Tong_ket_4 = 4
    elif Tong_ket >= 8:
        Tong_ket_4 = 3.5
    elif Tong_ket >= 7:
        Tong_ket_4 = 3
    elif Tong_ket >= 6.5:
        Tong_ket_4 = 2.5
    elif Tong_ket >= 5.5:
        Tong_ket_4 = 2
    elif Tong_ket >= 5:
        Tong_ket_4 = 1.5
    elif Tong_ket >= 4:
        Tong_ket_4 = 1
    else:
        Tong_ket_4 = 0

    sql_query = "UPDATE Diem SET diem_tong_ket_thang_4=%s where MSSV=%s and Ma_hoc_phan=(SELECT Ma_hoc_phan FROM course_class where ma_lop=%s)"
    sql_insert = (Tong_ket_4, MSSV, ma_lop)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Update TK4 Successful")
    update_gpa(MSSV)


def Update_Diem(s, Diem, MSSV, ma_lop):
    sql_query = "UPDATE Diem SET " + s + " = %s where MSSV = %s and ma_hoc_phan=(SELECT ma_hoc_phan from course_class where ma_lop=%s)"
    sql_insert = (Diem, MSSV,ma_lop)
    cur.execute(sql_query, sql_insert)
    conn.commit()
    print("Update Success")
    update_tong_ket(MSSV, ma_lop)


def Teacher_view_menu(ma_lop):
    while True:
        k = 0
        print("\n---------------Teacher Menu------------------")
        print("1. Xoa sinh vien")
        print("2. Nhap diem")
        print("3. Loc diem")
        print("4. Thoat")
        print("---------------------------------------------")

        a = int(input("Nhap chuc nang ban muon chon: "))

        if a == 1:
            MSSV = int(input("Nhap MSSV ban muon xoa: "))

            sql_query = "SELECT MSSV FROM student_class WHERE ma_lop = %s"
            sql_insert = (ma_lop,)
            cur.execute(sql_query, sql_insert)
            records = cur.fetchall()

            for record in records:
                if record[0] == MSSV:
                    k = 1

            if k == 1:
                sql_query = "DELETE FROM student_class WHERE MSSV = %s and ma_lop = %s"
                sql_insert = (MSSV, ma_lop)
                cur.execute(sql_query, sql_insert)
                conn.commit()
                update_gpa(MSSV)

            if k == 0:
                print("Khong ton tai MSSV ban da nhap")

        if a == 2:
            Chon_nhap = int(input("Nhap diem (GK: 1, CK: 0): "))
            while True:
                MSSV = int(input("Nhap MSSV ban muon nhap diem: "))

                sql_query = "SELECT MSSV FROM student_class where Ma_lop = %s"
                sql_insert = (ma_lop, )
                cur.execute(sql_query, sql_insert)
                records = cur.fetchall()

                for record in records:
                    if record[0] == MSSV:
                        k = 1

                if k == 1:                  

                    if Chon_nhap == 1:
                        Diem = float(input("Nhap diem GK: "))

                        sql_query = "UPDATE student_class SET Diem_GK = %s WHERE MSSV = %s and ma_lop =%s"
                        sql_insert = (Diem, MSSV, ma_lop)
                        cur.execute(sql_query, sql_insert)
                        conn.commit()
                        Update_Diem('diem_gk', Diem, MSSV, ma_lop)

                    if Chon_nhap == 0:
                        Diem = float(input("Nhap diem CK: "))

                        sql_query = "UPDATE student_class SET Diem_CK = %s WHERE MSSV = %s and ma_lop=%s"
                        sql_insert = (Diem, MSSV,ma_lop)
                        cur.execute(sql_query, sql_insert)
                        conn.commit()
                        Update_Diem('diem_ck', Diem, MSSV, ma_lop)

                if k == 0:
                    print("Khong ton tai MSSV ban da nhap")
                
                exit = int(
                    input("Ban co muon tiep tuc nhap diem khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 3:
            type = int(input("Nhap loai diem muon loc(GK:1,CK:0): "))
            max = float(input("Nhap gioi han tren: "))
            min = float(input("Nhap gioi han duoi: "))

            if max > 10 or max < 0 or min > 10 or min < 0 or max < min:
                print("Nhap gioi han sai")
            else:
                if type == 1:
                    sql_query = "SELECT * FROM student_class where Diem_GK>=%s and Diem_GK<=%s and Ma_lop=%s"
                    sql_insert = (min, max, ma_lop)
                    cur.execute(sql_query, sql_insert)
                    records = cur.fetchall()

                    print(
                        "---------------------Danh sach sinh vien-----------------------\n")
                    print(
                        "+-------------------------------------------------------------+")

                    print("|   {:<7}| {:<12} | {:<13} | {:<7} | {:<7} |".format(
                        "MSSV", "Ho_sinh_vien", "Ten_sinh_vien", "Diem_gk", "Diem_ck"))

                    for record in records:
                        print(
                            "|----------+--------------+---------------+---------+---------|")
                        print("| {:<8} |      {:<8}|     {:<10}|   {:<6}|   {:<6}|".format(
                            record[3], record[4], record[5], record[6], record[7]))
                    print(
                        "+-------------------------------------------------------------+")
                if type == 0:
                    sql_query = "SELECT * FROM student_class where Diem_CK>=%s and Diem_CK<=%s and Ma_lop=%s"
                    sql_insert = (min, max, ma_lop)
                    cur.execute(sql_query, sql_insert)
                    records = cur.fetchall()

                    print(
                        "---------------------Danh sach sinh vien-----------------------\n")
                    print(
                        "+-------------------------------------------------------------+")

                    print("|   {:<7}| {:<12} | {:<13} | {:<7} | {:<7} |".format(
                        "MSSV", "Ho_sinh_vien", "Ten_sinh_vien", "Diem_gk", "Diem_ck"))

                    for record in records:
                        print(
                            "|----------+--------------+---------------+---------+---------|")
                        print("| {:<8} |      {:<8}|     {:<10}|   {:<6}|   {:<6}|".format(
                            record[3], record[4], record[5], record[6], record[7]))
                    print(
                        "+-------------------------------------------------------------+")    
                    

        if a == 4:
            print("Ban da thoat chuc nang")
            break


def Teacher_view():
    while True:
        k = 0
        global user_name
        global New_user_name
        print("\n---------------Teacher Menu------------------")
        print("1. Quan li lop hoc")
        print("2. Xem lich day")
        print("3. Thay doi thong tin ca nhan")
        print("4. Thay doi tai khoan")
        print("5. Thoat")
        print("---------------------------------------------")
        a = int(input("Nhap chuc chuc nang ban muon chon: "))
        if a == 1:
            ma_lop = input("Nhap ma lop dang day muon xem sinh vien: ")
            sql_query = "SELECT Ma_lop FROM course_class"
            cur.execute(sql_query)
            records = cur.fetchall()

            for record in records:
                if record[0] == ma_lop:
                    k = 1

            if k == 1:
                print("----------------------Danh sach lop " +
                      ma_lop+"-----------------------------\n")

                print(
                    "+---------------------------------------------------------------------+")
                print("|    {:<8}| {:<12} |  {:<15}|  {:<9}|  {:<9}|".format(
                    "MSSV", "Ho_sinh_vien", "Ten_sinh_vien", "Diem_GK", "Diem_CK"))

                sql_query = "SELECT MSSV, Ho_sinh_vien, Ten_sinh_vien, Diem_GK, Diem_CK  FROM student_class where Ma_lop=%s"
                sql_insert = (ma_lop,)
                cur.execute(sql_query, sql_insert)
                records = cur.fetchall()

                for record in records:
                    print(
                        "|------------+--------------+-----------------+-----------+-----------|")
                    print("|  {:<10}|      {:<8}|      {:<11}|    {:<7}|    {:<7}|".format(
                        record[0], record[1], record[2], record[3], record[4]))

                print(
                    "+---------------------------------------------------------------------+")
                Teacher_view_menu(ma_lop)

            if k == 0:
                print("Ban khong day lop nay")

        if a == 2:
            sql_query = "SELECT Ma_lop, Thu, Tiet_bat_dau,Tiet_ket_thuc FROM course_class where Ma_giang_vien=(SELECT Ma_giang_vien from teacher where user_name=%s)"
            sql_insert = (user_name,)
            cur.execute(sql_query, sql_insert)
            print("\n-------------------Lich day--------------------\n")
            print("+---------------------------------------------+")
            print("| {:<6} | {:<3} | {:<12} | {:<13} |".format(
                "Ma_lop", "Thu", "Tiet_bat_dau", "Tiet_ket_thuc"))

            records = cur.fetchall()
            for record in records:
                print("+--------+-----+--------------+---------------+")
                print("| {:<6} |  {:<3}|      {:<8}|       {:<8}|".format(
                    record[0], record[1], record[2], record[3]))
            print("+---------------------------------------------+")

        if a == 3:
            print("+-------------------------------------------------------------------------------------------------------------------------+")
            print("| {:<13} | {:<14} | {:<13} | {:<8} | {:<13} |         {:<13}|  {:<20}|".format(
                "Ho_giang_vien", "Ten_giang_vien", "Ma_giang_vien", "Nam_sinh", "So_dien_thoai", "Mail", "Hoc_phan_giang_day"))

            sql_query = "SELECT * FROM teacher where user_name = %s"
            sql_insert = (user_name,)
            cur.execute(sql_query, sql_insert)
            record = cur.fetchone()

            print("+---------------+----------------+---------------+----------+---------------+----------------------+----------------------+")
            print("|     {:<10}|      {:<10}|   {:<12}|   {:<7}|  {:<13}| {:<20} |       {:<15}|".format(
                record[0], record[1], record[2], record[3], record[4], record[5], record[6]))
            print("+-------------------------------------------------------------------------------------------------------------------------+")
            col = input("Nhap thong tin muon thay doi: ")
            info = input("Nhap thong tin chinh sua: ")
            sql_query = "UPDATE teacher SET " + col + " = %s WHERE user_name = %s"
            sql_insert = (info, user_name)
            cur.execute(sql_query, sql_insert)
            conn.commit()
            if col == "Ho_giang_vien":
                sql_query = "UPDATE users SET ho = %s WHERE username = %s"
                sql_insert = (info, user_name)
                cur.execute(sql_query, sql_insert)
                conn.commit()
            if col == "Ten_giang_vien":
                sql_query = "UPDATE users SET ten = %s WHERE username = %s"
                sql_insert = (info, user_name)
                cur.execute(sql_query, sql_insert)
                conn.commit()
            print("Thay doi thanh cong!!\n")

            print("+-------------------------------------------------------------------------------------------------------------------------+")
            print("| {:<13} | {:<14} | {:<13} | {:<8} | {:<13} |         {:<13}|  {:<20}|".format(
                "Ho_giang_vien", "Ten_giang_vien", "Ma_giang_vien", "Nam_sinh", "So_dien_thoai", "Mail", "Hoc_phan_giang_day"))

            sql_query = "SELECT * FROM teacher where user_name = %s"
            sql_insert = (user_name,)
            cur.execute(sql_query, sql_insert)
            record = cur.fetchone()

            print("+---------------+----------------+---------------+----------+---------------+----------------------+----------------------+")
            print("|     {:<10}|      {:<10}|   {:<12}|   {:<7}|  {:<13}| {:<20} |       {:<15}|".format(
                record[0], record[1], record[2], record[3], record[4], record[5], record[6]))
            print("+-------------------------------------------------------------------------------------------------------------------------+")

            if col == "Hoc_phan_giang_day":
                sql_query = "DELETE from course_class WHERE Ma_hoc_phan = %s"
                sql_insert = (record[6],)
                cur.execute(sql_query, sql_insert)
                conn.commit()
        if a == 4:
            edit_user()
            sql_query = "UPDATE teacher SET user_name = %s WHERE user_name = %s"
            sql_insert = (New_user_name, user_name)
            cur.execute(sql_query, sql_insert)
            conn.commit()
            user_name = New_user_name

        if a == 5:
            print("Ban da thoat")
            break


def edit_user():
    global user_name
    global New_user_name
    New_user_name = input("New User name: ")
    New_Password = input("New PassWord: ")

    sql_query = "UPDATE users SET username = %s, password = %s WHERE username = %s"
    sql_insert = (New_user_name, New_Password, user_name)
    cur.execute(sql_query, sql_insert)
    conn.commit()

    print("Ban da thay doi thong tin thanh cong")


def course_menu():
    sql_query = "SELECT * FROM course"
    cur.execute(sql_query)
    records = cur.fetchall()

    print("------------------------------------------------Danh sach hoc phan----------------------------------------------------")
    print("\n+--------------------------------------------------------------------------------------------------------------------+")
    print("|   {:<14}|     {:<17}|  {:<10}|  {:<18}|   {:<17}|  {:<18}|".format(
        "Ma_hoc_phan", "Ten_hoc_phan", "Trong_so", "So_tin_hoc_phan", "So_tin_hoc_phi", "So_luong_dang_ky"))

    for record in records:
        print("|-----------------+----------------------+------------+--------------------+--------------------+--------------------|")
        print("|     {:<12}|       {:<15}|    {:<8}|         {:<11}|         {:<11}|         {:<11}|".format(
            record[0], record[1], record[2], record[3], record[4], record[5]))
    print("+--------------------------------------------------------------------------------------------------------------------+")
    while True:
        print("\n---------------Menu---------------")
        print("1. Them hoc phan")
        print("2. Xoa hoc phan")
        print("3. Thay doi thong tin hoc phan")
        print("4. Thoat")
        print("----------------------------------")

        a = int(input("Hay chon chuc nang: "))

        if a == 1:
            while True:
                k = 0
                Ma_HP = input("Nhap ma hoc phan: ")
                Ten_HP = input("Nhap ten hoc phan: ")
                Trongso = input("Trong so hoc phan: ")
                So_tin_hoc_phan = input("Nhap so tin hoc phan: ")
                So_tin_hoc_phi = input("Nhap so tin hoc phi: ")

                sql_query = "SELECT Ma_hoc_phan FROM course"
                cur.execute(sql_query)
                records = cur.fetchall()

                for record in records:
                    if record[0] == Ma_HP:
                        print("Ma hoc phan da ton tai")
                        k = 1

                if k == 0:
                    sql_query = "INSERT INTO course VALUES (%s, %s, %s, %s, %s,0)"
                    sql_insert = (Ma_HP, Ten_HP, Trongso,
                                  So_tin_hoc_phan, So_tin_hoc_phi)
                    cur.execute(sql_query, sql_insert)
                    conn.commit()

                    print("Ban da them hoc phan thanh cong")

                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 2:
            while True:
                k = 0
                ma_HP = input("Nhap ma hoc phan muon xoa: ")
                sql_query = "SELECT Ma_hoc_phan FROM course"
                cur.execute(sql_query)
                records = cur.fetchall()

                for record in records:
                    if record[0] == ma_HP:
                        k = 1

                if k == 1:
                    sql_query = "DELETE FROM course WHERE Ma_hoc_phan = %s"
                    sql_insert = (ma_HP,)
                    cur.execute(sql_query, sql_insert)
                    conn.commit()

                if k == 0:
                    print("Khong ton tai ma hoc phan")

                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 3:
            while True:
                k = 0
                ma_HP = input("Nhap ma hoc phan muon thay doi: ")
                sql_query = "SELECT Ma_hoc_phan FROM course"
                cur.execute(sql_query)
                records = cur.fetchall()

                for record in records:
                    if record[0] == ma_HP:
                        k = 1

                if k == 1:
                    col = input("Nhap thong tin muon thay doi: ")
                    info = input("Nhap thong tin chinh sua: ")
                    sql_query = "UPDATE course SET " + col + " = %s WHERE Ma_hoc_phan = %s"
                    sql_insert = (info, ma_HP)
                    cur.execute(sql_query, sql_insert)
                    conn.commit()
                    print("Ban da thay doi thanh cong")

                if k == 0:
                    print("Khong ton tai ma hoc phan")

                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 4:
            print("Ban da thoat")
            break


def add_course_class():

    list_gv = []
    print("Nhap thong tin lop hoc phan can them !")
    ma_hp = input("Nhap Ma_hoc_phan: ")
    sql_query = "SELECT Ho_giang_vien, Ten_giang_vien,Ma_giang_vien from teacher where hoc_phan_giang_day=%s"
    sql_insert = (ma_hp,)
    cur.execute(sql_query, sql_insert)
    records = cur.fetchall()
    print("--------------Danh sach giang vien giang day-------------\n")
    print("+-------------------------------------------------------+")
    print("|  {:<13}  |  {:<14}  |  {:<15} |".format(
        "Ho_giang_vien", "Ten_giang_vien", "Ma_giang_vien"))

    for record in records:
        list_gv.append(record[2])
        print("|-----------------+------------------+------------------|")
        print("|      {:<11}|       {:<11}|    {:<14}|".format(
            record[0], record[1], record[2]))
    print("+-------------------------------------------------------+")

    sql_query = "SELECT count(Ma_lop) from course_class where ma_hoc_phan =%s"
    sql_insert = (ma_hp,)
    cur.execute(sql_query, sql_insert)
    count = cur.fetchone()
    so_lop = int(count[0])
    sql_query = "SELECT Ten_hoc_phan, So_luong_dang_ky from course where ma_hoc_phan =%s"
    sql_insert = (ma_hp,)
    cur.execute(sql_query, sql_insert)
    record = cur.fetchone()
    Ten_hp = record[0]
    SLDK = int(record[1])
    So_lop_can_tao = SLDK//50 + 2 - so_lop
    print("So_lop_can_tao= ", So_lop_can_tao)
    if So_lop_can_tao > 0:
        while True:
            k = 0
            ma_lop = input("Nhap Ma_lop: ")
            ho = input("Nhap ho giang vien: ")
            ten = input("Nhap ten giang vien: ")
            ma_gv = input("Nhap ma giang vien: ")
            tiet_bat_dau = input("Nhap tiet bat dau: ")
            tiet_ket_thuc = input("Nhap tiet ket thuc: ")
            thu = input("Nhap thu: ")
            if int(tiet_bat_dau) >= int(tiet_ket_thuc):
                k = 1
            if int(tiet_bat_dau) < 1 and int(tiet_bat_dau) > 11:
                k = 1
            if int(tiet_ket_thuc) < 2 and int(tiet_ket_thuc) > 12:
                k = 1
            if int(thu) < 2 or int(thu) > 6:
                k = 1
            if ma_gv not in list_gv:
                k = 1
            if int(ma_lop) < 100000 or int(ma_lop) > 200000:
                k = 1
            if k == 1:
                print("Thong tin nhap bi loi!!! Vui long nhap lai")
            else:
                break
        sql_query = "INSERT INTO course_class VALUES (%s,%s,%s,%s,%s,%s,%s,%s,0, %s)"
        sql_insert = (ma_hp, Ten_hp, ma_lop, ho, ten,
                      tiet_bat_dau, tiet_ket_thuc, thu, ma_gv)
        cur.execute(sql_query, sql_insert)
        conn.commit()
        print("Add course_class successful")
    else:
        print("Khong can tao them lop nua")


def course_class_menu():
    while True:
        print("\n---------------Menu--------------------")
        print("1. Hien thi cac lop hoc phan")
        print("2. Them lop hoc phan")
        print("3. Cap nhat gio hoc")
        print("4. Thoat")
        print("-----------------------------------------")

        a = int(input("Hay chon chuc nang: "))
        if a == 1:
            while True:
                k = 0
                ma_HP = input("Nhap ma hoc phan muon hien thi cac lop: ")
                sql_query = "SELECT * FROM course_class WHERE Ma_hoc_phan = %s"
                sql_insert = (ma_HP,)
                cur.execute(sql_query, sql_insert)
                records = cur.fetchall()

                for record in records:
                    if record[0] == ma_HP:
                        k = 1

                if k == 1:
                    print(
                        "--------------------------Danh sach ma lop hoc phan------------------------------\n")
                    print(
                        "+-------------------------------------------------------------------------------+")
                    print("|   {:<9}|  {:<15}|  {:<15}|  {:<5}|  {:<20}|".format(
                        "Ma_lop", "Tiet_bat_dau", "Tiet_ket_thuc", "Thu", "So_luong_sinh_vien"))
                    for record in records:
                        print(
                            "|------------+-----------------+-----------------+-------+----------------------|")
                        print("|   {:<9}|        {:<8} |        {:<8} |   {:<3} |          {:<11} |".format(
                            record[2], record[5], record[6], record[7], record[8]))

                    print(
                        "+-------------------------------------------------------------------------------+")
                if k == 0:
                    print("Khong ton tai ma hoc phan")

                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 2:
            add_course_class()

        if a == 3:
            while True:
                k = 0
                Ma_lop = input("Nhap ma lop muon thay doi gio hoc: ")
                sql_query = "SELECT Ma_lop FROM course_class"
                cur.execute(sql_query)
                records = cur.fetchall()

                for record in records:
                    if record[0] == Ma_lop:
                        k = 1

                if k == 1:
                    Thu = input("Nhap thu: ")
                    Start = input("Nhap tiet bat dau: ")
                    End = input("Nhap tiet ket thuc: ")

                    sql_query = "UPDATE course_class SET Thu = %s, Tiet_bat_dau = %s, Tiet_ket_thuc = %s WHERE Ma_lop = %s"
                    sql_insert = (Thu, Start, End, Ma_lop)
                    cur.execute(sql_query, sql_insert)
                    conn.commit()

                if k == 0:
                    print("Khong ton tai ma lop")

                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 4:

            print("Ban da thoat chuc nang")
            break


def Student_display_menu():
    while True:
        print("\n---------------Menu---------------")
        print("1. Hien thi danh sach tat ca sinh vien")
        print("2. Danh sach sinh vien duoc hoc bong")
        print("3. Thoat")
        print("----------------------------------")
        a = int(input("Nhap chuc nang ban muon chon: "))
        if a == 1:
            print("------------------------------------------------Danh sach sinh vien-------------------------------------------------------\n")
            print("+------------------------------------------------------------------------------------------------------------------------+")
            print("|    {:<8}| {:<12} |  {:<15}|  {:<10}| {:<10} |  {:<15}|         {:<13}|  {:<5}|".format(
                "MSSV", "Ho_sinh_vien", "Ten_sinh_vien", "Nam_sinh", "Gioi_tinh", "So_dien_thoai", "Mail", "GPA"))

            sql_query = "SELECT * FROM student"
            cur.execute(sql_query)
            records = cur.fetchall()

            for record in records:
                print("|------------+--------------+-----------------+------------+------------+-----------------+----------------------+-------|")
                print("|  {:<10}|      {:<8}|      {:<11}|    {:<8}|     {:<7}|   {:<14}| {:<20} |  {:<5}|".format(
                    record[0], record[1], record[2], record[4], record[5], record[6], record[7], record[3]))

            print("+------------------------------------------------------------------------------------------------------------------------+")

        if a == 2:
            diem_HB = input("Nhap diem dat hoc bong: ")
            sql_query = "SELECT * FROM student WHERE GPA >= %s"
            sql_insert = (diem_HB,)
            cur.execute(sql_query, sql_insert)
            records = cur.fetchall()

            print("------------------------------------------------Danh sach sinh vien-------------------------------------------------------\n")
            print("+------------------------------------------------------------------------------------------------------------------------+")
            print("| {:<10} | {:<12} |  {:<15}|  {:<10}| {:<10} |  {:<15}|         {:<13}|  {:<5}|".format(
                "MSSV", "Ho_sinh_vien", "Ten_sinh_vien", "Nam_sinh", "Gioi_tinh", "So_dien_thoai", "Mail", "GPA"))

            for record in records:
                print("|------------+--------------+-----------------+------------+------------+-----------------+----------------------+-------|")
                print("|  {:<10}|      {:<8}|      {:<11}|    {:<8}|     {:<7}|   {:<14}| {:<20} |  {:<5}|".format(
                    record[0], record[1], record[2], record[4], record[5], record[6], record[7], record[3]))

            print("+------------------------------------------------------------------------------------------------------------------------+")

        if a == 3:
            print("Ban da thoat chuc nang")
            break


def Teacher_display_menu():
    while True:
        print("\n---------------Menu---------------")
        print("1. Hien thi danh sach giang vien")
        print("2. Loc giang vien day hoc phan")
        print("3. Xoa giang vien")
        print("4. Thoat")
        print("----------------------------------")

        a = int(input("Hay chon chuc nang: "))

        if a == 1:
            print("-----------------------------------------------Danh sach giang vien--------------------------------------------------------\n")
            print("+-------------------------------------------------------------------------------------------------------------------------+")
            print("| {:<13} | {:<14} | {:<13} | {:<8} | {:<13} |         {:<13}|  {:<20}|".format(
                "Ho_giang_vien", "Ten_giang_vien", "Ma_giang_vien", "Nam_sinh", "So_dien_thoai", "Mail", "Hoc_phan_giang_day"))

            sql_query = "SELECT * FROM teacher"
            cur.execute(sql_query)
            records = cur.fetchall()

            for record in records:
                print("+---------------+----------------+---------------+----------+---------------+----------------------+----------------------+")
                print("|     {:<10}|      {:<10}|   {:<12}|   {:<7}|  {:<13}| {:<20} |       {:<15}|".format(
                    record[0], record[1], record[2], record[3], record[4], record[5], record[6]))
            print("+-------------------------------------------------------------------------------------------------------------------------+")

        if a == 2:
            while True:
                k = 0
                Ma_HP = input("Nhap ma hoc phan can loc: ")

                sql_query = "SELECT * FROM teacher WHERE hoc_phan_giang_day = %s"
                sql_insert = (Ma_HP,)
                cur.execute(sql_query, sql_insert)
                records = cur.fetchall()

                for record in records:
                    if record[6] == Ma_HP:
                        k = 1

                if k == 1:
                    print(
                        "-----------------------------------------------Danh sach giang vien--------------------------------------------------------\n")
                    print(
                        "+-------------------------------------------------------------------------------------------------------------------------+")
                    print("| {:<13} | {:<14} | {:<13} | {:<8} | {:<13} |         {:<13}|  {:<20}|".format(
                        "Ho_giang_vien", "Ten_giang_vien", "Ma_giang_vien", "Nam_sinh", "So_dien_thoai", "Mail", "Hoc_phan_giang_day"))

                    for record in records:
                        print(
                            "+---------------+----------------+---------------+----------+---------------+----------------------+----------------------+")
                        print("|     {:<10}|      {:<10}|   {:<12}|   {:<7}|  {:<13}| {:<20} |       {:<15}|".format(
                            record[0], record[1], record[2], record[3], record[4], record[5], record[6]))
                    print(
                        "+-------------------------------------------------------------------------------------------------------------------------+")

                if k == 0:
                    print("Khong ton tai ma hoc phan")

                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 3:
            while True:
                k = 0
                Ma_GV = input("Nhap ma giang vien can xoa: ")

                sql_query = "SELECT Ma_giang_vien FROM teacher"
                cur.execute(sql_query)
                records = cur.fetchall()

                for record in records:
                    if record[0] == Ma_GV:
                        k = 1

                if k == 1:
                    sql_query = "DELETE FROM teacher WHERE Ma_giang_vien = %s"
                    sql_insert = (Ma_GV,)
                    cur.execute(sql_query, sql_insert)
                    conn.commit()
                    print("Da xoa thanh cong")

                if k == 0:
                    print("Khong ton tai ma giang vien")

                exit = int(
                    input("Ban co muon tiep tuc chuc nang nay khong(Yes:1 , No:0): "))
                if exit == 0:
                    print("Ban da thoat ")
                    break

        if a == 4:
            print("Ban da thoat")
            break


def Admin_view():
    while True:
        global user_name
        global New_user_name
        print("\n---------------Menu---------------")
        print("1. Thay doi thong tin tai khoan")
        print("2. Quan ly hoc phan  ")
        print("3. Quan ly lop hoc phan")
        print("4. Quan ly sinh vien")
        print("5. Quan ly giang vien")
        print("6. Thoat")
        print("----------------------------------")

        a = int(input("Hay chon chuc nang: "))
        if a == 1:
            edit_user()
            user_name = New_user_name

        if a == 2:
            course_menu()

        if a == 3:
            course_class_menu()

        if a == 4:
            Student_display_menu()

        if a == 5:
            Teacher_display_menu()

        if a == 6:
            print("Ban da thoat khoi chuc nang")
            break


def main():
    while True:
        print("\n---------------Menu---------------")
        print("1.Login")
        print("2.Register")
        print("3.Thoat")
        print("----------------------------------")

        a = int(input("Hay chon chuc nang: "))
        if a == 1:
            print("Ban da chon chuc nang: ", a)
            Login()

        if a == 2:
            print("Ban da chon chuc nang: ", a)
            Register()

        if a == 3:
            print("Ban da thoat chuong trinh")
            break


if __name__ == '__main__':
    create_table()
    Delete_data()
    Insert_data()
    main()
    cur.close()
    conn.close()
