# Tasks: Corrigir Fechamento Total do Hedge

## 1. Investigação do Problema
- [ ] 1.1 Analisar `ManageHedgeProfit()` para entender como está calculando o fechamento
- [ ] 1.2 Verificar se `CloseAllPositions()` está sendo chamada corretamente
- [ ] 1.3 Identificar porque posições negativas estão permanecendo abertas
- [ ] 1.4 Verificar se há múltiplos magic numbers ou símbolos envolvidos

## 2. Modificar ManageHedgeProfit()
- [ ] 2.1 Adicionar logging detalhado de TODAS as posições abertas antes de fechar
- [ ] 2.2 Implementar verificação adicional após CloseAllPositions()
- [ ] 2.3 Adicionar retry automático se houver posições remanescentes
- [ ] 2.4 Garantir que só resete o estado hedge após TODAS posições fecharem
- [ ] 2.5 Adicionar verificação final para confirmar que não há posições abertas

## 3. Melhorar CloseAllPositions()
- [ ] 3.1 Aumentar número de retries de 3 para 5
- [ ] 3.2 Adicionar delay entre retries (aumentar de 500ms para 1000ms)
- [ ] 3.3 Adicionar logging de cada posição individualmente
- [ ] 3.4 Retornar verdadeiro apenas se verificar que não há posições abertas
- [ ] 3.5 Adicionar função auxiliar para contar posições restantes

## 4. Adicionar Funções de Verificação
- [ ] 4.1 Implementar `CountOpenPositionsByMagic()` - contador específico
- [ ] 4.2 Implementar `GetAllPositionsInfo()` - listar detalhes de todas posições
- [ ] 4.3 Implementar `VerifyNoPositionsOpen()` - verificação final
- [ ] 4.4 Implementar `ForceCloseRemainingPositions()` - fallback forçado

## 5. Testes e Validação
- [ ] 5.1 Testar cenário: 3 posições (1 lucro, 2 prejuízo) → total positivo → fecha TODAS
- [ ] 5.2 Testar cenário: Posições de diferentes magic numbers → só afeta as do EA
- [ ] 5.3 Testar cenário: Falha no fechamento → retry automático
- [ ] 5.4 Testar cenário: Múltiplos símbolos → só fecha posições do símbolo configurado
- [ ] 5.5 Verificar logs detalhados para debugging