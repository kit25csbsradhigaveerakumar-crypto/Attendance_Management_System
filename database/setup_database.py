"""
Oracle Database Setup & Verification Script
Attendance Management System
------------------------------------------
Executes schema.sql, views.sql, procedures.sql, and sample_data.sql
against the configured Oracle Database instance.
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env
env_path = Path(__file__).resolve().parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

ORACLE_USER = os.getenv("ORACLE_USER", "attendance_admin")
ORACLE_PASSWORD = os.getenv("ORACLE_PASSWORD", "oracle")
ORACLE_DSN = os.getenv("ORACLE_DSN", "localhost:1521/XEPDB1")
ORACLE_CONFIG_DIR = os.getenv("ORACLE_CONFIG_DIR")

try:
    import oracledb
except ImportError:
    print("Error: python-oracledb library is not installed. Run: pip install oracledb")
    sys.exit(1)


def get_connection():
    """Establish Oracle connection in Thin mode."""
    print(f"Connecting to Oracle DB as '{ORACLE_USER}' on '{ORACLE_DSN}'...")
    if ORACLE_CONFIG_DIR and os.path.exists(ORACLE_CONFIG_DIR):
        return oracledb.connect(
            user=ORACLE_USER,
            password=ORACLE_PASSWORD,
            dsn=ORACLE_DSN,
            config_dir=ORACLE_CONFIG_DIR
        )
    return oracledb.connect(
        user=ORACLE_USER,
        password=ORACLE_PASSWORD,
        dsn=ORACLE_DSN
    )


def execute_sql_file(cursor, file_path: Path):
    """Read and execute statements from an SQL script."""
    print(f"\n---> Executing {file_path.name}...")
    if not file_path.exists():
        print(f"File not found: {file_path}")
        return False

    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Split by standard slash '/' for PL/SQL blocks or ';' for single DDL/DML
    # Clean handling for PL/SQL blocks vs standard SQL
    raw_blocks = content.split("\n/")
    for raw_block in raw_blocks:
        block = raw_block.strip()
        if not block:
            continue

        # If it's a PL/SQL block (starts with BEGIN or CREATE OR REPLACE PROCEDURE/FUNCTION/TRIGGER)
        upper_block = block.upper()
        if upper_block.startswith("BEGIN") or upper_block.startswith("CREATE OR REPLACE PROCEDURE") or upper_block.startswith("DECLARE"):
            try:
                cursor.execute(block)
                print(f"   [OK] Executed PL/SQL block ({block.splitlines()[0][:50]}...)")
            except Exception as e:
                print(f"   [WARN/ERROR] PL/SQL error: {e}")
        else:
            # Split standard statements by ';'
            statements = block.split(";")
            for stmt in statements:
                stmt_clean = stmt.strip()
                # Remove single-line comments at start
                lines = [l for l in stmt_clean.splitlines() if not l.strip().startswith("--")]
                sql = "\n".join(lines).strip()
                if not sql:
                    continue
                try:
                    cursor.execute(sql)
                    first_line = sql.splitlines()[0][:55]
                    print(f"   [OK] {first_line}")
                except Exception as e:
                    err_msg = str(e)
                    # Ignore table does not exist on drop
                    if "ORA-00942" in err_msg:
                        pass
                    else:
                        print(f"   [NOTE] Statement: {sql[:40]}... -> {e}")

    return True


def verify_database(cursor):
    """Run verification checks on tables, view, and procedure."""
    print("\n" + "="*60)
    print("RUNNING DATABASE VERIFICATION CHECKS")
    print("="*60)

    # 1. Count checks
    tables = ['student', 'faculty', 'subject', 'student_subject', 'attendance', 'attendance_summary']
    for t in tables:
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {t}")
            cnt = cursor.fetchone()[0]
            print(f"   Table '{t}': {cnt} records found.")
        except Exception as e:
            print(f"   Table '{t}' check failed: {e}")

    # 2. View check
    print("\nTesting STUDENT_ATTENDANCE_VIEW...")
    try:
        cursor.execute("""
            SELECT student_name, subject_name, total_classes, present_count, absent_count, attendance_percentage, attendance_category
            FROM student_attendance_view
            FETCH FIRST 5 ROWS ONLY
        """)
        rows = cursor.fetchall()
        print(f"   View successfully returned {len(rows)} sample rows:")
        for r in rows:
            print(f"     - {r[0]} | {r[1]} | Tot: {r[2]} | Pres: {r[3]} | {r[5]}% | {r[6]}")
    except Exception as e:
        print(f"   View check failed: {e}")

    # 3. PL/SQL Procedure check
    print("\nTesting CALCULATE_ATTENDANCE PL/SQL Procedure...")
    try:
        # Call procedure for student 1, subject 1
        cursor.callproc("calculate_attendance", [1, 1])
        cursor.execute("SELECT total_classes, present_count, attendance_percentage FROM attendance_summary WHERE student_id = 1 AND subject_id = 1")
        summary_row = cursor.fetchone()
        if summary_row:
            print(f"   Procedure output in attendance_summary for (Student 1, Subject 1):")
            print(f"     Total: {summary_row[0]}, Present: {summary_row[1]}, Pct: {summary_row[2]}%")
    except Exception as e:
        print(f"   Procedure test failed: {e}")


def main():
    print("="*60)
    print("ATTENDANCE MANAGEMENT SYSTEM - ORACLE DATABASE SETUP")
    print("="*60)
    base_dir = Path(__file__).resolve().parent

    try:
        conn = get_connection()
        conn.autocommit = True
        cursor = conn.cursor()
        print("Connected to Oracle Database successfully!")

        execute_sql_file(cursor, base_dir / "schema.sql")
        execute_sql_file(cursor, base_dir / "views.sql")
        execute_sql_file(cursor, base_dir / "procedures.sql")
        execute_sql_file(cursor, base_dir / "sample_data.sql")

        verify_database(cursor)

        cursor.close()
        conn.close()
        print("\n" + "="*60)
        print("ORACLE DATABASE SETUP & VERIFICATION COMPLETED SUCCESSFULLY!")
        print("="*60)

    except oracledb.Error as e:
        error_obj, = e.args
        print(f"\n[ORACLE CONNECTION ERROR]: {error_obj.message}")
        print("\nTroubleshooting tips:")
        print("1. Ensure Oracle Database service and listener are running.")
        print("2. Verify credentials in .env (ORACLE_USER, ORACLE_PASSWORD, ORACLE_DSN).")
        print("3. For local Oracle XE, default DSN is usually: localhost:1521/XEPDB1 or localhost:1521/XE")
        print("4. For Oracle 19c/21c, default DSN is usually: localhost:1521/orcl or localhost:1521/orclpdb")
        sys.exit(1)


if __name__ == "__main__":
    main()
