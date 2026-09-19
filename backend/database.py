"""
Database Management Layer
Attendance Management System
---------------------------
Supports Oracle Database (via python-oracledb) with automatic fallback
to local relational SQLite for testing if Oracle service is offline.
"""

import os
import sqlite3
from pathlib import Path
from dotenv import load_dotenv

env_path = Path(__file__).resolve().parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

ORACLE_USER = os.getenv("ORACLE_USER", "attendance_admin")
ORACLE_PASSWORD = os.getenv("ORACLE_PASSWORD", "oracle")
ORACLE_DSN = os.getenv("ORACLE_DSN", "localhost:1521/XEPDB1")
ORACLE_CONFIG_DIR = os.getenv("ORACLE_CONFIG_DIR")

# Try importing oracledb
try:
    import oracledb
    ORACLEDB_AVAILABLE = True
except ImportError:
    ORACLEDB_AVAILABLE = False

DB_MODE = "UNCHECKED" # "ORACLE" or "SQLITE_FALLBACK"
SQLITE_DB_PATH = Path(__file__).resolve().parent / "local_attendance.db"


def init_sqlite_fallback():
    """Initializes local relational database with exact schema and sample data."""
    conn = sqlite3.connect(SQLITE_DB_PATH)
    cursor = conn.cursor()
    cursor.execute("PRAGMA foreign_keys = ON;")

    cursor.executescript("""
    CREATE TABLE IF NOT EXISTS student (
        student_id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        department TEXT NOT NULL,
        year_of_study INTEGER NOT NULL CHECK (year_of_study BETWEEN 1 AND 4),
        section TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS faculty (
        faculty_id INTEGER PRIMARY KEY AUTOINCREMENT,
        faculty_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        department TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS subject (
        subject_id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_code TEXT UNIQUE NOT NULL,
        subject_name TEXT NOT NULL,
        department TEXT NOT NULL,
        year_of_study INTEGER NOT NULL CHECK (year_of_study BETWEEN 1 AND 4),
        semester INTEGER NOT NULL CHECK (semester BETWEEN 1 AND 8)
    );

    CREATE TABLE IF NOT EXISTS student_subject (
        student_id INTEGER NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
        subject_id INTEGER NOT NULL REFERENCES subject(subject_id) ON DELETE CASCADE,
        PRIMARY KEY (student_id, subject_id)
    );

    CREATE TABLE IF NOT EXISTS attendance (
        attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
        subject_id INTEGER NOT NULL REFERENCES subject(subject_id) ON DELETE CASCADE,
        attendance_date DATE NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('PRESENT', 'ABSENT')),
        marked_by INTEGER REFERENCES faculty(faculty_id) ON DELETE SET NULL,
        UNIQUE (student_id, subject_id, attendance_date)
    );

    CREATE TABLE IF NOT EXISTS attendance_summary (
        summary_id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
        subject_id INTEGER NOT NULL REFERENCES subject(subject_id) ON DELETE CASCADE,
        total_classes INTEGER DEFAULT 0 NOT NULL,
        present_count INTEGER DEFAULT 0 NOT NULL,
        absent_count INTEGER DEFAULT 0 NOT NULL,
        attendance_percentage REAL DEFAULT 0.0 NOT NULL CHECK (attendance_percentage BETWEEN 0 AND 100),
        last_calculated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (student_id, subject_id)
    );

    CREATE VIEW IF NOT EXISTS student_attendance_view AS
    SELECT 
        s.student_id,
        s.student_name,
        s.department,
        s.section,
        sub.subject_id,
        sub.subject_code,
        sub.subject_name,
        COUNT(a.attendance_id) AS total_classes,
        COALESCE(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS present_count,
        COALESCE(SUM(CASE WHEN a.status = 'ABSENT' THEN 1 ELSE 0 END), 0) AS absent_count,
        CASE 
            WHEN COUNT(a.attendance_id) = 0 THEN 0.00
            ELSE ROUND((CAST(COALESCE(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS REAL) / COUNT(a.attendance_id)) * 100, 2)
        END AS attendance_percentage,
        CASE 
            WHEN COUNT(a.attendance_id) = 0 THEN 'No Classes'
            WHEN (CAST(COALESCE(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS REAL) / COUNT(a.attendance_id)) * 100 >= 75 THEN 'Good Attendance'
            WHEN (CAST(COALESCE(SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END), 0) AS REAL) / COUNT(a.attendance_id)) * 100 >= 60 THEN 'Low Attendance'
            ELSE 'Critical Attendance'
        END AS attendance_category
    FROM student_subject ss
    INNER JOIN student s ON ss.student_id = s.student_id
    INNER JOIN subject sub ON ss.subject_id = sub.subject_id
    LEFT JOIN attendance a ON ss.student_id = a.student_id AND ss.subject_id = a.subject_id
    GROUP BY s.student_id, s.student_name, s.department, s.section, sub.subject_id, sub.subject_code, sub.subject_name;
    """)

    # Check if sample data exists
    cursor.execute("SELECT COUNT(*) FROM student")
    if cursor.fetchone()[0] == 0:
        cursor.executescript("""
        INSERT INTO faculty (faculty_id, faculty_name, email, password, department) VALUES
        (1, 'Dr. Rajesh Sharma', 'rajesh.sharma@college.edu', 'faculty123', 'Computer Science'),
        (2, 'Dr. Anita Desai', 'anita.desai@college.edu', 'faculty123', 'Computer Science'),
        (3, 'Prof. Vikram Patel', 'vikram.patel@college.edu', 'faculty123', 'Information Technology');

        INSERT INTO subject (subject_id, subject_code, subject_name, department, year_of_study, semester) VALUES
        (1, 'CS301', 'Database Management Systems', 'Computer Science', 3, 5),
        (2, 'CS302', 'Operating Systems', 'Computer Science', 3, 5),
        (3, 'CS303', 'Java Programming', 'Computer Science', 3, 5),
        (4, 'CS304', 'Computer Networks', 'Information Technology', 3, 5),
        (5, 'CS305', 'Web Technology', 'Information Technology', 3, 5);

        INSERT INTO student (student_id, student_name, email, password, department, year_of_study, section) VALUES
        (1, 'Aarav Sharma', 'aarav.sharma@student.edu', 'student123', 'Computer Science', 3, 'A'),
        (2, 'Diya Patel', 'diya.patel@student.edu', 'student123', 'Computer Science', 3, 'A'),
        (3, 'Rohan Verma', 'rohan.verma@student.edu', 'student123', 'Computer Science', 3, 'A'),
        (4, 'Sneha Reddy', 'sneha.reddy@student.edu', 'student123', 'Computer Science', 3, 'A'),
        (5, 'Kabir Mehta', 'kabir.mehta@student.edu', 'student123', 'Computer Science', 3, 'B'),
        (6, 'Ananya Iyer', 'ananya.iyer@student.edu', 'student123', 'Computer Science', 3, 'B'),
        (7, 'Aditya Joshi', 'aditya.joshi@student.edu', 'student123', 'Information Technology', 3, 'A'),
        (8, 'Pooja Nair', 'pooja.nair@student.edu', 'student123', 'Information Technology', 3, 'A'),
        (9, 'Manish Kumar', 'manish.kumar@student.edu', 'student123', 'Information Technology', 3, 'B'),
        (10, 'Tanvi Kulkarni', 'tanvi.kulkarni@student.edu', 'student123', 'Information Technology', 3, 'B');

        INSERT INTO student_subject (student_id, subject_id) VALUES
        (1, 1), (1, 2), (1, 3), (1, 5),
        (2, 1), (2, 2), (2, 3), (2, 5),
        (3, 1), (3, 2), (3, 3), (3, 5),
        (4, 1), (4, 2), (4, 3), (4, 5),
        (5, 1), (5, 2), (5, 3), (5, 5),
        (6, 1), (6, 2), (6, 3), (6, 5),
        (7, 1), (7, 3), (7, 4), (7, 5),
        (8, 1), (8, 3), (8, 4), (8, 5),
        (9, 1), (9, 3), (9, 4), (9, 5),
        (10, 1), (10, 3), (10, 4), (10, 5);
        """)

        # Populate attendance for dates
        dates = ['2026-08-01', '2026-08-03', '2026-08-04', '2026-08-06', '2026-08-08', '2026-08-10', 
                 '2026-08-11', '2026-08-13', '2026-08-15', '2026-08-17', '2026-08-18', '2026-08-20']
        patterns = {
            1:  ['PRESENT']*6 + ['ABSENT'] + ['PRESENT']*5,
            2:  ['PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'PRESENT', 'PRESENT'],
            3:  ['PRESENT', 'ABSENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT'],
            4:  ['ABSENT', 'PRESENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'PRESENT', 'ABSENT', 'ABSENT', 'PRESENT', 'PRESENT'],
            5:  ['ABSENT', 'PRESENT', 'ABSENT', 'ABSENT', 'PRESENT', 'ABSENT', 'PRESENT', 'ABSENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT'],
            6:  ['PRESENT', 'PRESENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'PRESENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT'],
            7:  ['ABSENT', 'ABSENT', 'PRESENT', 'ABSENT', 'PRESENT', 'ABSENT', 'ABSENT', 'PRESENT', 'ABSENT', 'ABSENT', 'PRESENT', 'PRESENT'],
            8:  ['PRESENT']*7 + ['ABSENT'] + ['PRESENT']*4,
            9:  ['PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT'],
            10: ['PRESENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT', 'ABSENT', 'PRESENT', 'PRESENT'],
        }
        for s_id, status_list in patterns.items():
            for d, st in zip(dates, status_list):
                cursor.execute("INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES (?, 1, ?, ?, 1)",
                               (s_id, d, st))

        conn.commit()
    conn.close()


def get_db_connection():
    """Get active database connection (Oracle or fallback)."""
    global DB_MODE
    if DB_MODE == "ORACLE" or (DB_MODE == "UNCHECKED" and ORACLEDB_AVAILABLE):
        try:
            if ORACLE_CONFIG_DIR and os.path.exists(ORACLE_CONFIG_DIR):
                conn = oracledb.connect(
                    user=ORACLE_USER,
                    password=ORACLE_PASSWORD,
                    dsn=ORACLE_DSN,
                    config_dir=ORACLE_CONFIG_DIR
                )
            else:
                conn = oracledb.connect(
                    user=ORACLE_USER,
                    password=ORACLE_PASSWORD,
                    dsn=ORACLE_DSN
                )
            DB_MODE = "ORACLE"
            return conn, "ORACLE"
        except Exception as e:
            if DB_MODE == "UNCHECKED":
                print(f"[NOTE] Oracle DB offline or unreachable ({e}). Using local database engine for immediate responsiveness.")
                DB_MODE = "SQLITE_FALLBACK"
                init_sqlite_fallback()
            elif DB_MODE == "ORACLE":
                raise e

    init_sqlite_fallback()
    conn = sqlite3.connect(SQLITE_DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn, "SQLITE_FALLBACK"


def execute_query(sql: str, params=None):
    """Executes a SELECT query and returns a list of dictionary rows."""
    conn, mode = get_db_connection()
    try:
        cursor = conn.cursor()
        # Adapt parameter placeholder if needed
        if mode == "SQLITE_FALLBACK":
            # Convert :name or :1 to ? if needed
            if params is None:
                cursor.execute(sql)
            elif isinstance(params, dict):
                cursor.execute(sql, params)
            elif isinstance(params, (list, tuple)):
                cursor.execute(sql, params)
            rows = cursor.fetchall()
            # Convert Row to dict
            return [dict(ix) for ix in rows]
        else:
            if params is None:
                cursor.execute(sql)
            elif isinstance(params, dict):
                cursor.execute(sql, params)
            elif isinstance(params, (list, tuple)):
                cursor.execute(sql, params)
            columns = [col[0].lower() for col in cursor.description] if cursor.description else []
            rows = cursor.fetchall()
            return [dict(zip(columns, row)) for row in rows]
    finally:
        conn.close()


def execute_scalar(sql: str, params=None):
    """Executes a SELECT query returning a single scalar value."""
    conn, mode = get_db_connection()
    try:
        cursor = conn.cursor()
        if params is None:
            cursor.execute(sql)
        else:
            cursor.execute(sql, params)
        row = cursor.fetchone()
        return row[0] if row else None
    finally:
        conn.close()


def execute_dml(sql: str, params=None):
    """Executes an INSERT, UPDATE, or DELETE statement and commits."""
    conn, mode = get_db_connection()
    try:
        cursor = conn.cursor()
        if params is None:
            cursor.execute(sql)
        else:
            cursor.execute(sql, params)
        conn.commit()
        last_id = getattr(cursor, 'lastrowid', None)
        return last_id
    finally:
        conn.close()


def call_calculate_attendance(student_id: int, subject_id: int):
    """Invokes the CALCULATE_ATTENDANCE PL/SQL procedure or local equivalent."""
    conn, mode = get_db_connection()
    try:
        cursor = conn.cursor()
        if mode == "ORACLE":
            cursor.callproc("calculate_attendance", [student_id, subject_id])
            conn.commit()
        else:
            # Replicate procedure logic
            cursor.execute("SELECT COUNT(*), COALESCE(SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END), 0), COALESCE(SUM(CASE WHEN status='ABSENT' THEN 1 ELSE 0 END), 0) FROM attendance WHERE student_id = ? AND subject_id = ?", (student_id, subject_id))
            tot, pres, absn = cursor.fetchone()
            pct = round((pres / tot) * 100, 2) if tot > 0 else 0.0
            cursor.execute("""
            INSERT INTO attendance_summary (student_id, subject_id, total_classes, present_count, absent_count, attendance_percentage, last_calculated)
            VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
            ON CONFLICT(student_id, subject_id) DO UPDATE SET
                total_classes = excluded.total_classes,
                present_count = excluded.present_count,
                absent_count = excluded.absent_count,
                attendance_percentage = excluded.attendance_percentage,
                last_calculated = CURRENT_TIMESTAMP
            """, (student_id, subject_id, tot, pres, absn, pct))
            conn.commit()
    finally:
        conn.close()
