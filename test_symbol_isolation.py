#!/usr/bin/env python3
"""
Script de teste para verificar se os sinais estão indo para os arquivos corretos
"""
import requests
import json
import time
import os
from datetime import datetime

WEBHOOK_URL = "http://localhost:8080/sinais"
MT5_COMMON_PATH = os.path.join(os.getenv('APPDATA'), 'MetaQuotes', 'Terminal', 'Common', 'Files')

def test_symbol_isolation():
    """Testar se sinais diferentes para símbolos diferentes são salvos em arquivos separados"""

    print("=" * 60)
    print("TESTE DE ISOLAMENTO DE SÍMBOLOS")
    print("=" * 60)

    # Testar 1: Sinal para XAUUSD
    print("\n1. Enviando sinal para XAUUSD...")
    xau_signal = {
        "action": "long",
        "symbol": "XAUUSD",
        "volume": 0.01
    }

    response = requests.post(WEBHOOK_URL, json=xau_signal)
    print(f"   Status Code: {response.status_code}")
    print(f"   Resposta: {response.json()}")

    # Verificar arquivo XAUUSD
    xau_file = os.path.join(MT5_COMMON_PATH, "signal_XAUUSD.json")
    print(f"   Arquivo XAUUSD: {xau_file}")
    print(f"   Arquivo existe: {os.path.exists(xau_file)}")

    if os.path.exists(xau_file):
        with open(xau_file, 'r') as f:
            content = json.load(f)
            print(f"   Conteúdo: {content}")

    # Testar 2: Sinal para BTCUSD
    print("\n2. Enviando sinal para BTCUSD...")
    btc_signal = {
        "action": "short",
        "symbol": "BTCUSD",
        "volume": 0.001
    }

    response = requests.post(WEBHOOK_URL, json=btc_signal)
    print(f"   Status Code: {response.status_code}")
    print(f"   Resposta: {response.json()}")

    # Verificar arquivo BTCUSD
    btc_file = os.path.join(MT5_COMMON_PATH, "signal_BTCUSD.json")
    print(f"   Arquivo BTCUSD: {btc_file}")
    print(f"   Arquivo existe: {os.path.exists(btc_file)}")

    if os.path.exists(btc_file):
        with open(btc_file, 'r') as f:
            content = json.load(f)
            print(f"   Conteúdo: {content}")

    # Testar 3: Sinal sem símbolo (deve usar padrão XAUUSD)
    print("\n3. Enviando sinal sem campo 'symbol'...")
    no_symbol_signal = {
        "action": "long",
        "volume": 0.01
    }

    response = requests.post(WEBHOOK_URL, json=no_symbol_signal)
    print(f"   Status Code: {response.status_code}")
    print(f"   Resposta: {response.json()}")

    # Verificar arquivo genérico
    generic_file = os.path.join(MT5_COMMON_PATH, "signal.json")
    print(f"   Arquivo genérico: {generic_file}")
    print(f"   Arquivo existe: {os.path.exists(generic_file)}")

    if os.path.exists(generic_file):
        with open(generic_file, 'r') as f:
            content = json.load(f)
            print(f"   Conteúdo: {content}")

    print("\n" + "=" * 60)
    print("RESumo DOS ARQUIVOS CRIADOS:")
    print("=" * 60)

    # Listar todos os arquivos signal_*.json
    signal_files = [f for f in os.listdir(MT5_COMMON_PATH) if f.startswith('signal_') and f.endswith('.json')]

    if signal_files:
        print("Arquivos de sinal criados:")
        for file in signal_files:
            file_path = os.path.join(MT5_COMMON_PATH, file)
            try:
                with open(file_path, 'r') as f:
                    content = json.load(f)
                    print(f"   - {file}: {content.get('action', 'N/A')} {content.get('symbol', 'N/A')}")
            except:
                print(f"   - {file}: [ERRO AO LER]")
    else:
        print("Nenhum arquivo de sinal encontrado!")

    print("\nTeste concluído!")

if __name__ == "__main__":
    # Aguarar servidor iniciar
    time.sleep(2)

    test_symbol_isolation()