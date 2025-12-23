## 1. Implementation

### 1.1 Input Parameters
- [x] 1.1.1 Adicionar `EnableTrendContinuation` (bool) - habilitar/desabilitar feature
- [x] 1.1.2 Adicionar `TrendContinuationDelaySec` (int) - tempo de espera antes de reentrar (default: 60)
- [x] 1.1.3 Adicionar `MaxConsecutiveReentries` (int) - máximo de reentradas seguidas (default: 3)
- [x] 1.1.4 Adicionar `ReentryRiskPercent` (double) - % de risco para reentradas (default: 1.5%)

### 1.2 Global State Variables
- [x] 1.2.1 Adicionar `lastTradeDirection` (string) - "buy" ou "sell"
- [x] 1.2.2 Adicionar `lastTradeCloseTime` (datetime) - timestamp do fechamento
- [x] 1.2.3 Adicionar `lastTradeProfit` (double) - lucro do último trade
- [x] 1.2.4 Adicionar `lastTradeWasWin` (bool) - se fechou com lucro
- [x] 1.2.5 Adicionar `consecutiveReentries` (int) - contador de reentradas
- [x] 1.2.6 Adicionar `hasOpenPosition` (bool) - cache de posição aberta
- [x] 1.2.7 Adicionar `lastKnownTicket` (ulong) - ticket da última posição

### 1.3 Detection Logic
- [x] 1.3.1 Criar função `HasOpenPositionForSymbol()` - verificar posição aberta
- [x] 1.3.2 Criar função `GetCurrentPositionTicket()` - obter ticket atual
- [x] 1.3.3 Criar função `GetPositionDirection()` - obter direção da posição
- [x] 1.3.4 Criar função `CheckPositionClosure()` - detectar quando posição foi fechada
- [x] 1.3.5 Criar função `RecordTradeResult()` - registrar resultado do trade via histórico
- [x] 1.3.6 Integrar detecção no `OnTick()`

### 1.4 Reentry Logic
- [x] 1.4.1 Criar função `ShouldReenterTrend()` - verificar condições de reentrada
- [x] 1.4.2 Criar função `CalculateReentryVolume()` - calcular volume com risco menor
- [x] 1.4.3 Criar função `ExecuteTrendContinuation()` - executar reentrada
- [x] 1.4.4 Integrar no `OnTimer()` para verificar periodicamente
- [x] 1.4.5 Reset do contador de reentradas quando novo sinal chega em `ProcessTradeSignal()`

### 1.5 Testing
- [ ] 1.5.1 Testar cenário: TP hit → timer → reentry na mesma direção
- [ ] 1.5.2 Testar cenário: SL hit → NÃO reentrar
- [ ] 1.5.3 Testar cenário: novo sinal chega antes do timer → NÃO reentrar
- [ ] 1.5.4 Testar cenário: max reentries atingido → parar
- [ ] 1.5.5 Testar cenário: feature desabilitada → comportamento normal
