/**
 * Students Management Controller
 */

let allSubjects = [];

document.addEventListener('DOMContentLoaded', async () => {
  const user = Session.requireAuth('faculty');
  if (!user) return;
  setupNavbarUser(user);

  await loadSubjectOptions();
  await loadStudents();

  // Check URL param if ?action=add was passed
  const params = new URLSearchParams(window.location.search);
  if (params.get('action') === 'add') {
    openAddStudentModal();
  }
});

async function loadSubjectOptions() {
  try {
    allSubjects = await apiFetch('/subjects');
    const container = document.getElementById('subjectCheckboxes');
    if (!container) return;
    container.innerHTML = allSubjects.map(s => `
      <label style="display: flex; align-items: center; gap: 0.4rem; font-size: 0.8rem; cursor: pointer;">
        <input type="checkbox" name="subjectCheck" value="${s.subject_id}">
        <span><strong>${s.subject_code}</strong>: ${s.subject_name}</span>
      </label>
    `).join('');
  } catch (err) {
    console.error("Failed to load subjects for enrollment:", err);
  }
}

async function loadStudents() {
  clearAlert('pageAlert');
  const dept = document.getElementById('filterDept').value;
  const year = document.getElementById('filterYear').value;
  const section = document.getElementById('filterSection').value;
  const search = document.getElementById('filterSearch').value.trim();

  let query = '/students?';
  const params = new URLSearchParams();
  if (dept) params.append('department', dept);
  if (year) params.append('year_of_study', year);
  if (section) params.append('section', section);
  if (search) params.append('search', search);

  try {
    const students = await apiFetch(`/students?${params.toString()}`);
    const tbody = document.getElementById('studentsTbody');

    if (!students || students.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="empty-state">No matching students found.</td></tr>';
      return;
    }

    tbody.innerHTML = students.map(s => `
      <tr>
        <td><strong>#${s.student_id}</strong></td>
        <td><strong>${s.student_name}</strong></td>
        <td>${s.email}</td>
        <td>${s.department}</td>
        <td>Year ${s.year_of_study}</td>
        <td><span class="badge" style="background:#f1f5f9; color:#334155; border:1px solid #cbd5e1;">Sec ${s.section}</span></td>
        <td style="text-align: right; white-space: nowrap;">
          <button class="btn btn-outline btn-sm" onclick="openEditStudentModal(${s.student_id})">Edit</button>
          <button class="btn btn-danger btn-sm" onclick="handleDeleteStudent(${s.student_id}, '${s.student_name}')">Delete</button>
        </td>
      </tr>
    `).join('');
  } catch (err) {
    showAlert('pageAlert', `Failed to load students: ${err.message}`);
  }
}

function resetFilters() {
  document.getElementById('filterDept').value = '';
  document.getElementById('filterYear').value = '';
  document.getElementById('filterSection').value = '';
  document.getElementById('filterSearch').value = '';
  loadStudents();
}

function openAddStudentModal() {
  clearAlert('modalAlert');
  document.getElementById('studentId').value = '';
  document.getElementById('modalTitle').textContent = 'Add New Student';
  document.getElementById('inputName').value = '';
  document.getElementById('inputEmail').value = '';
  document.getElementById('inputPassword').value = '';
  document.getElementById('inputPassword').required = true;
  document.getElementById('pwdHelp').textContent = 'Required for new accounts.';

  // Uncheck all subjects
  document.querySelectorAll('input[name="subjectCheck"]').forEach(cb => cb.checked = false);

  document.getElementById('studentModal').classList.add('active');
}

async function openEditStudentModal(studentId) {
  clearAlert('modalAlert');
  try {
    const s = await apiFetch(`/students/${studentId}`);

    document.getElementById('studentId').value = s.student_id;
    document.getElementById('modalTitle').textContent = `Edit Student: ${s.student_name}`;
    document.getElementById('inputName').value = s.student_name;
    document.getElementById('inputEmail').value = s.email;
    document.getElementById('inputPassword').value = '';
    document.getElementById('inputPassword').required = false;
    document.getElementById('pwdHelp').textContent = 'Leave empty to keep existing password.';
    document.getElementById('inputDept').value = s.department;
    document.getElementById('inputYear').value = s.year_of_study;
    document.getElementById('inputSection').value = s.section;

    const enrolledIds = (s.enrolled_subjects || []).map(sub => sub.subject_id);
    document.querySelectorAll('input[name="subjectCheck"]').forEach(cb => {
      cb.checked = enrolledIds.includes(parseInt(cb.value));
    });

    document.getElementById('studentModal').classList.add('active');
  } catch (err) {
    showAlert('pageAlert', `Failed to load student details: ${err.message}`);
  }
}

function closeStudentModal() {
  document.getElementById('studentModal').classList.remove('active');
}

async function handleSaveStudent(e) {
  e.preventDefault();
  clearAlert('modalAlert');

  const studentId = document.getElementById('studentId').value;
  const isEdit = Boolean(studentId);

  const selectedSubjects = Array.from(document.querySelectorAll('input[name="subjectCheck"]:checked'))
    .map(cb => parseInt(cb.value));

  const payload = {
    student_name: document.getElementById('inputName').value.trim(),
    email: document.getElementById('inputEmail').value.trim(),
    department: document.getElementById('inputDept').value,
    year_of_study: parseInt(document.getElementById('inputYear').value),
    section: document.getElementById('inputSection').value,
    subject_ids: selectedSubjects
  };

  const passwordVal = document.getElementById('inputPassword').value;
  if (!isEdit) {
    if (!passwordVal) {
      showAlert('modalAlert', 'Password is required when creating a student.');
      return;
    }
    payload.password = passwordVal;
  } else if (passwordVal.trim()) {
    payload.password = passwordVal.trim();
  }

  const saveBtn = document.getElementById('btnSaveStudent');
  saveBtn.disabled = true;
  saveBtn.textContent = 'Saving...';

  try {
    if (isEdit) {
      await apiFetch(`/students/${studentId}`, {
        method: 'PUT',
        body: JSON.stringify(payload)
      });
      showAlert('pageAlert', 'Student record updated successfully.', 'success');
    } else {
      await apiFetch('/students', {
        method: 'POST',
        body: JSON.stringify(payload)
      });
      showAlert('pageAlert', 'New student enrolled successfully.', 'success');
    }

    closeStudentModal();
    loadStudents();
  } catch (err) {
    showAlert('modalAlert', err.message);
  } finally {
    saveBtn.disabled = false;
    saveBtn.textContent = 'Save Student';
  }
}

async function handleDeleteStudent(studentId, name) {
  if (!confirm(`Are you sure you want to delete student "${name}"? All associated attendance records will also be removed.`)) {
    return;
  }

  try {
    await apiFetch(`/students/${studentId}`, { method: 'DELETE' });
    showAlert('pageAlert', `Student ${name} deleted successfully.`, 'success');
    loadStudents();
  } catch (err) {
    showAlert('pageAlert', `Failed to delete student: ${err.message}`);
  }
}
