from flask import Flask, request, jsonify
from flask_cors import CORS
import math

app = Flask(__name__)
CORS(app)

@app.route('/api/calculate', methods=['POST'])
def calculate_emi():
    data = request.get_json()
    principal = float(data.get('amount'))
    annual_interest = float(data.get('interest'))
    years = int(data.get('years'))

    monthly_interest = annual_interest / 12 / 100
    months = years * 12

    emi = principal * monthly_interest * math.pow((1 + monthly_interest), months) / (math.pow((1 + monthly_interest), months) - 1)
    total_payment = emi * months
    total_interest = total_payment - principal

    return jsonify({
        'emi': emi,
        'total_payment': total_payment,
        'total_interest': total_interest,
        'principal': principal
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
