# Grid Trading Specification

Estratégia de grid trading híbrida que combina sinais externos (webhook) com reversão automática por tendência, usando modo hedge para proteção contra perdas.

## ADDED Requirements

### Requirement: Signal-Based Grid Initiation
O EA SHALL iniciar um grid quando receber um sinal do webhook.

#### Scenario: First signal starts grid
- **WHEN** webhook envia `{"action": "long", "symbol": "XAUUSD"}`
- **THEN** EA abre primeira ordem BUY
- **AND** define `currentDirection = "buy"`
- **AND** começa a adicionar ordens a cada 5 segundos

#### Scenario: Signal for different symbol ignored
- **WHEN** EA configurado para XAUUSD
- **AND** webhook envia sinal para BTCUSD
- **THEN** sinal é ignorado
- **AND** nenhum ordem é aberta

### Requirement: Time-Based Grid Addition
O EA SHALL adicionar ordens ao grid em intervalos fixos de tempo, independente de novos sinais.

#### Scenario: Add grid order every 5 seconds
- **GIVEN** grid está ativo com direção BUY
- **AND** `GridIntervalSeconds = 5`
- **AND** lucro total < $100
- **AND** grid level < 20
- **WHEN** 5 segundos se passaram desde última ordem
- **THEN** EA abre nova ordem BUY
- **AND** incrementa `currentGridLevel`

#### Scenario: Stop adding when max level reached
- **GIVEN** grid level = 20
- **WHEN** intervalo de 5 segundos passa
- **THEN** nenhuma ordem é aberta
- **AND** EA registra "Max grid orders reached"

### Requirement: Profit Target Close All
O EA SHALL fechar todas as posições quando o lucro total atingir a meta configurada.

#### Scenario: Close all on $100 profit
- **GIVEN** grid está ativo
- **AND** `ProfitTargetMoney = 100.0`
- **AND** `CloseAllOnTarget = true`
- **WHEN** lucro total da conta >= $100
- **THEN** EA fecha todas as posições
- **AND** reseta estado do grid
- **AND** aguarda novo sinal do webhook

#### Scenario: CloseAllOnTarget disabled
- **GIVEN** `CloseAllOnTarget = false`
- **WHEN** lucro total >= $100
- **THEN** posições permanecem abertas
- **AND** grid continua adicionando ordens

### Requirement: Trend-Based Automatic Reversal
O EA SHALL detectar mudança de tendência via análise de candles e reverter automaticamente quando condições forem atendidas.

#### Scenario: Reversal with all profitable positions
- **GIVEN** grid ativo na direção BUY
- **AND** todas as 5 posições estão lucrativas
- **AND** lucro total >= $50
- **WHEN** 3 candles consecutivos são bearish
- **THEN** EA fecha todas as posições BUY
- **AND** abre primeiras ordens SELL
- **AND** `currentDirection = "sell"`
- **AND** continua grid na nova direção

#### Scenario: Trend reversal blocked - insufficient profit
- **GIVEN** grid ativo na direção BUY
- **AND** lucro total = $30 (< $50 mínimo)
- **WHEN** 3 candles consecutivos são bearish
- **THEN** reversão é bloqueada
- **AND** grid continua na direção atual

#### Scenario: Trend reversal with losing positions triggers hedge
- **GIVEN** grid ativo na direção BUY
- **AND** lucro total = $60
- **AND** 2 das 5 posições estão negativas
- **WHEN** 3 candles consecutivos são bearish
- **THEN** MANTÉM posições BUY abertas
- **AND** ativa modo Hedge
- **AND** abre primeiras ordens SELL
- **AND** continua adicionando SELLs a cada 5s

### Requirement: Hedge Mode Protection
O EA SHALL usar modo hedge quando há posições negativas e tendência muda, evitando realizar perdas.

#### Scenario: Enter hedge mode
- **GIVEN** grid BUY ativo com algumas posições negativas
- **WHEN** tendência muda para bearish
- **THEN** `inHedgeMode = true`
- **AND** `hedgeOldDirection = "buy"`
- **AND** posições BUY permanecem abertas
- **AND** EA abre ordens SELL
- **AND** `currentDirection = "sell"` (para novas ordens)

