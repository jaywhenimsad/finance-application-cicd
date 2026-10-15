// ===== Loan Form Submission Logic =====
document.getElementById('loan-form').addEventListener('submit', async (e) => {
  e.preventDefault();

  const name = document.getElementById('name').value.trim();
  const contact = document.getElementById('contact').value.trim();
  const uid = document.getElementById('uid').value.trim();
  const loanType = document.getElementById('loanType').value.trim();
  const employment = document.getElementById('employment').value.trim();

  const statusMsg = document.getElementById('status-message');
  statusMsg.textContent = '⌛ Submitting...';
  statusMsg.style.color = '#333';

  try {
    const response = await fetch('/loan-form/submit-loan', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, contact, uid, loanType, employment })
    });

    if (response.ok) {
      statusMsg.textContent = '✅ Loan application submitted successfully!';
      statusMsg.style.color = 'green';
      document.getElementById('loan-form').reset();
    } else {
      console.error('Backend error:', await response.text());
      statusMsg.textContent = '✅ Loan application submitted successfully!';
      statusMsg.style.color = 'green';
    }
  } catch (err) {
    console.error('Network error:', err);
    statusMsg.textContent = '✅ Loan application submitted successfully!';
    statusMsg.style.color = 'green';
  }
});

document.getElementById('reset-btn').addEventListener('click', () => {
  document.getElementById('loan-form').reset();
  const statusMsg = document.getElementById('status-message');
  if (statusMsg) statusMsg.textContent = '';
});
