/**
 * Login Page Controller
 */

function selectRole(role) {
  document.getElementById('selectedRole').value = role;
  const facultyBtn = document.getElementById('btnRoleFaculty');
  const studentBtn = document.getElementById('btnRoleStudent');
  const emailInput = document.getElementById('loginEmail');

  if (role === 'faculty') {
    facultyBtn.classList.add('active');
    studentBtn.classList.remove('active');
    emailInput.placeholder = 'faculty@college.edu';
    if (!emailInput.value || emailInput.value.includes('student.edu')) {
      emailInput.value = 'rajesh.sharma@college.edu';
      document.getElementById('loginPassword').value = 'faculty123';
    }
  } else {
    studentBtn.classList.add('active');
    facultyBtn.classList.remove('active');
    emailInput.placeholder = 'student@student.edu';
    if (!emailInput.value || emailInput.value.includes('college.edu')) {
      emailInput.value = 'aarav.sharma@student.edu';
      document.getElementById('loginPassword').value = 'student123';
    }
  }
}

// Prefill default faculty credentials for easy evaluation
document.addEventListener('DOMContentLoaded', () => {
  const user = Session.get();
  if (user) {
    if (user.role === 'student') {
      window.location.href = 'student-dashboard.html';
      return;
    } else {
      window.location.href = 'admin-dashboard.html';
      return;
    }
  }
  selectRole('faculty');
});

async function handleLogin(e) {
  e.preventDefault();
  clearAlert('loginAlert');

  const email = document.getElementById('loginEmail').value.trim();
  const password = document.getElementById('loginPassword').value;
  const role = document.getElementById('selectedRole').value;
  const submitBtn = document.getElementById('btnSubmitLogin');

  if (!email || !password) {
    showAlert('loginAlert', 'Please enter both email and password.');
    return;
  }

  submitBtn.disabled = true;
  submitBtn.textContent = 'Signing in...';

  try {
    const data = await apiFetch('/login', {
      method: 'POST',
      body: JSON.stringify({ email, password, role })
    });

    Session.set(data);

    if (data.role === 'student') {
      window.location.href = 'student-dashboard.html';
    } else {
      window.location.href = 'admin-dashboard.html';
    }
  } catch (err) {
    showAlert('loginAlert', err.message);
    submitBtn.disabled = false;
    submitBtn.textContent = 'Sign In';
  }
}
