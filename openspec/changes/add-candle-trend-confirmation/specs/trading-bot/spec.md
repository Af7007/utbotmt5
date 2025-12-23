## ADDED Requirements

### Requirement: Candle Direction Analysis
The system SHALL analyze candle direction (bullish/bearish) to confirm market trend before executing trend continuation reentry.

#### Scenario: Identify bullish candle
- **GIVEN** a completed candle on the configured timeframe
- **WHEN** the candle's close price is greater than its open price
- **THEN** the system identifies this candle as bullish

#### Scenario: Identify bearish candle
- **GIVEN** a completed candle on the configured timeframe
- **WHEN** the candle's close price is less than its open price
- **THEN** the system identifies this candle as bearish

#### Scenario: Identify neutral/doji candle
- **GIVEN** a completed candle on the configured timeframe
- **WHEN** the candle's close price equals its open price
- **THEN** the system identifies this candle as neutral (not counted for confirmation)

### Requirement: Trend Confirmation by Consecutive Candles
The system SHALL verify that a configurable number of recent candles are aligned with the expected trade direction before allowing trend continuation reentry.

#### Scenario: Confirm bullish trend with consecutive candles
- **GIVEN** EnableCandleConfirmation is enabled
- **AND** RequireConsecutiveCandles is true
- **AND** CandleConfirmationCount is set to 3
- **AND** the last trade direction was "buy"
- **WHEN** the last 3 completed candles are all bullish
- **THEN** the trend is confirmed for BUY reentry

#### Scenario: Reject reentry when candles are mixed
- **GIVEN** EnableCandleConfirmation is enabled
- **AND** RequireConsecutiveCandles is true
- **AND** CandleConfirmationCount is set to 3
- **AND** the last trade direction was "buy"
- **WHEN** only 2 of the last 3 candles are bullish
- **THEN** the trend is NOT confirmed
- **AND** reentry is delayed until confirmation

#### Scenario: Confirm trend with majority candles
- **GIVEN** EnableCandleConfirmation is enabled
- **AND** RequireConsecutiveCandles is false (majority mode)
- **AND** CandleConfirmationCount is set to 5
- **AND** the last trade direction was "sell"
- **WHEN** at least 3 of the last 5 candles are bearish
- **THEN** the trend is confirmed for SELL reentry

### Requirement: Wait for Candle Close
The system SHALL wait for the current candle to close before executing trend continuation reentry to avoid entering on incomplete price action.

#### Scenario: Wait for candle close before entry
- **GIVEN** EnableCandleConfirmation is enabled
- **AND** WaitForCandleClose is true
- **AND** trend is confirmed
- **AND** current candle is still forming
- **WHEN** ShouldReenterTrend() is called
- **THEN** reentry is delayed until candle closes

#### Scenario: Entry on new candle open
- **GIVEN** EnableCandleConfirmation is enabled
- **AND** WaitForCandleClose is true
- **AND** trend is confirmed
- **WHEN** a new candle just opened (previous candle closed)
- **THEN** reentry is allowed to execute

#### Scenario: Immediate entry when wait disabled
- **GIVEN** EnableCandleConfirmation is enabled
- **AND** WaitForCandleClose is false
- **AND** trend is confirmed
- **WHEN** ShouldReenterTrend() is called
- **THEN** reentry executes immediately without waiting for candle close

### Requirement: Configurable Confirmation Timeframe
The system SHALL allow configuration of the timeframe used for candle analysis, which may differ from the chart timeframe.

#### Scenario: Use different timeframe for confirmation
- **GIVEN** EnableCandleConfirmation is enabled
- **AND** CandleConfirmationTimeframe is set to PERIOD_M15
- **AND** the EA is running on M5 chart
- **WHEN** analyzing candles for trend confirmation
- **THEN** the system uses M15 candles for analysis

#### Scenario: Use current timeframe when set to PERIOD_CURRENT
- **GIVEN** EnableCandleConfirmation is enabled
- **AND** CandleConfirmationTimeframe is set to PERIOD_CURRENT
- **AND** the EA is running on M5 chart
- **WHEN** analyzing candles for trend confirmation
- **THEN** the system uses M5 candles for analysis

### Requirement: Candle Confirmation Configuration
The system SHALL allow configuration of candle confirmation parameters via EA input settings.

#### Scenario: Configure candle count
- **GIVEN** user sets CandleConfirmationCount = 5
- **WHEN** trend confirmation is checked
- **THEN** system analyzes the last 5 completed candles

#### Scenario: Configure confirmation mode
- **GIVEN** user sets RequireConsecutiveCandles = false
- **WHEN** trend confirmation is checked
- **THEN** system uses majority logic (more than 50% in direction)

#### Scenario: Feature disabled
- **GIVEN** EnableCandleConfirmation is disabled
- **WHEN** ShouldReenterTrend() is called
- **THEN** system skips candle analysis
- **AND** uses only timer-based reentry logic

## MODIFIED Requirements

### Requirement: Trend Continuation Reentry
The system SHALL allow automatic reentry in the same direction as the last trade when it closed with profit, no new signal was received within a configurable period, AND candle trend is confirmed (if enabled).

#### Scenario: Reentry with candle confirmation
- **GIVEN** EnableTrendContinuation is enabled
- **AND** EnableCandleConfirmation is enabled
- **AND** last trade closed with profit
- **AND** TrendContinuationDelaySec seconds have passed
- **AND** last N candles confirm the trend direction
- **WHEN** a new candle opens (if WaitForCandleClose is true)
- **THEN** the system opens a reentry position

#### Scenario: Reentry blocked by candle analysis
- **GIVEN** EnableTrendContinuation is enabled
- **AND** EnableCandleConfirmation is enabled
- **AND** last trade closed with profit
- **AND** TrendContinuationDelaySec seconds have passed
- **AND** candles do NOT confirm the trend direction
- **WHEN** ShouldReenterTrend() is called
- **THEN** the system does NOT open a reentry position
- **AND** continues checking on subsequent timer ticks
