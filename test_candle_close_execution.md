# Teste de Execução no Fechamento da Vela

## Configurações para Teste

1. **Parâmetros do EA:**
   - `OpenOnCandleClose = true` (habilitar)
   - `CandleCloseTimeframe = PERIOD_M1` (1 minuto para testes rápidos)
   - `MaxPendingSignals = 3`
   - `PendingSignalExpirationSec = 300`

## Cenários de Teste

### Cenário 1: Sinal Único
1. Iniciar EA com `OpenOnCandleClose = false`
2. Enviar sinal (deve executar imediatamente)
3. Mudar `OpenOnCandleClose = true`
4. Enviar novo sinal (deve aguardar fechamento da vela)
5. Verificar logs indicando "Signal queued for candle close"
6. Aguardar fechamento da vela e verificar execução

### Cenário 2: Múltiplos Sinais na Mesma Vela
1. Enviar 3 sinais consecutivos na mesma vela
2. Verificar que apenas o último é executado no fechamento
3. Verificar logs de remoção dos sinais mais antigos

### Cenário 3: Sinal Expirado
1. Enviar sinal com timestamp muito antigo
2. Aguardar expiração (5 minutos)
3. Verificar que sinal é removido da fila

### Cenário 4: Compatibilidade com Hedge
1. Habilitar `EnableHedge = true`
2. Abrir posição e entrar em modo hedge
3. Enviar sinal com `OpenOnCandleClose = true`
4. Verificar que hedge funciona corretamente

## Logs Esperados

```
=== CANDLE CLOSE EXECUTION ENABLED ===
Timeframe: PERIOD_M1
Max pending signals: 3
Signal expiration: 300 seconds

NEW VALID Signal received: {"action":"buy",...}
Signal queued for candle close execution (#1)

New candle detected on PERIOD_M1
Previous candle: 2024.01.01 12:00:00
Current candle: 2024.01.01 12:01:00

=== EXECUTING PENDING SIGNAL AT CANDLE CLOSE ===
Pending signals count: 1
Executing signal: {"action":"buy",...}

=== Processing PENDING Signal at Candle Close ===
Signal received earlier, now executing at candle close
Action: buy
```

## Comportamento Esperado
- Sinais são adicionados à fila quando `OpenOnCandleClose = true`
- Execução ocorre apenas no fechamento da vela
- Apenas o sinal mais recente é executado
- Sinais expiram após `PendingSignalExpirationSec`
- Compatível com todas as funcionalidades existentes