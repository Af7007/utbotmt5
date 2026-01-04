# Change: Corrigir Hedge Mode - Reverter Remoção e Ajustar Martingale

## Why

A mudança anterior removeu incorretamente o hedge mode. O usuário precisa:
1. **Hedge Mode**: Ao receber sinal oposto com posições negativas, NÃO fechar posições - abrir novas ordens na direção do sinal (hedge)
2. **Lote multiplicado consistente**: Todas as ordens do hedge devem usar lote multiplicado, não apenas a primeira
3. **Martingale contínuo**: O grid deve manter lote multiplicado enquanto estiver em hedge

## What Changes

- **READICIONAR** parâmetros de hedge: `EnableHedgeMode`, `HedgeProfitTarget`, `HedgeLotMultiplier`
- **READICIONAR** variáveis globais: `inHedgeMode`, `hedgeOldDirection`, `hedgeStartTime`, `hedgeNewLevel`
- **READICIONAR** lógica de detecção de posições negativas para ativar hedge
- **CORRIGIR** `CalculateVolume()` para usar lote multiplicado em TODAS as ordens do hedge (não só primeira)
- **MANTER** a separação entre lote fixo/percentual e multiplicador de hedge

## Impact

- Affected specs: `tvlucrogrid`
- Affected code: `tvlucrogrid.mq5`
  - Linhas 25-31: Readicionar parâmetros de hedge
  - Linhas 62-68: Readicionar variáveis de hedge
  - Linhas 303-341: Readicionar lógica de ativação de hedge
  - Linhas 411-427: Readicionar verificação de saída de hedge
  - Linhas 430-439: Usar lote multiplicado no grid do hedge
  - Linhas 607-618: Readicionar verificação de hedge em ShouldAddGridOrder
