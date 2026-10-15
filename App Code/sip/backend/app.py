from flask import Flask, request, jsonify
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
@app.route('/api/calculate', methods=['POST'])
def calculate():
    data = request.get_json()
    investment = float(data['investment'])
    rate = float(data['rate']) / 100 / 12
    months = int(data['years']) * 12
    fv = investment * (((1 + rate) ** months - 1) / rate) * (1 + rate)
    invested = investment * months
    returns = fv - invested
    return jsonify({'invested': round(invested, 2), 'returns': round(returns, 2), 'total': round(fv, 2)})
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
