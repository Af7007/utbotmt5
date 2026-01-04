## ADDED Requirements

### Requirement: Hedge Mode with Negative Positions
The EA SHALL provide a hedge mode that opens positions in the opposite direction when a reversal signal is received AND existing positions are in loss, instead of closing the losing positions.

#### Scenario: Activate hedge on opposite signal with losses
- **WHEN** `EnableHedgeMode` is `true`
- **AND** there are open positions in one direction
- **AND** those positions have negative profit (loss)
- **AND** an opposite signal is received
- **THEN** the EA SHALL NOT close the existing positions
- **AND** the EA SHALL set `inHedgeMode = true`
- **AND** the EA SHALL store the old direction in `hedgeOldDirection`
- **AND** the EA SHALL open the first position in the new direction with multiplied lot size

#### Scenario: Close positions on opposite signal with profit
- **WHEN** `EnableHedgeMode` is `false` OR all positions are profitable
- **AND** an opposite signal is received
- **THEN** the EA SHALL close all positions
- **AND** the EA SHALL open new position in the signal direction

### Requirement: Hedge Lot Multiplier
The EA SHALL apply a lot multiplier to ALL positions opened in hedge mode, not just the first one.

#### Scenario: All hedge orders use multiplied lot
- **WHEN** `inHedgeMode` is `true`
- **THEN** every new order SHALL calculate volume as: `baseVolume × HedgeLotMultiplier`
- **AND** baseVolume SHALL be `FixedLotSize` if `UseFixedLots=true`, or calculated by percentage if false
- **AND** the multiplied lot SHALL apply to ALL grid orders in the hedge direction

### Requirement: Hedge Profit Target
The EA SHALL close all positions (both directions) when total profit reaches the hedge profit target.

#### Scenario: Exit hedge when profit target reached
- **WHEN** `inHedgeMode` is `true`
- **AND** total profit from ALL positions (both directions) >= `HedgeProfitTarget`
- **THEN** the EA SHALL close all positions
- **AND** the EA SHALL reset hedge state
- **AND** the EA SHALL wait for a new signal before trading

## MODIFIED Requirements

### Requirement: CalculateVolume Function
The `CalculateVolume()` function SHALL support hedge mode with lot multiplier applied to all hedge orders.

#### Scenario: Fixed lot with hedge multiplier
- **WHEN** `UseFixedLots` is `true` AND `inHedgeMode` is `true`
- **THEN** the EA SHALL return `FixedLotSize × HedgeLotMultiplier`
- **AND** this SHALL apply to ALL orders while in hedge mode

#### Scenario: Percentage lot with hedge multiplier
- **WHEN** `UseFixedLots` is `false` AND `inHedgeMode` is `true`
- **THEN** the EA SHALL calculate base volume from percentage
- **AND** multiply the result by `HedgeLotMultiplier`
- **AND** this SHALL apply to ALL orders while in hedge mode

#### Scenario: Normal mode (no hedge)
- **WHEN** `inHedgeMode` is `false`
- **THEN** the EA SHALL calculate volume normally (fixed or percentage)
- **AND** the EA SHALL NOT apply any multiplier

## REMOVED Requirements

### Requirement: Reversal Martingale with lastClosedLots
**REMOVED** - The variables `lastClosedBuyLot` and `lastClosedSellLot` are removed.

**Reason**: Hedge mode now handles martingale through `HedgeLotMultiplier` applied to all hedge orders. The previous attempt to use "closed lot" for reversal martingale was incorrect.

**Migration**: Use `EnableHedgeMode=true` and `HedgeLotMultiplier` for multiplied lots on reversal with existing positions.
