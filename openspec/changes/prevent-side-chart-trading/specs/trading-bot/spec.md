## ADDED Requirements
### Requirement: Chart Layout Detection and Trading Prevention
The EA SHALL detect when the chart is in an unsuitable layout (side chart or too small) and prevent trading operations until the chart is properly configured.

#### Scenario: Side chart detection
- **WHEN** the chart is in side chart mode and `AllowSideChart` is false
- **THEN** the EA SHALL block all trading operations
- **AND** the EA SHALL display a warning in the info panel
- **AND** the EA SHALL log "BLOCKED: Side chart detected - trading disabled"
- **AND** the EA SHALL continue monitoring for layout changes

#### Scenario: Small chart detection
- **WHEN** the chart width is less than `MinChartWidth` pixels
- **OR** the chart height is less than `MinChartHeight` pixels
- **AND** `CheckChartSize` is enabled
- **THEN** the EA SHALL block all trading operations
- **AND** the EA SHALL display the current dimensions in the panel
- **AND** the EA SHALL show required minimum dimensions

#### Scenario: Chart suitability verification
- **WHEN** trading signals are processed
- **THEN** the EA SHALL first check `IsChartSuitable()`
- **IF** the chart is not suitable
- **THEN** the EA SHALL ignore the signal
- **AND** the EA SHALL update the panel with BLOCKED status
- **AND** the EA SHALL NOT reset `lastProcessedJson`

## MODIFIED Requirements
### Requirement: Enhanced Info Panel with Chart Status
The EA SHALL enhance the info panel to display current chart layout status and trading restrictions.

#### Scenario: Chart status visualization
- **WHEN** the EA is running with ShowInfoPanel enabled
- **THEN** the panel SHALL display current chart dimensions
- **AND** the panel SHALL show chart mode (NORMAL/SIDE/BLOCKED)
- **AND** the panel SHALL use special colors when trading is blocked
- **AND** the panel SHALL display minimum size requirements when applicable

#### Scenario: Trading operation validation
- **WHEN** `ProcessTradeSignal()` is called
- **THEN** the EA SHALL validate chart suitability before processing
- **IF** chart is unsuitable
- **THEN** the EA SHALL log the blocking reason
- **AND** SHALL NOT execute any trades
- **AND** SHALL preserve the signal for when chart becomes suitable

#### Scenario: Automatic recovery
- **WHEN** a blocked chart becomes suitable (normal mode + minimum size)
- **THEN** the EA SHALL automatically resume trading
- **AND** SHALL clear all blocking indicators
- **AND** SHALL log "Trading resumed - chart is now suitable"
- **AND** SHALL process any pending signals normally

## ADDED Requirements
### Requirement: Chart Dimension Monitoring
The EA SHALL continuously monitor chart dimensions to detect layout changes and adjust trading permissions accordingly.

#### Scenario: Real-time dimension updates
- **WHEN** the chart window is resized
- **THEN** the EA SHALL detect the new dimensions
- **AND** SHALL update the trading status accordingly
- **AND** SHALL refresh the panel with new dimensions
- **AND** SHALL automatically unblock if dimensions become adequate

#### Scenario: Minimum dimension configuration
- **WHEN** `CheckChartSize` is true
- **AND** chart dimensions change below minimum requirements
- **THEN** the EA SHALL immediately block new trades
- **AND** SHALL display dimension requirements in the panel
- **AND** SHALL use color coding to indicate restriction type

#### Scenario: Side chart permission override
- **WHEN** `AllowSideChart` is enabled
- **THEN** the EA SHALL allow trading regardless of chart layout
- **AND** the panel SHALL display "SIDE MODE ENABLED"
- **AND** the EA SHALL continue all normal operations