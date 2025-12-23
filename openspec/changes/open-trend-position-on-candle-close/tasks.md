# Tasks: Abrir Posição de Trend no Fechamento da Vela

## 1. Novos Parâmetros de Configuração
- [ ] 1.1 Adicionar `OpenOnCandleClose` (bool) - habilitar/desabilitar feature
- [ ] 1.2 Adicionar `CandleCloseTimeframe` (ENUM_TIMEFRAMES) - timeframe para monitorar (default: PERIOD_CURRENT)
- [ ] 1.3 Adicionar `MaxPendingSignals` (int) - máximo de sinais pendentes (default: 3)
- [ ] 1.4 Adicionar `PendingSignalExpirationSec` (int) - expiração de sinal pendente (default: 300)

## 2. Variáveis Globais para Gerenciamento
- [ ] 2.1 Adicionar array `pendingSignals[]` - fila de sinais pendentes
- [ ] 2.2 Adicionar `pendingSignalsCount` - contador de sinais na fila
- [ ] 2.3 Adicionar `lastCandleCloseTime` - último timestamp de fechamento
- [ ] 2.4 Adicionar `isProcessingCandleClose` - flag para evitar processamento duplicado

## 3. Funções de Gerenciamento de Fila
- [ ] 3.1 Implementar `QueuePendingSignal(string signalJson)` - adiciona sinal à fila
- [ ] 3.2 Implementar `GetOldestPendingSignal()` - retorna sinal mais antigo
- [ ] 3.3 Implementar `RemoveExpiredPendingSignals()` - limpa sinais expirados
- [ ] 3.4 Implementar `ClearPendingSignals()` - limpa toda a fila

## 4. Detecção de Fechamento de Vela
- [ ] 4.1 Implementar `IsNewCandleClosed(ENUM_TIMEFRAMES)` - detecta nova vela fechada
- [ ] 4.2 Implementar `GetCurrentCandleTime(ENUM_TIMEFRAMES)` - obtém tempo da vela atual
- [ ] 4.3 Implementar `WasCandleJustClosed()` - verificação precisa de fechamento
- [ ] 4.4 Adicionar tolerância para evitar falsos positivos

## 5. Modificar OnTimer()
- [ ] 5.1 Adicionar verificação de `OpenOnCandleClose`
- [ ] 5.2 Se habilitado: chamar `QueuePendingSignal()` em vez de `ProcessTradeSignal()`
- [ ] 5.3 Adicionar chamada para `ProcessPendingSignals()` na detecção de fechamento
- [ ] 5.4 Implementar limite de tempo para não processar muito rápido no fechamento

## 6. Modificar ProcessTradeSignal()
- [ ] 6.1 Adicionar parâmetro `isPendingExecution` (default: false)
- [ ] 6.2 Quando `isPendingExecution = true`: pular verificação de timestamp
- [ ] 6.3 Adicionar logging diferenciado para execução pendente
- [ ] 6.4 Garantir que posições anteriores sejam fechadas normalmente

## 7. Integração e Testes
- [ ] 7.1 Testar com `OpenOnCandleClose = false` - comportamento normal
- [ ] 7.2 Testar com `OpenOnCandleClose = true` - aguardar fechamento
- [ ] 7.3 Testar múltiplos sinais na mesma vela - apenas o último deve executar
- [ ] 7.4 Testar expiração de sinais pendentes
- [ ] 7.5 Verificar compatibilidade com Hedge e Trend Continuation