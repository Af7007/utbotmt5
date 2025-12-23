# Change: Adicionar Sistema de Hedge Martingale

## Why
O sistema atual fecha posições quando recebe um sinal oposto, perdendo a oportunidade de recuperar perdas através de hedge. Com um sistema de hedge martingale, quando uma posição está em prejuízo e recebe sinal contrário, uma nova posição na direção oposta é aberta com volume incrementado (martingale), permitindo recuperar as perdas quando a meta de lucro total é atingida.

## What Changes
- **BREAKING**: Novo comportamento quando há sinal oposto com posição em prejuízo
- Adicionar inputs para configurar sistema de hedge:
  - `EnableHedge` - Ativar/desativar sistema de hedge
  - `HedgeProfitTarget` - Meta de lucro em pontos (default: 100)
  - `HedgeMultiplier` - Multiplicador martingale (default: 2.0)
  - `MaxHedgeLevels` - Máximo de níveis de hedge permitidos (segurança)
- Nova lógica em `ProcessTradeSignal`:
  - Se posição aberta está em prejuízo e recebe sinal oposto → abrir hedge
  - Se posição aberta está em lucro ou recebe mesmo sinal → comportamento atual
- Nova função `ManageHedgeProfit`:
  - Calcular lucro/prejuízo total de todas as posições abertas
  - Quando lucro total >= meta → fechar todas as posições
- Nova função `OpenHedgePosition`:
  - Calcular volume com martingale (volume anterior * multiplicador)
  - Abrir posição na direção oposta sem TP/SL (gerenciado pelo lucro total)
- Remover TP/SL individual das posições em hedge (meta é lucro total)

## Impact
- Affected specs: `trading-hedge` (nova capability)
- Affected code: `tvlucro.mq5`
  - `ProcessTradeSignal()` - Detectar condição de hedge
  - `OnTick()` - Adicionar chamada para `ManageHedgeProfit()`
  - Novas funções: `OpenHedgePosition()`, `ManageHedgeProfit()`, `CalculateHedgeVolume()`, `GetTotalOpenProfit()`, `IsPositionInLoss()`, `GetOpenPositionDirection()`
