# Change: Corrigir Fechamento Total do Hedge

## Why
O sistema de hedge atual está deixando ordens negativas abertas quando o lucro total atinge a meta. Isso é crítico porque:
1. Positivou o total (lucro) mas ainda há posições negativas em aberto
2. Exposição de risco contínuo com posições perdedoras
3. Comportamento inesperado - o trader acredita que tudo foi fechado
4. Pode levar a perdas maiores se o mercado se mover contra as posições restantes

## What Changes
- **BREAKING**: Modificação do comportamento de fechamento do hedge
- Garantir que TODAS as posições sejam fechadas quando o lucro total atinge a meta
- Melhorar logging para mostrar detalhes de quais posições estão sendo fechadas
- Adicionar verificação adicional para garantir que nenhuma posição permaneça aberta
- Implementar retry no fechamento caso falhe alguma posição

## Impact
- Affected specs: `trading-hedge` (correção de comportamento crítico)
- Affected code: `tvlucro.mq5`
  - `ManageHedgeProfit()` - Garantir fechamento de TODAS as posições
  - `CloseAllPositions()` - Adicionar retry e melhor logging
  - `ResetHedgeState()` - Chamada após confirmar que todas posições foram fechadas