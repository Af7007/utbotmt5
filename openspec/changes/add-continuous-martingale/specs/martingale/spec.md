# Martingale Progression Specification

## ADDED Requirements

### Requirement: Continuous Martingale Mode
The EA SHALL provide a continuous martingale mode where each new order multiplies the lot size of the **last opened order** in the same direction, creating exponential progression.

#### Scenario: First order uses base lot
- **GIVEN** EnableContinuousMartingale is true
- **AND** no previous orders exist in the direction
- **WHEN** a signal is received
- **THEN** open order with FixedLotSize (e.g., 0.01)

#### Scenario: Second order multiplies first
- **GIVEN** EnableContinuousMartingale is true
- **AND** MartingaleMultiplier is 1.5
- **AND** last order opened with 0.01 lot
- **WHEN** adding a grid order
- **THEN** open new order with 0.015 lot (0.01 × 1.5)

#### Scenario: Third order multiplies second
- **GIVEN** EnableContinuousMartingale is true
- **AND** MartingaleMultiplier is 1.5
- **AND** last order opened with 0.015 lot
- **WHEN** adding a grid order
- **THEN** open new order with 0.0225 lot (0.015 × 1.5)

#### Scenario: Fourth order continues progression
- **GIVEN** EnableContinuousMartingale is true
- **AND** MartingaleMultiplier is 1.5
- **AND** last order opened with 0.0225 lot
- **WHEN** adding a grid order
- **THEN** open new order with 0.03375 lot (0.0225 × 1.5)

### Requirement: Direction-Specific Lot Tracking
The EA SHALL track the last opened lot size separately for BUY and SELL directions.

#### Scenario: Buy and sell have separate progressions
- **GIVEN** EnableContinuousMartingale is true
- **AND** last BUY order was 0.03 lot
- **AND** last SELL order was 0.01 lot
- **WHEN** opening a new BUY order
- **THEN** calculate based on 0.03 (not 0.01)
- **AND** WHEN opening a new SELL order
- **THEN** calculate based on 0.01 (not 0.03)

#### Scenario: Hedge mode maintains both progressions
- **GIVEN** EA is in hedge mode
- **AND** old direction has orders at 0.01, 0.015 lots
- **AND** new direction has orders at 0.01, 0.02 lots
- **WHEN** adding order to new direction
- **THEN** multiply the new direction's last lot (0.02)
- **NOT** the old direction's lot

### Requirement: Martingale Reset on Close
The EA SHALL reset the martingale progression to base lot when all positions are closed.

#### Scenario: Reset after profit target
- **GIVEN** EnableContinuousMartingale is true
- **AND** last order opened with 0.03 lot
- **WHEN** profit target is reached and all positions close
- **THEN** reset lastBuyLotSize and lastSellLotSize to 0
- **AND** next order uses FixedLotSize

#### Scenario: Reset after manual close
- **GIVEN** EnableContinuousMartingale is true
- **AND** last order opened with 0.03 lot
- **WHEN** all positions are manually closed
- **THEN** next signal starts from FixedLotSize

#### Scenario: Reset on signal reversal (no hedge)
- **GIVEN** EnableContinuousMartingale is true
- **AND** all current positions are profitable
- **AND** last BUY order was 0.03 lot
- **WHEN** SELL signal is received
- **THEN** close all BUY positions
- **AND** open first SELL at FixedLotSize (reset)

### Requirement: Broker Maximum Lot Protection
The EA SHALL cap calculated lot size at the broker's maximum allowed lot size.

#### Scenario: Cap at broker maximum
- **GIVEN** EnableContinuousMartingale is true
- **AND** broker maximum lot is 0.10
- **AND** calculated martingale lot is 0.15
- **WHEN** opening order
- **THEN** use 0.10 lot (broker max)
- **AND** log warning about cap applied

#### Scenario: Continue progression after cap
- **GIVEN** previous order was capped at 0.10 (broker max)
- **AND** broker maximum lot is 0.10
- **WHEN** opening next order
- **THEN** use 0.10 lot (cannot exceed max)
- **AND** continue opening at max until positions close

### Requirement: Backwards Compatibility
The EA SHALL maintain the current fixed multiplier behavior when continuous martingale is disabled.

#### Scenario: Disabled continuous martingale
- **GIVEN** EnableContinuousMartingale is false
- **AND** HedgeLotMultiplier is 1.5
- **WHEN** opening hedge orders
- **THEN** all orders use FixedLotSize × HedgeLotMultiplier
- **AND** lot size does NOT progress between orders

#### Scenario: Default configuration
- **GIVEN** EA is initialized with default parameters
- **THEN** EnableContinuousMartingale is false
- **AND** behavior matches current production version

### Requirement: Martingale Configuration Parameters
The EA SHALL provide input parameters to configure continuous martingale behavior.

#### Scenario: EnableContinuousMartingale parameter
- **PARAMETER NAME:** EnableContinuousMartingale
- **TYPE:** bool
- **DEFAULT:** false
- **DESCRIPTION:** Enable true martingale progression (each order multiplies last order's lot)

#### Scenario: MartingaleMultiplier parameter
- **PARAMETER NAME:** MartingaleMultiplier
- **TYPE:** double
- **DEFAULT:** 1.5
- **DESCRIPTION:** Multiplier applied to last lot size for next order (e.g., 1.5 = 50% increase)
- **VALID RANGE:** 1.0 to 3.0

### Requirement: Martingale Progression Logging
The EA SHALL log the martingale progression level for each order opened.

#### Scenario: Log progression level
- **GIVEN** EnableContinuousMartingale is true
- **WHEN** opening an order
- **THEN** log "MARTINGALE Level N: X lot (Yx base)"
- **WHERE** N is the order number, X is lot size, Y is multiplier from base

#### Scenario: Log first order
- **WHEN** first order in direction opens
- **THEN** log "MARTINGALE Level 1: 0.01 lot (1.0x base)"

#### Scenario: Log fourth order
- **GIVEN** multiplier is 1.5
- **WHEN** fourth order opens
- **THEN** log "MARTINGALE Level 4: 0.034 lot (3.375x base)"