#### Scenario: Exit hedge on profit target
- **GIVEN** modo hedge ativo
- **AND** `HedgeProfitTarget = 30.0`
- **WHEN** lucro total (BUYs + SELLs) >= $30
- **THEN** EA fecha TODAS as posições
- **AND** reseta estado do grid
- **AND** aguarda novo sinal do webhook

#### Scenario: Exit hedge on breakeven
- **GIVEN** modo hedge ativo
- **AND** `CloseHedgeOnBreakeven = true`
- **WHEN** lucro total >= $0
- **THEN** EA fecha TODAS as posições
- **AND** reseta estado do grid

#### Scenario: Exit hedge on max duration
- **GIVEN** modo hedge ativo
- **AND** `MaxHedgeDurationMinutes = 60`
- **WHEN** 60 minutos se passaram desde início do hedge
- **THEN** EA fecha TODAS as posições
- **AND** reseta estado do grid

### Requirement: Stop Adding Against Trend
O EA SHALL parar de adicionar ordens quando candles indicam tendência contrária.

#### Scenario: Stop grid when 2 candles against
- **GIVEN** grid BUY ativo
- **AND** `AgainstTrendThreshold = 2`
- **WHEN** 2 candles consecutivos são bearish
- **THEN** EA para de adicionar ordens BUY
- **AND** aguarda reversão ou sinal oposto

### Requirement: Webhook Signal Reversal
O EA SHALL processar sinais opostos do webhook e acionar reversão quando condições permitirem.

#### Scenario: Opposite webhook signal with profit
- **GIVEN** grid BUY ativo
- **AND** lucro total >= $50
- **AND** todas posições lucrativas
- **WHEN** webhook envia `{"action": "short", "symbol": "XAUUSD"}`
- **THEN** EA fecha todas posições BUY
- **AND** abre primeiras ordens SELL
- **AND** continua grid na nova direção

#### Scenario: Opposite webhook signal with losses
- **GIVEN** grid BUY ativo
- **AND** algumas posições negativas
- **WHEN** webhook envia `{"action": "short", "symbol": "XAUUSD"}`
- **THEN** EA NÃO fecha posições BUY
- **AND** ativa modo Hedge
- **AND** abre ordens SELL ao lado

#### Scenario: Same webhook signal ignored
- **GIVEN** grid BUY ativo
- **WHEN** webhook envia `{"action": "long", "symbol": "XAUUSD"}` (mesma direção)
- **THEN** sinal é ignorado
- **AND** grid continua normalmente

### Requirement: Visual Information Panel
O EA SHALL exibir painel visual com informações em tempo real do grid.

#### Scenario: Panel displays current state
- **GIVEN** `ShowInfoPanel = true`
- **WHEN** EA está rodando
- **THEN** painel mostra:
  - Direção atual (BUY/SELL/NONE)
  - Nível do grid (0-20)
  - Lucro total em $
  - Tempo até próxima ordem
  - Status (WAITING/GRID ACTIVE/TARGET REACHED)

### Requirement: Multi-Symbol Support
O EA SHALL suportar múltiplos símbolos via arquivo de sinal específico.

#### Scenario: Each symbol has independent signal file
- **GIVEN** EA configurado para XAUUSD
- **WHEN** webhook envia `{"action": "long", "symbol": "BTCUSD"}`
- **THEN** arquivo `signal_BTCUSD.json` é criado
- **AND** EA XAUUSD ignora este sinal
- **AND** EA BTCUSD (se existir) processa o sinal

### Requirement: Trailing Stop
O EA SHALL implementar trailing stop para posições lucrativas.

#### Scenario: Trailing stop activates
- **GIVEN** `EnableTrailingStop = true`
- **AND** `TrailingStartPoints = 200`
- **AND** posição BUY com 250 pontos de lucro
- **WHEN** preço sobe para 300 pontos de lucro
- **THEN** stop loss é movido para 200 pontos de lucro
- **AND** lucro garantido de 100 pontos

