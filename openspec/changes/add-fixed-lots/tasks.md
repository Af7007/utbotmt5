# Tasks: Adicionar Lote Fixo

## 1. Novos Parâmetros de Entrada
- [ ] 1.1 Adicionar `UseFixedLots` (bool, default: false) - habilitar lotes fixos
- [ ] 1.2 Adicionar `FixedLotSize` (double, default: 0.01) - tamanho do lote fixo
- [ ] 1.3 Adicionar `ValidateLotSize` (bool, default: true) - validar limites do broker

## 2. Modificar CalculateVolume()
- [ ] 2.1 Adicionar verificação de UseFixedLots no início da função
- [ ] 2.2 Se UseFixedLots = true: retornar FixedLotSize diretamente
- [ ] 2.3 Se UseFixedLots = false: manter cálculo baseado em RiskPercent
- [ ] 2.4 Adicionar logging indicando qual método está sendo usado

## 3. Validação de Lote Fixo
- [ ] 3.1 Implementar `ValidateAndAdjustLotSize()` - ajusta para limites do broker
- [ ] 3.2 Obter min/max lotes do símbolo via SYMBOL_VOLUME_MIN/MAX
- [ ] 3.3 Obter step size via SYMBOL_VOLUME_STEP
- [ ] 3.4 Ajustar FixedLotSize para estar dentro dos limites
- [ ] 3.5 Logar ajustes se necessário

## 4. Modificar OnInit()
- [ ] 4.1 Adicionar validação inicial do FixedLotSize
- [ ] 4.2 Logar configuração de volume ao iniciar
- [ ] 4.3 Exibir qual método será usado (fixo ou percentual)
- [ ] 4.4 Validar combinação de parâmetros

## 5. Testes e Validação
- [ ] 5.1 Testar UseFixedLots = true com lotes diferentes
- [ ] 5.2 Testar UseFixedLots = false (comportamento atual)
- [ ] 5.3 Testar lotes abaixo do mínimo → deve ajustar
- [ ] 5.4 Testar lotes acima do máximo → deve ajustar
- [ ] 5.5 Verificar que hedge usa o mesmo volume
- [ ] 5.6 Verificar que trend continuation usa o mesmo volume

## 6. Documentação e Logs
- [ ] 6.1 Adicionar comentários explicando a nova lógica
- [ ] 6.2 Melhorar logs de volume calculado
- [ ] 6.3 Logar quando ajuste automático é feito
- [ ] 6.4 Documentar nova opção nos logs de inicialização