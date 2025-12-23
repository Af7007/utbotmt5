import requests
import json

print("Testing webhook with debug info...\n")

# Test with direction field
print("=== Test 1: direction field ===")
try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json={'direction': 'buy', 'symbol': 'BTCUSD'},
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    print(f"Response headers: {dict(response.headers)}")
except Exception as e:
    print(f"Error: {e}")

print("\n" + "="*50 + "\n")

# Test with action field
print("=== Test 2: action field ===")
try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json={'action': 'long'},
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    print(f"Response headers: {dict(response.headers)}")
except Exception as e:
    print(f"Error: {e}")