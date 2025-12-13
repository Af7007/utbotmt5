# 📊 Guia: Stop Loss Baseado em Candles

## 🎯 NOVA FUNCIONALIDADE v3.3

### **SL Baseado em Price Action**
Agora você pode configurar o Stop Loss automaticamente baseado no fundo/topo dos últimos candles!

---

## ⚙️ COMO FUNCIONA

### **Para Ordens BUY (Compra):**
```
SL = LOW do último candle - margem

Exemplo:
Último candle: Low = 2650.00
Margem: 20 pontos ($0.20)
SL = 2650.00 - 0.20 = 2649.80
```

### **Para Ordens SELL (Venda):**
```
SL = HIGH do último candle + margem

Exemplo:
Último candle: High = 2655.00
Margem: 20 pontos ($0.20)
SL = 2655.00 + 0.20 = 2655.20
```

---

## 📐 VANTAGENS

✅ **SL dinâmico** baseado na estrutura do mercado
✅ **Respeita suporte/resistência** recente
✅ **Adapta-se à volatilidade** automaticamente
✅ **Mais profissional** que SL fixo
✅ **Protege contra breakouts falsos**

---

## ⚙️ PARÂMETROS

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `UseCandleBasedSL` | bool | false | Ativar SL baseado em candles |
| `CandleLookback` | int | 1 | Quantos candles analisar |
| `CandleSLMarginPoints` | int | 20 | Margem em pontos |

### **UseCandleBasedSL:**
- `false` → Usa SL fixo (StopLossPoints)
- `true` → Usa SL baseado em candles

### **CandleLookback:**
- `1` → Usa apenas o último candle
- `2` → Analisa os 2 últimos candles e pega o extremo
- `3` → Analisa os 3 últimos, etc.

### **CandleSLMarginPoints:**
- Margem de segurança além do Low/High
- Para XAUUSD: 10-50 pontos ($0.10-$0.50)
- Para BTCUSD: 100-500 pontos ($1-$5)

---

## 📊 EXEMPLOS PRÁTICOS

### **Exemplo 1: Último Candle (Padrão)**

**Configuração:**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 20
```

**Cenário BUY:**
```
Último candle:
  Open: 2650.00
  High: 2652.00
  Low: 2648.50
  Close: 2651.00

Entry: 2651.50
SL = 2648.50 - 0.20 = 2648.30
```

### **Exemplo 2: Múltiplos Candles**

**Configuração:**
```
UseCandleBasedSL = true
CandleLookback = 3
CandleSLMarginPoints = 50
```

**Cenário BUY:**
```
Últimos 3 candles:
  Candle 1: Low = 2648.50
  Candle 2: Low = 2647.80 ← MAIS BAIXO
  Candle 3: Low = 2649.00

Entry: 2651.50
SL = 2647.80 - 0.50 = 2647.30
```

### **Exemplo 3: BTCUSD**

**Configuração:**
```
Symbol: BTCUSD
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 200
```

**Cenário BUY:**
```
Último candle:
  Low = 90300.00

Entry: 90350.00
SL = 90300.00 - 2.00 = 90298.00
Distance = 90350.00 - 90298.00 = $52
```

---

## 🎯 CONFIGURAÇÕES RECOMENDADAS

### **Day Trading (Scalping):**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 10    // XAUUSD
```
**Por quê?** SL apertado, próximo à ação recente

### **Swing Trading:**
```
UseCandleBasedSL = true
CandleLookback = 3
CandleSLMarginPoints = 50    // XAUUSD
```
**Por quê?** SL mais largo, dá espaço para respirar

### **Price Action (Engulfing, Pin Bar):**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 20    // XAUUSD
```
**Por quê?** SL logo abaixo do padrão

### **Suporte/Resistência:**
```
UseCandleBasedSL = true
CandleLookback = 5
CandleSLMarginPoints = 30    // XAUUSD
```
**Por quê?** Encontra o extremo da zona

---

## 📝 LOGS ESPERADOS

Quando você usar Candle-Based SL, verá nos logs:

**Inicialização:**
```
--- Candle-Based SL Settings ---
Candle-Based SL: YES
Lookback Candles: 1
Margin: 20 points
```

**Abertura de Ordem BUY:**
```
Candle-Based SL (BUY): Lowest Low = 2648.50 - Margin (20 pts) = SL 2648.30
=== BUY ORDER ===
Entry: 2651.50 | SL: 2648.30 (distance = 3.20) | TP: 2661.50
BUY SUCCESS: Vol=0.01 Entry=2651.50 SL=2648.30 TP=2661.50
```

**Abertura de Ordem SELL:**
```
Candle-Based SL (SELL): Highest High = 2655.00 + Margin (20 pts) = SL 2655.20
=== SELL ORDER ===
Entry: 2653.00 | SL: 2655.20 (distance = 2.20) | TP: 2643.00
SELL SUCCESS: Vol=0.01 Entry=2653.00 SL=2655.20 TP=2643.00
```

---

## ⚠️ CONSIDERAÇÕES IMPORTANTES

### **1. Distância Variável do SL**

Com Candle-Based SL, a distância do SL pode variar:
- Candles grandes → SL mais distante
- Candles pequenos → SL mais próximo

**Isso afeta:**
- Volume calculado (risco fixo %)
- Proporção Risk:Reward

### **2. Volume Ajustado Automaticamente**

O EA calcula o volume baseado na distância REAL do SL:

```
SL Fixo (500 pontos):
  Volume = Risk / ($5) = constante

