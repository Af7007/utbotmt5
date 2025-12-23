# Marcador de Tendências no Painel

## ADDED Requirements
### Requirement: Trend Indicator Display
The EA SHALL display a visual trend indicator in the info panel showing the current market direction based on moving averages.

#### Scenario: Trend direction calculation
- **WHEN** the info panel is enabled and TrendMarkerEnabled is true
- **THEN** the EA SHALL calculate trend using two moving averages (fast and slow)
- **AND** the EA SHALL classify trend as UP (fast > slow), DOWN (fast < slow), or NEUTRAL (near equal)
- **AND** the EA SHALL update the trend indicator on each tick or panel update

#### Scenario: Visual trend representation
- **WHEN** displaying trend information
- **THEN** the panel SHALL show:
  - Arrow icon: ↑ for uptrend, ↓ for downtrend, → for neutral
  - Trend text: "TREND: UP" / "TREND: DOWN" / "TREND: NEUTRAL"
  - Color coding: Green for uptrend, Red for downtrend, Gray for neutral
  - Trend strength indicator (optional): "STRONG" / "MODERATE" / "WEAK"

#### Scenario: Trend strength calculation
- **WHEN** TrendMarkerEnabled is true and trend strength display is enabled
- **THEN** the EA SHALL calculate trend strength based on:
  - Angle between moving averages
  - Distance between moving averages in percentage
  - Recent price action consistency
  - **AND** SHALL classify as:
    - STRONG: > 2% separation and consistent angle
    - MODERATE: 0.5-2% separation
    - WEAK: < 0.5% separation

#### Scenario: Trend marker configuration
- **WHEN** configuring the EA
- **THEN** the user SHALL be able to set:
  - TrendMarkerEnabled (bool, default: true) - Enable/disable trend marker
  - TrendMAPeriodFast (int, default: 9) - Fast MA period
  - TrendMAPeriodSlow (int, default: 21) - Slow MA period
  - TrendMAType (enum, default: EMA) - Type: SMA, EMA, SMMA, LWMA
  - TrendStrengthDisplay (bool, default: true) - Show trend strength

#### Scenario: Real-time trend updates
- **WHEN** a new tick arrives and panel update interval is reached
- **THEN** the EA SHALL:
  - Recalculate moving averages with latest price
  - Update trend direction if changed
  - Refresh visual indicator immediately
  - Log trend changes if enabled

#### Scenario: Trend marker positioning
- **WHEN** displaying the trend marker in the panel
- **THEN** the EA SHALL position it:
  - Above strategy status section
  - With prominent visual hierarchy
  - Using larger font size (10pt) compared to other info
  - With appropriate spacing from other elements

## MODIFIED Requirements
### Requirement: Enhanced Panel Layout
The EA SHALL reorganize the info panel to accommodate the trend marker prominently.

#### Scenario: Panel reorganization
- **WHEN** TrendMarkerEnabled is true
- **THEN** the panel SHALL layout:
  1. Header (TVLucro EA v4.5)
  2. **TREND MARKER** (new, highlighted section)
  3. Strategy Status (Hedge, Trend, Candle, Close)
  4. Chart Status (if chart checking enabled)
  5. Position Info
  6. Performance Info
  7. Configuration Info
  8. Last Action & Signal
  9. Timestamp

#### Scenario: Panel height adjustment
- **WHEN** adding trend marker
- **THEN** the panel background SHALL increase height by 30 pixels
- **AND** SHALL maintain proper spacing between sections
- **AND** SHALL adjust all subsequent element positions

#### Scenario: Visual prominence
- **WHEN** displaying trend marker
- **THEN** the EA SHALL:
  - Use bold font for trend text
  - Add subtle background highlight for trend section
  - Ensure high contrast for trend arrow
  - Update panel width if needed for trend text

## TECHNICAL Requirements
### Implementation Details
- Moving average calculations using MQL5 iMA() function
- Efficient update mechanism (only when price changes significantly)
- Color constants defined for trend states
- Error handling for MA calculation failures
- Option to disable without removing code (for performance)

### Performance Considerations
- Cache MA values and only recalculate when necessary
- Limit trend strength calculations to panel update interval
- Use built-in MQL5 indicators for optimal performance