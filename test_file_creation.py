#!/usr/bin/env python3
"""
Teste rápido de criação de arquivos específicos por símbolo
"""
import json
import os

MT5_COMMON_PATH = os.path.join(os.getenv('APPDATA'), 'MetaQuotes', 'Terminal', 'Common', 'Files')

def test_file_creation():
    symbols = ['XAUUSD', 'BTCUSD', 'EURUSD', 'GBPUSD']

    print("Testando criação de arquivos específicos por símbolo...")

    for symbol in symbols:
        payload = {
            "action": "long" if symbol in ['XAUUSD', 'EURUSD'] else "short",
            "symbol": symbol,
            "volume": 0.01 if symbol == 'XAUUSD' else 0.001 if symbol == 'BTCUSD' else 0.1 if symbol == 'EURUSD' else 0.05
        }

        # Criar nome de arquivo específico para o símbolo
        symbol_file = f"signal_{symbol}.json"
        signal_file_path = os.path.join(MT5_COMMON_PATH, symbol_file)

        print(f"\nCriando arquivo para {symbol}: {symbol_file}")

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
                print(f"  Conteúdo: {content.get('action')} {content.get('symbol')} (volume: {content.get('volume')})")
        else:
            print(f"  ✗ Arquivo não encontrado!")

    # Listar todos os arquivos criados
    print("\n\nArquivos encontrados no diretório:")
    for filename in os.listdir(MT5_COMMON_PATH):
        if filename.startswith('signal_') and filename.endswith('.json'):
            filepath = os.path.join(MT5_COMMON_PATH, filename)
            try:
                with open(filepath, 'r') as f:
                    content = json.load(f)
                    print(f"  [OK] {filename}: {content.get('action', '?')} {content.get('symbol', '?')}")
            except:
                print(f"  ✗ {filename}: [ERRO AO LER]")

if __name__ == "__main__":
    test_file_creation()