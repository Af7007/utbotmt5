#!/usr/bin/env python3
"""
Signal Client - Lê sinais do servidor ngrok e salva localmente para o EA MT5

Uso:
    1. Configure NGROK_URL abaixo com a URL do seu servidor ngrok
    2. Execute: python signal_client.py
    3. Para rodar em background: pythonw.exe signal_client.py

Para auto-iniciar com Windows:
    1. Win+R -> shell:startup -> Enter
    2. Crie atalho: pythonw.exe "C:\caminho\para\signal_client.py"
"""

import requests
import json
import os
import time
from datetime import datetime

# ==================== CONFIGURAÇÕES ====================
# URL do servidor (ngrok local OU Vercel)
# Opcões:
#   ngrok local: "https://livelier-nonpurposively-monty.ngrok-free.dev"
#   Vercel:      "https://tradingview-signal-server.vercel.app"
NGROK_URL = "https://tradingview-signal-server.vercel.app"

# Nome do arquivo de sinal
SIGNAL_FILENAME = "signal_XAUUSD.json"

# Intervalo de verificação (segundos)
CHECK_INTERVAL = 5

# =======================================================

def get_mt5_common_path():
    """
    Retorna o caminho do diretório FILE_COMMON do MetaTrader 5
    """
    username = os.getenv('USERNAME')
    # Caminho padrão do MT5 para arquivos compartilhados
    return rf"C:\Users\{username}\AppData\Roaming\MetaQuotes\Terminal\Common\Files\{SIGNAL_FILENAME}"


def fetch_signal():
    """
    Busca o sinal do servidor ngrok e salva localmente
    """
    local_path = get_mt5_common_path()
    timestamp = datetime.now().strftime('%H:%M:%S')

    try:
        response = requests.get(
            f"{NGROK_URL}/signal",
            timeout=5,
            headers={'Accept': 'application/json'}
        )

        if response.status_code == 200:
            content = response.text.strip()

            # Verificar se não está vazio
            if content and content not in ['{}', '""', '']:
                # Salvar no arquivo local
                with open(local_path, 'w') as f:
                    f.write(content)

                # Mostrar sinal recebido (formatado)
                try:
                    signal_data = json.loads(content)
                    action = signal_data.get('action', signal_data.get('ticker', '?'))
                    symbol = signal_data.get('symbol', signal_data.get('exchange', '?'))
                    print(f"[{timestamp}] ✓ Sinal: {symbol} | {action}")
                except:
                    print(f"[{timestamp}] ✓ Sinal atualizado ({len(content)} chars)")
            else:
                print(f"[{timestamp}] - Sem sinal disponível")

        elif response.status_code == 404:
            print(f"[{timestamp}] - Nenhum sinal no servidor")
        else:
            print(f"[{timestamp}] ! Erro HTTP {response.status_code}")

    except requests.exceptions.Timeout:
        print(f"[{timestamp}] ! Timeout - servidor não respondeu")
    except requests.exceptions.ConnectionError:
        print(f"[{timestamp}] ! Erro de conexão - verifique a URL ngrok")
    except Exception as e:
        print(f"[{timestamp}] ! Erro: {e}")


def main():
    """Loop principal"""
    print("=" * 50)
    print("    TRADINGVIEW SIGNAL CLIENT")
    print("=" * 50)
    print(f"Servidor: {NGROK_URL}/signal")
    print(f"Arquivo local: {get_mt5_common_path()}")
    print(f"Intervalo: {CHECK_INTERVAL} segundos")
    print("=" * 50)
    print("Pressione Ctrl+C para encerrar...\n")

    # Verificar se o diretório existe
    local_path = get_mt5_common_path()
    dir_path = os.path.dirname(local_path)
    if not os.path.exists(dir_path):
        print(f"AVISO: Diretório não encontrado: {dir_path}")
        print("Certifique-se de que o MetaTrader 5 está instalado.\n")

    while True:
        fetch_signal()
        time.sleep(CHECK_INTERVAL)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nClient encerrado.")
