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

    # Log detalhado da requisição
    logger.info(f"=== WEBHOOK REQUEST ===")
    logger.info(f"From: {request.remote_addr}")
    logger.info(f"Content-Type: {request.content_type}")
    logger.info(f"Raw Data: {request.get_data(as_text=True)}")
    print(f"[WEBHOOK] Received from {request.remote_addr}: {request.get_data(as_text=True)}")

    # Tentar parsear como JSON primeiro
    data = None
    content_type = request.content_type or ""

    
    # Verificar se é JSON ou form data
    if 'application/json' in content_type:
        try:
            data = request.get_json()
            logger.info(f"Parsed JSON data: {data}")
        except Exception as e:
            logger.error(f"Failed to parse JSON: {e}")
            return jsonify({'error': 'Invalid JSON format'}), 400
    elif 'form' in content_type:
        try:
            data = request.form.to_dict()
            logger.info(f"Parsed form data: {data}")
        except Exception as e:
            logger.error(f"Failed to parse form data: {e}")
            return jsonify({'error': 'Invalid form data format'}), 400
    else:
        # Tentar como JSON mesmo assim
        try:
            data = request.get_json()
            logger.info(f"Attempted JSON parsing: {data}")
        except:
            logger.error("Request is not JSON or form")
            return jsonify({'error': 'Invalid data format. Use JSON or form urlencoded'}), 400

    if data is None:
        logger.error("No data parsed")
        return jsonify({'error': 'No data provided'}), 400

    # Validar campo 'direction' (novo formato) ou 'action' (antigo formato)
    direction = None
    logger.info(f"DEBUG: Data keys: {list(data.keys())}")
    logger.info(f"DEBUG: Has 'direction': {'direction' in data}")
    logger.info(f"DEBUG: Has 'action': {'action' in data}")

    if 'direction' in data:
        # Novo formato: "direction": "buy" ou "sell"
        direction = data['direction'].lower()
        logger.info(f"DEBUG: Direction found: {direction}")
        if direction not in ['buy', 'sell']:
            logger.error(f"Invalid direction: {direction}")
            return jsonify({'error': f"Invalid direction. Use 'buy' or 'sell'"}), 400
    elif 'action' in data:
        # Formato legado: "action": "long" ou "short"
        action = data['action'].lower()
        logger.info(f"DEBUG: Action found: {action}")
        direction = SIGNAL_MAP.get(action)
        if not direction:
            logger.error(f"Invalid action: {action}")
            return jsonify({'error': f"Invalid action. Use 'long' or 'short'"}), 400
    else:
        logger.error(f"Missing 'direction' or 'action' field: {data}")
        return jsonify({'error': 'Missing required field: direction (or action for legacy)'}), 400

    # Validar campo 'symbol' (opcional, para compatibilidade multi-símbolo)
    symbol = data.get('symbol', 'XAUUSD')  # Default para XAUUSD se não especificado

    # Validar campo 'volume' (opcional)
    volume = data.get('volume', 0.01)  # Default de 0.01 se não especificado

    # Criar payload legado com action e symbol
    # Se veio direction, converter para action
    if 'direction' in data:
        payload_action = "long" if direction == "buy" else "short"
    else:
        payload_action = action

    payload = {
        'action': payload_action,  # long ou short
        'symbol': symbol,  # Adicionar símbolo ao payload
        'volume': volume,
        'timestamp': datetime.now().strftime('%Y-%m-%dT%H:%M:%S')
    }

    logger.info(f"DEBUG: Payload final: {payload}")
    logger.info(f"Signal received: {payload_action} for {symbol} (volume: {volume})")

    # Escrever sinal em arquivo JSON
    try:
        import json

        # Determinar o símbolo
        symbol = payload.get('symbol', 'XAUUSD')

        # Criar nome de arquivo específico para o símbolo
        symbol_file = f"signal_{symbol}.json"
        signal_file_path = os.path.join(MT5_COMMON_PATH, symbol_file)

        # Salvar arquivo específico para o símbolo
        with open(signal_file_path, 'w') as f:
            json.dump(payload, f, indent=2)

        logger.info(f"Signal written to {symbol_file} for {symbol}: {payload}")
        print(f"[WEBHOOK] Signal {payload_action} written to {symbol_file} for {symbol}")

        # Também escrever no arquivo genérico signal.json para compatibilidade
        generic_file = "signal.json"
        generic_file_path = os.path.join(MT5_COMMON_PATH, generic_file)
        with open(generic_file_path, 'w') as f:
            json.dump(payload, f, indent=2)

        logger.info(f"Also written to {generic_file} for compatibility")

        response = jsonify({
            'status': 'success',
            'message': f'Signal {payload_action} written to {symbol_file}',
            'symbol': symbol,
            'data': payload
        })

        logger.info(f"=== RESPONSE: {response.get_json()} ===")
        return response, 200

    except Exception as e:
        logger.error(f"Failed to write signal to file: {e}")
        return jsonify({'error': 'Failed to write signal'}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'ok', 'service': 'webhook_receiver'}), 200

