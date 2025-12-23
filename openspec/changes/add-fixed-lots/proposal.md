# Change: Adicionar Lote Fixo como Parâmetro de Entrada

## Why
O EA atualmente está usando lotes de 0.01 independentemente das preferências do usuário, o que limita a flexibilidade da estratégia de trading. Isso é problemático porque:

1. Usuários com maior capital precisam de lotes maiores para meaningful gains
2. Usuários com capital menor podem precisar de lotes menores para gerenciamento de risco
3. Estratégias diferentes requerem tamanhos de posição diferentes
4. O cálculo baseado em % do equity pode não ser adequado para todos os cenários
5. Muitos traders preferem controle explícito sobre o tamanho da posição

Adicionar um parâmetro de lote fixo permite que os usuários tenham controle total sobre o tamanho das posições, mantendo a opção de usar o cálculo automático como alternativa.

## What Changes
- Adicionar parâmetro `UseFixedLots` (bool) para habilitar/desabilitar lotes fixos
- Adicionar parâmetro `FixedLotSize` (double) para definir o tamanho do lote fixo
- Modificar função `CalculateVolume()` para usar o lote fixo quando habilitado
- Manter compatibilidade com cálculo baseado em RiskPercent como padrão
- Adicionar validação para garantir que o lote fixo esteja dentro dos limites do broker

## Impact
- Affected specs: `trading-bot` (nova funcionalidade de gerenciamento de volume)
- Affected code: `tvlucro.mq5`
  - Novos inputs: `UseFixedLots`, `FixedLotSize`
  - `CalculateVolume()` - Modificar para suporte a lotes fixos
  - `PlaceBuyOrder()`, `PlaceSellOrder()` - Já usam CalculateVolume()
  - `OnInit()` - Adicionar validação do lote fixo
  - Hedge e Trend Continuation já usarão o novo volume automaticamente