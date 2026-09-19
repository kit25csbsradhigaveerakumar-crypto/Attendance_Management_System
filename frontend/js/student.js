/**
 * Student Portal Controller
 */

document.addEventListener('DOMContentLoaded', async () => {
  if (document.getElementById('welcomeTitle')) {
    const user = Session.requireAuth('student');
    if (!user) return;
    setupNavbarUser(user);

    await loadStudentDashboard(user.user_id);
  }
});

async function loadStudentDashboard(studentId) {
  clearAlert('studentAlert');
  try {
    const data = await apiFetch(`/reports/student/${studentId}`);

    document.getElementById('welcomeTitle').textContent = `Welcome, ${data.student.student_name}`;
    document.getElementById('studentMetaInfo').textContent = `${data.student.department} • Year ${data.student.year_of_study} • Section ${data.student.section}`;

    const ov = data.overall;
    document.getElementById('statOverallPct').textContent = `${ov.attendance_percentage.toFixed(2)}%`;
    document.getElementById('statTotalSubjects').textContent = ov.total_subjects;
    document.getElementById('statAttended').textContent = ov.classes_attended;
    document.getElementById('statAbsent').textContent = ov.classes_absent;
    document.getElementById('statCategoryBadge').innerHTML = renderCategoryBadge(ov.attendance_category, ov.attendance_percentage);

    const tbody = document.getElementById('studentSubjectTbody');
    if (!data.subject_wise || data.subject_wise.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="empty-state">You are not enrolled in any subjects yet.</td></tr>';
      return;
    }

    tbody.innerHTML = data.subject_wise.map(s => `
      <tr>
        <td><strong>${s.subject_code}</strong></td>
        <td>${s.subject_name}</td>
        <td style="text-align: center;">${s.total_classes}</td>
        <td style="text-align: center; color: #059669; font-weight: 600;">${s.present_count}</td>
        <td style="text-align: center; color: #dc2626; font-weight: 600;">${s.absent_count}</td>
        <td style="text-align: right; font-weight: 700;">${s.attendance_percentage.toFixed(2)}%</td>
        <td style="text-align: center;">${renderCategoryBadge(s.attendance_category, s.attendance_percentage)}</td>
      </tr>
    `).join('');

  } catch (err) {
    showAlert('studentAlert', `Failed to load dashboard: ${err.message}`);
  }
}

// -------------------------------------------------------
// Student Attendance History Page Controller
// -------------------------------------------------------
async function initStudentAttendanceHistoryPage() {
  const user = Session.requireAuth('student');
  if (!user) return;
  setupNavbarUser(user);

  await loadStudentReportSummary(user.user_id);
  await loadStudentEnrolledSubjects(user.user_id);
  await loadStudentAttendanceHistory();
}

async function loadStudentReportSummary(studentId) {
  try {
    const data = await apiFetch(`/reports/student/${studentId}`);
    const ov = data.overall;
    document.getElementById('historyOverallPct').textContent = `${ov.attendance_percentage.toFixed(2)}%`;
    document.getElementById('historyCategoryTag').innerHTML = renderCategoryBadge(ov.attendance_category, ov.attendance_percentage);
  } catch (err) {
    console.error("Summary fetch error:", err);
  }
}

async function loadStudentEnrolledSubjects(studentId) {
  try {
    const student = await apiFetch(`/students/${studentId}`);
    const select = document.getElementById('historySubjectFilter');
    if (!select) return;

    select.innerHTML = '<option value="">All Enrolled Subjects</option>' +
      (student.enrolled_subjects || []).map(s => `<option value="${s.subject_id}">${s.subject_code} - ${s.subject_name}</option>`).join('');
  } catch (err) {
    console.error("Enrolled subjects fetch error:", err);
  }
}

async function loadStudentAttendanceHistory() {
  clearAlert('studentHistoryAlert');
  const user = Session.get();
  if (!user) return;

  const subjectId = document.getElementById('historySubjectFilter').value;
  const params = new URLSearchParams();
  if (subjectId) params.append('subject_id', subjectId);

  try {
    const records = await apiFetch(`/attendance/student/${user.user_id}?${params.toString()}`);
    const tbody = document.getElementById('studentHistoryTbody');

    if (!records || records.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" class="empty-state">No attendance records found for this selection.</td></tr>';
      return;
    }

    tbody.innerHTML = records.map(r => {
      const badgeClass = r.status === 'PRESENT' ? 'badge-present' : 'badge-absent';
      return `
        <tr>
          <td>${r.attendance_date}</td>
          <td><strong>${r.subject_code}</strong></td>
          <td>${r.subject_name}</td>
          <td style="text-align: center;"><span class="badge ${badgeClass}">${r.status}</span></td>
          <td style="color: var(--text-muted);">${r.marked_by || 'Course Faculty'}</td>
        </tr>
      `;
    }).join('');
  } catch (err) {
    showAlert('studentHistoryAlert', `Failed to load attendance history: ${err.message}`);
  }
}

function resetHistoryFilter() {
  document.getElementById('historySubjectFilter').value = '';
  loadStudentAttendanceHistory();
}
