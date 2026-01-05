# Change: Hedge Mode Sempre Respeita Sinais - Adiciona Ordens Continuamente

## Why

O hedge mode anterior ignorava sinais após entrar em hedge. Isso impedia que o EA adicionasse mais ordens ao hedge quando novos sinais eram recebidos.

## What Changes

- **ADICIONAR** lógica para processar sinais na mesma direção do hedge (adiciona ordens ao hedge atual)
- **MODIFICAR** lógica para processar sinais na direção oposta durante hedge (adiciona ordens na direção do sinal, também com lote multiplicado)
- **MANTER** lote multiplicado (HedgeLotMultiplier) para TODAS as ordens abertas durante hedge
- **SAIR** do hedge apenas quando lucro >= HedgeProfitTarget

## Impact

- Affected specs: `tvlucrogrid`
- Affected code: `tvlucrogrid.mq5`
  - Linhas 285-307: Novo bloco para sinais na mesma direção do hedge
  - Linhas 407-433: Modificado para adicionar ordens em sinais opostos durante hedge

## Novo Comportamento

| Situação | Ação |
|----------|------|
| **Sinal na mesma direção do hedge** | Adiciona ordem ao hedge (lote × HedgeLotMultiplier) |
| **Sinal na direção oposta (durante hedge)** | Adiciona ordem na direção do sinal (lote × HedgeLotMultiplier) |
| **Lucro total >= HedgeProfitTarget** | Fecha TODAS as posições, volta ao lote normal |

## Exemplo

```
1. Sinal BUY → abre BUY 0.01
2. Sinal SELL (com prejuízo) → ativa HEDGE, abre SELL 0.015
3. Sinal SELL (novamente) → abre SELL 0.015 (mais hedge)
4. Sinal BUY → abre BUY 0.015 (ordem oposta também multiplicada!)
5. ...continua adicionando enquanto recebe sinais...
6. Lucro >= $50 → fecha TODAS, volta ao lote 0.01
```
