import requests
import json
import time

print("=== Testando Webhook com Símbolo ===\n")

# Test 1: Enviar sinal legado sem símbolo (deve usar default XAUUSD)
print("Test 1: Enviando action:long sem símbolo...")
try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json={'action': 'long'},
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Error: {e}")

time.sleep(1)

# Test 2: Enviar sinal legado com símbolo
print("\nTest 2: Enviando action:short com símbolo BTCUSD...")
try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json={'action': 'short', 'symbol': 'BTCUSD'},
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Error: {e}")

time.sleep(1)

# Test 3: Enviar novo formato direction com símbolo
print("\nTest 3: Enviando direction:buy com símbolo EURUSD...")
try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json={'direction': 'buy', 'symbol': 'EURUSD'},
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Error: {e}")

print("\n=== Verificando arquivo signal.json ===")
try:
    with open(r'C:\Users\adan\AppData\Roaming\MetaQuotes\Terminal\Common\Files\signal.json', 'r') as f:
        content = f.read()
        print("Conteúdo do arquivo:")
        print(content)
except Exception as e:
    print(f"Erro ao ler arquivo: {e}")