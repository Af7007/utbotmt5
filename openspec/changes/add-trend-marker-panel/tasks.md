# Tasks: Adicionar Marcador de Tendências no Painel

## 1. Novos Parâmetros de Configuração
- [ ] 1.1 Adicionar `TrendMarkerEnabled` (bool, default: true) - Ativar marcador de tendência
- [ ] 1.2 Adicionar `TrendMAPeriodFast` (int, default: 9) - Período da MA rápida
- [ ] 1.3 Adicionar `TrendMAPeriodSlow` (int, default: 21) - Período da MA lenta
- [ ] 1.4 Adicionar `TrendMAType` (enum, default: 1) - Tipo: 0=SMA, 1=EMA, 2=SMMA, 3=LWMA
- [ ] 1.5 Adicionar `TrendStrengthDisplay` (bool, default: true) - Exibir força da tendência

## 2. Cálculo da Tendência
- [ ] 2.1 Implementar `CalculateTrend()` - Calcula direção baseada em MAs
- [ ] 2.2 Implementar `GetTrendStrength()` - Calcula força da tendência
- [ ] 2.3 Implementar `GetTrendArrow()` - Retorna caractere da seta
- [ ] 2.4 Implementar `GetTrendColor()` - Retorna cor baseada na tendência

## 3. Atualização do Painel
- [ ] 3.1 Modificar `CreateInfoPanel()` - Adicionar seção de tendência
- [ ] 3.2 Modificar `UpdatePanel()` - Atualizar marcador de tendência
- [ ] 3.3 Ajustar layout do painel para acomodar nova seção
- [ ] 3.4 Aumentar altura do painel em 30 pixels

## 4. Elementos Visuais
- [ ] 4.1 Criar labels para tendência (direção e força)
- [ ] 4.2 Implementar cores: verde (alta), vermelho (baixa), cinza (neutro)
- [ ] 4.3 Adicionar ícones de seta: ↑ ↓ →
- [ ] 4.4 Destacar seção com fundo sutil

## 5. Lógica de Atualização
- [ ] 5.1 Calcular tendências a cada tick
- [ ] 5.2 Atualizar painel apenas em intervalos configurados
- [ ] 5.3 Logar mudanças de tendência
- [ ] 5.4 Tratar erros de cálculo de MA

## 6. Testes e Validação
- [ ] 6.1 Testar tendência de alta (MA rápida > MA lenta)
- [ ] 6.2 Testar tendência de baixa (MA rápida < MA lenta)
- [ ] 6.3 Testar tendência neutra (MAs próximas)
- [ ] 6.4 Validar força da tendência (forte/moderada/fraca)
- [ ] 6.5 Verificar performance com múltiplos timeframes