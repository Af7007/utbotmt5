# 📝 Changelog v3.3 - Stop Loss Baseado em Candles

## 🎉 NOVA FUNCIONALIDADE

### **SL Dinâmico Baseado em Price Action**

Agora o EA pode colocar o Stop Loss automaticamente baseado no fundo/topo dos últimos candles!

---

## ✨ O QUE FOI ADICIONADO

### **1. Novos Parâmetros:**

```mql5
input bool UseCandleBasedSL = false;      // SL baseado em candles
input int  CandleLookback = 1;            // Quantos candles olhar
input int  CandleSLMarginPoints = 20;     // Margem além do Low/High
```

### **2. Nova Função:**

```mql5
double GetCandleBasedSL(bool isBuy)
{
    // Encontra o LOW mais baixo (BUY) ou HIGH mais alto (SELL)
    // nos últimos X candles
    // Adiciona margem de segurança
    // Retorna preço do SL
}
```

### **3. Lógica Atualizada:**

**PlaceBuyOrder():**
- Se `UseCandleBasedSL = false` → SL fixo (como antes)
- Se `UseCandleBasedSL = true` → SL = Lowest Low - margem

**PlaceSellOrder():**
- Se `UseCandleBasedSL = false` → SL fixo (como antes)
- Se `UseCandleBasedSL = true` → SL = Highest High + margem

---

## 📊 COMO FUNCIONA

### **Para BUY (Compra):**

```
Últimos candles:
  Candle 1: Low = 2648.50
  Candle 2: Low = 2647.80 ← MAIS BAIXO
  Candle 3: Low = 2649.00

Com CandleLookback = 3:
SL = 2647.80 - CandleSLMarginPoints
```

### **Para SELL (Venda):**

```
Últimos candles:
  Candle 1: High = 2655.00 ← MAIS ALTO
  Candle 2: High = 2654.20
  Candle 3: High = 2653.50

Com CandleLookback = 3:
SL = 2655.00 + CandleSLMarginPoints
```

---

## ⚙️ CONFIGURAÇÃO

### **Modo 1: SL Fixo (Padrão - Como Antes)**

```
UseCandleBasedSL = false
StopLossPoints = 500

Resultado:
SL sempre a 500 pontos da entrada
```

### **Modo 2: SL Baseado em 1 Candle**

```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 20

Resultado:
SL abaixo do low do último candle + margem
```

### **Modo 3: SL Baseado em Múltiplos Candles**

```
UseCandleBasedSL = true
CandleLookback = 3
CandleSLMarginPoints = 50

Resultado:
SL abaixo do low mais baixo dos últimos 3 candles + margem
```

---

## 🎯 CASOS DE USO

### **1. Pin Bar / Hammer:**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 10

→ SL logo abaixo do pavio (wick)
```

### **2. Breakout:**
```
UseCandleBasedSL = true
CandleLookback = 2
CandleSLMarginPoints = 30

→ SL abaixo da consolidação anterior
```

### **3. Suporte/Resistência:**
```
UseCandleBasedSL = true
CandleLookback = 5
CandleSLMarginPoints = 50

→ SL abaixo de toda a zona de suporte
```

---

## 📝 LOGS ESPERADOS

### **Inicialização:**

```
--- Candle-Based SL Settings ---
Candle-Based SL: YES
Lookback Candles: 1
Margin: 20 points
```

### **Abertura de Ordem:**

```
Candle-Based SL (BUY): Lowest Low = 2648.50 - Margin (20 pts) = SL 2648.30
=== BUY ORDER ===
Entry: 2651.50 | SL: 2648.30 (distance = 3.20) | TP: 2661.50
BUY SUCCESS: Vol=0.01 Entry=2651.50 SL=2648.30 TP=2661.50
```

---

## ⚠️ IMPORTANTE

### **1. Distância Variável**

Com Candle-Based SL, a distância do SL varia:
- Candles grandes → SL mais distante → Volume menor
- Candles pequenos → SL mais próximo → Volume maior

### **2. Timeframe Atual**

O EA usa o timeframe do gráfico onde está rodando:
- M1 → Candles de 1 minuto
- M5 → Candles de 5 minutos
- H1 → Candles de 1 hora

**Certifique-se de estar no timeframe correto!**

### **3. Volume Auto-Ajustado**

O volume é calculado baseado na distância REAL do SL:
```
Risk = 2% de $1000 = $20

SL Distance = $3.20
Volume = $20 / $3.20 = 0.06 lotes

SL Distance = $10.00
Volume = $20 / $10.00 = 0.02 lotes
```

---

## 🔄 MIGRAÇÃO

### **De v3.2 para v3.3:**

**Nenhuma mudança necessária!**

O comportamento padrão é o mesmo:
```
UseCandleBasedSL = false  (padrão)
```

Para usar a nova funcionalidade:
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 20
```

---

## 📊 ESTATÍSTICAS

**Código:**
- Linhas adicionadas: ~60
- Nova função: `GetCandleBasedSL()`
- Parâmetros novos: 3
- Versão: 3.3

**Compatibilidade:**
- ✅ 100% retrocompatível
- ✅ Funciona com BTCUSD
- ✅ Funciona com XAUUSD
- ✅ Funciona com Forex
- ✅ Funciona com Breakeven
- ✅ Funciona com Trailing Stop

---

## 🎯 VALORES SUGERIDOS

### **XAUUSD (Scalping):**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 10    // $0.10
```

### **XAUUSD (Day Trading):**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 20    // $0.20
```

### **XAUUSD (Swing):**
```
UseCandleBasedSL = true
CandleLookback = 3
CandleSLMarginPoints = 50    // $0.50
```

### **BTCUSD:**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 200   // $2.00
```

---

## 📚 DOCUMENTAÇÃO

**Novos arquivos:**
- **GUIA_CANDLE_SL.md** - Guia completo
- **CHANGELOG_V3_3.md** - Este arquivo

**Arquivos atualizados:**
- **tv.mq5** - v3.3 com Candle-Based SL

---

## ✅ TESTE

1. **Recompile o EA** (F7)
2. **Configure:**
   ```
   UseCandleBasedSL = true
   CandleLookback = 1
   CandleSLMarginPoints = 20
   ```
3. **Envie sinal de teste**
4. **Verifique logs:**
   - Deve mostrar "Candle-Based SL"
   - Deve mostrar Low/High do candle
   - SL deve estar posicionado corretamente

---

## 🎉 RESUMO

**v3.3 adiciona:**
- ✅ SL dinâmico baseado em price action
- ✅ Respeita estrutura do mercado
- ✅ Adapta-se à volatilidade
- ✅ Mais profissional
- ✅ Totalmente configurável
- ✅ 100% retrocompatível

---

**Versão 3.3 pronta!** 🚀
**Agora com SL profissional baseado em candles!** 📊
