
import os
from flask import Flask, render_template
import time

app = Flask(__name__)

# Simulated config (failure injection)
FAIL_MODE = os.environ.get('APP_FAILMODE', 'none')  # values: none, db_timeout, bad_secret, spike

@app.route('/')
def index():
    return render_template('index.html', fail_mode=FAIL_MODE)

@app.route('/health')
def health():
    return {'status': 'ok', 'time': time.time(), 'fail_mode': FAIL_MODE}

@app.route('/simulate')
def simulate():
    # Generate 500s based on FAIL_MODE
    if FAIL_MODE == 'db_timeout':
        # Simulate a slow dependency or timeout
        time.sleep(3)
        raise Exception('Dependency timeout: database unreachable')
    elif FAIL_MODE == 'bad_secret':
        secret = os.environ.get('APP_SECRET')
        if not secret:
            raise Exception('Missing secret: APP_SECRET not set')
    elif FAIL_MODE == 'spike':
        # Simulate CPU spike by doing some compute
        s = 0
        for i in range(10_000_00):
            s += i
    return {'result': 'ok', 'fail_mode': FAIL_MODE}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8000)))
