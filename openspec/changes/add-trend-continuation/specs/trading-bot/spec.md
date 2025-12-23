## ADDED Requirements

### Requirement: Trend Continuation Reentry
The system SHALL allow automatic reentry in the same direction as the last trade when it closed with profit and no new signal was received within a configurable period.

#### Scenario: Reentry after TP hit with no new signal
- **GIVEN** EnableTrendContinuation está habilitado
- **AND** último trade fechou com lucro (TP ou breakeven positivo)
- **AND** a direção do último trade foi "buy"
- **WHEN** TrendContinuationDelaySeconds segundos passam sem novo sinal
- **AND** não há posição aberta
- **AND** consecutiveReentries < MaxConsecutiveReentries
- **THEN** o sistema abre uma nova posição BUY automaticamente
- **AND** incrementa consecutiveReentries

#### Scenario: No reentry after stop loss
- **GIVEN** EnableTrendContinuation está habilitado
- **AND** último trade fechou com prejuízo (SL)
- **WHEN** qualquer tempo passa
- **THEN** o sistema NÃO abre reentrada automática
- **AND** reseta consecutiveReentries para 0

#### Scenario: New signal cancels reentry timer
- **GIVEN** EnableTrendContinuation está habilitado
- **AND** último trade fechou com lucro
- **AND** timer de reentrada está contando
- **WHEN** novo sinal de webhook chega
- **THEN** o sistema processa o novo sinal normalmente
- **AND** reseta consecutiveReentries para 0
- **AND** cancela qualquer reentrada pendente

#### Scenario: Max reentries reached
- **GIVEN** EnableTrendContinuation está habilitado
- **AND** consecutiveReentries == MaxConsecutiveReentries
- **WHEN** último trade fecha com lucro
- **THEN** o sistema NÃO abre reentrada automática
- **AND** aguarda novo sinal de webhook

#### Scenario: Feature disabled
- **GIVEN** EnableTrendContinuation está desabilitado (false)
- **WHEN** qualquer trade fecha
- **THEN** o sistema NÃO monitora para reentrada
- **AND** comportamento permanece igual ao atual (aguarda webhook)

### Requirement: Trend Continuation Configuration
The system SHALL allow configuration of reentry parameters via EA input settings.

#### Scenario: Configure reentry delay
- **GIVEN** usuário define TrendContinuationDelaySeconds = 30
- **WHEN** trade fecha com lucro
- **THEN** sistema aguarda 30 segundos antes de considerar reentrada

#### Scenario: Configure max reentries
- **GIVEN** usuário define MaxConsecutiveReentries = 5
- **WHEN** trades consecutivos fecham com lucro e reentram
- **THEN** sistema permite até 5 reentradas antes de parar

#### Scenario: Configure reentry risk
- **GIVEN** usuário define ReentryRiskPercent = 1.0 (menor que RiskPercent principal de 2.0)
- **WHEN** sistema executa reentrada automática
- **THEN** volume é calculado usando 1.0% do equity (mais conservador)

### Requirement: Trade Result Tracking
The system SHALL track the result of the last closed trade to determine reentry eligibility.

#### Scenario: Track winning trade
- **WHEN** posição fecha com profit > 0
- **THEN** sistema registra lastTradeWasWin = true
- **AND** registra lastTradeDirection com a direção da posição
- **AND** registra lastTradeCloseTime com timestamp atual
- **AND** registra lastTradeProfit com o valor do lucro

#### Scenario: Track losing trade
- **WHEN** posição fecha com profit <= 0
- **THEN** sistema registra lastTradeWasWin = false
- **AND** reseta consecutiveReentries para 0

#### Scenario: Detect position closure
- **GIVEN** posição aberta com Magic Number do EA
- **WHEN** posição é fechada (por TP, SL, trailing stop, ou breakeven)
- **THEN** sistema detecta o fechamento automaticamente
- **AND** registra resultado antes do próximo ciclo de timer