@app.route('/status', methods=['GET'])
def status():
    """Status endpoint - lista todos os arquivos de sinal específicos"""
    import os
    import os.path

    # Listar todos os arquivos signal_*.json
    signal_files = {}
    try:
        if os.path.exists(MT5_COMMON_PATH):
            for filename in os.listdir(MT5_COMMON_PATH):
                if filename.startswith('signal_') and filename.endswith('.json'):
                    file_path = os.path.join(MT5_COMMON_PATH, filename)
                    try:
                        import json
                        with open(file_path, 'r') as f:
                            signal_files[filename] = json.load(f)
                    except:
                        signal_files[filename] = {'error': 'Could not read file'}
    except Exception as e:
        return jsonify({'error': f'Failed to list signals: {e}'}), 500

    return jsonify({
        'status': 'running',
        'signal_files': signal_files,
        'signal_count': len(signal_files),
        'mt5_path': MT5_COMMON_PATH,
        'timestamp': datetime.now(timezone.utc).isoformat()
    }), 200

@app.route('/examples', methods=['GET'])
def examples():
    """Exemplos de uso do webhook"""
    examples = {
        'buy_signal': {
            'method': 'POST',
            'url': f'http://localhost:{WEBHOOK_PORT}/sinais',
            'headers': {'Content-Type': 'application/json'},
            'body': {
                'direction': 'buy',
                'symbol': 'BTCUSD',
                'volume': 0.01
            }
        },
        'sell_signal': {
            'method': 'POST',
            'url': f'http://localhost:{WEBHOOK_PORT}/sinais',
            'headers': {'Content-Type': 'application/json'},
            'body': {
                'direction': 'sell',
                'symbol': 'XAUUSD',
                'volume': 0.1
            }
        },
        'legacy_long': {
            'method': 'POST',
            'url': f'http://localhost:{WEBHOOK_PORT}/sinais',
            'headers': {'Content-Type': 'application/json'},
            'body': {
                'action': 'long'
            }
        },
        'legacy_short': {
            'method': 'POST',
            'url': f'http://localhost:{WEBHOOK_PORT}/sinais',
            'headers': {'Content-Type': 'application/json'},
            'body': {
                'action': 'short'
            }
        }
    }

    return jsonify({
        'status': 'examples',
        'supported_symbols': ['BTCUSD', 'XAUUSD', 'EURUSD', 'GBPUSD', 'USDJPY'],
        'examples': examples,
        'note': 'Use direction (buy/sell) para novo formato ou action (long/short) para formato legado. O comentário da ordem é gerado automaticamente pelo EA (ex: buy:BTCUSDc)'
    }), 200

if __name__ == '__main__':
    logger.info("Starting webhook receiver v2.0 (multi-symbol support)...")
    logger.info(f"Signal directory: {MT5_COMMON_PATH}")
    logger.info(f"Signal format: signal_{{SYMBOL}}.json (ex: signal_XAUUSD.json)")
    logger.info(f"Available endpoints: /sinais, /health, /status, /examples")
    print(f"Signal files will be written to: {MT5_COMMON_PATH}")
    print(f"Format: signal_SYMBOL.json (e.g., signal_XAUUSD.json)")
    print(f"Access examples at: http://localhost:{WEBHOOK_PORT}/examples")
    app.run(host='0.0.0.0', port=WEBHOOK_PORT, debug=False)
