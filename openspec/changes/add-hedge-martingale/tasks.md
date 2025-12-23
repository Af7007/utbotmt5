# Tasks: Hedge Martingale

## 1. Configuração
- [x] 1.1 Adicionar inputs de configuração do hedge
  - `EnableHedge` (bool, default: false)
  - `HedgeProfitTarget` (int, default: 100 pontos)
  - `HedgeMultiplier` (double, default: 2.0)
  - `MaxHedgeLevels` (int, default: 5)
- [x] 1.2 Adicionar variáveis globais de controle
  - `currentHedgeLevel` - nível atual de martingale
  - `isInHedgeMode` - flag indicando modo hedge ativo
  - `lastHedgeVolume` - último volume usado no hedge
  - `initialHedgeVolume` - volume inicial da primeira posição

## 2. Funções de Suporte
- [x] 2.1 Implementar `GetOpenPositionDirection()` - retorna direção da posição aberta (BUY/SELL/NONE)
- [x] 2.2 Implementar `IsAnyPositionInLoss()` - verifica se posições estão em prejuízo total
- [x] 2.3 Implementar `GetTotalOpenProfitInPoints()` - calcula lucro/prejuízo total em pontos de todas as posições
- [x] 2.4 Implementar `GetTotalOpenVolume()` - retorna volume total de posições abertas
- [x] 2.5 Implementar `CountOpenPositions()` - conta posições abertas do EA
- [x] 2.6 Implementar `CalculateHedgeVolume()` - calcula volume do hedge com martingale
- [x] 2.7 Implementar `OpenHedgePosition()` - abre posição de hedge sem TP/SL

## 3. Lógica Principal
- [x] 3.1 Modificar `ProcessTradeSignal()` para detectar condição de hedge:
  - Se EnableHedge=true E tem posição aberta E posição em prejuízo E sinal oposto → hedge
  - Caso contrário → comportamento atual (fechar e abrir nova)
- [x] 3.2 Implementar `ManageHedgeProfit()` - verificar lucro total e fechar quando atingir meta
- [x] 3.3 Adicionar chamada `ManageHedgeProfit()` em `OnTick()`
- [x] 3.4 Desabilitar breakeven/trailing em modo hedge (posições sem TP/SL individual)

## 4. Reset e Segurança
- [x] 4.1 Implementar `ResetHedgeState()` - reset do estado de hedge quando todas posições fecham
- [x] 4.2 Adicionar verificação de `MaxHedgeLevels` para evitar excesso de martingale
- [x] 4.3 Adicionar logs detalhados para monitoramento do hedge

## 5. Inicialização
- [x] 5.1 Adicionar logs de configuração do hedge em `OnInit()`

## 6. Testes (Manual)
- [ ] 6.1 Testar cenário: sinal oposto com posição em prejuízo → abre hedge
- [ ] 6.2 Testar cenário: lucro total atinge meta → fecha todas posições
- [ ] 6.3 Testar cenário: máximo de níveis atingido → comportamento de segurança
- [ ] 6.4 Testar cenário: hedge desabilitado → comportamento normal
