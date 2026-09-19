/**
 * Admin / Faculty Dashboard Controller
 */

document.addEventListener('DOMContentLoaded', async () => {
  const user = Session.requireAuth('faculty');
  if (!user) return;
  setupNavbarUser(user);

  loadDashboardData();
});

async function loadDashboardData() {
  try {
    const stats = await apiFetch('/reports/dashboard-stats');

    document.getElementById('statTotalStudents').textContent = stats.total_students ?? 0;
    document.getElementById('statTotalSubjects').textContent = stats.total_subjects ?? 0;
    document.getElementById('statTotalFaculty').textContent = stats.total_faculty ?? 0;
    document.getElementById('statTodayAttendance').textContent = stats.today_attendance_count ?? 0;

    const tbody = document.getElementById('recentAttendanceTbody');
    if (!stats.recent_records || stats.recent_records.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" class="empty-state">No attendance records logged yet.</td></tr>';
      return;
    }

    tbody.innerHTML = stats.recent_records.map(r => {
      const badgeClass = r.status === 'PRESENT' ? 'badge-present' : 'badge-absent';
      return `
        <tr>
          <td>${r.attendance_date}</td>
          <td><strong>${r.student_name}</strong></td>
          <td>${r.section}</td>
          <td>${r.subject_code}</td>
          <td><span class="badge ${badgeClass}">${r.status}</span></td>
        </tr>
      `;
    }).join('');

  } catch (err) {
    showAlert('dashboardAlert', `Failed to load dashboard metrics: ${err.message}`);
  }
}
