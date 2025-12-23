# Tasks: Prevenir Operações em Gráfico Lateral

## 1. Novos Parâmetros de Configuração
- [ ] 1.1 Adicionar `CheckChartSize` (bool, default: true) - Verificar tamanho do gráfico
- [ ] 1.2 Adicionar `MinChartWidth` (int, default: 400) - Largura mínima para operar
- [ ] 1.3 Adicionar `MinChartHeight` (int, default: 300) - Altura mínima para operar
- [ ] 1.4 Adicionar `AllowSideChart` (bool, default: false) - Permitir gráfico lateral

## 2. Detecção do Tipo de Gráfico
- [ ] 2.1 Implementar `IsSideChart()` - Detecta se gráfico está em modo lateral
- [ ] 2.2 Implementar `GetChartWidth()` - Obtém largura da janela do gráfico
- [ ] 2.3 Implementar `GetChartHeight()` - Obtém altura da janela do gráfico
- [ ] 2.4 Implementar `IsChartSuitable()` - Verifica se gráfico é adequado

## 3. Sistema de Bloqueio de Operações
- [ ] 3.1 Modificar `OnTick()` para verificar gráfico antes de operar
- [ ] 3.2 Modificar `ProcessTradeSignal()` para bloquear em gráfico inadequado
- [ ] 3.3 Implementar `ShouldBlockTrading()` - Lógica de decisão de bloqueio
- [ ] 3.4 Adicionar logging de bloqueio no painel e journal

## 4. Indicadores Visuais
- [ ] 4.1 Implementar `DisplayChartWarning()` - Mostra aviso no painel
- [ ] 4.2 Implementar `UpdateChartStatus()` - Atualiza status no painel
- [ ] 4.3 Adicionar cor especial para gráfico bloqueado
- [ ] 4.4 Exibir dimensões atuais no painel quando bloqueado

## 5. Recuperação Automática
- [ ] 5.1 Detectar quando gráfico se torna adequado
- 5.2 Remover aviso do painel automaticamente
- 5.3 Logar retorno ao modo normal
- 5.4 Retomar processamento normal de sinais

## 6. Testes e Validação
- [ ] 6.1 Testar gráfico normal → deve operar normalmente
- [ ] 6.2 Testar gráfico lateral → deve bloquear (se AllowSideChart=false)
- [ ] 6.3 Testar gráfico pequeno → deve bloquear
- [ ] 6.4 Testar AllowSideChart=true → permite gráfico lateral
- [ ] 6.5 Verificar que painel mostra status corretamente