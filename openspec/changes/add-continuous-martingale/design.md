# Design: Continuous Martingale for TVLucroGrid EA

## Context

O TVLucroGrid EA implementa estratégia de grid com hedge mode. Atualmente, quando entra em hedge mode, todas as ordens na nova direção usam o mesmo lote multiplicado (`HedgeLotMultiplier * FixedLotSize`). O usuário deseja um verdadeiro martingale onde cada ordem subsequente multiplica o lote da ordem anterior.

**Current behavior:**
```
Order 1: 0.01 (base lot)
Order 2: 0.015 (0.01 * 1.5)
Order 3: 0.015 (0.01 * 1.5)  ← SAME as Order 2
Order 4: 0.015 (0.01 * 1.5)  ← SAME as Order 2
```

**Desired behavior:**
```
Order 1: 0.010 (base lot, 1x)
Order 2: 0.015 (0.010 * 1.5, 1.5x)
Order 3: 0.023 (0.015 * 1.5, 2.25x)  ← TRUE MARTINGALE
Order 4: 0.034 (0.023 * 1.5, 3.375x) ← TRUE MARTINGALE
```

## Goals / Non-Goals

**Goals:**
- Implementar martingale contínuo baseado no último lote aberto
- Manter compatibilidade com comportamento atual (opt-in via parâmetro)
- Suportar tracking de lotes por direção (buy/sell separados)
- Proteger contra lotes que excedam limite máximo do broker

**Non-Goals:**
- Modificar a lógica de quando entrar em hedge mode
- Alterar targets de profit ou stop loss
- Mudar a forma como os sinais são processados

## Decisions

### 1. Armazenamento por Direção
**Decisão:** Manter variáveis separadas para `lastBuyLotSize` e `lastSellLotSize`

**Justificativa:** Em hedge mode, podem existir posições em ambas direções. Cada direção deve ter sua própria progressão de martingale.

### 2. Reset de Progressão
**Decisão:** Resetar a progressão de martingale quando:
- Todas as posições forem fechadas
- Um novo sinal for recebido na mesma direção (reinicia do base lot)
- Hedge mode for encerrado

**Justificativa:** Evita progressão infinita e permite "fresh start" quando mercado muda.

### 3. Validação de Lote Máximo
**Decisão:** Antes de abrir ordem, verificar se `calculatedLot <= brokerMaxLot`

**Justificativa:** Prevenir erro de execução. Se exceder, usar `brokerMaxLot` e logar aviso.

### 4. Modo Híbrido
**Decisão:** Adicionar parâmetro `EnableContinuousMartingale` (default: false)

**Justificativa:** Permite testar novo comportamento sem quebrar setups existentes. Usuário pode opt-in quando confortável.

## Algorithm

```
// When opening an order:
IF EnableContinuousMartingale == true THEN
    lastLot = GetLastLotSize(direction)
    IF lastLot == 0 THEN
        nextLot = FixedLotSize  // First order
    ELSE
        nextLot = lastLot * MartingaleMultiplier
    END IF
    nextLot = MIN(nextLot, brokerMaxLot)  // Cap at max
    nextLot = MAX(nextLot, brokerMinLot)  // Ensure minimum
ELSE
    nextLot = FixedLotSize * HedgeLotMultiplier  // Old behavior
END IF

// After successful order execution:
UpdateLastLotSize(direction, actualLotOpened)
```

## Data Structures

```mql5
// New global variables
double lastBuyLotSize = 0.0;   // Last lot size for BUY orders
double lastSellLotSize = 0.0;  // Last lot size for SELL orders

// New input parameters
input bool EnableContinuousMartingale = false;  // Enable true martingale progression
input double MartingaleMultiplier = 1.5;        // Multiplier for each subsequent order
```

## Risks / Trade-offs

### Risk: Crescimento Exponencial
**Risco:** Após 10 níveis: 0.01 → 0.01 × 1.5^10 ≈ 0.057 lotes (57x o original)
**Mitigação:** `MaxGridOrders` limita o número de ordens; validação de `brokerMaxLot`

### Risk: Memória de Estado
**Risco:** Se EA for reiniciado, perde-se o histórico de últimos lotes
**Mitigação:** Ao reiniciar, recomeça do base lot (comportamento seguro)

### Trade-off: Complexidade
O código aumenta em complexidade para tracking de estado por direção
**Benefício:** Martingale verdadeiro conforme solicitado

## Migration Plan

1. Adicionar parâmetros com defaults mantendo comportamento atual
2. Testar extensivamente com EnableContinuousMartingale=false
3. Usuário pode habilitar quando pronto
4. Monitorar logs para verificar progressão de lotes

## Open Questions

- Q1: Deve persistir estado de last lot sizes em arquivo?
  - **A:** Não, por enquanto. Reinício é um "reset" seguro.