SL Baseado em Candle (varia 300-700 pontos):
  Volume = Risk / (distância variável) = ajustado
```

### **3. Validação de Stop Level**

O EA ainda valida o stop level mínimo do broker:
- Se SL calculado for muito próximo → Ordem falhará
- Solução: Aumente `CandleSLMarginPoints`

### **4. Timeframe Atual**

O EA usa `PERIOD_CURRENT` (timeframe do gráfico):
- M1 → Candles de 1 minuto
- M5 → Candles de 5 minutos
- H1 → Candles de 1 hora

**Certifique-se de estar no timeframe correto!**

---

## 🔄 COMPARAÇÃO: Fixo vs Candles

### **SL Fixo (Tradicional):**
```
Vantagens:
  ✅ Previsível
  ✅ Consistente
  ✅ Fácil de calcular

Desvantagens:
  ❌ Ignora estrutura do mercado
  ❌ Pode ser muito curto ou muito largo
  ❌ Mesmo tamanho para qualquer situação
```

### **SL Baseado em Candles:**
```
Vantagens:
  ✅ Respeita suporte/resistência
  ✅ Adapta-se à volatilidade
  ✅ Mais profissional
  ✅ Protege contra fakeouts

Desvantagens:
  ⚠️ Distância variável
  ⚠️ Pode ser muito largo às vezes
  ⚠️ Depende do timeframe
```

---

## 🧪 COMO TESTAR

### **Teste 1: Modo Candle-Based**

```
1. Configure:
   UseCandleBasedSL = true
   CandleLookback = 1
   CandleSLMarginPoints = 20

2. Envie sinal de teste

3. Verifique logs:
   - Deve mostrar "Candle-Based SL"
   - Deve mostrar Low/High do candle
   - SL deve estar abaixo do Low (BUY) ou acima do High (SELL)
```

### **Teste 2: Comparar com Fixo**

```
Teste A (Fixo):
  UseCandleBasedSL = false
  StopLossPoints = 500
  → SL sempre a $5 da entrada

Teste B (Candles):
  UseCandleBasedSL = true
  CandleLookback = 1
  → SL varia conforme candles
```

---

## 📊 ESTRATÉGIAS DE USO

### **Estratégia 1: Pin Bar**
```
Quando identificar Pin Bar:
  UseCandleBasedSL = true
  CandleLookback = 1
  CandleSLMarginPoints = 10

SL logo abaixo do pavio (wick) do pin bar
```

### **Estratégia 2: Breakout**
```
Quando breakout acontecer:
  UseCandleBasedSL = true
  CandleLookback = 2
  CandleSLMarginPoints = 30

SL abaixo da consolidação anterior
```

### **Estratégia 3: Suporte/Resistência**
```
Quando operar em S/R:
  UseCandleBasedSL = true
  CandleLookback = 3
  CandleSLMarginPoints = 50

SL abaixo da zona de suporte completa
```

---

## ⚙️ COMBINANDO COM OUTRAS FUNCIONALIDADES

### **Candle SL + Breakeven:**
```
UseCandleBasedSL = true
EnableBreakeven = true
BreakEvenPoints = 100

Fluxo:
1. SL inicial abaixo do candle
2. Quando lucro ≥ 100 pts → Breakeven
3. Depois → Trailing
```

### **Candle SL + Trailing:**
```
UseCandleBasedSL = true
EnableTrailingStop = true
TrailingStopPoints = 100

Fluxo:
1. SL inicial abaixo do candle (variável)
2. Breakeven ativa
3. Trailing segue o preço
```

---

## 📋 CHECKLIST

- [ ] UseCandleBasedSL configurado
- [ ] CandleLookback definido (1-5 típico)
- [ ] CandleSLMarginPoints adequado ao símbolo
- [ ] Timeframe do gráfico correto
- [ ] Teste em conta demo
- [ ] Logs mostram SL correto
- [ ] Ordem aberta sem erros
- [ ] SL está no lugar esperado

---

## 🎯 VALORES SUGERIDOS

### **XAUUSD:**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 20    // $0.20
```

### **BTCUSD:**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 200   // $2.00
```

### **EUR/USD:**
```
UseCandleBasedSL = true
CandleLookback = 1
CandleSLMarginPoints = 30    // 3 pips
```

---

**Agora você tem SL profissional baseado em price action!** 🎯
