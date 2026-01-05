# Change: Martingale por Sinais Consecutivos - NUNCA Fecha Posições

## Why

O hedge atual não implementa martingale progressivo. O comportamento desejado é:
- Cada sinal oposto consecutivo dobra o lote (2×, 4×, 8×...)
- **NUNCA fecha posições** até atingir lucro >= $50
- Ambas direções ficam abertas simultaneamente

## What Changes

- **ADICIONAR** contador de sinais consecutivos (`consecutiveSignalCount`)
- **ADICIONAR** lógica para calcular lote como `FixedLotSize × (2 ^ consecutiveSignalCount)`
- **MODIFICAR** para NUNCA fechar posições exceto quando lucro alvo é atingido
- **REMOVER** lógica de fechar posições na reversão

## Impact

- Affected specs: `tvlucrogrid`
- Affected code: `tvlucrogrid.mq5`

## Comportamento Esperado

```
Sinal 1 (BUY)  → Abre 0.01 (1x)       | Posições: BUY×0.01
Sinal 2 (SELL) → Abre 0.02 (2x)       | Posições: BUY×0.01, SELL×0.02
Sinal 3 (BUY)  → Abre 0.04 (4x)       | Posições: BUY×0.01+0.04, SELL×0.02
Sinal 4 (SELL) → Abre 0.08 (8x)       | Posições: BUY×0.01+0.04, SELL×0.02+0.08
Lucro >= $50   → Fecha TUDO, volta a 0.01
```

## Exemplo Visual

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SINAL 1: BUY                                                               │
│  → Lote: 0.01 × 2^0 = 0.01 (1x)                                          │
│  → NÃO fecha nada                                                         │
│  → Posições: BUY 0.01                                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  SINAL 2: SELL (oposto consecutivo #1)                                    │
│  → Lote: 0.01 × 2^1 = 0.02 (2x)                                          │
│  → NÃO fecha BUY (mantém aberto!)                                        │
│  → Posições: BUY 0.01, SELL 0.02                                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  SINAL 3: BUY (oposto consecutivo #2)                                     │
│  → Lote: 0.01 × 2^2 = 0.04 (4x)                                          │
│  → NÃO fecha SELL (mantém aberto!)                                       │
│  → Posições: BUY 0.01+0.04, SELL 0.02                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  SINAL 4: SELL (oposto consecutivo #3)                                    │
│  → Lote: 0.01 × 2^3 = 0.08 (8x)                                          │
│  → NÃO fecha BUY (mantém aberto!)                                        │
│  → Posições: BUY 0.01+0.04, SELL 0.02+0.08                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  Continua... (sinais continuam chegando)                                   │
│  → Cada sinal oposto: dobra o lote novamente                               │
│  → NUNCA fecha posições abertas                                           │
│  → Acumula posições em AMBAS direções                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  Lucro >= $50                                                              │
│  → Fecha: TODAS posições de UMA VEZ                                      │
│  → Reset: consecutiveSignalCount = 0                                      │
│  → Próximo sinal volta a 0.01                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```
