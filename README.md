# Attendance Management System

**Oracle Database + FastAPI + Web Application**  
*Designed for Oracle COE Academic Project Evaluation*

---

## 1. Project Overview

The **Attendance Management System** is a professional, database-driven academic web application built with a primary focus on **Oracle Database, Relational SQL, and PL/SQL**, integrated with a lightweight **Python FastAPI REST backend** and a clean, responsive **academic frontend (HTML5, CSS3, JavaScript)**.

The system enforces strict data integrity using Oracle primary keys, foreign keys, identity columns, check constraints, and unique constraints (preventing duplicate attendance for the same student, subject, and date). All statistics and reports are calculated directly from normalized relational tables using aggregate queries, an Oracle View (`STUDENT_ATTENDANCE_VIEW`), and a PL/SQL Procedure (`CALCULATE_ATTENDANCE`).

---

## 2. Technology Stack

- **Database**: Oracle Database (12c / 19c / 21c / 23ai / XE / Cloud Free Tier), Oracle SQL, PL/SQL
- **Database Driver**: `python-oracledb` (Thin Mode — runs directly without requiring Oracle Instant Client binaries)
- **Backend API**: Python 3.11+, FastAPI, Uvicorn, Pydantic
- **Frontend**: Vanilla HTML5, Responsive Academic CSS, Vanilla JavaScript (Fetch API)
- **Architecture**: RESTful Client-Server Architecture

---

## 3. Database Architecture & Schema

The relational schema is fully normalized and implemented in [`database/schema.sql`](database/schema.sql):

```
+---------------+        1:M        +--------------------+        M:1        +---------------+
|    STUDENT    | ----------------> |     ATTENDANCE     | <---------------- |    SUBJECT    |
+---------------+                   +--------------------+                   +---------------+
        |                                     ^                                      |
        | 1:M                                 | 1:M                                  | 1:M
        v                                     |                                      v
+--------------------+              +--------------------+              +--------------------+
|  STUDENT_SUBJECT   |              |      FACULTY       |              | ATTENDANCE_SUMMARY |
+--------------------+              +--------------------+              +--------------------+
```

### Table Definitions

1. **`STUDENT`**:
   - `student_id`: Primary Key (Identity)
   - `student_name`: Student full name
   - `email`: Institutional email address (`UNIQUE`)
   - `password`: Authentication credential
   - `department`: Academic department
   - `year_of_study`: Current cohort year (`CHECK (year_of_study BETWEEN 1 AND 4)`)
   - `section`: Classroom section (`A`, `B`)
   - `created_at`: Registration timestamp

2. **`FACULTY`**:
   - `faculty_id`: Primary Key (Identity)
   - `faculty_name`: Instructor name
   - `email`: Institutional email (`UNIQUE`)
   - `password`: Authentication credential
   - `department`: Academic department

3. **`SUBJECT`**:
   - `subject_id`: Primary Key (Identity)
   - `subject_code`: Curriculum code (`UNIQUE`, e.g., `CS301`)
   - `subject_name`: Course title (e.g., `Database Management Systems`)
   - `department`: Offering department
   - `year_of_study`: Eligible year (`CHECK 1-4`)
   - `semester`: Current semester (`CHECK 1-8`)

4. **`STUDENT_SUBJECT`**:
   - `student_id`: Foreign Key (`ON DELETE CASCADE`)
   - `subject_id`: Foreign Key (`ON DELETE CASCADE`)
   - Composite Primary Key: `(student_id, subject_id)`

5. **`ATTENDANCE`**:
   - `attendance_id`: Primary Key (Identity)
   - `student_id`: Foreign Key
   - `subject_id`: Foreign Key
   - `attendance_date`: Lecture date (`DATE`)
   - `status`: Attendance status (`CHECK (status IN ('PRESENT', 'ABSENT'))`)
   - `marked_by`: Foreign Key to `FACULTY(faculty_id)`
   - **Composite Unique Constraint**: `CONSTRAINT uq_student_subject_date UNIQUE (student_id, subject_id, attendance_date)` *(Guarantees duplicate attendance cannot be inserted)*

6. **`ATTENDANCE_SUMMARY`**:
   - `summary_id`: Primary Key (Identity)
   - `student_id`, `subject_id`: Foreign Keys with `UNIQUE (student_id, subject_id)`
   - `total_classes`, `present_count`, `absent_count`
   - `attendance_percentage`: Calculated percentage (`CHECK BETWEEN 0 AND 100`)
   - `last_calculated`: Timestamp maintained by the PL/SQL procedure

---

## 4. Oracle PL/SQL & Views

