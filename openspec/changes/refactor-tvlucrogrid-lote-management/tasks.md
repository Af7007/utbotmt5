## 1. Remoção de Parâmetros e Variáveis de Hedge

- [x] 1.1 Remover parâmetros de entrada: `EnableHedgeMode`, `HedgeProfitTarget`, `HedgeLotMultiplier`
- [x] 1.2 Remover variáveis globais de hedge: `inHedgeMode`, `hedgeOldDirection`, `hedgeStartTime`, `hedgeNewLevel`
- [x] 1.3 Remover prints relacionados a hedge do `OnInit()`

## 2. Remoção de Lógica de Hedge do OnTimer()

- [x] 2.1 Remover verificação de sinal oposto para ativar hedge (linhas 315-391)
- [x] 2.2 Remover lógica de verificação de hedge mode ativo (linhas 503-535)
- [x] 2.3 Remover verificação de `inHedgeMode` em `ShouldAddGridOrder()` (linha 552)
- [x] 2.4 Remover branch de hedge em `ShouldAddGridOrder()` (linhas 560-568)
- [x] 2.5 Remover verificação de `inHedgeMode` em `ManageTrailingStop()` (linha 580)

## 3. Remoção de Funções de Hedge

- [x] 3.1 Remover função `ExecuteGridOrderWithMultiplier()` (linhas 930-1056)
- [x] 3.2 Substituir chamadas a `ExecuteGridOrderWithMultiplier()` por `ExecuteGridOrder()`

## 4. Refatoração de CalculateVolume()

- [x] 4.1 Simplificar lógica para respeitar `UseFixedLots` corretamente
- [x] 4.2 Quando `UseFixedLots = true`: usar `FixedLotSize` diretamente
- [x] 4.3 Quando `UseFixedLots = false`: calcular baseado em `RiskPercent`
- [x] 4.4 Remover parâmetro `multiplier` da função `CalculateVolume()`
- [x] 4.5 Remover lógica de multiplicador legacy (linhas 1200-1205)
- [x] 4.6 Manter lógica de validação de lot step (linhas 1208-1227)

## 5. Ajuste do Martingale Contínuo

- [x] 5.1 Garantir que martingale contínuo funcione com lotes fixos quando `UseFixedLots = true`
- [x] 5.2 Quando `EnableContinuousMartingale = true` e `UseFixedLots = false`: usar percentual
- [x] 5.3 Quando `EnableContinuousMartingale = true` e `UseFixedLots = true`: usar martingale sobre `FixedLotSize`

## 6. Limpeza de ResetGridState()

- [x] 6.1 Remover reset das variáveis de hedge de `ResetGridState()`
- [x] 6.2 Manter apenas reset de martingale contínuo

## 7. Atualização de Comentários e Logs

- [x] 7.1 Atualizar comentários sobre estratégia (remover referências a hedge)
- [x] 7.2 Simplificar logs de heartbeat (remover indicadores de hedge)

## 8. Validação

- [x] 8.1 Compilar o EA sem erros
- [x] 8.2 Verificar que `UseFixedLots = true` usa sempre o mesmo lote (sem multiplicação)
- [x] 8.3 Verificar que `UseFixedLots = false` calcula corretamente o percentual
- [x] 8.4 Testar martingale contínuo com lotes fixos
- [x] 8.5 Testar martingale contínuo com percentual
