/**
 * Subjects Management Controller
 */

document.addEventListener('DOMContentLoaded', async () => {
  const user = Session.requireAuth('faculty');
  if (!user) return;
  setupNavbarUser(user);

  await loadSubjects();

  // Check URL param if ?action=add was passed
  const params = new URLSearchParams(window.location.search);
  if (params.get('action') === 'add') {
    openAddSubjectModal();
  }
});

async function loadSubjects() {
  clearAlert('pageAlert');
  try {
    const subjects = await apiFetch('/subjects');
    const tbody = document.getElementById('subjectsTbody');

    if (!subjects || subjects.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No subjects found in curriculum.</td></tr>';
      return;
    }

    tbody.innerHTML = subjects.map(s => `
      <tr>
        <td><strong>${s.subject_code}</strong></td>
        <td>${s.subject_name}</td>
        <td>${s.department}</td>
        <td>Year ${s.year_of_study}</td>
        <td>Semester ${s.semester}</td>
        <td style="text-align: right; white-space: nowrap;">
          <button class="btn btn-outline btn-sm" onclick="openEditSubjectModal(${s.subject_id})">Edit</button>
          <button class="btn btn-danger btn-sm" onclick="handleDeleteSubject(${s.subject_id}, '${s.subject_code}')">Delete</button>
        </td>
      </tr>
    `).join('');
  } catch (err) {
    showAlert('pageAlert', `Failed to load subjects: ${err.message}`);
  }
}

function openAddSubjectModal() {
  clearAlert('modalAlert');
  document.getElementById('subjectId').value = '';
  document.getElementById('modalTitle').textContent = 'Add New Subject';
  document.getElementById('inputCode').value = '';
  document.getElementById('inputName').value = '';
  document.getElementById('inputDept').value = 'Computer Science';
  document.getElementById('inputYear').value = '3';
  document.getElementById('inputSemester').value = '5';

  document.getElementById('subjectModal').classList.add('active');
}

async function openEditSubjectModal(subjectId) {
  clearAlert('modalAlert');
  try {
    const s = await apiFetch(`/subjects/${subjectId}`);

    document.getElementById('subjectId').value = s.subject_id;
    document.getElementById('modalTitle').textContent = `Edit Subject: ${s.subject_code}`;
    document.getElementById('inputCode').value = s.subject_code;
    document.getElementById('inputName').value = s.subject_name;
    document.getElementById('inputDept').value = s.department;
    document.getElementById('inputYear').value = s.year_of_study;
    document.getElementById('inputSemester').value = s.semester;

    document.getElementById('subjectModal').classList.add('active');
  } catch (err) {
    showAlert('pageAlert', `Failed to load subject details: ${err.message}`);
  }
}

function closeSubjectModal() {
  document.getElementById('subjectModal').classList.remove('active');
}

async function handleSaveSubject(e) {
  e.preventDefault();
  clearAlert('modalAlert');

  const subjectId = document.getElementById('subjectId').value;
  const isEdit = Boolean(subjectId);

  const payload = {
    subject_code: document.getElementById('inputCode').value.trim().toUpperCase(),
    subject_name: document.getElementById('inputName').value.trim(),
    department: document.getElementById('inputDept').value,
    year_of_study: parseInt(document.getElementById('inputYear').value),
    semester: parseInt(document.getElementById('inputSemester').value)
  };

  const saveBtn = document.getElementById('btnSaveSubject');
  saveBtn.disabled = true;
  saveBtn.textContent = 'Saving...';

  try {
    if (isEdit) {
      await apiFetch(`/subjects/${subjectId}`, {
        method: 'PUT',
        body: JSON.stringify(payload)
      });
      showAlert('pageAlert', 'Subject updated successfully.', 'success');
    } else {
      await apiFetch('/subjects', {
        method: 'POST',
        body: JSON.stringify(payload)
      });
      showAlert('pageAlert', 'New subject added to curriculum.', 'success');
    }

    closeSubjectModal();
    loadSubjects();
  } catch (err) {
    showAlert('modalAlert', err.message);
  } finally {
    saveBtn.disabled = false;
    saveBtn.textContent = 'Save Subject';
  }
}

async function handleDeleteSubject(subjectId, code) {
  if (!confirm(`Are you sure you want to delete subject "${code}"? All enrolled student mappings and attendance logs for this subject will be removed.`)) {
    return;
  }

  try {
    await apiFetch(`/subjects/${subjectId}`, { method: 'DELETE' });
    showAlert('pageAlert', `Subject ${code} deleted successfully.`, 'success');
    loadSubjects();
  } catch (err) {
    showAlert('pageAlert', `Failed to delete subject: ${err.message}`);
  }
}
