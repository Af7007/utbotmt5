# Tarefas: Implementação do Positive Scalping

## Tarefa 1: Adicionar Parâmetros de Configuração
- [ ] Adicionar 6 novos input parameters no topo do arquivo tvlucro.mq5
- [ ] Configurar valores defaults recomendados
- [ ] Documentar cada parâmetro nos comentários

## Tarefa 2: Implementar Variáveis de Estado
- [ ] Adicionar 5 variáveis globais para gerenciar estado scalping
- [ ] Inicializar variáveis em OnInit()
- [ ] Adicionar reset no início de cada trade

## Tarefa 3: Modificar OnInit()
- [ ] Adicionar reset de estado scalping
- [ ] Adicionar logging inicial do sistema
- [ ] Integrar com painel informativo

## Tarefa 4: Implementar Verificação de Positividade
- [ ] Criar função `IsPositionProfitable()` para verificar lucro > 0
- [ ] Criar função `HasProfitableDuration()` verificar tempo > threshold
- [ ] Integração com OnTimer() verificação contínua

## Tarefa 5: Implementar Lógica de Abertura
- [ ] Criar função `OpenScalpingPosition()` para abrir novas posições
- [ ] Calcular volume baseado em multiplicador
- [ ] Verificar limite de posições
- [ ] Atualizar estado scalping

## Tarefa 6: Implementar Verificação de Meta
- [ ] Criar função `CheckScalpingTarget()` calcular lucro total
- [ ] Comparar com meta configurável
- [ ] Fechar todas as posições se meta atingida
- [ ] Resetar estado scalping

## Tarefa 7: Implementar Gestão de Breakeven
- [ ] Adicionar opção de breakeven para posições scalping
- [ ] Mover SL para breakeven após X pontos de lucro
- [ ] Proteger lucro em tendências favoráveis

## Tarefa 8: Atualizar Painel Informativo
- [ ] Adicionar indicador de modo scalping ativo
- [ ] Mostrar nível atual: X/Y
- [ ] Exibir lucro acumulado
- [ ] Mostrar countdown para próxima posição

## Tarefa 9: Adicionar Logging Detalhado
- [ ] Logs de inicialização do sistema
- [ ] Logs de gatilho de abertura
- [ ] Logs de progresso
- [ ] Logs de meta atingida
- [ ] Logs de reset

## Tarefa 10: Testes e Validação
- [ ] Teste 1: Sucesso completo (atingir meta)
- [ ] Teste 2: Parcial (2-3 posições)
- [ ] Teste 3: Não acionar com prejuízo
- [ ] Teste 4: Limite de posições
- [ ] Teste 5: Integração com hedge (desabilitar quando ativo)

## Tarefa 11: Atualizar Documentação
- [ ] Atualizar comentários no código
- [ ] Adicionar exemplos de configuração
- [ ] Documentar riscos e benefícios
- [ ] Criar seção no README

## Tarefa 12: Performance e Otimização
- [ ] Otimizar cálculos de lucro (evitar loops desnecessários)
- [ ] Adicionar timeout máximo (ex: 5 minutos)
- [ ] Proteger contra condições de mercado extremas

## Checklist de Validação

### Antes da Implementação
- [ ] Todos os cenários de uso documentados
- [ ] Parâmetros defaults testados
- [ ] Impacto em outros sistemas analisado

### Durante o Desenvolvimento
- [ ] Cada tarefa implementada separadamente
- [ ] Logs para depuração em cada etapa
- [ ] Testes unitários para funções críticas

### Pós-Implementação
- [ ] Todos os testes cenários passaram
- [ ] Integração com sistemas existentes verificada
- [ ] Performance aceitável (CPU/RAM)
- [ ] Documentação finalizada

## Casos de Uso Esperados

### Configuração Conservadora
```mql5
EnablePositiveScalping = true
PositiveProfitSeconds = 30
ScalpingVolumeMultiplier = 1.2
MaxScalpingLevels = 3
ScalpingProfitTarget = 150
```

### Configuração Agressiva
```mql5
EnablePositiveScalping = true
PositiveProfitSeconds = 10
ScalpingVolumeMultiplier = 1.8
MaxScalpingLevels = 5
ScalpingProfitTarget = 300
```

### Desabilitado (Padrão)
```mql5
EnablePositiveScalping = false  // Sistema desativado
```

## Observações Importantes

1. **Risco Elevado**: Este sistema aumenta significativamente o risco
2. **Mercado Volátil**: Funciona melhor em tendências fortes
3. **Capital Suficiente**: Requer capital adequado para suportar múltiplas posições
4. **Monitoramento**: Recomendação de monitoramento ativo durante operação
5. **Combinação com Hedge**: Não recomendado usar ambos simultaneamente