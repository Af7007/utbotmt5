#!/usr/bin/env python3
"""
Teste simples da lógica de salvamento de arquivos
"""
import json
import os
from datetime import datetime

MT5_COMMON_PATH = os.path.join(os.getenv('APPDATA'), 'MetaQuotes', 'Terminal', 'Common', 'Files')

def test_save_files():
    print("Teste de salvamento de arquivos por símbolo")

    # Test 1: XAUUSD signal
    symbol = "XAUUSD"
    payload = {
        "action": "long",
        "symbol": symbol,
        "volume": 0.01
    }

    symbol_file = f"signal_{symbol}.json"
    signal_file_path = os.path.join(MT5_COMMON_PATH, symbol_file)

    # Garantir que o diretório exista
    os.makedirs(MT5_COMMON_PATH, exist_ok=True)

    # Salvar arquivo específico para o símbolo
    with open(signal_file_path, 'w') as f:
        json.dump(payload, f, indent=2)

    print(f"[OK] Arquivo criado: {symbol_file}")

    # Verificar se existe
    if os.path.exists(signal_file_path):
        with open(signal_file_path, 'r') as f:
            content = json.load(f)
            print(f"[OK] Conteúdo: {content}")

    # Test 2: BTCUSD signal
    symbol = "BTCUSD"
    payload = {
        "action": "short",
        "symbol": symbol,
        "volume": 0.001
    }

    symbol_file = f"signal_{symbol}.json"
    signal_file_path = os.path.join(MT5_COMMON_PATH, symbol_file)

    # Salvar arquivo específico para o símbolo
    with open(signal_file_path, 'w') as f:
        json.dump(payload, f, indent=2)

    print(f"[OK] Arquivo criado: {symbol_file}")

    # Verificar se existe
    if os.path.exists(signal_file_path):
        with open(signal_file_path, 'r') as f:
            content = json.load(f)
            print(f"[OK] Conteúdo: {content}")

    # Listar todos os arquivos criados
    print("\nArquivos encontrados:")
    for filename in os.listdir(MT5_COMMON_PATH):
        if filename.startswith('signal_') and filename.endswith('.json'):
            filepath = os.path.join(MT5_COMMON_PATH, filename)
            try:
                with open(filepath, 'r') as f:
                    content = json.load(f)
                    print(f"  - {filename}: {content.get('action', '?')} {content.get('symbol', '?')}")
            except:
                print(f"  - {filename}: [ERRO AO LER]")

if __name__ == "__main__":
    test_save_files()