# Change: Abrir Posição de Trend no Fechamento da Vela

## Why
O EA atualmente abre posições imediatamente ao receber um sinal, mesmo no meio de uma vela. Isso pode resultar em:
1. Entradas prematuras antes da confirmação do fechamento da vela
2. Pior execução de preço (dentro da vela, não no fechamento)
3. Maior volatilidade no momento da entrada
4. Possibilidade de reversão dentro da mesma vela

Abrir posições apenas no fechamento da vela proporciona:
- Confirmação mais forte do movimento
- Preços de execução mais estáveis
- Alinhamento com estratégias de análise técnica
- Redução de ruído de mercado

## What Changes
- Adicionar opção para aguardar fechamento da vela antes de abrir posição
- Implementar sistema de fila de sinais pendentes
- Processar sinais pendentes no fechamento de cada vela
- Configurar timeframe para monitoramento de fechamento
- Preservar comportamento atual (execução imediata) como opção padrão

## Impact
- Affected specs: `trading-bot` (nova funcionalidade de timing de entrada)
- Affected code: `tvlucro.mq5`
  - Novos inputs: `OpenOnCandleClose`, `CandleCloseTimeframe`
  - `OnTimer()` - Adicionar verificação de fechamento de vela
  - `ProcessTradeSignal()` - Modificar para suportar execução pendente
  - Novas funções: `QueuePendingSignal()`, `ProcessPendingSignals()`, `IsCandleClosing()`