/**
 * Attendance Marking & Records Controller
 */

let enrolledStudents = [];

document.addEventListener('DOMContentLoaded', async () => {
  // If we are on mark-attendance.html
  if (document.getElementById('attDate')) {
    const user = Session.requireAuth('faculty');
    if (!user) return;
    setupNavbarUser(user);

    // Default to today's date
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('attDate').value = today;

    await loadSubjectDropdown();
  }
});

async function loadSubjectDropdown() {
  try {
    const subjects = await apiFetch('/subjects');
    const select = document.getElementById('attSubject');
    if (!select) return;

    select.innerHTML = '<option value="">-- Choose Subject --</option>' + 
      subjects.map(s => `<option value="${s.subject_id}">${s.subject_code} - ${s.subject_name}</option>`).join('');
  } catch (err) {
    showAlert('attendanceAlert', `Failed to load subjects: ${err.message}`);
  }
}

async function onFilterCriteriaChange() {
  clearAlert('attendanceAlert');
  const subjectId = document.getElementById('attSubject').value;
  const dateVal = document.getElementById('attDate').value;
  const rosterCard = document.getElementById('rosterCard');
  const emptyPrompt = document.getElementById('emptyPromptCard');

  if (!subjectId || !dateVal) {
    rosterCard.style.display = 'none';
    emptyPrompt.style.display = 'block';
    return;
  }

  try {
    const subDetails = await apiFetch(`/subjects/${subjectId}`);
    enrolledStudents = subDetails.students || [];

    if (enrolledStudents.length === 0) {
      rosterCard.style.display = 'block';
      emptyPrompt.style.display = 'none';
      document.getElementById('rosterTbody').innerHTML = '<tr><td colspan="5" class="empty-state">No students are currently enrolled in this subject.</td></tr>';
      document.getElementById('studentCountLabel').textContent = '(0 students)';
      return;
    }

    rosterCard.style.display = 'block';
    emptyPrompt.style.display = 'none';
    filterStudentListBySection();

  } catch (err) {
    showAlert('attendanceAlert', `Error loading class list: ${err.message}`);
  }
}

function filterStudentListBySection() {
  const section = document.getElementById('attSection').value;
  const filtered = section 
    ? enrolledStudents.filter(s => s.section.toUpperCase() === section.toUpperCase())
    : enrolledStudents;

  const tbody = document.getElementById('rosterTbody');
  document.getElementById('studentCountLabel').textContent = `(${filtered.length} students enrolled)`;

  if (filtered.length === 0) {
    tbody.innerHTML = '<tr><td colspan="5" class="empty-state">No students found in selected section.</td></tr>';
    return;
  }

  tbody.innerHTML = filtered.map(s => `
    <tr data-student-id="${s.student_id}">
      <td><strong>#${s.student_id}</strong></td>
      <td><strong>${s.student_name}</strong></td>
      <td>${s.department}</td>
      <td><span class="badge" style="background:#f1f5f9; color:#334155; border:1px solid #cbd5e1;">Sec ${s.section}</span></td>
      <td style="text-align: center;">
        <div class="status-switch">
          <input type="radio" id="st_pres_${s.student_id}" name="status_${s.student_id}" value="PRESENT" checked>
          <label for="st_pres_${s.student_id}" class="lbl-present">Present</label>

          <input type="radio" id="st_abs_${s.student_id}" name="status_${s.student_id}" value="ABSENT">
          <label for="st_abs_${s.student_id}" class="lbl-absent">Absent</label>
        </div>
      </td>
    </tr>
  `).join('');
}

function markAll(status) {
  const radios = document.querySelectorAll(`input[type="radio"][value="${status}"]`);
  radios.forEach(r => r.checked = true);
}

