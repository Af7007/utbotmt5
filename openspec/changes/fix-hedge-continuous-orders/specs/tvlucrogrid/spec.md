## ADDED Requirements

### Requirement: Continuous Hedge Order Addition
The EA SHALL add orders continuously while in hedge mode whenever a signal is received, regardless of signal direction.

#### Scenario: Signal in same direction as current hedge
- **WHEN** `inHedgeMode` is `true`
- **AND** a new signal is received matching `currentDirection`
- **THEN** the EA SHALL add an order to the hedge grid
- **AND** the order SHALL use `baseVolume × HedgeLotMultiplier`

#### Scenario: Signal in opposite direction during hedge
- **WHEN** `inHedgeMode` is `true`
- **AND** a new signal is received opposite to `currentDirection`
- **THEN** the EA SHALL add an order in the signal direction
- **AND** the order SHALL ALSO use `baseVolume × HedgeLotMultiplier`

#### Scenario: Multiple signals during hedge
- **WHEN** in hedge mode AND multiple signals are received
- **THEN** the EA SHALL add an order for EACH signal received
- **AND** all orders SHALL use the multiplied lot size
- **UNTIL** profit target is reached

## MODIFIED Requirements

### Requirement: Hedge Signal Processing
The EA SHALL process ALL signals while in hedge mode, never ignoring them.

#### Scenario: Always process signals in hedge mode
- **WHEN** `inHedgeMode` is `true` AND any signal is received
- **THEN** the EA SHALL process the signal (add order)
- **AND** SHALL NOT ignore the signal

## REMOVED Requirements

### Requirement: Ignore Signals During Hedge
**REMOVED** - Previously, the EA would ignore signals while in hedge mode.

**Reason**: Changed to always respect signals and add orders continuously.

**Migration**: Hedge mode now adds orders for every signal received until profit target is reached.
