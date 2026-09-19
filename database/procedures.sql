-- =======================================================
-- ORACLE PL/SQL: ATTENDANCE MANAGEMENT SYSTEM
-- Procedure: CALCULATE_ATTENDANCE
-- =======================================================

CREATE OR REPLACE PROCEDURE calculate_attendance (
    p_student_id IN NUMBER,
    p_subject_id IN NUMBER
) IS
    v_total NUMBER := 0;
    v_present NUMBER := 0;
    v_absent NUMBER := 0;
    v_percentage NUMBER(5, 2) := 0;
BEGIN
    -- 1. Count total classes for the given student and subject
    SELECT COUNT(*)
    INTO v_total
    FROM attendance
    WHERE student_id = p_student_id
      AND subject_id = p_subject_id;

    -- 2. Count present classes
    SELECT COUNT(*)
    INTO v_present
    FROM attendance
    WHERE student_id = p_student_id
      AND subject_id = p_subject_id
      AND status = 'PRESENT';

    -- 3. Count absent classes
    SELECT COUNT(*)
    INTO v_absent
    FROM attendance
    WHERE student_id = p_student_id
      AND subject_id = p_subject_id
      AND status = 'ABSENT';

    -- 4. Calculate attendance percentage
    IF v_total > 0 THEN
        v_percentage := ROUND((v_present / v_total) * 100, 2);
    ELSE
        v_percentage := 0;
    END IF;

    -- 5. Insert or update ATTENDANCE_SUMMARY using MERGE
    MERGE INTO attendance_summary s
    USING dual
    ON (s.student_id = p_student_id AND s.subject_id = p_subject_id)
    WHEN MATCHED THEN
        UPDATE SET
            s.total_classes         = v_total,
            s.present_count         = v_present,
            s.absent_count          = v_absent,
            s.attendance_percentage = v_percentage,
            s.last_calculated       = CURRENT_TIMESTAMP
    WHEN NOT MATCHED THEN
        INSERT (
            student_id,
            subject_id,
            total_classes,
            present_count,
            absent_count,
            attendance_percentage,
            last_calculated
        ) VALUES (
            p_student_id,
            p_subject_id,
            v_total,
            v_present,
            v_absent,
            v_percentage,
            CURRENT_TIMESTAMP
        );

    COMMIT;
END calculate_attendance;
/

-- Helper procedure to recalculate attendance summaries for all student-subject pairs
CREATE OR REPLACE PROCEDURE refresh_all_attendance_summaries IS
BEGIN
    FOR r IN (SELECT student_id, subject_id FROM student_subject) LOOP
        calculate_attendance(r.student_id, r.subject_id);
    END LOOP;
END refresh_all_attendance_summaries;
/
