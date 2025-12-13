from flask import Flask, request, jsonify
import requests
import logging
from logging.handlers import RotatingFileHandler
from datetime import datetime, timezone
import os

app = Flask(__name__)

# Configurações
WEBHOOK_PORT = 8080
MT5_COMMON_PATH = os.path.join(os.getenv('APPDATA'), 'MetaQuotes', 'Terminal', 'Common', 'Files')
SIGNAL_FILE = os.path.join(MT5_COMMON_PATH, "signal.json")  # Arquivo compartilhado com MT5
API_KEY = os.getenv('WEBHOOK_API_KEY', 'default-secret-key')

# Mapeamento de sinais
SIGNAL_MAP = {
    "long": "buy",
    "short": "sell"
}

# Setup logging
os.makedirs('logs', exist_ok=True)
os.makedirs(MT5_COMMON_PATH, exist_ok=True)
handler = RotatingFileHandler('logs/webhook.log', maxBytes=10*1024*1024, backupCount=5)
handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logger = logging.getLogger('webhook')
logger.addHandler(handler)
logger.setLevel(logging.INFO)

@app.route('/sinais', methods=['POST'])
def receive_signal():
    """Recebe webhook externo com sinais de trading"""

    # Validar JSON
    if not request.is_json:
        logger.error("Request is not JSON")
        return jsonify({'error': 'Content-Type must be application/json'}), 400

    data = request.json

    # Validar campo 'action'
    if 'action' not in data:
        logger.error(f"Missing 'action' field: {data}")
        return jsonify({'error': 'Missing required field: action'}), 400

    # Traduzir long/short para buy/sell
    action = SIGNAL_MAP.get(data['action'].lower())
    if not action:
        logger.error(f"Invalid action: {data['action']}")
        return jsonify({'error': f"Invalid action. Use 'long' or 'short'"}), 400

    # Criar payload normalizado
    payload = {
        'action': action,
        'timestamp': datetime.now(timezone.utc).isoformat()
    }

    logger.info(f"Signal received: {data['action']} -> {action}")

    # Escrever sinal em arquivo JSON
    try:
        import json
        with open(SIGNAL_FILE, 'w') as f:
            json.dump(payload, f)

        logger.info(f"Signal written to file successfully: {payload}")
        return jsonify({
            'status': 'success',
            'message': f'Signal {action} written to file',
            'data': payload
        }), 200

    except Exception as e:
        logger.error(f"Failed to write signal to file: {e}")
        return jsonify({'error': 'Failed to write signal'}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'ok', 'service': 'webhook_receiver'}), 200

@app.route('/status', methods=['GET'])
def status():
    """Status endpoint (opcional - para monitoramento)"""
    import os.path
    signal_exists = os.path.exists(SIGNAL_FILE)

    last_signal = None
    if signal_exists:
        try:
            import json
            with open(SIGNAL_FILE, 'r') as f:
                last_signal = json.load(f)
        except:
            pass

    return jsonify({
        'status': 'running',
        'signal_file': SIGNAL_FILE,
        'signal_exists': signal_exists,
        'last_signal': last_signal,
        'timestamp': datetime.now(timezone.utc).isoformat()
    }), 200

if __name__ == '__main__':
    logger.info("Starting webhook receiver...")
    logger.info(f"Signal file path: {SIGNAL_FILE}")
    print(f"Signal file will be written to: {SIGNAL_FILE}")
    app.run(host='0.0.0.0', port=WEBHOOK_PORT, debug=False)
