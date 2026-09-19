"""
Attendance Reports & Statistics Routes
Attendance Management System
Powered by Oracle View: STUDENT_ATTENDANCE_VIEW
"""

from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from datetime import date
from backend.database import execute_query, execute_scalar

router = APIRouter(prefix="/reports", tags=["Reports"])


@router.get("/summary", response_model=List[dict])
def get_attendance_reports(
    student_id: Optional[int] = None,
    subject_id: Optional[int] = None,
    category: Optional[str] = None
):
    """Fetches attendance metrics dynamically from STUDENT_ATTENDANCE_VIEW."""
    sql = """
        SELECT 
            student_id,
            student_name,
            department,
            section,
            subject_id,
            subject_code,
            subject_name,
            total_classes,
            present_count,
            absent_count,
            attendance_percentage,
            attendance_category
        FROM student_attendance_view
        WHERE 1=1
    """
    params = []

    if student_id:
        sql += " AND student_id = ?"
        params.append(student_id)
    if subject_id:
        sql += " AND subject_id = ?"
        params.append(subject_id)
    if category:
        sql += " AND attendance_category = ?"
        params.append(category)

    sql += " ORDER BY attendance_percentage ASC, student_name, subject_code"
    return execute_query(sql, params if params else None)


@router.get("/student/{student_id}")
def get_student_report(student_id: int):
    """Subject-wise and overall attendance metrics for a single student."""
    # Check student exists
    st = execute_query("SELECT student_id, student_name, department, year_of_study, section FROM student WHERE student_id = ?", (student_id,))
    if not st:
        raise HTTPException(status_code=404, detail="Student not found")

    student_info = st[0]

    # Subject-wise attendance from view
    subject_records = execute_query(
        """SELECT subject_id, subject_code, subject_name, total_classes, present_count, absent_count, attendance_percentage, attendance_category
           FROM student_attendance_view
           WHERE student_id = ?
           ORDER BY subject_code""",
        (student_id,)
    )

    # Compute overall statistics from raw attendance
    overall_stats = execute_query(
        """SELECT 
               COUNT(a.attendance_id) AS total_classes,
               COALESCE(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS total_present,
               COALESCE(SUM(CASE WHEN a.status = 'ABSENT' THEN 1 ELSE 0 END), 0) AS total_absent
           FROM attendance a
           WHERE a.student_id = ?""",
        (student_id,)
    )[0]

    total_classes = overall_stats["total_classes"] or 0
    total_present = overall_stats["total_present"] or 0
    total_absent = overall_stats["total_absent"] or 0
    overall_percentage = round((total_present / total_classes) * 100, 2) if total_classes > 0 else 0.0

    if overall_percentage >= 75:
        overall_category = "Good Attendance"
    elif overall_percentage >= 60:
        overall_category = "Low Attendance"
    else:
        overall_category = "Critical Attendance"

    return {
        "student": student_info,
        "overall": {
            "total_subjects": len(subject_records),
            "total_classes": total_classes,
            "classes_attended": total_present,
            "classes_absent": total_absent,
            "attendance_percentage": overall_percentage,
            "attendance_category": overall_category
        },
        "subject_wise": subject_records
    }


@router.get("/subject/{subject_id}")
def get_subject_report(subject_id: int):
    """Attendance metrics for all students enrolled in a particular subject."""
    sub = execute_query("SELECT subject_id, subject_code, subject_name, department FROM subject WHERE subject_id = ?", (subject_id,))
    if not sub:
        raise HTTPException(status_code=404, detail="Subject not found")

    records = execute_query(
        """SELECT student_id, student_name, department, section, total_classes, present_count, absent_count, attendance_percentage, attendance_category
           FROM student_attendance_view
           WHERE subject_id = ?
           ORDER BY attendance_percentage DESC, student_name""",
        (subject_id,)
    )

    # Calculate average attendance for this subject
    avg_pct = execute_scalar(
        """SELECT ROUND(AVG(attendance_percentage), 2) FROM student_attendance_view WHERE subject_id = ?""",
        (subject_id,)
    )

    return {
        "subject": sub[0],
        "average_percentage": avg_pct or 0.0,
        "students": records
    }


@router.get("/dashboard-stats")
def get_dashboard_stats():
    """Aggregates summary counts for Admin/Faculty Dashboard."""
    total_students = execute_scalar("SELECT COUNT(*) FROM student") or 0
    total_subjects = execute_scalar("SELECT COUNT(*) FROM subject") or 0
    total_faculty = execute_scalar("SELECT COUNT(*) FROM faculty") or 0

    today_str = date.today().isoformat()
    today_attendance = execute_scalar("SELECT COUNT(*) FROM attendance WHERE attendance_date = ?", (today_str,)) or 0

    # Also grab recent 5 attendance entries for quick preview
    recent_records = execute_query(
        """SELECT 
               a.attendance_id,
               a.attendance_date,
               s.student_name,
               s.section,
               sub.subject_code,
               a.status
           FROM attendance a
           JOIN student s ON a.student_id = s.student_id
           JOIN subject sub ON a.subject_id = sub.subject_id
           ORDER BY a.attendance_id DESC
           LIMIT 5"""
    )

    return {
        "total_students": total_students,
        "total_subjects": total_subjects,
        "total_faculty": total_faculty,
        "today_attendance_count": today_attendance,
        "recent_records": recent_records
    }
