-- =======================================================
-- ORACLE SAMPLE DATA: ATTENDANCE MANAGEMENT SYSTEM
-- =======================================================

-- -------------------------------------------------------
-- 1. INSERT FACULTY MEMBERS (3 Faculty)
-- -------------------------------------------------------
INSERT INTO faculty (faculty_id, faculty_name, email, password, department)
VALUES (1, 'Dr. Rajesh Sharma', 'rajesh.sharma@college.edu', 'faculty123', 'Computer Science');

INSERT INTO faculty (faculty_id, faculty_name, email, password, department)
VALUES (2, 'Dr. Anita Desai', 'anita.desai@college.edu', 'faculty123', 'Computer Science');

INSERT INTO faculty (faculty_id, faculty_name, email, password, department)
VALUES (3, 'Prof. Vikram Patel', 'vikram.patel@college.edu', 'faculty123', 'Information Technology');

-- -------------------------------------------------------
-- 2. INSERT SUBJECTS (5 Subjects)
-- -------------------------------------------------------
INSERT INTO subject (subject_id, subject_code, subject_name, department, year_of_study, semester)
VALUES (1, 'CS301', 'Database Management Systems', 'Computer Science', 3, 5);

INSERT INTO subject (subject_id, subject_code, subject_name, department, year_of_study, semester)
VALUES (2, 'CS302', 'Operating Systems', 'Computer Science', 3, 5);

INSERT INTO subject (subject_id, subject_code, subject_name, department, year_of_study, semester)
VALUES (3, 'CS303', 'Java Programming', 'Computer Science', 3, 5);

INSERT INTO subject (subject_id, subject_code, subject_name, department, year_of_study, semester)
VALUES (4, 'CS304', 'Computer Networks', 'Information Technology', 3, 5);

INSERT INTO subject (subject_id, subject_code, subject_name, department, year_of_study, semester)
VALUES (5, 'CS305', 'Web Technology', 'Information Technology', 3, 5);

-- -------------------------------------------------------
-- 3. INSERT STUDENTS (10 Students)
-- -------------------------------------------------------
INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (1, 'Aarav Sharma', 'aarav.sharma@student.edu', 'student123', 'Computer Science', 3, 'A');

INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (2, 'Diya Patel', 'diya.patel@student.edu', 'student123', 'Computer Science', 3, 'A');

INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (3, 'Rohan Verma', 'rohan.verma@student.edu', 'student123', 'Computer Science', 3, 'A');

INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (4, 'Sneha Reddy', 'sneha.reddy@student.edu', 'student123', 'Computer Science', 3, 'A');

INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (5, 'Kabir Mehta', 'kabir.mehta@student.edu', 'student123', 'Computer Science', 3, 'B');

INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (6, 'Ananya Iyer', 'ananya.iyer@student.edu', 'student123', 'Computer Science', 3, 'B');

INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (7, 'Aditya Joshi', 'aditya.joshi@student.edu', 'student123', 'Information Technology', 3, 'A');

INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (8, 'Pooja Nair', 'pooja.nair@student.edu', 'student123', 'Information Technology', 3, 'A');

INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (9, 'Manish Kumar', 'manish.kumar@student.edu', 'student123', 'Information Technology', 3, 'B');

INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section)
VALUES (10, 'Tanvi Kulkarni', 'tanvi.kulkarni@student.edu', 'student123', 'Information Technology', 3, 'B');

