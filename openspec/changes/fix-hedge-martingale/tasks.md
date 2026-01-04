## 1. Readicionar Parâmetros e Variáveis de Hedge

- [x] 1.1 Readicionar parâmetros: `EnableHedgeMode`, `HedgeProfitTarget`, `HedgeLotMultiplier`
- [x] 1.2 Readicionar variáveis globais: `inHedgeMode`, `hedgeOldDirection`, `hedgeStartTime`, `hedgeNewLevel`
- [x] 1.3 Remover variáveis temporárias `lastClosedBuyLot` e `lastClosedSellLot` (não serão mais necessárias)

## 2. Readicionar Lógica de Ativação do Hedge

- [x] 2.1 No OnTimer, ao receber sinal oposto, verificar se há posições com prejuízo
- [x] 2.2 Se houver posições negativas E `EnableHedgeMode=true`, ATIVAR hedge (não fechar posições)
- [x] 2.3 Ao ativar hedge, definir `hedgeOldDirection`, `hedgeStartTime`, resetar `hedgeNewLevel`
- [x] 2.4 Atualizar `currentDirection` para nova direção do sinal

## 3. Readicionar Lógica de Saída do Hedge

- [x] 3.1 Verificar se profit total atingiu `HedgeProfitTarget`
- [x] 3.2 Se atingiu, fechar TODAS as posições (ambas direções) e resetar estado
- [x] 3.3 Pular verificação de `ProfitTargetMoney` principal enquanto estiver em hedge

## 4. Corrigir CalculateVolume para Hedge

- [x] 4.1 Quando em hedge mode, usar `HedgeLotMultiplier` sobre o lote base
- [x] 4.2 O multiplicador deve ser aplicado a TODAS as ordens do hedge, não só a primeira
- [x] 4.3 Lote base = `FixedLotSize` se `UseFixedLots=true`, ou calculado por % se false
- [x] 4.4 Remover lógica de `lastClosedBuyLot/lastClosedSellLot` (não mais necessária)

## 5. Corrigir ShouldAddGridOrder

- [x] 5.1 Readicionar verificação de `hedgeNewLevel` para limite de ordens no hedge
- [x] 5.2 Em hedge mode, contar ordens da nova direção separadamente

## 6. Corrigir ExecuteGridOrder

- [x] 6.1 Atualizar `hedgeNewLevel` quando em hedge mode
- [x] 6.2 Adicionar logs indicando "HEDGE MODE" nas ordens

## 7. Atualizar ManageTrailingStop

- [x] 7.1 Desabilitar trailing stop enquanto estiver em hedge mode

## 8. Atualizar ResetGridState

- [x] 8.1 Readicionar reset das variáveis de hedge
- [x] 8.2 Remover `lastClosedBuyLot` e `lastClosedSellLot`

## 9. Validação

- [x] 9.1 Testar: sinal BUY, depois SELL com prejuízo → deve abrir hedge (não fechar BUY)
- [x] 9.2 Testar: em hedge, todas as ordens SELL devem ter lote × HedgeLotMultiplier
- [x] 9.3 Testar: ao atingir HedgeProfitTarget, fechar todas as posições
