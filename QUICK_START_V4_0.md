# 🚀 Quick Start - v4.0 ATR-Based SL

## ✅ MUDANÇAS PRINCIPAIS

**v4.0 SIMPLIFICA o EA:**
- ✅ SL inicial baseado em ATR (NOVO)
- ❌ Removido: SL baseado em candles
- ❌ Removido: Trailing dinâmico ATR
- ✅ Trailing é sempre fixo agora

---

## 🔧 RECOMPILAR

```
1. F4 → Abrir tv.mq5
2. F7 → Compilar
3. Verifique: "0 error(s)"
```

---

## ⚙️ CONFIGURAÇÃO BÁSICA

### **Modo 1: SL Fixo (Padrão - Como Antes)**

```
UseATRBasedSL = false
StopLossPoints = 500      // Seu valor
TakeProfitPoints = 1000   // Seu valor
TrailingStopPoints = 100  // Sempre fixo agora

Resultado:
→ SL sempre a 500 pontos
→ Comportamento previsível
```

### **Modo 2: SL Adaptativo com ATR (NOVO)**

```
UseATRBasedSL = true      ← ATIVAR
ATRPeriod = 14            ← Padrão
ATRMultiplier = 1.5       ← Ajuste conforme estratégia

Resultado:
→ SL adapta à volatilidade
→ Mercado calmo: SL próximo
→ Mercado volátil: SL mais largo
```

---

## 📝 LOGS ESPERADOS

### **Inicialização (ATR ON):**

```
=== HttpTrader EA Initialized v4.0 ===
Symbol: XAUUSD
...
--- Stop Loss Settings ---
ATR-Based SL: YES (Adaptive)
ATR Period: 14
ATR Multiplier: 1.5x
Note: SL adapts to volatility at order open
```

### **Abertura de Ordem:**

```
ATR-Based SL (BUY): ATR=1.20 x 1.5 = 1.80 → SL=2648.20
=== BUY ORDER ===
Entry: 2650.00 | SL: 2648.20 (distance = 1.8) | TP: 2660.00
BUY SUCCESS: ...
```

---

## 🧪 TESTE RÁPIDO (5 min)

### **1. Testar SL Fixo:**

```
UseATRBasedSL = false
StopLossPoints = 500

Enviar sinal:
curl -X POST https://your-url/sinais -d '{"action":"long"}'

Verificar:
✅ SL a 500 pontos da entrada
```

### **2. Testar SL com ATR:**

```
UseATRBasedSL = true
ATRPeriod = 14
ATRMultiplier = 1.5

Enviar sinal:
curl -X POST https://your-url/sinais -d '{"action":"long"}'

Verificar:
✅ Log mostra: "ATR-Based SL (BUY): ATR=X.XX x 1.5"
✅ SL varia conforme ATR atual
```

---

## ⚠️ BREAKING CHANGES

### **1. UseCandleBasedSL foi removido**

```
Antes (v3.x):
  UseCandleBasedSL = true
  CandleLookback = 1

Agora (v4.0):
  UseATRBasedSL = true    ← Use isto
  ATRMultiplier = 1.5
```

### **2. UseDynamicTrailing foi removido**

```
Antes (v3.x):
  UseDynamicTrailing = true
  → Trailing adaptava com ATR

Agora (v4.0):
  (parâmetro não existe)
  → Trailing é SEMPRE fixo
```

---

## 🎯 VALORES SUGERIDOS

### **Scalping M5:**
```
UseATRBasedSL = true
ATRMultiplier = 1.0
```

### **Day Trading M15:**
```
UseATRBasedSL = true
ATRMultiplier = 1.5
```

### **Swing H1:**
```
UseATRBasedSL = true
ATRMultiplier = 2.0
```

---

## ✅ CHECKLIST

- [ ] Recompilado (v4.0)
- [ ] Parâmetros atualizados
- [ ] Testado SL fixo
- [ ] Testado SL com ATR
- [ ] Logs corretos
- [ ] SL adapta à volatilidade

---

## 📚 DOCUMENTAÇÃO

- **CHANGELOG_V4_0.md** - Mudanças completas
- **CORRECAO_V3_6.md** - Fix anterior (AutoAdjust)

---

**v4.0 pronta!** 🚀
**SL adaptativo onde importa!** 📊
