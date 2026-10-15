// Sync slider and text input for Investment
document.getElementById('investment-slider').addEventListener('input', e => {
  document.getElementById('investment').value = e.target.value;
});
document.getElementById('investment').addEventListener('input', e => {
  document.getElementById('investment-slider').value = e.target.value;
});

// Sync slider and text input for Rate
document.getElementById('rate-slider').addEventListener('input', e => {
  document.getElementById('rate').value = e.target.value;
});
document.getElementById('rate').addEventListener('input', e => {
  document.getElementById('rate-slider').value = e.target.value;
});

// Sync slider and text input for Years
document.getElementById('years-slider').addEventListener('input', e => {
  document.getElementById('years').value = e.target.value;
});
document.getElementById('years').addEventListener('input', e => {
  document.getElementById('years-slider').value = e.target.value;
});

// On clicking calculate button
document.getElementById('calculate').addEventListener('click', () => {
  const investment = parseFloat(document.getElementById('investment').value);
  const rate = parseFloat(document.getElementById('rate').value);
  const years = parseInt(document.getElementById('years').value);

  // 🔥 UPDATED fetch URL to work with Ingress path
  // Earlier it was: fetch('/api/calculate', { ... })
  // Now prefixed with /sip-calc so Ingress forwards correctly
  fetch('/sip-calc/api/calculate', {   // ✅ UPDATED
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ investment, rate, years })
  })
  .then(res => res.json())
  .then(data => {
    document.getElementById('invested').textContent = data.invested;
    document.getElementById('returns').textContent = data.returns;
    document.getElementById('total').textContent = data.total;
    renderChart(data.invested, data.returns);
  });
});

// Render pie chart for breakup
function renderChart(invested, returns) {
  const ctx = document.getElementById('breakupChart').getContext('2d');
  if (window.breakupChart) window.breakupChart.destroy();
  window.breakupChart = new Chart(ctx, {
    type: 'pie',
    data: {
      labels: ['Invested', 'Returns'],
      datasets: [{
        data: [invested, returns],
        backgroundColor: ['#4b0082', '#7c3aed']
      }]
    }
  });
}
