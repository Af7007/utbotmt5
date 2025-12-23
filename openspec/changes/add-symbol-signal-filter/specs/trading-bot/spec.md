# Filtragem de Sinais por Símbolo

## ADDED Requirements
### Requirement: Symbol-Based Signal Filtering
The EA SHALL ignore trade signals that are not intended for the configured trading symbol.

#### Scenario: Signal symbol validation
- **WHEN** a signal is received via webhook
- **THEN** the EA SHALL check if the signal contains a 'symbol' field
- **AND** SHALL compare the signal's symbol with the configured `TradingSymbol`
- **AND** SHALL process the signal ONLY if:
  - Signal symbol matches `TradingSymbol` exactly (case-sensitive)
  - OR signal symbol is missing (backward compatibility)
  - OR signal symbol is empty (backward compatibility)

#### Scenario: Supported symbols
- **WHEN** configuring the EA for Bitcoin trading
- **THEN** supported symbols SHALL include:
  - Forex pairs: "EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "NZDUSD", "USDCAD"
  - Commodity: "XAUUSD" (Gold/Ouro)
  - Cryptocurrency: "BTCUSD" (Bitcoin)
  - Other valid MT5 symbols

#### Scenario: Symbol mismatch handling
- **WHEN** a signal contains a symbol that does NOT match `TradingSymbol`
- **THEN** the EA SHALL:
  - Log a warning indicating the signal was ignored
  - Continue processing normally (no error)
  - Keep the file for potential future use

#### Scenario: JSON format validation
- **WHEN** receiving a signal via JSON webhook
- **THEN** the expected format SHALL be:
  ```json
  {
    "symbol": "BTCUSD",
    "direction": "buy",
    "volume": 0.01,
    "timestamp": "2025-01-19T10:30:00Z"
  }
  ```
- **AND** examples for different symbols SHALL be:
  - Forex: `"symbol": "EURUSD"`
  - Gold: `"symbol": "XAUUSD"`
  - Bitcoin: `"symbol": "BTCUSD"`
- **AND** backward compatibility SHALL be maintained for signals without 'symbol' field

#### Scenario: Multiple trade viewer support
- **WHEN** multiple trade viewers are sending signals
- **THEN** the EA SHALL:
  - Process signals only for its configured symbol
  - Ignore signals from other trade viewers silently
  - Maintain separate operation for each EA instance

#### Scenario: Logging and debugging
- **WHEN** a signal is ignored due to symbol mismatch
- **THEN** the EA SHALL log:
  - Timestamp of the ignored signal
  - Signal direction (for debugging)
  - Expected vs actual symbol
  - Reason: "Signal ignored - symbol mismatch"

#### Scenario: Configuration flexibility
- **WHEN** configuring the EA
- **THEN** the user SHALL be able to:
  - Set `TradingSymbol` to match their trade viewer
  - Change symbols dynamically without EA restart
  - Use any valid MT5 symbol name

## MODIFIED Requirements
### Requirement: Signal Processing Logic
The signal processing SHALL include symbol validation before executing trades.

#### Scenario: Enhanced signal processing flow
- **STEP 1**: Read signal from JSON file
- **STEP 2**: Parse JSON and extract fields
- **STEP 3**: Validate symbol compatibility (NEW)
- **STEP 4**: If symbol mismatch → log and return (NEW)
- **STEP 5**: If valid symbol → continue with normal processing

## TECHNICAL Requirements
### Implementation Details
- Use `StringCompare()` for case-sensitive symbol matching
- Add helper function `IsSignalForThisSymbol(string jsonString)`
- Add helper function `LogIgnoredSignal(string symbol, string direction)`
- Maintain backward compatibility by treating missing symbol as valid
- Update logging to include symbol information

### Performance Considerations
- Symbol comparison is O(1) operation
- No impact on signal processing performance
- Logging of ignored signals is minimal overhead

### Error Handling
- Gracefully handle missing or malformed symbol field
- Continue operation even if symbol field is invalid type
- Log parsing errors but don't crash the EA