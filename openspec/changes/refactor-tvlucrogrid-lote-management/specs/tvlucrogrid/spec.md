## ADDED Requirements

### Requirement: Fixed Lot Mode
The EA SHALL provide a fixed lot mode where all positions use the same lot size regardless of grid level or martingale progression.

#### Scenario: Fixed lot without continuous martingale
- **WHEN** `UseFixedLots` is `true` AND `EnableContinuousMartingale` is `false`
- **THEN** the EA SHALL use `FixedLotSize` for all orders
- **AND** the EA SHALL NOT multiply the lot size at any grid level
- **AND** the EA SHALL validate the lot size against broker limits

#### Scenario: Fixed lot with continuous martingale
- **WHEN** `UseFixedLots` is `true` AND `EnableContinuousMartingale` is `true`
- **THEN** the EA SHALL use `FixedLotSize` as the base lot for the first order
- **AND** the EA SHALL multiply the PREVIOUS order's lot by `MartingaleMultiplier` for subsequent orders
- **AND** the EA SHALL track lot size separately for BUY and SELL directions

### Requirement: Percentage-Based Lot Mode
The EA SHALL provide a percentage-based lot mode where position size is calculated based on account equity and risk percentage.

#### Scenario: Percentage lot calculation
- **WHEN** `UseFixedLots` is `false`
- **THEN** the EA SHALL calculate volume as: `equity * (RiskPercent / 100) / stopLossValue`
- **AND** the EA SHALL ensure minimum lot size from broker is respected
- **AND** the EA SHALL log the calculated volume

#### Scenario: Percentage lot with continuous martingale
- **WHEN** `UseFixedLots` is `false` AND `EnableContinuousMartingale` is `true`
- **THEN** the EA SHALL calculate the first order based on `RiskPercent`
- **AND** the EA SHALL multiply the PREVIOUS order's lot by `MartingaleMultiplier` for subsequent orders

## MODIFIED Requirements

### Requirement: CalculateVolume Function
The `CalculateVolume()` function SHALL respect the `UseFixedLots` parameter strictly without any external multiplier interference.

#### Scenario: Fixed lot path
- **WHEN** `UseFixedLots` is `true` AND `EnableContinuousMartingale` is `false`
- **THEN** the EA SHALL return `FixedLotSize` directly
- **AND** the EA SHALL skip any multiplication logic
- **AND** the EA SHALL validate against broker min/max/step

#### Scenario: Percentage calculation path
- **WHEN** `UseFixedLots` is `false` AND `EnableContinuousMartingale` is `false`
- **THEN** the EA SHALL calculate: `volume = equity * (RiskPercent / 100) / SL_value`
- **AND** the EA SHALL return 0.01 if calculation fails
- **AND** the EA SHALL validate against broker min/max/step

#### Scenario: Continuous martingale path
- **WHEN** `EnableContinuousMartingale` is `true` AND a direction is provided
- **THEN** the EA SHALL get the last lot size for that direction
- **WHEN** last lot size > 0
- **THEN** the EA SHALL return `lastLot * MartingaleMultiplier`
- **WHEN** last lot size = 0 (first order in direction)
- **THEN** the EA SHALL use base lot (FixedLotSize if true, otherwise calculated percentage)

## REMOVED Requirements

### Requirement: Hedge Mode
**REMOVED** - The hedge mode system has been completely removed.

**Reason**: Hedge mode introduced complex lot multiplication that interfered with fixed lot mode and made the code harder to maintain. Continuous martingale provides similar functionality with clearer semantics.

**Migration**:
- Users relying on hedge should switch to continuous martingale mode
- The `HedgeLotMultiplier` behavior is now replaced by `MartingaleMultiplier` in continuous martingale mode
- Hedge profit target is replaced by the standard `ProfitTargetMoney` parameter

### Requirement: HedgeLotMultiplier Parameter
**REMOVED** - The `HedgeLotMultiplier` input parameter has been removed.

**Reason**: This parameter multiplied lots in hedge mode, causing confusion with fixed lots. Its functionality is replaced by `MartingaleMultiplier` in continuous martingale mode.

### Requirement: ExecuteGridOrderWithMultiplier Function
**REMOVED** - The `ExecuteGridOrderWithMultiplier()` function has been removed.

**Reason**: This function existed only for hedge mode with lot multiplication. All order execution now uses `ExecuteGridOrder()` directly.

### Requirement: Hedge State Variables
**REMOVED** - All hedge state tracking variables have been removed.

**Reason**: With hedge mode removed, these variables are no longer needed:
- `inHedgeMode`
- `hedgeOldDirection`
- `hedgeStartTime`
- `hedgeNewLevel`
