import requests
import json

# Testar com JSON
print("=== Testando com JSON ===")
try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json={'direction': 'buy', 'symbol': 'BTCUSD'},
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"Erro: {e}")

# Testar com form data
print("\n=== Testando com Form Data ===")
try:
    response = requests.post(
        'http://localhost:8080/sinais',
        data={'direction': 'buy', 'symbol': 'BTCUSD'},
        headers={'Content-Type': 'application/x-www-form-urlencoded'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"Erro: {e}")

# Testar com formato legado
print("\n=== Testando com formato legado ===")
try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json={'action': 'long'},
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"Erro: {e}")