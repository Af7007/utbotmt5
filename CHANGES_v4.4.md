# TVLucro EA v4.4 - Chart Layout Prevention

## New Features Added:
1. **Chart Layout Detection**: Prevents trading when chart is in side mode or too small
2. **New Input Parameters**:
   - `CheckChartSize` (bool, default: true) - Enable/disable size checking
   - `MinChartWidth` (int, default: 400) - Minimum width in pixels
   - `MinChartHeight` (int, default: 300) - Minimum height in pixels
   - `AllowSideChart` (bool, default: false) - Allow/block side chart trading

3. **New Functions**:
   - `IsSideChart()` - Detects if chart is in vertical orientation
   - `GetChartWidth()` / `GetChartHeight()` - Get chart dimensions
   - `IsChartSuitable()` - Main validation function

4. **Trading Block System**:
   - OnTimer() checks chart suitability before processing signals
   - ProcessTradeSignal() blocks execution if chart unsuitable
   - ExecuteTrendContinuation() and OpenHedgePosition() also check chart

5. **Visual Panel Updates**:
   - New "CHART STATUS" line showing current chart state
   - Color coding: Green (normal), Red (blocked), Orange (too small), Yellow (side allowed)
   - Displays current dimensions when relevant

6. **Logging**:
   - Detailed logging when chart is blocked
   - Configuration displayed on startup
   - Only logs once per minute to avoid spam

## Behavior:
- **Normal Mode**: Chart width >= 400px AND height >= 300px AND not side chart (unless allowed)
- **Side Chart Blocked**: When width < 60% of height and AllowSideChart=false
- **Small Chart Blocked**: When dimensions below minimum and CheckChartSize=true
- **Auto-recovery**: Trading resumes automatically when chart becomes suitable

## Version Update:
- Updated from v4.3 to v4.4
- All existing functionality preserved
- Backward compatible - new parameters have sensible defaults

## Files Modified:
- tvlucro.mq5: Main EA file with all implementations