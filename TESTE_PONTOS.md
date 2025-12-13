# 🧪 Teste de Verificação - Sistema em Pontos

## ✅ O QUE FOI ALTERADO

O EA **tv.mq5** foi modificado para trabalhar **diretamente com PONTOS** ao invés de PIPS.

---

## 🔍 VERIFICAR SE ESTÁ FUNCIONANDO

### **Passo 1: Recompilar o EA**

1. Abra o **MetaEditor** (F4 no MT5)
2. Abra o arquivo **tv.mq5**
3. Pressione **F7** para compilar
4. Verifique se não há erros

**Esperado:**
```
0 error(s), 0 warning(s)
Compilation successful
```

### **Passo 2: Adicionar ao Gráfico**

1. Feche o EA atual (se estiver rodando)
2. Arraste **tv** da janela Navigator para o gráfico
3. Na aba **"Inputs"** você verá:

**NOVOS NOMES:**
```
TakeProfitPoints = 1000      (era TakeProfitPips)
StopLossPoints = 500         (era StopLossPips)
BreakEvenPoints = 100        (era BreakEvenPips)
BreakEvenExtraPoints = 20    (era BreakEvenExtraPips)
TrailingStopPoints = 100     (era TrailingStopPips)
TrailingStepPoints = 50      (era TrailingStepPips)
```

### **Passo 3: Verificar Logs de Inicialização**

Na aba **"Experts"** você deve ver:

```
=== HttpTrader EA Initialized (Simple/No DLL) ===
Symbol: XAUUSD
Point Size: 0.01
Digits: 2
Risk Percent: 0.0001%
Take Profit: 1000 points (10.0 price distance)
Stop Loss: 500 points (5.0 price distance)
--- Breakeven Settings ---
Breakeven Enabled: YES
Breakeven Trigger: 100 points profit
Breakeven Extra: +20 points from entry
--- Trailing Stop Settings ---
Trailing Stop Enabled: YES
Trailing Distance: 100 points
Trailing Step: 50 points
```

**Verificar:**
- ✅ `Point Size: 0.01` (para XAUUSD)
- ✅ `1000 points (10.0 price distance)` → 1000 × 0.01 = $10 ✓
- ✅ `500 points (5.0 price distance)` → 500 × 0.01 = $5 ✓

---

## 🧪 TESTE PRÁTICO

### **Teste 1: Enviar Sinal de COMPRA**

```bash
curl -X POST https://livelier-nonpurposively-monty.ngrok-free.dev/sinais \
  -H "Content-Type: application/json" \
  -d '{"action": "long"}'
```

### **Teste 2: Verificar Logs da Ordem**

Na aba **"Experts"** você deve ver:

```
Signal received: {"action": "buy"...}
=== Processing Trade Signal ===
Action: buy
Closing all positions for XAUUSD
Volume calculated: Equity=... Risk=... Volume=...
=== BUY ORDER ===
Entry: 2650.50 | SL: 2645.50 (500 pts = 5.0) | TP: 2660.50 (1000 pts = 10.0)
BUY SUCCESS: Vol=0.01 Entry=2650.50 SL=2645.50 (500 points) TP=2660.50 (1000 points)
=== Trade Signal Processed ===
```

**Verificar:**
- ✅ `SL: 2645.50 (500 pts = 5.0)` → Distância de $5.00 ✓
- ✅ `TP: 2660.50 (1000 pts = 10.0)` → Distância de $10.00 ✓
- ✅ SL e TP estão corretos!

---

## 📊 CÁLCULO MANUAL (XAUUSD)

Se entrada for **2650.00**:

### **Stop Loss (500 pontos):**
```
SL = Entry - (StopLossPoints × Point)
SL = 2650.00 - (500 × 0.01)
SL = 2650.00 - 5.00
SL = 2645.00 ✓
```

### **Take Profit (1000 pontos):**
```
TP = Entry + (TakeProfitPoints × Point)
TP = 2650.00 + (1000 × 0.01)
TP = 2650.00 + 10.00
TP = 2660.00 ✓
```

### **Breakeven (100 pontos):**
```
Ativa quando lucro ≥ 100 × 0.01 = $1.00
Move SL para: Entry + (20 × 0.01) = Entry + $0.20
```

### **Trailing Stop (100 pontos):**
```
Mantém SL a 100 × 0.01 = $1.00 do preço atual
Move a cada 50 × 0.01 = $0.50 de progresso
```

---

## ⚠️ TROUBLESHOOTING

### **Problema 1: SL muito pequeno ou muito grande**

**Causa:** Parâmetros configurados errados
**Solução:** Veja o GUIA_PONTOS.md para valores recomendados

**Para XAUUSD:**
- SL de $5 = 500 pontos
- TP de $10 = 1000 pontos

### **Problema 2: Erro "SL/TP too close"**

**Causa:** Broker exige distância mínima maior
**Solução:** Aumente os valores dos pontos

**Exemplo:**
```
Se mínimo é 200 pontos, use:
StopLossPoints = 500    (ao invés de 100)
TakeProfitPoints = 1000 (ao invés de 200)
```

### **Problema 3: Volume muito pequeno**

**Causa:** RiskPercent = 0.0001% está muito baixo
**Solução:** Aumente para 1-2%

```
RiskPercent = 2.0  (2% do equity)
```

Com equity de $1000:
- 2% = $20 de risco por trade
- Com SL de $5 → Volume ≈ 0.04 lotes

---

## 📝 COMPARAÇÃO ANTES/DEPOIS

### **ANTES (com Pips):**
```mql5
TakeProfitPips = 100           // 100 pips
// Código: StopLossPips * 10 * point
// Problema: Multiplicador fixo, pode estar errado
```

### **DEPOIS (com Pontos):**
```mql5
TakeProfitPoints = 1000        // 1000 pontos = $10
// Código: TakeProfitPoints * point
// Vantagem: Direto, sem conversão, sempre correto
```

---

## ✅ CHECKLIST DE VERIFICAÇÃO

- [ ] EA recompilado sem erros
- [ ] EA adicionado ao gráfico
- [ ] Parâmetros mostram "Points" ao invés de "Pips"
- [ ] Logs de inicialização mostram valores corretos
- [ ] Enviei sinal de teste
- [ ] Logs da ordem mostram SL/TP corretos
- [ ] Distâncias de SL/TP estão corretas em $
- [ ] Volume está adequado (não muito pequeno)
- [ ] Breakeven configurado corretamente
- [ ] Trailing Stop configurado corretamente

---

## 🎯 VALORES FINAIS ESPERADOS

**Com configuração padrão:**
```
Symbol: XAUUSD
Point: 0.01
TakeProfitPoints: 1000 → $10.00
StopLossPoints: 500 → $5.00
BreakEvenPoints: 100 → $1.00
TrailingStopPoints: 100 → $1.00
```

**Resultado esperado em ordem:**
```
Entry: 2650.00
SL: 2645.00 (distância de $5.00) ✓
TP: 2660.00 (distância de $10.00) ✓
```

---

## 📚 PRÓXIMOS PASSOS

1. ✅ Verifique todos os itens do checklist
2. ✅ Teste em conta DEMO
3. ✅ Ajuste parâmetros conforme sua estratégia
4. ✅ Consulte GUIA_PONTOS.md para configurações
5. ✅ Documente suas configurações personalizadas

---

**Sistema atualizado e pronto para uso!** 🚀
