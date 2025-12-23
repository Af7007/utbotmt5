## ADDED Requirements
### Requirement: Visual Strategy Information Panel
The EA SHALL provide an optional visual panel displaying real-time status of all strategies and system information.

#### Scenario: Panel display configuration
- **WHEN** `ShowInfoPanel` is enabled
- **THEN** the EA SHALL create a visual panel on the left side of the chart
- **AND** the panel SHALL display at coordinates (PanelX, PanelY)
- **AND** the panel SHALL have the specified PanelWidth
- **AND** the panel SHALL update every PanelUpdateInterval seconds

#### Scenario: Strategy status visualization
- **WHEN** the panel is displayed
- **THEN** the EA SHALL show status indicators for each strategy:
  - Hedge Martingale: ENABLED/DISABLED with current level
  - Trend Continuation: ENABLED/DISABLED with reentry count
  - Candle Confirmation: ENABLED/DISABLED with confirmation status
  - Candle Close Execution: ENABLED/DISABLED with pending signals count
- **AND** each status SHALL use intuitive colors (green=active, red=inactive)

#### Scenario: Position information display
- **WHEN** positions are open
- **THEN** the panel SHALL display:
  - Number of open positions
  - Current P&L (profit/loss)
  - Position direction(s) and lot size(s)
  - Time since position opened
- **AND** this information SHALL update in real-time

#### Scenario: Performance metrics display
- **WHEN** the EA is running
- **THEN** the panel SHALL show:
  - Total trades executed today
  - Today's profit/loss
  - Current lot size mode (fixed/risk percentage)
  - Last signal received time
  - Last action executed

## MODIFIED Requirements
### Requirement: UI Integration and Updates
The EA SHALL integrate the visual panel seamlessly with existing functionality without impacting performance.

#### Scenario: Panel lifecycle management
- **WHEN** the EA initializes
- **THEN** it SHALL create panel objects if ShowInfoPanel is true
- **WHEN** the EA deinitializes
- **THEN** it SHALL clean up all panel objects
- **AND** SHALL restore chart to original state

#### Scenario: Real-time updates without performance impact
- **WHEN** panel updates are required
- **THEN** the EA SHALL only update data that has changed
- **AND** SHALL limit update frequency to PanelUpdateInterval
- **AND** SHALL NOT interfere with order execution or signal processing

#### Scenario: Multi-timeframe compatibility
- **WHEN** user switches chart timeframes
- **THEN** the panel SHALL remain visible and accurate
- **AND** SHALL not lose or corrupt its data
- **AND** SHALL maintain its position relative to chart edges