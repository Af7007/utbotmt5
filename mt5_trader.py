import argparse
import requests
import logging
import sys

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

URL = 'http://local.host:5000'

def send_trade(action, symbol, volume, sl, tp, price=None):
    """
    Send a trade signal to MetaTrader 5 via HTTP POST request.
    """
    data = {
        "action": action,
        "symbol": symbol,
        "volume": volume,
        "sl": sl,
        "tp": tp
    }
    if price is not None:
        data["price"] = price

    try:
        response = requests.post(URL, json=data, timeout=10)
        response.raise_for_status()
        logging.info(f"Trade sent successfully: {data}")
        print("Trade sent successfully.")
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to send trade: {e}")
        print(f"Error: Failed to send trade. {e}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Send trading signals to MetaTrader 5")
    parser.add_argument('--action', choices=['buy', 'sell'], required=True, help='Type of operation: buy or sell')
    parser.add_argument('--symbol', default='XAUUSD', help='Trading symbol (default: XAUUSD)')
    parser.add_argument('--volume', type=float, required=True, help='Volume (lot size)')
    parser.add_argument('--sl', type=float, default=0, help='Stop Loss (default: 0)')
    parser.add_argument('--tp', type=float, default=0, help='Take Profit (default: 0)')
    parser.add_argument('--price', type=float, help='Entry price for limit orders (optional)')

    args = parser.parse_args()
    send_trade(args.action, args.symbol, args.volume, args.sl, args.tp, args.price)

if __name__ == '__main__':
    main()