import requests
import json

print("=== Verificando versão do webhook ===")

# Teste simples
response = requests.post(
    'http://localhost:8080/sinais',
    json={'action': 'test', 'symbol': 'TEST'},
    headers={'Content-Type': 'application/json'}
)

print(f"Status Code: {response.status_code}")
print(f"Response: {response.json()}")

# Verificar arquivo gerado
try:
    with open(r'C:\Users\adan\AppData\Roaming\MetaQuotes\Terminal\Common\Files\signal.json', 'r') as f:
        content = f.read()
        print(f"\nArquivo signal.json:\n{content}")
except Exception as e:
    print(f"Erro ao ler arquivo: {e}")