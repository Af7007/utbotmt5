import requests
import json
import time
from datetime import datetime, timezone

print("=== Testing Complete Symbol Filtering System ===\n")

# Test 1: Send a signal with timestamp (should be processed)
print("Test 1: Sending signal with timestamp (BTCUSD)...")
signal_with_timestamp = {
    "direction": "buy",
    "symbol": "BTCUSD",
    "volume": 0.01,
    "timestamp": datetime.now(timezone.utc).isoformat()
}

try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json=signal_with_timestamp,
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Error: {e}")

time.sleep(2)

# Test 2: Send signal without timestamp (should be processed with warning)
print("\nTest 2: Sending signal without timestamp (XAUUSD)...")
signal_without_timestamp = {
    "direction": "sell",
    "symbol": "XAUUSD",
    "volume": 0.1
}

try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json=signal_without_timestamp,
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Error: {e}")

time.sleep(2)

# Test 3: Send legacy format signal (should be converted)
print("\nTest 3: Sending legacy format signal (EURUSD)...")
legacy_signal = {
    "action": "long"
}

try:
    response = requests.post(
        'http://localhost:8080/sinais',
        json=legacy_signal,
        headers={'Content-Type': 'application/json'}
    )
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Error: {e}")

print("\n=== Check signal.json file content ===")
try:
    with open(r'C:\Users\adan\AppData\Roaming\MetaQuotes\Terminal\Common\Files\signal.json', 'r') as f:
        content = f.read()
        print("Signal file content:")
        print(content)
except Exception as e:
    print(f"Error reading signal file: {e}")

print("\n=== Check webhook logs ===")
try:
    with open(r'C:\utbot\logs\webhook.log', 'r') as f:
        lines = f.readlines()
        print("Last 10 log entries:")
        for line in lines[-10:]:
            print(line.strip())
except Exception as e:
    print(f"Error reading log file: {e}")