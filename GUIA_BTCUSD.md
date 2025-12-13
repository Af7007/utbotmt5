# 🪙 Guia BTCUSD - Sistema Auto-Ajustável

## ✅ IMPLEMENTADO: AUTO-AJUSTE POR SÍMBOLO

O EA agora detecta automaticamente o símbolo e ajusta os valores de SL/TP!

---

## 🎯 COMO FUNCIONA

Quando `AutoAdjustForSymbol = true` (padrão), o EA:

1. **Detecta o símbolo** (BTCUSD, XAUUSD, EUR/USD, etc.)
2. **Consulta o stop level mínimo** do broker
3. **Ajusta automaticamente** SL/TP/Breakeven/Trailing
4. **Garante valores válidos** que o broker aceita

---

## 🪙 VALORES PARA BTCUSD

### **Auto-Ajustados:**
```
Symbol: BTCUSD
Price: ~$90,000

TakeProfit: 10000 points = $100
StopLoss: 5000 points = $50
Breakeven: 1000 points = $10
Trailing: 2000 points = $20
```

### **Por que esses valores?**

BTCUSD precisa de stops maiores porque:
- Preço alto (~$90k)
- Volatilidade alta
- Brokers exigem distância mínima maior
- $50 de SL = apenas 0.05% do preço

---

## ⚙️ CONFIGURAÇÃO NO MT5

### **Opção 1: Auto-Ajuste (RECOMENDADO)**

```
TradingSymbol = "BTCUSD"
AutoAdjustForSymbol = true
RiskPercent = 2.0

// Valores serão ajustados automaticamente!
// TP → 10000 pontos ($100)
// SL → 5000 pontos ($50)
```

### **Opção 2: Manual**

```
TradingSymbol = "BTCUSD"
AutoAdjustForSymbol = false
RiskPercent = 2.0
TakeProfitPoints = 10000    // $100
StopLossPoints = 5000       // $50
BreakEvenPoints = 1000      // $10
TrailingStopPoints = 2000   // $20
```

---

## 📊 COMPARAÇÃO DE SÍMBOLOS

| Símbolo | Point | TP (pontos) | TP (preço) | SL (pontos) | SL (preço) |
|---------|-------|-------------|------------|-------------|------------|
| **BTCUSD** | 0.01 | 10000 | $100 | 5000 | $50 |
| **XAUUSD** | 0.01 | 1000 | $10 | 500 | $5 |
| **EURUSD** | 0.00001 | 200 | 20 pips | 100 | 10 pips |

---

## 🔍 LOGS DE INICIALIZAÇÃO

Quando você adicionar o EA ao gráfico BTCUSD, verá:

```
=== AUTO-ADJUSTING FOR SYMBOL ===
Symbol: BTCUSD
Point: 0.01
Min Stop Level: 0 points (0.0 price distance)
Detected: BTCUSD - Using larger stop values
ADJUSTED VALUES:
  TakeProfit: 10000 points (100.0 price)
  StopLoss: 5000 points (50.0 price)
  Breakeven: 1000 points
  Trailing: 2000 points

=== HttpTrader EA Initialized v3.2 ===
Symbol: BTCUSD
Point Size: 0.01
Digits: 2
Risk Percent: 2.0%
Auto-Adjust: YES
--- Active Values (AUTO-ADJUSTED) ---
Take Profit: 10000 points (100.0 price distance)
Stop Loss: 5000 points (50.0 price distance)
```

---

## 🧪 TESTE PARA BTCUSD

### **Passo 1: Configurar EA**
```
1. Arraste "tv" para o gráfico BTCUSD
2. Verifique: AutoAdjustForSymbol = true
3. Configure: RiskPercent = 2.0
4. Clique OK
```

### **Passo 2: Verificar Logs**
```
Na aba "Experts", confirme que vê:
"Detected: BTCUSD - Using larger stop values"
"TakeProfit: 10000 points"
```

### **Passo 3: Enviar Sinal**
```bash
curl -X POST https://livelier-nonpurposively-monty.ngrok-free.dev/sinais \
  -H "Content-Type: application/json" \
  -d '{"action": "long"}'
```

### **Passo 4: Verificar Ordem**
```
Deve aparecer nos logs:
=== BUY ORDER ===
Entry: 90350.63 | SL: 90300.63 (5000 pts = 50.0) | TP: 90450.63 (10000 pts = 100.0)
BUY SUCCESS: Vol=0.01 Entry=90350.63 SL=90300.63 (5000 points) TP=90450.63 (10000 points)
```

