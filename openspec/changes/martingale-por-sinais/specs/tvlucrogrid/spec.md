## ADDED Requirements

### Requirement: Martingale por Sinais Consecutivos sem Fechamento
The EA SHALL multiply lot size by `MartingaleMultiplier` for each consecutive signal WITHOUT closing any positions until profit target is reached.

#### Scenario: First signal (consecutive count = 1)
- **WHEN** EA receives first signal
- **THEN** lot size SHALL be `FixedLotSize × MartingaleMultiplier^0 = FixedLotSize`
- **AND** `consecutiveSignalCount` SHALL be 1
- **AND** open `MaxGridOrders` orders immediately (not over time)

#### Scenario: Second signal (consecutive count = 2)
- **WHEN** EA receives second signal (opposite or same direction)
- **THEN** DO NOT close any existing positions
- **AND** lot size SHALL be `FixedLotSize × MartingaleMultiplier^1`
- **AND** `consecutiveSignalCount` SHALL be 2
- **AND** open `MaxGridOrders` orders immediately

#### Scenario: Third signal (consecutive count = 3)
- **WHEN** EA receives third signal
- **THEN** DO NOT close any existing positions
- **AND** lot size SHALL be `FixedLotSize × MartingaleMultiplier^2`
- **AND** `consecutiveSignalCount` SHALL be 3
- **AND** open `MaxGridOrders` orders immediately

### Requirement: Close All Only on Profit Target
The EA SHALL close ALL positions ONLY when hedge profit target is reached.

#### Scenario: Profit target reached
- **WHEN** total profit >= HedgeProfitTarget
- **THEN** CLOSE ALL positions (both directions)
- **AND** RESET `consecutiveSignalCount` to 0
- **AND** next signal SHALL use base lot size

### Requirement: Trailing Stop Only on First Signal
The EA SHALL apply trailing stop ONLY during the first signal (consecutiveSignalCount = 1).

#### Scenario: First signal trailing stop
- **WHEN** `consecutiveSignalCount` = 1
- **THEN** trailing stop SHALL be active

#### Scenario: Second signal onwards - no trailing stop
- **WHEN** `consecutiveSignalCount` > 1
- **THEN** trailing stop SHALL be disabled
- **AND** control SHALL be by HedgeProfitTarget only

## MODIFIED Requirements

### Requirement: CalculateVolume with Consecutive Signals
`CalculateVolume()` SHALL use `consecutiveSignalCount` and `MartingaleMultiplier` to determine lot size.

#### Scenario: Calculate lot with consecutive signals
- **WHEN** `consecutiveSignalCount` = N
- **THEN** volume per order = `FixedLotSize × MartingaleMultiplier^(N-1)`
- **AND** total per signal = `volume per order × MaxGridOrders`

### Requirement: Signal Processing Opens Multiple Orders
The EA SHALL open `MaxGridOrders` orders immediately upon receiving a signal.

#### Scenario: Process signal opens multiple orders
- **WHEN** receiving a valid signal
- **THEN** DO NOT call `CloseAllPositions()`
- **AND** DO increment `consecutiveSignalCount`
- **AND** open `MaxGridOrders` orders immediately with calculated lot size
- **AND** DO NOT use time-based grid order addition

## REMOVED Requirements

### Requirement: Time-Based Grid Order Addition
**REMOVED** - Previously, the EA would add grid orders over time using `GridIntervalSeconds`.

**Reason**: Each signal now opens `MaxGridOrders` orders immediately.

**Migration**: Grid orders are now opened immediately on each signal, not over time.
