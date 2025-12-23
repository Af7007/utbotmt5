## MODIFIED Requirements
### Requirement: Signal Processing on EA Startup
The EA SHALL NOT process existing signals from the signal file when initialized, and SHALL preserve any existing open positions until a new signal is received.

#### Scenario: EA startup with existing positions
- **WHEN** the EA is initialized with open positions already present
- **THEN** the EA SHALL keep all existing positions open
- **AND** the EA SHALL continue managing those positions (breakeven, trailing stop)
- **AND** the EA SHALL NOT close any positions until a new valid signal is received

#### Scenario: EA startup with old signal file
- **WHEN** the EA starts and finds a signal.json file with old content
- **THEN** the EA SHALL ignore the existing signal content
- **AND** the EA SHALL record initialization timestamp
- **AND** the EA SHALL only process signals with timestamp after initialization

#### Scenario: New signal after startup
- **WHEN** a new signal is received after EA initialization
- **THEN** the EA SHALL validate the signal timestamp
- **AND** the EA SHALL process the signal if timestamp > initialization time
- **AND** the EA SHALL close existing positions before opening new position per normal logic

## ADDED Requirements
### Requirement: Signal Timestamp Validation
The EA SHALL validate signal timestamps to prevent processing of old signals during startup.

#### Scenario: Valid timestamp check
- **WHEN** processing any signal
- **THEN** the EA SHALL extract the timestamp field from JSON
- **AND** the EA SHALL compare with initialization timestamp
- **AND** the EA SHALL reject signals with timestamp <= initialization time

#### Scenario: Signal without timestamp
- **WHEN** a signal doesn't have a timestamp field
- **THEN** the EA SHALL reject the signal
- **AND** the EA SHALL log an error about missing timestamp
- **AND** the EA SHALL continue normal operation without processing the signal