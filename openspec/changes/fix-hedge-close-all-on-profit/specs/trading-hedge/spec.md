## MODIFIED Requirements
### Requirement: Complete Hedge Position Closure
The EA SHALL close ALL hedge positions (both profitable and losing) when the total profit reaches the hedge target, ensuring no positions remain open after hedge completion.

#### Scenario: Mixed profit/loss hedge positions
- **WHEN** the hedge system has multiple positions open with mixed profit/loss
- **AND** the total profit (profit + loss sum) reaches the HedgeProfitTarget
- **THEN** the EA SHALL close ALL positions associated with the hedge
- **AND** the EA SHALL NOT leave any losing positions open
- **AND** the EA SHALL reset the hedge state only after ALL positions are confirmed closed

#### Scenario: Hedge position closure verification
- **WHEN** attempting to close hedge positions at target profit
- **THEN** the EA SHALL attempt to close each position individually with retries
- **AND** the EA SHALL verify that no positions remain open after closure attempts
- **AND** the EA SHALL log detailed information about each position closed
- **AND** the EA SHALL retry closure if any positions remain open after first attempt

#### Scenario: Hedge closure failure recovery
- **WHEN** some hedge positions fail to close on first attempt
- **THEN** the EA SHALL retry closing remaining positions up to 5 times
- **AND** the EA SHALL increase delay between each retry attempt
- **AND** the EA SHALL log error details for any positions that fail to close
- **AND** the EA SHALL only reset hedge state after successful closure of ALL positions

## ADDED Requirements
### Requirement: Hedge Position Inventory Tracking
The EA SHALL maintain complete visibility of all open hedge positions and their status throughout the hedge lifecycle.

#### Scenario: Position inventory before closure
- **WHEN** the hedge profit target is reached
- **THEN** the EA SHALL log all open positions with details (ticket, profit, direction, volume)
- **AND** the EA SHALL calculate and display the total profit breakdown (profitable vs losing positions)
- **AND** the EA SHALL identify which positions belong to the hedge system

#### Scenario: Multiple symbol position filtering
- **WHEN** the EA is trading multiple symbols or has multiple EAs running
- **THEN** the EA SHALL only close positions matching the configured TradingSymbol
- **AND** the EA SHALL only close positions with the configured MagicNumber
- **AND** the EA SHALL NOT interfere with positions from other EAs or symbols