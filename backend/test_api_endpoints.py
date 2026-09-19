"""
API Endpoints Automated Test Suite
Attendance Management System
"""

import sys
from pathlib import Path

# Add project root to sys.path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)

def run_tests():
    print("="*65)
    print("RUNNING FASTAPI ENDPOINTS & BUSINESS LOGIC TEST SUITE")
    print("="*65)

    # 1. Test Login - Faculty
    print("\n[Test 1] Faculty Login...")
    res = client.post("/api/login", json={
        "email": "rajesh.sharma@college.edu",
        "password": "faculty123",
        "role": "faculty"
    })
    assert res.status_code == 200, f"Faculty login failed: {res.text}"
    faculty_data = res.json()
    assert faculty_data["role"] == "faculty"
    print(f"   [PASSED] Welcome {faculty_data['name']} ({faculty_data['role']})")

    # 2. Test Login - Student
    print("\n[Test 2] Student Login...")
    res = client.post("/api/login", json={
        "email": "aarav.sharma@student.edu",
        "password": "student123",
        "role": "student"
    })
    assert res.status_code == 200, f"Student login failed: {res.text}"
    student_data = res.json()
    assert student_data["role"] == "student"
    print(f"   [PASSED] Welcome {student_data['name']} ({student_data['role']})")

    # 3. Test Login - Invalid Credentials
    print("\n[Test 3] Invalid Login Prevention...")
    res = client.post("/api/login", json={
        "email": "aarav.sharma@student.edu",
        "password": "wrongpassword",
        "role": "student"
    })
    assert res.status_code == 401, f"Expected 401, got {res.status_code}"
    print("   [PASSED] Wrong password correctly rejected with 401 Unauthorized.")

    # 4. Test Get Dashboard Stats
    print("\n[Test 4] Admin Dashboard Stats...")
    res = client.get("/api/reports/dashboard-stats")
    assert res.status_code == 200, f"Dashboard stats failed: {res.text}"
    stats = res.json()
    print(f"   [PASSED] Students: {stats['total_students']}, Subjects: {stats['total_subjects']}, Faculty: {stats['total_faculty']}")
    assert stats["total_students"] >= 10
    assert stats["total_subjects"] >= 5

    # 5. Test Get Students List & Filters
    print("\n[Test 5] Students API List & Filtering...")
    res = client.get("/api/students?department=Computer Science")
    assert res.status_code == 200
    cs_students = res.json()
    print(f"   [PASSED] Found {len(cs_students)} Computer Science students.")
    assert len(cs_students) > 0

    # 6. Test Mark Attendance & Duplicate Prevention
    print("\n[Test 6] Mark Attendance & Duplicate Constraint Enforcement...")
    test_date = "2026-09-01"
    mark_payload = {
        "subject_id": 1,
        "attendance_date": test_date,
        "marked_by": 1,
        "records": [
            {"student_id": 1, "status": "PRESENT"},
            {"student_id": 2, "status": "ABSENT"},
            {"student_id": 3, "status": "PRESENT"}
        ]
    }
    # First save should succeed
    res = client.post("/api/attendance", json=mark_payload)
    assert res.status_code == 201, f"Mark attendance failed: {res.text}"
    print("   [PASSED] First attendance batch recorded successfully.")

    # Second save on same date & subject for same students should FAIL with 409 Conflict
    res_dup = client.post("/api/attendance", json=mark_payload)
    assert res_dup.status_code == 409, f"Expected 409 Conflict, got: {res_dup.status_code} - {res_dup.text}"
    print(f"   [PASSED] Duplicate attendance blocked with 409: {res_dup.json()['detail']}")

    # 7. Test Attendance Reports from View
    print("\n[Test 7] Attendance Reports (View & Categories)...")
    res = client.get("/api/reports/summary?subject_id=1")
    assert res.status_code == 200
    report_items = res.json()
    assert len(report_items) > 0
    print(f"   [PASSED] Generated {len(report_items)} student subject reports.")
    for item in report_items[:3]:
        print(f"     - {item['student_name']}: {item['attendance_percentage']}% ({item['attendance_category']})")

    # 8. Test Student Personal Report
    print("\n[Test 8] Student Personal Report Overview...")
    res = client.get("/api/reports/student/1")
    assert res.status_code == 200
    st_rep = res.json()
    print(f"   [PASSED] Student 1 Overall: {st_rep['overall']['attendance_percentage']}% ({st_rep['overall']['attendance_category']})")
    assert "subject_wise" in st_rep

    print("\n" + "="*65)
    print("ALL API ENDPOINTS & LOGIC TESTS PASSED SUCCESSFULLY!")
    print("="*65)

if __name__ == "__main__":
    run_tests()
