# Change: Adicionar TVLucroGrid - Trading Grid Híbrido

## Why
O sistema atual (HttpTrader) executa apenas uma posição por sinal. O TVLucroGrid EA implementa uma estratégia de grid que adiciona ordens progressivamente a cada 5 segundos até atingir meta de lucro ($100), combinando sinais de webhook com reversão automática por tendência.

## What Changes
- **NOVO**: Novo EA `tvlucrogrid.mq5` com estratégia de grid trading
- Grid trading: Adiciona ordens a cada 5 segundos até atingir 20 ordens ou meta de $100
- Sistema híbrido de reversão:
  - Via webhook (sinal oposto)
  - Via detecção de tendência (candles M1)
- Modo Hedge: Quando há posições negativas, adiciona ordens na nova direção sem fechar as antigas
- Painel visual com informações em tempo real
- Multi-símbolo: Suporta XAUUSD, BTCUSD, EURUSD, GBPUSD, etc.

## Impact
- Affected specs: `grid-trading` (nova capability)
- Affected code:
  - `tvlucrogrid.mq5` - Novo EA
  - `webhook_receiver.py` - Já suporta multi-símbolo
