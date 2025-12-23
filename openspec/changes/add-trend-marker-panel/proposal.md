# Change: Adicionar Marcador de Tendências no Painel

## Why
O EA atualmente não exibe informações visuais sobre a tendência atual do mercado. Ter um marcador de tendências no painel ajudará o trader a:
1. Identificar rapidamente a direção da tendência
2. Tomar decisões mais informadas
3. Complementar os sinais recebidos com análise técnica visual
4. Melhorar a experiência do usuário com informações contextuais

## What Changes
- Adicionar indicador de tendência baseado em médias móveis
- Exibir seta ou ícone indicando direção (alta/baixa/neutro)
- Mostrar força da tendência (forte/moderada/fraca)
- Permitir configuração do período e tipo das médias móveis
- Integrar visualmente com o painel existente

## Impact
- Affected specs: `trading-bot` (nova funcionalidade visual)
- Affected code: `tvlucro.mq5`
  - Novos inputs: `TrendMarkerEnabled`, `TrendMAPeriodFast`, `TrendMAPeriodSlow`, `TrendMAType`
  - Funções: `CalculateTrend()`, `GetTrendStrength()`, `UpdateTrendMarker()`
  - Modificações: `CreateInfoPanel()`, `UpdatePanel()`