document.addEventListener('DOMContentLoaded', () => {
  const loanAmount = document.getElementById('loanAmount');
  const interestRate = document.getElementById('interestRate');
  const loanTenure = document.getElementById('loanTenure');

  const amountDisplay = document.getElementById('amountDisplay');
  const interestDisplay = document.getElementById('interestDisplay');
  const tenureDisplay = document.getElementById('tenureDisplay');

  const emiResult = document.getElementById('emiResult');
  const totalPaid = document.getElementById('totalPaid');

  const calculateBtn = document.getElementById('calculateBtn');
  let chart;

  loanAmount.oninput = () => amountDisplay.textContent = loanAmount.value;
  interestRate.oninput = () => interestDisplay.textContent = interestRate.value;
  loanTenure.oninput = () => tenureDisplay.textContent = loanTenure.value;

  calculateBtn.addEventListener('click', () => {
    // -------------------------------
    // 🔥 CHANGED: use correct API path
    // Instead of absolute "/api/calculate", we build a relative URL
    // that works when the app is served under /emi-calc.
    // window.location.pathname gives us the current base path.
    // -------------------------------
    const basePath = window.location.pathname.replace(/\/$/, ''); // remove trailing slash if any
    const apiUrl = `${basePath}/api/calculate`; // e.g. /emi-calc/api/calculate

    fetch(apiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        amount: parseFloat(loanAmount.value),
        interest: parseFloat(interestRate.value),
        years: parseInt(loanTenure.value)
      })
    })
    .then(res => {
      if (!res.ok) {
        console.error('API error', res.status, res.statusText);
        throw new Error(`API responded with status ${res.status}`);
      }
      return res.json();
    })
    .then(data => {
      // -------------------------------
      // ✅ No change: update results as before
      // -------------------------------
      emiResult.textContent = data.emi.toFixed(2);
      totalPaid.textContent = data.total_payment.toFixed(2);

      if (chart) chart.destroy();
      const ctx = document.getElementById('loanChart').getContext('2d');
      chart = new Chart(ctx, {
        type: 'pie',
        data: {
          labels: ['Principal', 'Total Interest'],
          datasets: [{
            data: [data.principal, data.total_interest],
            backgroundColor: ['#4b0082', '#7c3aed']
          }]
        },
        options: { responsive: true }
      });
    })
    .catch(err => {
      console.error('Error calling API:', err);
      alert('Failed to calculate EMI. Please try again later.');
    });
  });
});
