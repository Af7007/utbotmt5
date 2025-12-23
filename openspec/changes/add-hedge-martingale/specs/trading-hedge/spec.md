# Trading Hedge Martingale

## ADDED Requirements

### Requirement: Hedge Configuration
The system SHALL provide configuration parameters for hedge martingale mode. The parameters MUST allow full control over hedge behavior.

#### Scenario: Hedge parameters available
- **WHEN** the EA is initialized
- **THEN** the following inputs SHALL be available:
  - `EnableHedge` (bool) - Enable/disable hedge system (default: false)
  - `HedgeProfitTarget` (int) - Profit target in points (default: 100)
  - `HedgeMultiplier` (double) - Martingale volume multiplier (default: 2.0)
  - `MaxHedgeLevels` (int) - Maximum hedge levels allowed (default: 5)

### Requirement: Hedge Condition Detection
The system SHALL detect when to open a hedge position instead of closing the current position. The system MUST evaluate position state and received signal.

#### Scenario: Opposite signal with losing position
- **WHEN** EnableHedge is active
- **AND** there is an open position for the symbol
- **AND** current position is in loss (profit < 0)
- **AND** received signal is opposite to position direction
- **THEN** the system SHALL open a hedge position in signal direction

#### Scenario: Opposite signal with winning position
- **WHEN** EnableHedge is active
- **AND** there is an open position for the symbol
- **AND** current position is in profit (profit >= 0)
- **AND** received signal is opposite to position direction
- **THEN** the system SHALL close position and open new one (default behavior)

#### Scenario: Hedge disabled
- **WHEN** EnableHedge is disabled
- **AND** received signal is opposite to position direction
- **THEN** the system SHALL close position and open new one (default behavior)

### Requirement: Martingale Volume Calculation
The system SHALL calculate hedge position volumes using martingale progression. The multiplier MUST be applied to the previous volume.

#### Scenario: First hedge volume
- **WHEN** it is the first hedge position (level 1)
- **THEN** volume SHALL be: original_volume * HedgeMultiplier

#### Scenario: Subsequent hedge volumes
- **WHEN** it is hedge level N (N > 1)
- **THEN** volume SHALL be: previous_volume * HedgeMultiplier

#### Scenario: Maximum levels reached
- **WHEN** hedge count reaches MaxHedgeLevels
- **AND** new opposite signal is received
- **THEN** the system SHALL keep current positions and NOT open new hedge
- **AND** the system SHALL log warning about limit reached

### Requirement: Total Profit Management
The system SHALL monitor total profit of all open positions and MUST close when target is reached.

#### Scenario: Profit target reached
- **WHEN** system is in hedge mode (multiple open positions)
- **AND** total profit of all positions >= HedgeProfitTarget points
- **THEN** the system SHALL close all positions immediately
- **AND** the system SHALL reset hedge state (level = 0, mode = false)
- **AND** the system SHALL log hedge success with profit obtained

#### Scenario: Total profit calculation
- **WHEN** there are multiple open positions for the symbol
- **THEN** total profit SHALL be the sum of profit/loss of all positions in points

### Requirement: Hedge Positions Without Individual TP/SL
Positions opened in hedge mode SHALL NOT have individual Take Profit or Stop Loss. The system MUST manage closing by total profit.

#### Scenario: Opening hedge position
- **WHEN** a hedge position is opened
- **THEN** the position SHALL be opened without TP (Take Profit = 0)
- **AND** the position SHALL be opened without SL (Stop Loss = 0)
- **AND** management SHALL be done by total profit

### Requirement: Hedge State Reset
The system SHALL reset hedge state when all positions are closed. The reset MUST occur automatically.

#### Scenario: Reset after target closure
- **WHEN** all positions are closed by reaching profit target
- **THEN** hedge level SHALL be reset to 0
- **AND** hedge mode flag SHALL be false
- **AND** next signal SHALL start normal operation

#### Scenario: Reset after manual closure
- **WHEN** all positions are closed externally (manually or by another EA)
- **THEN** the system SHALL detect that there are no open positions
- **AND** hedge level SHALL be reset to 0
- **AND** hedge mode flag SHALL be false