### Requirement: Drawdown Protection
O EA SHALL parar de adicionar ordens quando o drawdown máximo for atingido.

#### Scenario: Stop adding on max drawdown
- **GIVEN** grid ativo
- **AND** `MaxDrawdownPercent = 10.0`
- **AND** equity da conta = $10,000
- **WHEN** lucro total <= -$1,000 (10% do equity)
- **THEN** EA para de adicionar ordens
- **AND** registra "Drawdown limit reached"

### Requirement: Per-Order Stop Loss
O EA SHALL fechar individualmente posições que excedam o limite máximo de perda.

#### Scenario: Close position on max loss
- **GIVEN** posição aberta com -$25 de prejuízo
- **AND** `MaxLossPerOrder = 20.0`
- **WHEN** perda da posição excede $20
- **THEN** EA fecha esta posição individualmente
- **AND** outras posições permanecem abertas

### Requirement: Position State Recovery
O EA SHALL detectar quando posições são fechadas externamente e resetar o estado do grid.

#### Scenario: Reset when no positions exist
- **GIVEN** grid ativo com `currentDirection = "buy"`
- **AND** `currentGridLevel = 5`
- **WHEN** todas as posições são fechadas externamente (manualmente)
- **THEN** EA detecta que não há posições
- **AND** reseta `currentDirection = ""`
- **AND** reseta `currentGridLevel = 0`
- **AND** aguarda novo sinal do webhook

### Requirement: Force Reset Mode
O EA SHALL suportar modo de reset forçado ao receber novo sinal, mesmo com posições negativas.

#### Scenario: Force reset closes losing positions
- **GIVEN** grid ativo com algumas posições negativas
- **AND** `ForceResetOnNewSignal = true`
- **WHEN** novo sinal webhook chega
- **THEN** EA avisa sobre posições negativas que serão fechadas
- **AND** espera 5 segundos (aviso)
- **AND** fecha TODAS as posições (incluindo negativas)
- **AND** reseta estado do grid
- **AND** abre primeira ordem na nova direção

#### Scenario: Force reset disabled (default)
- **GIVEN** grid ativo com algumas posições negativas
- **AND** `ForceResetOnNewSignal = false`
- **WHEN** novo sinal webhook chega
- **THEN** EA NÃO fecha posições negativas
- **AND** usa modo Hedge se sinal for oposto

### Requirement: Trend Detection Options
O EA SHALL configurar modo de detecção de tendência (consecutivo ou maioria).

#### Scenario: Require consecutive candles (default)
- **GIVEN** `RequireConsecutiveCandles = true`
- **AND** `TrendCheckCandles = 3`
- **WHEN** verificando tendência bearish
- **THEN** todos os 3 candles DEVEM ser bearish para confirmar

#### Scenario: Majority mode for trend detection
- **GIVEN** `RequireConsecutiveCandles = false`
- **AND** `TrendCheckCandles = 3`
- **WHEN** verificando tendência bearish
- **THEN** 2 de 3 candles bearish é suficiente para confirmar

### Requirement: Reverse Regardless of Profit
O EA SHALL suportar reversão automática mesmo sem lucro mínimo se configurado.

#### Scenario: Reverse without profit when enabled
- **GIVEN** `ReverseOnTrendRegardlessProfit = true`
- **AND** lucro total = $20 (< $50 mínimo)
- **AND** 3 candles confirmam tendência oposta
- **AND** todas posições lucrativas
- **WHEN** condição de reversão é avaliada
- **THEN** EA reverte mesmo com lucro abaixo do mínimo

#### Scenario: Reverse blocked when disabled (default)
- **GIVEN** `ReverseOnTrendRegardlessProfit = false`
- **AND** lucro total = $20 (< $50 mínimo)
- **AND** 3 candles confirmam tendência oposta
- **WHEN** condição de reversão é avaliada
- **THEN** reversão é bloqueada por lucro insuficiente
