-- =======================================================
-- ORACLE SQL QUERIES: ATTENDANCE MANAGEMENT SYSTEM
-- Project: Oracle COE Academic Project
-- Demonstrates: SELECT, WHERE, ORDER BY, GROUP BY, HAVING,
-- COUNT, SUM, AVG, CASE, INNER JOIN, LEFT JOIN, Subqueries
-- =======================================================

-- -------------------------------------------------------
-- Query 1: Display all students
-- -------------------------------------------------------
SELECT 
    student_id,
    student_name,
    email,
    department,
    year_of_study,
    section,
    created_at
FROM student
ORDER BY department, year_of_study, section, student_name;

-- -------------------------------------------------------
-- Query 2: Display all subjects
-- -------------------------------------------------------
SELECT 
    subject_id,
    subject_code,
    subject_name,
    department,
    year_of_study,
    semester
FROM subject
ORDER BY year_of_study, semester, subject_code;

-- -------------------------------------------------------
-- Query 3: Display attendance records for a student (e.g., student_id = 1)
-- -------------------------------------------------------
SELECT 
    a.attendance_id,
    s.student_id,
    s.student_name,
    sub.subject_code,
    sub.subject_name,
    TO_CHAR(a.attendance_date, 'YYYY-MM-DD') AS attendance_date,
    a.status,
    f.faculty_name AS marked_by_faculty
FROM attendance a
INNER JOIN student s ON a.student_id = s.student_id
INNER JOIN subject sub ON a.subject_id = sub.subject_id
LEFT JOIN faculty f ON a.marked_by = f.faculty_id
WHERE a.student_id = 1
ORDER BY a.attendance_date DESC, sub.subject_code;

-- -------------------------------------------------------
-- Query 4: Display subject-wise attendance summary for all students
-- -------------------------------------------------------
SELECT 
    s.student_id,
    s.student_name,
    sub.subject_code,
    sub.subject_name,
    COUNT(a.attendance_id) AS total_classes,
    NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS present_count,
    NVL(SUM(CASE WHEN a.status = 'ABSENT' THEN 1 ELSE 0 END), 0) AS absent_count,
    ROUND(
        (NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) / NULLIF(COUNT(a.attendance_id), 0)) * 100, 
        2
    ) AS attendance_percentage
FROM student_subject ss
INNER JOIN student s ON ss.student_id = s.student_id
INNER JOIN subject sub ON ss.subject_id = sub.subject_id
LEFT JOIN attendance a ON ss.student_id = a.student_id AND ss.subject_id = a.subject_id
GROUP BY s.student_id, s.student_name, sub.subject_code, sub.subject_name
ORDER BY s.student_name, sub.subject_code;

-- -------------------------------------------------------
-- Query 5: Calculate total classes attended and conducted for a student (student_id = 1)
-- -------------------------------------------------------
SELECT 
    s.student_id,
    s.student_name,
    COUNT(a.attendance_id) AS total_classes_conducted
FROM student s
LEFT JOIN attendance a ON s.student_id = a.student_id
WHERE s.student_id = 1
GROUP BY s.student_id, s.student_name;

-- -------------------------------------------------------
-- Query 6: Calculate present count for a student across all subjects
-- -------------------------------------------------------
SELECT 
    s.student_id,
    s.student_name,
    COUNT(a.attendance_id) AS total_present_classes
FROM student s
INNER JOIN attendance a ON s.student_id = a.student_id
WHERE s.student_id = 1 
  AND a.status = 'PRESENT'
GROUP BY s.student_id, s.student_name;

-- -------------------------------------------------------
-- Query 7: Calculate absent count for a student across all subjects
-- -------------------------------------------------------
SELECT 
    s.student_id,
    s.student_name,
    COUNT(a.attendance_id) AS total_absent_classes
FROM student s
INNER JOIN attendance a ON s.student_id = a.student_id
WHERE s.student_id = 1 
  AND a.status = 'ABSENT'
GROUP BY s.student_id, s.student_name;

-- -------------------------------------------------------
-- Query 8: Calculate overall attendance percentage for each student
-- Attendance % = (Total Present / Total Classes) * 100
-- -------------------------------------------------------
SELECT 
    s.student_id,
    s.student_name,
    s.department,
    s.section,
    COUNT(a.attendance_id) AS total_classes,
    NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS total_present,
    NVL(SUM(CASE WHEN a.status = 'ABSENT' THEN 1 ELSE 0 END), 0) AS total_absent,
    ROUND(
        (NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) / NULLIF(COUNT(a.attendance_id), 0)) * 100, 
        2
    ) AS overall_percentage