async function saveAttendance() {
  clearAlert('attendanceAlert');
  const user = Session.get();
  const subjectId = parseInt(document.getElementById('attSubject').value);
  const attDate = document.getElementById('attDate').value;
  const rows = document.querySelectorAll('#rosterTbody tr[data-student-id]');

  if (rows.length === 0) {
    showAlert('attendanceAlert', 'No students to record attendance for.');
    return;
  }

  const records = [];
  rows.forEach(tr => {
    const studentId = parseInt(tr.getAttribute('data-student-id'));
    const checked = tr.querySelector('input[type="radio"]:checked');
    if (checked) {
      records.push({
        student_id: studentId,
        status: checked.value
      });
    }
  });

  const payload = {
    subject_id: subjectId,
    attendance_date: attDate,
    marked_by: user ? user.user_id : null,
    records: records
  };

  const btn = document.getElementById('btnSaveAttendance');
  btn.disabled = true;
  btn.textContent = 'Saving to Oracle Database...';

  try {
    const res = await apiFetch('/attendance', {
      method: 'POST',
      body: JSON.stringify(payload)
    });

    showAlert('attendanceAlert', `✓ ${res.message} Attendance records saved and percentages updated via PL/SQL.`, 'success');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  } catch (err) {
    showAlert('attendanceAlert', `Error: ${err.message}`, 'error');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  } finally {
    btn.disabled = false;
    btn.textContent = 'SAVE ATTENDANCE';
  }
}

// -------------------------------------------------------
// Attendance Records Log Functions
// -------------------------------------------------------
async function initAttendanceRecordsPage() {
  const user = Session.requireAuth('faculty');
  if (!user) return;
  setupNavbarUser(user);

  await loadRecordFilterOptions();
  await loadRecords();
}

async function loadRecordFilterOptions() {
  try {
    const [students, subjects] = await Promise.all([
      apiFetch('/students'),
      apiFetch('/subjects')
    ]);

    const studentSelect = document.getElementById('filterRecordStudent');
    studentSelect.innerHTML = '<option value="">All Students</option>' + 
      students.map(s => `<option value="${s.student_id}">${s.student_name} (${s.section})</option>`).join('');

    const subjectSelect = document.getElementById('filterRecordSubject');
    subjectSelect.innerHTML = '<option value="">All Subjects</option>' + 
      subjects.map(s => `<option value="${s.subject_id}">${s.subject_code} - ${s.subject_name}</option>`).join('');
  } catch (err) {
    console.error("Filter options load error:", err);
  }
}

async function loadRecords() {
  clearAlert('recordsAlert');
  const dateVal = document.getElementById('filterRecordDate').value;
  const studentId = document.getElementById('filterRecordStudent').value;
  const subjectId = document.getElementById('filterRecordSubject').value;
  const statusVal = document.getElementById('filterRecordStatus').value;

  const params = new URLSearchParams();
  if (dateVal) params.append('date', dateVal);
  if (studentId) params.append('student_id', studentId);
  if (subjectId) params.append('subject_id', subjectId);
  if (statusVal) params.append('status_filter', statusVal);

  try {
    const records = await apiFetch(`/attendance?${params.toString()}`);
    const tbody = document.getElementById('recordsTbody');

    if (!records || records.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No matching attendance records found.</td></tr>';
      return;
    }

    tbody.innerHTML = records.map(r => {
      const badgeClass = r.status === 'PRESENT' ? 'badge-present' : 'badge-absent';
      return `
        <tr>
          <td>${r.attendance_date}</td>
          <td><strong>${r.student_name}</strong></td>
          <td><span class="badge" style="background:#f1f5f9; color:#334155; border:1px solid #cbd5e1;">Sec ${r.section}</span></td>
          <td><strong>${r.subject_code}</strong>: ${r.subject_name}</td>
          <td><span class="badge ${badgeClass}">${r.status}</span></td>
          <td style="color: var(--text-muted);">${r.marked_by_name || 'System Admin'}</td>
        </tr>
      `;
    }).join('');
  } catch (err) {
    showAlert('recordsAlert', `Failed to load records: ${err.message}`);
  }
}

function resetRecordFilters() {
  document.getElementById('filterRecordDate').value = '';
  document.getElementById('filterRecordStudent').value = '';
  document.getElementById('filterRecordSubject').value = '';
  document.getElementById('filterRecordStatus').value = '';
  loadRecords();
}
