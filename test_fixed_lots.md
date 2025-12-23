# Teste de Lotes Fixos

## Configurações para Teste

### Teste 1: Lote Fixo Padrão
- `UseFixedLots = true`
- `FixedLotSize = 0.01`
- `ValidateLotSize = true`

### Teste 2: Lote Fixo Maior
- `UseFixedLots = true`
- `FixedLotSize = 0.10`
- `ValidateLotSize = true`

### Teste 3: Lote Fixo Abaixo do Mínimo
- `UseFixedLots = true`
- `FixedLotSize = 0.001` (provavelmente abaixo do mínimo)
- `ValidateLotSize = true`

### Teste 4: Modo Percentual (comportamento atual)
- `UseFixedLots = false`
- `RiskPercent = 2.0`
- Fixed lot settings ignorados

### Teste 5: Validação Desabilitada
- `UseFixedLots = true`
- `FixedLotSize = 0.05`
- `ValidateLotSize = false`

## Logs Esperados

### Com lotes fixos:
```
=== FIXED LOT SIZE MODE ===
Fixed lot size: 0.01
Lot validation: ENABLED

=== USING FIXED LOT SIZE ===
Fixed lot size requested: 0.01

=== LOT SIZE VALIDATION ===
Requested lot: 0.01
Broker limits - Min: 0.01, Max: 100.0, Step: 0.01
Final lot size: 0.01
```

### Com lotes fixos sem validação:
```
=== FIXED LOT SIZE MODE ===
Fixed lot size: 0.05
Lot validation: DISABLED

=== USING FIXED LOT SIZE ===
Fixed lot size requested: 0.05
```

### Com modo percentual:
```
=== RISK PERCENTAGE MODE ===
Risk percent: 2.0%

=== CALCULATING VOLUME BASED ON RISK PERCENTAGE ===
Volume calculation: Equity=10000 Risk=200 %=2.0
Initial calculated volume: 0.02
```

## Comportamento Esperado
- Com `UseFixedLots = true`: Usa sempre o FixedLotSize
- Com `UseFixedLots = false`: Calcula baseado no RiskPercent
- Validação ajusta automaticamente para limites do broker
- Hedge multiplica o lote fixo pelo HedgeMultiplier
- Trend continuation usa o mesmo lote fixo para reentradas