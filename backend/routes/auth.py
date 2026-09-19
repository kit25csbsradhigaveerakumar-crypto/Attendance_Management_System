"""
Authentication Routes
Attendance Management System
"""

from fastapi import APIRouter, HTTPException, status
from backend.models.schemas import LoginRequest, LoginResponse
from backend.database import execute_query

router = APIRouter(prefix="", tags=["Authentication"])


@router.post("/login", response_model=LoginResponse)
def login(creds: LoginRequest):
    email = creds.email.strip().lower()
    password = creds.password.strip()
    role = creds.role.strip().lower()

    if role in ["admin", "faculty"]:
        # Query faculty table
        rows = execute_query(
            "SELECT faculty_id, faculty_name, email, password, department FROM faculty WHERE LOWER(email) = ?",
            (email,)
        )
        if not rows:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid faculty email or credentials."
            )
        user = rows[0]
        if user["password"] != password:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect password."
            )
        return LoginResponse(
            token=f"faculty-token-{user['faculty_id']}",
            user_id=user["faculty_id"],
            name=user["faculty_name"],
            email=user["email"],
            role="faculty",
            department=user["department"]
        )

    elif role == "student":
        # Query student table
        rows = execute_query(
            "SELECT student_id, student_name, email, password, department FROM student WHERE LOWER(email) = ?",
            (email,)
        )
        if not rows:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid student email or credentials."
            )
        user = rows[0]
        if user["password"] != password:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect password."
            )
        return LoginResponse(
            token=f"student-token-{user['student_id']}",
            user_id=user["student_id"],
            name=user["student_name"],
            email=user["email"],
            role="student",
            department=user["department"]
        )

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Role must be either 'faculty' (or admin) or 'student'."
        )
