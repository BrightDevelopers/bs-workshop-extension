'use strict';

const EXTENSION_URL = 'http://localhost:8080/';
const POLL_INTERVAL_MS = 1000;

function updateUI(message, uptimeSeconds) {
  document.getElementById('message').textContent = message;
  document.getElementById('uptime').textContent = 'Uptime: ' + uptimeSeconds + 's';

  const status = document.getElementById('status');
  status.textContent = '● connected';
  status.className = '';
}

function showError() {
  document.getElementById('message').textContent = 'Extension not responding';
  document.getElementById('uptime').textContent = '';

  const status = document.getElementById('status');
  status.textContent = '● waiting for extension';
  status.className = 'error';
}

async function poll() {
  try {
    const response = await fetch(EXTENSION_URL);
    if (!response.ok) {
      showError();
      return;
    }
    const data = await response.json();
    updateUI(data.message, data.uptime_seconds);
  } catch (e) {
    showError();
  }
}

window.main = function main() {
  poll();
  setInterval(poll, POLL_INTERVAL_MS);
};
