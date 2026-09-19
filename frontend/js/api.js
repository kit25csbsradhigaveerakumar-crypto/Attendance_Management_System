/**
 * Common API Client & Session Helpers
 * Attendance Management System
 */

// Dynamically detect API URL whether accessed via http://127.0.0.1:8080, file://, or live server
let API_BASE = '/api';
if (window.location.protocol === 'file:' || (window.location.port && window.location.port !== '8080')) {
  API_BASE = 'http://127.0.0.1:8080/api';
}

const Session = {
  get() {
    try {
      const data = localStorage.getItem('attendance_user');
      return data ? JSON.parse(data) : null;
    } catch (e) {
      return null;
    }
  },

  set(user) {
    localStorage.setItem('attendance_user', JSON.stringify(user));
  },

  clear() {
    localStorage.removeItem('attendance_user');
  },

  requireAuth(requiredRole = null) {
    const user = this.get();
    if (!user) {
      window.location.href = 'index.html';
      return null;
    }

    if (requiredRole) {
      const userRole = user.role.toLowerCase();
      const targetRole = requiredRole.toLowerCase();

      if (targetRole === 'faculty' && userRole !== 'faculty' && userRole !== 'admin') {
        window.location.href = 'student-dashboard.html';
        return null;
      }

      if (targetRole === 'student' && userRole !== 'student') {
        window.location.href = 'admin-dashboard.html';
        return null;
      }
    }

    return user;
  }
};

async function apiFetch(endpoint, options = {}) {
  let url = `${API_BASE}${endpoint}`;
  const defaultHeaders = {
    'Content-Type': 'application/json'
  };

  const user = Session.get();
  if (user && user.token) {
    defaultHeaders['Authorization'] = `Bearer ${user.token}`;
  }

  let response;
  try {
    response = await fetch(url, {
      ...options,
      headers: {
        ...defaultHeaders,
        ...(options.headers || {})
      }
    });
  } catch (netErr) {
    // If relative /api failed, retry against http://127.0.0.1:8080/api
    if (!url.startsWith('http://127.0.0.1:8080')) {
      try {
        url = `http://127.0.0.1:8080/api${endpoint}`;
        response = await fetch(url, {
          ...options,
          headers: {
            ...defaultHeaders,
            ...(options.headers || {})
          }
        });
        API_BASE = 'http://127.0.0.1:8080/api';
      } catch (retryErr) {
        throw new Error("Unable to connect to the backend server. Please verify that the FastAPI server is running on http://127.0.0.1:8080.");
      }
    } else {
      throw new Error("Unable to connect to the backend server. Please verify that the FastAPI server is running on http://127.0.0.1:8080.");
    }
  }

  const isJson = (response.headers.get('content-type') || '').includes('application/json');
  const data = isJson ? await response.json() : await response.text();

  if (!response.ok) {
    const errorMsg = (data && data.detail) ? data.detail : (typeof data === 'string' ? data : 'An unexpected error occurred.');
    throw new Error(errorMsg);
  }

  return data;
}

function renderCategoryBadge(category, percentage) {
  const cat = (category || '').toLowerCase();
  const pctStr = percentage !== undefined ? `${percentage}%` : '';

  if (cat.includes('good') || percentage >= 75) {
    return `<span class="badge badge-good">${category || 'Good Attendance'}</span>`;
  } else if (cat.includes('low') || (percentage >= 60 && percentage < 75)) {
    return `<span class="badge badge-low">${category || 'Low Attendance'}</span>`;
  } else if (cat.includes('critical') || (percentage !== undefined && percentage < 60)) {
    return `<span class="badge badge-critical">${category || 'Critical Attendance'}</span>`;
  }
  return `<span class="badge badge-low">${category || 'N/A'}</span>`;
}

function showAlert(containerId, message, type = 'error') {
  const container = document.getElementById(containerId);
  if (!container) return;
  container.innerHTML = `
    <div class="alert alert-${type}">
      ${message}
    </div>
  `;
}

function clearAlert(containerId) {
  const container = document.getElementById(containerId);
  if (container) container.innerHTML = '';
}

function setupNavbarUser(user) {
  const nameEl = document.getElementById('navUserName');
  const roleEl = document.getElementById('navUserRole');
  if (nameEl && user) nameEl.textContent = user.name;
  if (roleEl && user) roleEl.textContent = user.role.toUpperCase();

  const logoutBtn = document.getElementById('btnLogout');
  if (logoutBtn) {
    logoutBtn.addEventListener('click', () => {
      Session.clear();
      window.location.href = 'index.html';
    });
  }
}
