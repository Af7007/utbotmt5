## ADDED Requirements
### Requirement: Fixed Lot Size Configuration
The EA SHALL provide an option to use a fixed lot size instead of percentage-based risk calculation for position sizing.

#### Scenario: Fixed lot size enabled
- **WHEN** `UseFixedLots` is enabled
- **THEN** the EA SHALL use `FixedLotSize` for all position openings
- **AND** the EA SHALL ignore RiskPercent calculation
- **AND** the EA SHALL ensure the fixed lot size is within broker limits

#### Scenario: Fixed lot size validation
- **WHEN** `FixedLotSize` is outside broker minimum/maximum limits
- **THEN** the EA SHALL adjust the lot size to the nearest valid value
- **AND** the EA SHALL log the adjustment made
- **AND** the EA SHALL continue with the adjusted lot size

#### Scenario: Fixed lot size with hedge positions
- **WHEN** hedge system is active with fixed lots
- **THEN** the EA SHALL use `FixedLotSize` for all hedge positions
- **AND** the EA SHALL apply HedgeMultiplier to the base FixedLotSize
- **AND** the EA SHALL maintain consistent sizing across all hedge levels

#### Scenario: Fixed lot size with trend continuation
- **WHEN** trend continuation reentry occurs with fixed lots
- **THEN** the EA SHALL use `FixedLotSize` for all reentry positions
- **AND** the EA SHALL ignore ReentryRiskPercent when fixed lots are enabled

## MODIFIED Requirements
### Requirement: Volume Calculation Method Selection
The EA SHALL support both fixed lot sizing and percentage-based risk calculation, allowing users to choose their preferred method.

#### Scenario: Volume calculation with fixed lots
- **WHEN** `CalculateVolume()` is called and `UseFixedLots` is true
- **THEN** the EA SHALL return `FixedLotSize` directly
- **AND** the EA SHALL log "Using fixed lot size: X.XX"
- **AND** the EA SHALL skip equity percentage calculations

#### Scenario: Volume calculation with percentage risk
- **WHEN** `CalculateVolume()` is called and `UseFixedLots` is false
- **THEN** the EA SHALL calculate based on RiskPercent (current behavior)
- **AND** the EA SHALL log "Calculating volume based on X% risk"
- **AND** the EA SHALL maintain all existing risk management logic

#### Scenario: Volume step size compliance
- **WHEN** any lot size is calculated or set
- **THEN** the EA SHALL ensure the lot size matches broker's SYMBOL_VOLUME_STEP
- **AND** the EA SHALL round up/down to the nearest valid step if necessary
- **AND** the EA SHALL log any rounding adjustments made