FROM student s
LEFT JOIN attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.student_name, s.department, s.section
ORDER BY overall_percentage DESC;

-- -------------------------------------------------------
-- Query 9: Display students with overall attendance below 75%
-- (Uses HAVING clause with aggregate formula)
-- -------------------------------------------------------
SELECT 
    s.student_id,
    s.student_name,
    s.department,
    s.section,
    COUNT(a.attendance_id) AS total_classes,
    NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS total_present,
    ROUND(
        (NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) / NULLIF(COUNT(a.attendance_id), 0)) * 100, 
        2
    ) AS attendance_percentage
FROM student s
LEFT JOIN attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.student_name, s.department, s.section
HAVING (NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) / NULLIF(COUNT(a.attendance_id), 0)) * 100 < 75
ORDER BY attendance_percentage ASC;

-- -------------------------------------------------------
-- Query 10: Display students with overall attendance 75% or above (Eligible)
-- -------------------------------------------------------
SELECT 
    s.student_id,
    s.student_name,
    s.department,
    s.section,
    COUNT(a.attendance_id) AS total_classes,
    NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS total_present,
    ROUND(
        (NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) / NULLIF(COUNT(a.attendance_id), 0)) * 100, 
        2
    ) AS attendance_percentage
FROM student s
LEFT JOIN attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.student_name, s.department, s.section
HAVING (NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) / NULLIF(COUNT(a.attendance_id), 0)) * 100 >= 75
ORDER BY attendance_percentage DESC;

-- -------------------------------------------------------
-- Query 11: Display average attendance percentage for each subject
-- (Uses Subquery + AVG aggregate)
-- -------------------------------------------------------
SELECT 
    sub.subject_id,
    sub.subject_code,
    sub.subject_name,
    sub.department,
    COUNT(a.attendance_id) AS total_attendance_entries,
    ROUND(
        AVG(CASE WHEN a.status = 'PRESENT' THEN 100.0 ELSE 0.0 END), 
        2
    ) AS avg_attendance_percentage
FROM subject sub
LEFT JOIN attendance a ON sub.subject_id = a.subject_id
GROUP BY sub.subject_id, sub.subject_code, sub.subject_name, sub.department
ORDER BY avg_attendance_percentage DESC;

-- -------------------------------------------------------
-- Query 12: Display the number of present and absent students for a particular date (e.g., '2026-08-01')
-- -------------------------------------------------------
SELECT 
    sub.subject_code,
    sub.subject_name,
    TO_CHAR(a.attendance_date, 'YYYY-MM-DD') AS class_date,
    SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END) AS total_present,
    SUM(CASE WHEN a.status = 'ABSENT'  THEN 1 ELSE 0 END) AS total_absent,
    COUNT(*) AS total_marked
FROM attendance a
INNER JOIN subject sub ON a.subject_id = sub.subject_id
WHERE a.attendance_date = DATE '2026-08-01'
GROUP BY sub.subject_code, sub.subject_name, a.attendance_date;

-- -------------------------------------------------------
-- Query 13: Display chronological attendance history for a particular student
-- (with Subject details and Faculty marker)
-- -------------------------------------------------------
SELECT 
    a.attendance_id,
    TO_CHAR(a.attendance_date, 'YYYY-MM-DD') AS attendance_date,
    sub.subject_code,
    sub.subject_name,
    a.status,
    f.faculty_name AS marked_by
FROM attendance a
INNER JOIN subject sub ON a.subject_id = sub.subject_id
LEFT JOIN faculty f ON a.marked_by = f.faculty_id
WHERE a.student_id = 1
ORDER BY a.attendance_date DESC, sub.subject_code;

-- -------------------------------------------------------
-- Query 14: Display students with critical attendance below 60%
-- (Subject-wise breakdown using STUDENT_ATTENDANCE_VIEW)
-- -------------------------------------------------------
SELECT 
    student_id,
    student_name,
    department,
    section,
    subject_code,
    subject_name,
    total_classes,
    present_count,
    absent_count,
    attendance_percentage,
    attendance_category
FROM student_attendance_view
WHERE attendance_percentage < 60
ORDER BY attendance_percentage ASC, student_name;
