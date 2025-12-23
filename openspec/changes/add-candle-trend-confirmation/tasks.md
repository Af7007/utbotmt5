## 1. Implementation

### 1.1 Input Parameters
- [x] 1.1.1 Adicionar `EnableCandleConfirmation` (bool) - habilitar confirmação por candles
- [x] 1.1.2 Adicionar `CandleConfirmationCount` (int) - número de velas a verificar (default: 3)
- [x] 1.1.3 Adicionar `CandleConfirmationTF` (ENUM_TIMEFRAMES) - timeframe para análise
- [x] 1.1.4 Adicionar `RequireConsecutiveCandles` (bool) - exigir todas consecutivas ou maioria
- [x] 1.1.5 Adicionar `WaitForCandleClose` (bool) - aguardar fechamento antes de entrar

### 1.2 Candle Analysis Functions
- [x] 1.2.1 Criar função `IsBullishCandle(int index, ENUM_TIMEFRAMES)` - verificar se vela é bullish
- [x] 1.2.2 Criar função `IsBearishCandle(int index, ENUM_TIMEFRAMES)` - verificar se vela é bearish
- [x] 1.2.3 Criar função `CountBullishCandles(int count, ENUM_TIMEFRAMES)` - contar velas bullish
- [x] 1.2.4 Criar função `CountBearishCandles(int count, ENUM_TIMEFRAMES)` - contar velas bearish
- [x] 1.2.5 Criar função `AreAllCandlesInDirection(string, int, ENUM_TIMEFRAMES)` - verificar todas

### 1.3 Trend Confirmation Logic
- [x] 1.3.1 Criar função `IsTrendConfirmedByCandles(string direction)` - verificação completa
- [x] 1.3.2 Criar função `IsNewCandleFormed(ENUM_TIMEFRAMES)` - detectar nova vela
- [x] 1.3.3 Criar função `TimeframeToString(ENUM_TIMEFRAMES)` - helper para logging
- [x] 1.3.4 Integrar verificação no `ShouldReenterTrend()`

### 1.4 State Management
- [x] 1.4.1 Adicionar `lastCheckedCandleTime` (datetime) - timestamp da última vela
- [x] 1.4.2 Inicializar `lastCheckedCandleTime` no OnInit
- [x] 1.4.3 Atualizar `lastCheckedCandleTime` após reentrada bem-sucedida

### 1.5 Testing
- [ ] 1.5.1 Testar cenário: 3 velas bullish → confirma BUY
- [ ] 1.5.2 Testar cenário: 2 bullish + 1 bearish → NÃO confirma (modo consecutivo)
- [ ] 1.5.3 Testar cenário: aguarda fechamento de vela antes de entrar
- [ ] 1.5.4 Testar cenário: feature desabilitada → comportamento original
- [ ] 1.5.5 Testar cenário: timeframe diferente do gráfico
