## ADDED Requirements
### Requirement: Candle Close Execution
The EA SHALL provide an option to execute trade signals only at the close of a candle instead of immediately upon signal reception.

#### Scenario: Signal reception with candle close enabled
- **WHEN** `OpenOnCandleClose` is enabled and a signal is received
- **THEN** the EA SHALL queue the signal for later execution
- **AND** the EA SHALL NOT execute the trade immediately
- **AND** the EA SHALL wait for the current candle to close
- **AND** the EA SHALL execute the queued signal only after candle closes

#### Scenario: Candle close execution
- **WHEN** a candle closes and there are pending signals
- **THEN** the EA SHALL process the most recent signal (discard older ones)
- **AND** the EA SHALL execute the trade with normal position management
- **AND** the EA SHALL clear all other pending signals
- **AND** the EA SHALL reset the pending signal queue

#### Scenario: Multiple signals before candle close
- **WHEN** multiple signals are received before candle closes
- **THEN** the EA SHALL keep only the most recent signal
- **AND** the EA SHALL discard older signals from the queue
- **AND** the EA SHALL execute only the most recent signal at candle close

#### Scenario: Pending signal expiration
- **WHEN** a pending signal remains in queue longer than `PendingSignalExpirationSec`
- **THEN** the EA SHALL remove the expired signal
- **AND** the EA SHALL log the expiration event
- **AND** the EA SHALL NOT execute the expired signal

## MODIFIED Requirements
### Requirement: Signal Processing Timing
The EA SHALL support both immediate and candle-close based execution modes configurable by the user.

#### Scenario: Immediate execution mode (default)
- **WHEN** `OpenOnCandleClose` is disabled
- **THEN** the EA SHALL execute signals immediately upon reception
- **AND** the EA SHALL maintain current behavior for backward compatibility

#### Scenario: Candle close time frame selection
- **WHEN** `OpenOnCandleClose` is enabled
- **THEN** the EA SHALL monitor candle closes on `CandleCloseTimeframe`
- **AND** the EA SHALL support different timeframes for execution timing
- **AND** the EA SHALL default to the current chart timeframe if not specified