-- -------------------------------------------------------
-- 4. INSERT STUDENT_SUBJECT MAPPINGS
-- -------------------------------------------------------
-- CS Students (1 to 6) enrolled in DBMS(1), OS(2), Java(3), Web Tech(5)
INSERT INTO student_subject (student_id, subject_id) VALUES (1, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (1, 2);
INSERT INTO student_subject (student_id, subject_id) VALUES (1, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (1, 5);

INSERT INTO student_subject (student_id, subject_id) VALUES (2, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (2, 2);
INSERT INTO student_subject (student_id, subject_id) VALUES (2, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (2, 5);

INSERT INTO student_subject (student_id, subject_id) VALUES (3, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (3, 2);
INSERT INTO student_subject (student_id, subject_id) VALUES (3, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (3, 5);

INSERT INTO student_subject (student_id, subject_id) VALUES (4, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (4, 2);
INSERT INTO student_subject (student_id, subject_id) VALUES (4, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (4, 5);

INSERT INTO student_subject (student_id, subject_id) VALUES (5, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (5, 2);
INSERT INTO student_subject (student_id, subject_id) VALUES (5, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (5, 5);

INSERT INTO student_subject (student_id, subject_id) VALUES (6, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (6, 2);
INSERT INTO student_subject (student_id, subject_id) VALUES (6, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (6, 5);

-- IT Students (7 to 10) enrolled in DBMS(1), Java(3), Networks(4), Web Tech(5)
INSERT INTO student_subject (student_id, subject_id) VALUES (7, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (7, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (7, 4);
INSERT INTO student_subject (student_id, subject_id) VALUES (7, 5);

INSERT INTO student_subject (student_id, subject_id) VALUES (8, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (8, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (8, 4);
INSERT INTO student_subject (student_id, subject_id) VALUES (8, 5);

INSERT INTO student_subject (student_id, subject_id) VALUES (9, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (9, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (9, 4);
INSERT INTO student_subject (student_id, subject_id) VALUES (9, 5);

INSERT INTO student_subject (student_id, subject_id) VALUES (10, 1);
INSERT INTO student_subject (student_id, subject_id) VALUES (10, 3);
INSERT INTO student_subject (student_id, subject_id) VALUES (10, 4);
INSERT INTO student_subject (student_id, subject_id) VALUES (10, 5);

-- -------------------------------------------------------
-- 5. INSERT REALISTIC ATTENDANCE RECORDS (12 Class Dates)
-- Dates: 2026-08-01, 2026-08-03, 2026-08-04, 2026-08-06,
--        2026-08-08, 2026-08-10, 2026-08-11, 2026-08-13,
--        2026-08-15, 2026-08-17, 2026-08-18, 2026-08-20
-- Student 1 (Aarav): High (>85%)
-- Student 2 (Diya): High (>85%)
-- Student 3 (Rohan): Average (60% - 74%)
-- Student 4 (Sneha): Average (60% - 74%)
-- Student 5 (Kabir): Critical (<60%)
-- Student 6 (Ananya): High (>75%)
-- Student 7 (Aditya): Critical (<60%)
-- Student 8 (Pooja): High (>80%)
-- Student 9 (Manish): Low/Average (60% - 70%)
-- Student 10 (Tanvi): Good (75%)
-- -------------------------------------------------------

-- SUBJECT 1: Database Management Systems (Taught by Faculty 1 - Dr. Rajesh Sharma)
-- 12 dates for Students 1..10
-- Student 1 (Aarav): 11 Present, 1 Absent (91.67%)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-01', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-03', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-04', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-06', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-08', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-10', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-11', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-13', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-15', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-17', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-18', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 1, DATE '2026-08-20', 'PRESENT', 1);

-- Student 2 (Diya): 10 Present, 2 Absent (83.33%)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-01', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-03', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-04', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-06', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-08', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-10', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-11', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-13', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-15', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-17', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-18', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 1, DATE '2026-08-20', 'PRESENT', 1);

-- Student 3 (Rohan): 8 Present, 4 Absent (66.67% - Low)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-01', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-03', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-04', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-06', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-08', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-10', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-11', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-13', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-15', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-17', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-18', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 1, DATE '2026-08-20', 'PRESENT', 1);

-- Student 4 (Sneha): 8 Present, 4 Absent (66.67% - Low)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-01', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-03', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-04', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-06', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-08', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-10', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-11', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-13', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-15', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-17', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-18', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (4, 1, DATE '2026-08-20', 'PRESENT', 1);

-- Student 5 (Kabir): 6 Present, 6 Absent (50.00% - Critical)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-01', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-03', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-04', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-06', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-08', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-10', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-11', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-13', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-15', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-17', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-18', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 1, DATE '2026-08-20', 'PRESENT', 1);

-- Student 6 (Ananya): 10 Present, 2 Absent (83.33% - Good)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-01', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-03', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-04', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-06', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-08', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-10', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-11', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-13', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-15', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-17', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-18', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (6, 1, DATE '2026-08-20', 'PRESENT', 1);

-- Student 7 (Aditya): 5 Present, 7 Absent (41.67% - Critical)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-01', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-03', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-04', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-06', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-08', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-10', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-11', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-13', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-15', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-17', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-18', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 1, DATE '2026-08-20', 'PRESENT', 1);

-- Student 8 (Pooja): 11 Present, 1 Absent (91.67% - Good)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-01', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-03', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-04', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-06', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-08', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-10', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-11', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-13', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-15', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-17', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-18', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 1, DATE '2026-08-20', 'PRESENT', 1);

-- Student 9 (Manish): 8 Present, 4 Absent (66.67% - Low)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-01', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-03', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-04', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-06', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-08', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-10', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-11', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-13', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-15', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-17', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-18', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (9, 1, DATE '2026-08-20', 'PRESENT', 1);

-- Student 10 (Tanvi): 9 Present, 3 Absent (75.00% - Good)
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-01', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-03', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-04', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-06', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-08', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-10', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-11', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-13', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-15', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-17', 'ABSENT',  1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-18', 'PRESENT', 1);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (10, 1, DATE '2026-08-20', 'PRESENT', 1);

-- -------------------------------------------------------
-- SUBJECT 2: Operating Systems (Taught by Faculty 2 - Dr. Anita Desai)
-- Enrolled: Students 1..6
-- -------------------------------------------------------
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-02', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-05', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-07', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-09', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-12', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-14', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-16', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-19', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-21', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 2, DATE '2026-08-23', 'PRESENT', 2);

INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-02', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-05', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-07', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-09', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-12', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-14', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-16', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-19', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-21', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (2, 2, DATE '2026-08-23', 'PRESENT', 2);

INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-02', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-05', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-07', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-09', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-12', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-14', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-16', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-19', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-21', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (3, 2, DATE '2026-08-23', 'ABSENT',  2);

INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-02', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-05', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-07', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-09', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-12', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-14', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-16', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-19', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-21', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 2, DATE '2026-08-23', 'ABSENT',  2);

-- -------------------------------------------------------
-- SUBJECT 3: Java Programming (Taught by Faculty 2 - Dr. Anita Desai)
-- Enrolled: Students 1..10
-- -------------------------------------------------------
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-01', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-03', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-05', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-08', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-10', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-12', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-15', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-17', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-19', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 3, DATE '2026-08-22', 'PRESENT', 2);

INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-01', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-03', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-05', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-08', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-10', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-12', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-15', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-17', 'ABSENT',  2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-19', 'PRESENT', 2);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 3, DATE '2026-08-22', 'ABSENT',  2);

-- -------------------------------------------------------
-- SUBJECT 4: Computer Networks (Taught by Faculty 3 - Prof. Vikram Patel)
-- Enrolled: Students 7..10
-- -------------------------------------------------------
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-02', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-04', 'ABSENT',  3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-06', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-09', 'ABSENT',  3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-11', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-13', 'ABSENT',  3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-16', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-18', 'ABSENT',  3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-20', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (7, 4, DATE '2026-08-22', 'ABSENT',  3);

INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-02', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-04', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-06', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-09', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-11', 'ABSENT',  3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-13', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-16', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-18', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-20', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (8, 4, DATE '2026-08-22', 'PRESENT', 3);

-- -------------------------------------------------------
-- SUBJECT 5: Web Technology (Taught by Faculty 3 - Prof. Vikram Patel)
-- Enrolled: Students 1..10
-- -------------------------------------------------------
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 5, DATE '2026-08-03', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 5, DATE '2026-08-06', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 5, DATE '2026-08-10', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 5, DATE '2026-08-13', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 5, DATE '2026-08-17', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (1, 5, DATE '2026-08-20', 'PRESENT', 3);

INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 5, DATE '2026-08-03', 'ABSENT',  3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 5, DATE '2026-08-06', 'ABSENT',  3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 5, DATE '2026-08-10', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 5, DATE '2026-08-13', 'ABSENT',  3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 5, DATE '2026-08-17', 'PRESENT', 3);
INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (5, 5, DATE '2026-08-20', 'ABSENT',  3);

COMMIT;

-- -------------------------------------------------------
-- 6. INITIALIZE ATTENDANCE SUMMARY USING PL/SQL PROCEDURE
-- -------------------------------------------------------
BEGIN
    refresh_all_attendance_summaries;
END;
/
