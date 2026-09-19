"""
Student Management Routes
Attendance Management System
"""

from fastapi import APIRouter, HTTPException, status, Query
from typing import List, Optional
from backend.models.schemas import StudentCreate, StudentUpdate, StudentResponse
from backend.database import execute_query, execute_dml, get_db_connection

router = APIRouter(prefix="/students", tags=["Students"])


@router.get("", response_model=List[dict])
def get_all_students(
    department: Optional[str] = None,
    year_of_study: Optional[int] = None,
    section: Optional[str] = None,
    search: Optional[str] = None
):
    sql = "SELECT student_id, student_name, email, department, year_of_study, section, created_at FROM student WHERE 1=1"
    params = []

    if department:
        sql += " AND department = ?"
        params.append(department)
    if year_of_study:
        sql += " AND year_of_study = ?"
        params.append(year_of_study)
    if section:
        sql += " AND section = ?"
        params.append(section)
    if search:
        sql += " AND (LOWER(student_name) LIKE ? OR LOWER(email) LIKE ?)"
        term = f"%{search.lower()}%"
        params.extend([term, term])

    sql += " ORDER BY department, year_of_study, section, student_name"
    rows = execute_query(sql, params if params else None)
    return rows


@router.get("/{student_id}")
def get_student(student_id: int):
    rows = execute_query("SELECT student_id, student_name, email, department, year_of_study, section, created_at FROM student WHERE student_id = ?", (student_id,))
    if not rows:
        raise HTTPException(status_code=404, detail="Student not found")

    student = rows[0]
    # Fetch enrolled subjects
    subjects = execute_query(
        """SELECT s.subject_id, s.subject_code, s.subject_name 
           FROM student_subject ss 
           JOIN subject s ON ss.subject_id = s.subject_id 
           WHERE ss.student_id = ?""",
        (student_id,)
    )
    student["enrolled_subjects"] = subjects
    return student


@router.post("", status_code=status.HTTP_201_CREATED)
def create_student(data: StudentCreate):
    # Check if email exists
    existing = execute_query("SELECT student_id FROM student WHERE LOWER(email) = ?", (data.email.strip().lower(),))
    if existing:
        raise HTTPException(status_code=400, detail="A student with this email address already exists.")

    conn, mode = get_db_connection()
    try:
        cursor = conn.cursor()
        if mode == "ORACLE":
            cursor.execute(
                """INSERT INTO student (student_name, email, password, department, year_of_study, section)
                   VALUES (?, ?, ?, ?, ?, ?)""",
                (data.student_name.strip(), data.email.strip().lower(), data.password, data.department.strip(), data.year_of_study, data.section.strip().upper())
            )
            cursor.execute("SELECT student_id FROM student WHERE email = ?", (data.email.strip().lower(),))
            student_id = cursor.fetchone()[0]
        else:
            cursor.execute(
                """INSERT INTO student (student_name, email, password, department, year_of_study, section)
                   VALUES (?, ?, ?, ?, ?, ?)""",
                (data.student_name.strip(), data.email.strip().lower(), data.password, data.department.strip(), data.year_of_study, data.section.strip().upper())
            )
            student_id = cursor.lastrowid

        # Enroll in selected subjects
        if data.subject_ids:
            for sub_id in data.subject_ids:
                cursor.execute(
                    "INSERT INTO student_subject (student_id, subject_id) VALUES (?, ?)",
                    (student_id, sub_id)
                )

        conn.commit()
        return {"message": "Student created successfully", "student_id": student_id}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Database error: {str(e)}")
    finally:
        conn.close()


@router.put("/{student_id}")
def update_student(student_id: int, data: StudentUpdate):
    existing = execute_query("SELECT student_id FROM student WHERE student_id = ?", (student_id,))
    if not existing:
        raise HTTPException(status_code=404, detail="Student not found")

    conn, mode = get_db_connection()
    try:
        cursor = conn.cursor()
        fields = []
        params = []

        if data.student_name is not None:
            fields.append("student_name = ?")
            params.append(data.student_name.strip())
        if data.email is not None:
            # Check unique
            chk = execute_query("SELECT student_id FROM student WHERE LOWER(email) = ? AND student_id != ?", (data.email.strip().lower(), student_id))
            if chk:
                raise HTTPException(status_code=400, detail="Email already used by another student.")
            fields.append("email = ?")
            params.append(data.email.strip().lower())
        if data.password is not None and data.password.strip():
            fields.append("password = ?")
            params.append(data.password.strip())
        if data.department is not None:
            fields.append("department = ?")
            params.append(data.department.strip())
        if data.year_of_study is not None:
            fields.append("year_of_study = ?")
            params.append(data.year_of_study)
        if data.section is not None:
            fields.append("section = ?")
            params.append(data.section.strip().upper())

        if fields:
            sql = f"UPDATE student SET {', '.join(fields)} WHERE student_id = ?"
            params.append(student_id)
            cursor.execute(sql, params)

        if data.subject_ids is not None:
            cursor.execute("DELETE FROM student_subject WHERE student_id = ?", (student_id,))
            for sub_id in data.subject_ids:
                cursor.execute("INSERT INTO student_subject (student_id, subject_id) VALUES (?, ?)", (student_id, sub_id))

        conn.commit()
        return {"message": "Student updated successfully"}
    finally:
        conn.close()


@router.delete("/{student_id}")
def delete_student(student_id: int):
    existing = execute_query("SELECT student_id FROM student WHERE student_id = ?", (student_id,))
    if not existing:
        raise HTTPException(status_code=404, detail="Student not found")

    execute_dml("DELETE FROM student WHERE student_id = ?", (student_id,))
    return {"message": "Student deleted successfully"}
