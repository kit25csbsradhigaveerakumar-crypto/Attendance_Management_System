"""
Pydantic Schemas for Request and Response Models
Attendance Management System
"""

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import date, datetime


# Auth Schemas
class LoginRequest(BaseModel):
    email: str
    password: str
    role: str = Field(..., description="Role: 'faculty' (or 'admin') or 'student'")


class LoginResponse(BaseModel):
    token: str
    user_id: int
    name: str
    email: str
    role: str
    department: str


# Student Schemas
class StudentBase(BaseModel):
    student_name: str
    email: str
    department: str
    year_of_study: int = Field(..., ge=1, le=4)
    section: str


class StudentCreate(StudentBase):
    password: str
    subject_ids: Optional[List[int]] = []


class StudentUpdate(BaseModel):
    student_name: Optional[str] = None
    email: Optional[str] = None
    password: Optional[str] = None
    department: Optional[str] = None
    year_of_study: Optional[int] = Field(None, ge=1, le=4)
    section: Optional[str] = None
    subject_ids: Optional[List[int]] = None


class StudentResponse(StudentBase):
    student_id: int
    created_at: Optional[str] = None


# Subject Schemas
class SubjectBase(BaseModel):
    subject_code: str
    subject_name: str
    department: str
    year_of_study: int = Field(..., ge=1, le=4)
    semester: int = Field(..., ge=1, le=8)


class SubjectCreate(SubjectBase):
    pass


class SubjectUpdate(BaseModel):
    subject_code: Optional[str] = None
    subject_name: Optional[str] = None
    department: Optional[str] = None
    year_of_study: Optional[int] = Field(None, ge=1, le=4)
    semester: Optional[int] = Field(None, ge=1, le=8)


class SubjectResponse(SubjectBase):
    subject_id: int


# Attendance Schemas
class AttendanceItem(BaseModel):
    student_id: int
    status: str = Field(..., description="'PRESENT' or 'ABSENT'")


class MarkAttendanceRequest(BaseModel):
    subject_id: int
    attendance_date: str = Field(..., description="YYYY-MM-DD")
    records: List[AttendanceItem]
    marked_by: Optional[int] = None


class AttendanceRecordResponse(BaseModel):
    attendance_id: int
    student_id: int
    student_name: str
    subject_id: int
    subject_code: str
    subject_name: str
    attendance_date: str
    status: str
    marked_by_name: Optional[str] = None


# Report Schemas
class SubjectAttendanceReport(BaseModel):
    student_id: int
    student_name: str
    department: str
    section: str
    subject_id: int
    subject_code: str
    subject_name: str
    total_classes: int
    present_count: int
    absent_count: int
    attendance_percentage: float
    attendance_category: str


class DashboardStatsResponse(BaseModel):
    total_students: int
    total_subjects: int
    total_faculty: int
    today_attendance_count: int
