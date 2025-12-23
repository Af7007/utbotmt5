# Change: Adicionar Painel Visual de Estratégias

## Why
O EA atual exibe informações apenas através de logs no journal, dificultando o monitoramento em tempo real das estratégias ativas e status do sistema. Um painel visual oferece:

1. **Visibilidade imediata** - Status de todas as estratégias sem precisar verificar logs
2. **Monitoramento em tempo real** - Informações atualizadas constantemente
3. **Experiência profissional** - Interface limpa e moderna para traders
4. **Diagnóstico rápido** - Identificação visual de problemas ou configurações
5. **Confiança do usuário** - Transparência total do que o EA está fazendo

## What Changes
- Adicionar painel informativo no lado esquerdo da tela
- Exibir status de todas as estratégias e funcionalidades
- Mostrar informações de posições abertas e resultados
- Design moderno e limpo com cores intuitivas
- Atualização em tempo real dos dados
- Opção para habilitar/desabilitar o painel

## Impact
- Affected specs: `trading-bot` (nova funcionalidade de UI)
- Affected code: `tvlucro.mq5`
  - Novos inputs: `ShowInfoPanel`, `PanelX`, `PanelY`, `PanelWidth`
  - Novas funções: `DrawInfoPanel()`, `UpdatePanelData()`, `CreatePanelObjects()`
  - Modificações: `OnTick()`, `OnTimer()`, `OnInit()`, `OnDeinit()`
  - Sistema de objetos gráficos para renderização do painel