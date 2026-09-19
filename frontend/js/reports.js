/**
 * Attendance Reports Controller
 * Powered by Oracle View: STUDENT_ATTENDANCE_VIEW
 */

document.addEventListener('DOMContentLoaded', async () => {
  const user = Session.requireAuth('faculty');
  if (!user) return;
  setupNavbarUser(user);

  await loadReportFilters();
  await loadReports();
});

async function loadReportFilters() {
  try {
    const [students, subjects] = await Promise.all([
      apiFetch('/students'),
      apiFetch('/subjects')
    ]);

    const studentSelect = document.getElementById('reportFilterStudent');
    studentSelect.innerHTML = '<option value="">All Students</option>' + 
      students.map(s => `<option value="${s.student_id}">${s.student_name} (${s.section})</option>`).join('');

    const subjectSelect = document.getElementById('reportFilterSubject');
    subjectSelect.innerHTML = '<option value="">All Subjects</option>' + 
      subjects.map(s => `<option value="${s.subject_id}">${s.subject_code} - ${s.subject_name}</option>`).join('');
  } catch (err) {
    console.error("Failed to load report filter dropdowns:", err);
  }
}

async function loadReports() {
  clearAlert('reportsAlert');
  const studentId = document.getElementById('reportFilterStudent').value;
  const subjectId = document.getElementById('reportFilterSubject').value;
  const category = document.getElementById('reportFilterCategory').value;

  const params = new URLSearchParams();
  if (studentId) params.append('student_id', studentId);
  if (subjectId) params.append('subject_id', subjectId);
  if (category) params.append('category', category);

  try {
    const records = await apiFetch(`/reports/summary?${params.toString()}`);
    const tbody = document.getElementById('reportsTbody');

    if (!records || records.length === 0) {
      tbody.innerHTML = '<tr><td colspan="9" class="empty-state">No attendance report records matching criteria.</td></tr>';
      return;
    }

    tbody.innerHTML = records.map(r => `
      <tr>
        <td><strong>${r.student_name}</strong></td>
        <td>${r.department}</td>
        <td><span class="badge" style="background:#f1f5f9; color:#334155; border:1px solid #cbd5e1;">Sec ${r.section}</span></td>
        <td><strong>${r.subject_code}</strong>: ${r.subject_name}</td>
        <td style="text-align: center;">${r.total_classes}</td>
        <td style="text-align: center; color: #065f46; font-weight: 600;">${r.present_count}</td>
        <td style="text-align: center; color: #9f1239; font-weight: 600;">${r.absent_count}</td>
        <td style="text-align: right; font-weight: 700;">${r.attendance_percentage.toFixed(2)}%</td>
        <td style="text-align: center;">${renderCategoryBadge(r.attendance_category, r.attendance_percentage)}</td>
      </tr>
    `).join('');
  } catch (err) {
    showAlert('reportsAlert', `Failed to load reports: ${err.message}`);
  }
}

function resetReportFilters() {
  document.getElementById('reportFilterStudent').value = '';
  document.getElementById('reportFilterSubject').value = '';
  document.getElementById('reportFilterCategory').value = '';
  loadReports();
}
