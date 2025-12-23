# Change: Prevenir Operações em Gráfico Lateral

## Why
Quando o EA está rodando em um gráfico no modo lateral (side chart), ocorrem problemas críticos:

1. **Distorção Visual**: O painel informativo e o gráfico lateral competem por espaço, dificultando a leitura
2. **Risco de Execução**: Operações podem ser executadas sem visualização adequada do preço
3. **Experiência do Usuário**: Interface poluída e pouco profissional
4. **Dificuldade de Análise**: Impossível analisar padrões de preço em gráfico muito estreito
5. **Conflito Visual**: O painel pode ocultar ou interferir na análise técnica

É essencial garantir que o EA só opere em gráficos com visualização adequada para permitir monitoramento eficaz e execução segura das operações.

## What Changes
- Adicionar detecção automática do tipo de gráfico (normal vs lateral)
- Adicionar verificação de tamanho mínimo do gráfico para operação segura
- Bloquear temporariamente operações quando em gráfico inadequado
- Exibir aviso claro no painel sobre a restrição
- Permitir configuração de parâmetros mínimos (largura/altura)
- Retomar automaticamente as operações quando o gráfico for restaurado

## Impact
- Affected specs: `trading-bot` (nova funcionalidade de segurança)
- Affected code: `tvlucro.mq5`
  - Novos inputs: `MinChartWidth`, `MinChartHeight`, `CheckChartSize`
  - `IsChartSuitable()` - Detecta gráfico adequado
  - Modificações: `OnTick()`, `ProcessTradeSignal()`, `UpdatePanel()`
  - Nova função: `GetChartDimensions()`, `DisplayWarning()`