"""
Subject Management Routes
Attendance Management System
"""

from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from backend.models.schemas import SubjectCreate, SubjectUpdate, SubjectResponse
from backend.database import execute_query, execute_dml, get_db_connection

router = APIRouter(prefix="/subjects", tags=["Subjects"])


@router.get("", response_model=List[dict])
def get_all_subjects():
    rows = execute_query(
        "SELECT subject_id, subject_code, subject_name, department, year_of_study, semester FROM subject ORDER BY year_of_study, semester, subject_code"
    )
    return rows


@router.get("/{subject_id}")
def get_subject(subject_id: int):
    rows = execute_query(
        "SELECT subject_id, subject_code, subject_name, department, year_of_study, semester FROM subject WHERE subject_id = ?",
        (subject_id,)
    )
    if not rows:
        raise HTTPException(status_code=404, detail="Subject not found")

    sub = rows[0]
    # Get enrolled students
    students = execute_query(
        """SELECT s.student_id, s.student_name, s.department, s.section 
           FROM student_subject ss
           JOIN student s ON ss.student_id = s.student_id
           WHERE ss.subject_id = ?
           ORDER BY s.section, s.student_name""",
        (subject_id,)
    )
    sub["students"] = students
    return sub


@router.post("", status_code=status.HTTP_201_CREATED)
def create_subject(data: SubjectCreate):
    existing = execute_query("SELECT subject_id FROM subject WHERE UPPER(subject_code) = ?", (data.subject_code.strip().upper(),))
    if existing:
        raise HTTPException(status_code=400, detail="A subject with this subject code already exists.")

    conn, mode = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            """INSERT INTO subject (subject_code, subject_name, department, year_of_study, semester)
               VALUES (?, ?, ?, ?, ?)""",
            (data.subject_code.strip().upper(), data.subject_name.strip(), data.department.strip(), data.year_of_study, data.semester)
        )
        conn.commit()
        return {"message": "Subject created successfully"}
    finally:
        conn.close()


@router.put("/{subject_id}")
def update_subject(subject_id: int, data: SubjectUpdate):
    existing = execute_query("SELECT subject_id FROM subject WHERE subject_id = ?", (subject_id,))
    if not existing:
        raise HTTPException(status_code=404, detail="Subject not found")

    fields = []
    params = []
    if data.subject_code is not None:
        chk = execute_query("SELECT subject_id FROM subject WHERE UPPER(subject_code) = ? AND subject_id != ?", (data.subject_code.strip().upper(), subject_id))
        if chk:
            raise HTTPException(status_code=400, detail="Subject code is already used by another subject.")
        fields.append("subject_code = ?")
        params.append(data.subject_code.strip().upper())
    if data.subject_name is not None:
        fields.append("subject_name = ?")
        params.append(data.subject_name.strip())
    if data.department is not None:
        fields.append("department = ?")
        params.append(data.department.strip())
    if data.year_of_study is not None:
        fields.append("year_of_study = ?")
        params.append(data.year_of_study)
    if data.semester is not None:
        fields.append("semester = ?")
        params.append(data.semester)

    if fields:
        sql = f"UPDATE subject SET {', '.join(fields)} WHERE subject_id = ?"
        params.append(subject_id)
        execute_dml(sql, params)

    return {"message": "Subject updated successfully"}


@router.delete("/{subject_id}")
def delete_subject(subject_id: int):
    existing = execute_query("SELECT subject_id FROM subject WHERE subject_id = ?", (subject_id,))
    if not existing:
        raise HTTPException(status_code=404, detail="Subject not found")

    execute_dml("DELETE FROM subject WHERE subject_id = ?", (subject_id,))
    return {"message": "Subject deleted successfully"}