---

## ⚠️ PROBLEMAS COMUNS

### **Erro: "invalid stops" (10016)**

**Causa:** Stop level mínimo do broker é maior que o configurado

**Solução AUTOMÁTICA:**
O EA agora detecta e ajusta automaticamente!

**Solução MANUAL:**
```
1. Verifique o stop level mínimo:
   Print("Min Stop Level: ", SymbolInfoInteger("BTCUSD", SYMBOL_TRADE_STOPS_LEVEL));

2. Se for 100, use:
   StopLossPoints = 5000 (ou maior)
   TakeProfitPoints = 10000 (ou maior)
```

### **Volume muito pequeno**

**Causa:** RiskPercent muito baixo

**Solução:**
```
RiskPercent = 2.0  // Para equity $1000 = $20 de risco

Com SL de $50 → Volume ≈ 0.4 lotes
```

---

## 💡 CÁLCULO DE RISCO

### **Exemplo com BTCUSD:**

**Configuração:**
```
Equity: $1000
RiskPercent: 2.0%
StopLossPoints: 5000 ($50)
```

**Cálculo:**
```
Risk Amount = $1000 × 2% = $20
SL Distance = $50
Volume = $20 / $50 = 0.4 lotes

Interpretação:
- Se SL bater, perde $20 (2% do equity)
- Se TP bater ($100), ganha $40 (4% do equity)
- Proporção Risk:Reward = 1:2 ✅
```

---

## 🎯 VALORES SUGERIDOS POR ESTRATÉGIA

### **Conservador (Swing Trading):**
```
TakeProfitPoints = 15000     // $150
StopLossPoints = 7500        // $75
BreakEvenPoints = 1500       // $15
TrailingStopPoints = 3000    // $30
```

### **Moderado (PADRÃO):**
```
TakeProfitPoints = 10000     // $100
StopLossPoints = 5000        // $50
BreakEvenPoints = 1000       // $10
TrailingStopPoints = 2000    // $20
```

### **Agressivo (Day Trading):**
```
TakeProfitPoints = 5000      // $50
StopLossPoints = 2500        // $25
BreakEvenPoints = 500        // $5
TrailingStopPoints = 1000    // $10
```

### **Scalping:**
```
TakeProfitPoints = 2000      // $20
StopLossPoints = 1000        // $10
BreakEvenPoints = 200        // $2
TrailingStopPoints = 500     // $5
```

---

## 📋 CHECKLIST BTCUSD

- [ ] EA adicionado ao gráfico BTCUSD
- [ ] AutoAdjustForSymbol = true
- [ ] RiskPercent ajustado (1-3%)
- [ ] Logs mostram "Detected: BTCUSD"
- [ ] Valores ajustados aparecem (10000/5000)
- [ ] AutoTrading ativado (botão verde)
- [ ] Sinal de teste enviado
- [ ] Ordem aberta com SL/TP corretos
- [ ] Sem erro "invalid stops"
- [ ] Volume adequado (não muito pequeno)

---

## 🔄 MUDAR ENTRE SÍMBOLOS

### **De BTCUSD para XAUUSD:**
```
1. Remova o EA do gráfico BTCUSD
2. Adicione ao gráfico XAUUSD
3. AutoAdjustForSymbol detecta automaticamente
4. Valores serão ajustados para XAUUSD
```

**O EA detecta e ajusta sozinho!** 🎉

---

## 📊 EXEMPLO COMPLETO

**Sinal LONG em BTCUSD:**

```
Preço: 90350.63

Ordem Aberta:
Entry: 90350.63
SL: 90300.63 (-$50)
TP: 90450.63 (+$100)

Breakeven em 90360.63 (+$10):
→ SL move para 90350.63 + $0.20

Trailing a partir daí:
→ SL segue preço mantendo $20 de distância

Resultado:
Se bater TP = +$100
Se bater SL após trailing = +$20~$80 dependendo
```

---

## ✅ RESUMO

**ANTES (v3.1):**
- ❌ Valores fixos causavam "invalid stops"
- ❌ Tinha que ajustar manualmente por símbolo
- ❌ Erro difícil de resolver

**AGORA (v3.2):**
- ✅ Detecta símbolo automaticamente
- ✅ Ajusta valores automaticamente
- ✅ Valida contra stop level mínimo
- ✅ Funciona em BTCUSD, XAUUSD, Forex, etc!

---

**Pronto para operar BTCUSD!** 🚀
