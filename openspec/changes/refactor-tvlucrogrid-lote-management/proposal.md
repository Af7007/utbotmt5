# Change: Refatorar Gestão de Lotes e Remover Hedge do TVLucroGrid

## Why

O TVLucroGrid EA atual tem problemas de gestão de lotes:
1. O parâmetro `UseFixedLots` não é respeitado corretamente em hedge mode (multiplica por `HedgeLotMultiplier`)
2. O modo contínuo de martingale ignora completamente o `UseFixedLots`
3. O hedge mode adiciona complexidade desnecessária e comportamentos inesperados no cálculo de lotes
4. A lógica atual mistura múltiplos multiplicadores de forma confusa

## What Changes

- **REMOVER** completamente o sistema de Hedge (parâmetros e lógica)
- **REMOVER** os parâmetros `EnableHedgeMode`, `HedgeProfitTarget`, `HedgeLotMultiplier`
- **REMOVER** todas as variáveis globais de hedge: `inHedgeMode`, `hedgeOldDirection`, `hedgeStartTime`, `hedgeNewLevel`
- **REMOVER** a função `ExecuteGridOrderWithMultiplier()`
- **SIMPLIFICAR** `CalculateVolume()` para respeitar estritamente `UseFixedLots`
- **MANTER** apenas o modo contínuo de martingale (`EnableContinuousMartingale`)

## Impact

- Affected specs: `tvlucrogrid` (nova spec)
- Affected code: `tvlucrogrid.mq5`
  - Linhas 34-36: Parâmetros de hedge (remover)
  - Linhas 66-70: Variáveis globais de hedge (remover)
  - Linhas 300-391, 502-535, 560-568: Lógica de hedge (remover)
  - Linhas 930-1056: Função `ExecuteGridOrderWithMultiplier()` (remover)
  - Linhas 1156-1239: `CalculateVolume()` (refatorar)
