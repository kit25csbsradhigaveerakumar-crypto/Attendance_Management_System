-- =======================================================
-- ORACLE VIEW: ATTENDANCE MANAGEMENT SYSTEM
-- View: STUDENT_ATTENDANCE_VIEW
-- Combines Student, Subject, Counts, Percentage, and Category
-- =======================================================

CREATE OR REPLACE VIEW student_attendance_view AS
SELECT 
    s.student_id,
    s.student_name,
    s.department,
    s.section,
    sub.subject_id,
    sub.subject_code,
    sub.subject_name,
    COUNT(a.attendance_id) AS total_classes,
    NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS present_count,
    NVL(SUM(CASE WHEN a.status = 'ABSENT' THEN 1 ELSE 0 END), 0) AS absent_count,
    CASE 
        WHEN COUNT(a.attendance_id) = 0 THEN 0.00
        ELSE ROUND((NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) / COUNT(a.attendance_id)) * 100, 2)
    END AS attendance_percentage,
    CASE 
        WHEN COUNT(a.attendance_id) = 0 THEN 'No Classes'
        WHEN (NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) / COUNT(a.attendance_id)) * 100 >= 75 THEN 'Good Attendance'
        WHEN (NVL(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) / COUNT(a.attendance_id)) * 100 >= 60 THEN 'Low Attendance'
        ELSE 'Critical Attendance'
    END AS attendance_category
FROM student_subject ss
INNER JOIN student s ON ss.student_id = s.student_id
INNER JOIN subject sub ON ss.subject_id = sub.subject_id
LEFT JOIN attendance a ON ss.student_id = a.student_id AND ss.subject_id = a.subject_id
GROUP BY 
    s.student_id,
    s.student_name,
    s.department,
    s.section,
    sub.subject_id,
    sub.subject_code,
    sub.subject_name;