### 1. Oracle View: `STUDENT_ATTENDANCE_VIEW` ([`database/views.sql`](database/views.sql))
Combines students, subjects, attendance counts, exact percentage formula, and academic eligibility categories:
- **Good Attendance / Eligible**: $\ge 75\%$
- **Low Attendance**: $60\% \le \text{Percentage} < 75\%$
- **Critical Attendance**: $< 60\%$

```sql
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
    s.student_id, s.student_name, s.department, s.section,
    sub.subject_id, sub.subject_code, sub.subject_name;
```

### 2. PL/SQL Procedure: `CALCULATE_ATTENDANCE` ([`database/procedures.sql`](database/procedures.sql))
Accepts `(p_student_id, p_subject_id)`, aggregates lecture counts, computes percentage dynamically, and executes an atomic `MERGE INTO attendance_summary`.

---

## 5. Important SQL Queries

All 14 required queries are implemented and tested in [`database/queries.sql`](database/queries.sql):

1. **Display all students** (`ORDER BY department, year, section, name`)
2. **Display all subjects** (`ORDER BY year, semester, code`)
3. **Display attendance records for a student** (Joined with student, subject, and faculty)
4. **Display subject-wise attendance** (`GROUP BY student and subject`)
5. **Calculate total classes for a student** (`COUNT(attendance_id)`)
6. **Calculate present count** (`status = 'PRESENT'`)
7. **Calculate absent count** (`status = 'ABSENT'`)
8. **Calculate attendance percentage** (`(Present / Total) * 100`)
9. **Display students below 75%** (`HAVING percentage < 75`)
10. **Display students 75% or above** (`HAVING percentage >= 75`)
11. **Display average attendance for each subject** (`AVG(CASE WHEN status='PRESENT'...)`)
12. **Display present and absent counts for a particular date** (`WHERE attendance_date = DATE 'YYYY-MM-DD'`)
13. **Display attendance history for a student** (`ORDER BY date DESC`)
14. **Display students with critical attendance below 60%** (Queried from `student_attendance_view`)

---

## 6. Setup and Installation

### Prerequisites
- Python 3.10+ installed
- Oracle Database running locally or remotely (Oracle 19c, 21c, 23ai, XE, or Cloud Free Tier)
- Required Python libraries:
  ```bash
  pip install fastapi uvicorn oracledb pydantic python-dotenv
  ```

### Step 1: Configure Environment Variables
Copy `.env.example` to `.env` and configure your Oracle credentials:
```ini
ORACLE_USER=attendance_admin
ORACLE_PASSWORD=your_password
ORACLE_DSN=localhost:1521/XEPDB1
APP_HOST=127.0.0.1
APP_PORT=8000
```

### Step 2: Initialize the Oracle Database
Run the setup script to execute `schema.sql`, `views.sql`, `procedures.sql`, and `sample_data.sql`:
```bash
python database/setup_database.py
```

To run the SQL logic verification suite:
```bash
python database/test_sql_logic.py
```

### Step 3: Launch the Application
Start the FastAPI server:
```bash
python -m uvicorn backend.main:app --reload --port 8000
```
Open your browser at:
👉 **`http://127.0.0.1:8000`**

---

## 7. Demo Credentials for Evaluation

| Role | Email | Password | Access |
| :--- | :--- | :--- | :--- |
| **Faculty / Admin** | `rajesh.sharma@college.edu` | `faculty123` | Full admin dashboard, student & subject management, mark attendance, audit records, attendance reports |
| **Faculty (CS)** | `anita.desai@college.edu` | `faculty123` | Faculty access |
| **Faculty (IT)** | `vikram.patel@college.edu` | `faculty123` | Faculty access |
| **Student (High Att.)** | `aarav.sharma@student.edu` | `student123` | Student portal, 91.67% overall attendance, subject breakdown, history |
| **Student (Low Att.)** | `rohan.verma@student.edu` | `student123` | Student portal, 66.67% overall attendance (Low category) |
| **Student (Critical)** | `kabir.mehta@student.edu` | `student123` | Student portal, 50.00% overall attendance (Critical category) |

---

## 8. Testing Checklist

1. **Admin / Faculty Login**: Sign in with `rajesh.sharma@college.edu` / `faculty123`.
2. **Dashboard Cards**: Review active student counts, curriculum subjects, faculty, and today's attendance logs.
3. **Mark Attendance**:
   - Select today's date, Subject `CS301 - Database Management Systems`.
   - Toggle student attendance pills (Present/Absent).
   - Click **Save Attendance** to insert into the database.
   - Attempt saving again for the same date and subject &rarr; verifies the unique constraint blocks duplicate submissions with HTTP 409.
4. **Attendance Reports**: Navigate to Reports to view real-time calculations from `student_attendance_view`, filtered by category (Good, Low, Critical).
5. **Student Portal Login**: Sign in with `aarav.sharma@student.edu` / `student123` to view personalized overall attendance %, subject breakdowns, and chronological history.
