# Tasks: Implementar Painel Visual de Estratégias

## 1. Novos Parâmetros de Configuração
- [ ] 1.1 Adicionar `ShowInfoPanel` (bool, default: true) - mostrar/ocultar painel
- [ ] 1.2 Adicionar `PanelX` (int, default: 20) - posição X do painel
- [ ] 1.3 Adicionar `PanelY` (int, default: 50) - posição Y do painel
- [ ] 1.4 Adicionar `PanelWidth` (int, default: 200) - largura do painel
- [ ] 1.5 Adicionar `PanelUpdateInterval` (int, default: 1) - segundos entre atualizações

## 2. Estrutura de Dados do Painel
- [ ] 2.1 Criar struct `PanelData` com informações exibidas
- [ ] 2.2 Adicionar variável global `lastPanelUpdate`
- [ ] 2.3 Implementar `UpdatePanelData()` - coleta informações atuais
- [ ] 2.4 Implementar `GetStrategyStatus()` - status de cada estratégia

## 3. Sistema de Objetos Gráficos
- [ ] 3.1 Implementar `CreatePanelObjects()` - criar elementos do painel
- [ ] 3.2 Implementar `DrawPanelBackground()` - fundo e bordas
- [ ] 3.3 Implementar `DrawPanelHeader()` - título do EA
- [ ] 3.4 Implementar `DrawStrategyStatus()` - status das estratégias
- [ ] 3.5 Implementar `DrawPositionInfo()` - informações de posições
- [ ] 3.6 Implementar `DrawPerformanceInfo()` - estatísticas

## 4. Sistema de Cores e Layout
- [ ] 4.1 Definir constantes de cores (verde=ativo, vermelho=inativo, etc)
- [ ] 4.2 Implementar sistema de ícones/símbolos visuais
- [ ] 4.3 Criar layout responsivo com espaçamento adequado
- [ ] 4.4 Implementar tooltips informativos

## 5. Integração com EA
- [ ] 5.1 Modificar `OnInit()` - criar painel se habilitado
- [ ] 5.2 Modificar `OnTick()` - atualizar painel periodicamente
- [ ] 5.3 Modificar `OnTimer()` - refresh do painel
- [ ] 5.4 Modificar `OnDeinit()` - limpar objetos do painel
- [ ] 5.5 Implementar `RefreshPanel()` - atualização completa

## 6. Funcionalidades do Painel
- [ ] 6.1 Exibir status: Hedge, Trend Continuation, Candle Confirmation
- [ ] 6.2 Mostrar ultima ação executada
- [ ] 6.3 Exibir posições abertas e PL atual
- [ ] 6.4 Mostrar configurações atuais (lote, TP/SL)
- [ ] 6.5 Indicar modo de execução (imediata/fechamento vela)
- [ ] 6.6 Exibir contagem de trades e performance

## 7. Otimização e Testes
- [ ] 7.1 Implementar updates apenas quando dados mudam
- [ ] 7.2 Testar desempenho com múltiplos timeframes
- [ ] 7.3 Verificar compatibilidade com diferentes resoluções
- [ ] 7.4 Testar persistência ao mudar de timeframe
- [ ] 7.5 Validar que não interfere na execução de ordens