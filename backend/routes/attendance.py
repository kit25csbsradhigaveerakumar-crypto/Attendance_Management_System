"""
Attendance Management & Marking Routes
Attendance Management System
"""

from fastapi import APIRouter, HTTPException, status, Query
from typing import List, Optional
from backend.models.schemas import MarkAttendanceRequest, AttendanceRecordResponse
from backend.database import execute_query, execute_dml, get_db_connection, call_calculate_attendance

router = APIRouter(prefix="/attendance", tags=["Attendance"])


@router.post("", status_code=status.HTTP_201_CREATED)
def mark_attendance(data: MarkAttendanceRequest):
    if not data.records:
        raise HTTPException(status_code=400, detail="No student attendance records provided.")

    # Validate subject exists
    sub = execute_query("SELECT subject_id, subject_name FROM subject WHERE subject_id = ?", (data.subject_id,))
    if not sub:
        raise HTTPException(status_code=404, detail="Subject not found.")

    # Check for existing duplicate attendance on this date for this subject
    placeholders = ",".join("?" for _ in data.records)
    student_ids = [r.student_id for r in data.records]
    check_query = f"""
        SELECT a.student_id, s.student_name 
        FROM attendance a
        JOIN student s ON a.student_id = s.student_id
        WHERE a.subject_id = ? AND a.attendance_date = ? AND a.student_id IN ({placeholders})
    """
    duplicates = execute_query(check_query, [data.subject_id, data.attendance_date] + student_ids)
    if duplicates:
        dup_names = ", ".join(d["student_name"] for d in duplicates[:3])
        if len(duplicates) > 3:
            dup_names += f" and {len(duplicates) - 3} others"
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Attendance has ALREADY been recorded for this subject on {data.attendance_date} for: {dup_names}. Duplicate records are prohibited by database constraints."
        )

    # Insert records in a transaction
    conn, mode = get_db_connection()
    try:
        cursor = conn.cursor()
        inserted_count = 0
        for item in data.records:
            st = item.status.strip().upper()
            if st not in ['PRESENT', 'ABSENT']:
                raise HTTPException(status_code=400, detail=f"Invalid attendance status: '{st}'. Must be PRESENT or ABSENT.")

            cursor.execute(
                """INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by)
                   VALUES (?, ?, ?, ?, ?)""",
                (item.student_id, data.subject_id, data.attendance_date, st, data.marked_by)
            )
            inserted_count += 1

        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Failed to record attendance: {str(e)}")
    finally:
        conn.close()

    # Invoke PL/SQL CALCULATE_ATTENDANCE procedure for each student to maintain ATTENDANCE_SUMMARY
    for item in data.records:
        try:
            call_calculate_attendance(item.student_id, data.subject_id)
        except Exception as e:
            print(f"Notice: Procedure calculation update failed for student {item.student_id}: {e}")

    return {
        "message": f"Successfully marked attendance for {inserted_count} students.",
        "date": data.attendance_date,
        "subject_id": data.subject_id
    }


@router.get("", response_model=List[dict])
def get_attendance_records(
    date: Optional[str] = None,
    student_id: Optional[int] = None,
    subject_id: Optional[int] = None,
    status_filter: Optional[str] = None
):
    sql = """
        SELECT 
            a.attendance_id,
            a.student_id,
            s.student_name,
            s.department,
            s.section,
            a.subject_id,
            sub.subject_code,
            sub.subject_name,
            a.attendance_date,
            a.status,
            f.faculty_name AS marked_by_name
        FROM attendance a
        INNER JOIN student s ON a.student_id = s.student_id
        INNER JOIN subject sub ON a.subject_id = sub.subject_id
        LEFT JOIN faculty f ON a.marked_by = f.faculty_id
        WHERE 1=1
    """
    params = []

    if date:
        sql += " AND a.attendance_date = ?"
        params.append(date)
    if student_id:
        sql += " AND a.student_id = ?"
        params.append(student_id)
    if subject_id:
        sql += " AND a.subject_id = ?"
        params.append(subject_id)
    if status_filter:
        sql += " AND a.status = ?"
        params.append(status_filter.strip().upper())

    sql += " ORDER BY a.attendance_date DESC, sub.subject_code, s.student_name"
    return execute_query(sql, params if params else None)


@router.get("/student/{student_id}", response_model=List[dict])
def get_student_attendance_history(student_id: int, subject_id: Optional[int] = None):
    sql = """
        SELECT 
            a.attendance_id,
            a.attendance_date,
            sub.subject_id,
            sub.subject_code,
            sub.subject_name,
            a.status,
            f.faculty_name AS marked_by
        FROM attendance a
        INNER JOIN subject sub ON a.subject_id = sub.subject_id
        LEFT JOIN faculty f ON a.marked_by = f.faculty_id
        WHERE a.student_id = ?
    """
    params = [student_id]
    if subject_id:
        sql += " AND a.subject_id = ?"
        params.append(subject_id)

    sql += " ORDER BY a.attendance_date DESC, sub.subject_code"
    return execute_query(sql, params)


@router.get("/subject/{subject_id}", response_model=List[dict])
def get_subject_attendance_history(subject_id: int, date: Optional[str] = None):
    sql = """
        SELECT 
            a.attendance_id,
            a.attendance_date,
            s.student_id,
            s.student_name,
            s.section,
            a.status,
            f.faculty_name AS marked_by
        FROM attendance a
        INNER JOIN student s ON a.student_id = s.student_id
        LEFT JOIN faculty f ON a.marked_by = f.faculty_id
        WHERE a.subject_id = ?
    """
    params = [subject_id]
    if date:
        sql += " AND a.attendance_date = ?"
        params.append(date)

    sql += " ORDER BY a.attendance_date DESC, s.section, s.student_name"
    return execute_query(sql, params)
