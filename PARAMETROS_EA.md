# ⚙️ Parâmetros do EA tv.mq5

## 📋 LISTA COMPLETA DE PARÂMETROS

### **Trading Settings:**

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `TradingSymbol` | string | "XAUUSD" | Símbolo a ser negociado |
| `MagicNumber` | int | 12345 | Número mágico para identificar ordens |
| `RiskPercent` | double | 2.0 | Percentual do equity por trade |
| `TakeProfitPips` | int | 100 | Take Profit em pips |
| `StopLossPips` | int | 50 | Stop Loss inicial em pips |
| `PollingIntervalSec` | int | 1 | Frequência de leitura do arquivo (segundos) |
| `SignalFilePath` | string | "signal.json" | Nome do arquivo de sinal |

### **Breakeven Settings:**

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `EnableBreakeven` | bool | true | Ativar/Desativar Breakeven |
| `BreakEvenPips` | int | 10 | Lucro necessário para ativar breakeven |
| `BreakEvenExtraPips` | int | 2 | Pips além do ponto de entrada |

### **Trailing Stop Settings:**

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `EnableTrailingStop` | bool | true | Ativar/Desativar Trailing Stop |
| `TrailingStopPips` | int | 10 | Distância do SL em relação ao preço |
| `TrailingStepPips` | int | 5 | Mover SL a cada X pips |

---

## 🎯 CONFIGURAÇÕES RÁPIDAS

### **Perfil 1: Conservador**
```
TradingSymbol = "XAUUSD"
RiskPercent = 1.0
TakeProfitPips = 150
StopLossPips = 75
EnableBreakeven = true
BreakEvenPips = 20
BreakEvenExtraPips = 5
EnableTrailingStop = true
TrailingStopPips = 25
TrailingStepPips = 12
```

### **Perfil 2: Moderado (PADRÃO)**
```
TradingSymbol = "XAUUSD"
RiskPercent = 2.0
TakeProfitPips = 100
StopLossPips = 50
EnableBreakeven = true
BreakEvenPips = 10
BreakEvenExtraPips = 2
EnableTrailingStop = true
TrailingStopPips = 10
TrailingStepPips = 5
```

### **Perfil 3: Agressivo**
```
TradingSymbol = "XAUUSD"
RiskPercent = 3.0
TakeProfitPips = 80
StopLossPips = 40
EnableBreakeven = true
BreakEvenPips = 5
BreakEvenExtraPips = 1
EnableTrailingStop = true
TrailingStopPips = 7
TrailingStepPips = 3
```

### **Perfil 4: Apenas Breakeven**
```
TradingSymbol = "XAUUSD"
RiskPercent = 2.0
TakeProfitPips = 100
StopLossPips = 50
EnableBreakeven = true
BreakEvenPips = 10
BreakEvenExtraPips = 2
EnableTrailingStop = false
```

### **Perfil 5: Apenas Trailing**
```
TradingSymbol = "XAUUSD"
RiskPercent = 2.0
TakeProfitPips = 100
StopLossPips = 50
EnableBreakeven = false
EnableTrailingStop = true
TrailingStopPips = 15
TrailingStepPips = 7
```

---

## 🔧 COMO CONFIGURAR NO MT5

1. **Abrir Propriedades do EA:**
   - Clique com botão direito no gráfico
   - **"Expert Advisors"** → **"Properties"**

2. **Aba "Inputs":**
   - Aqui você verá todos os parâmetros
   - Altere os valores conforme desejado

3. **Salvar:**
   - Clique em **"OK"**
   - O EA será reiniciado com as novas configurações

---

## 💡 DICAS DE CONFIGURAÇÃO

### **RiskPercent:**
- **1%:** Muito conservador (crescimento lento)
- **2%:** Recomendado para maioria dos traders
- **3-5%:** Agressivo (risco maior)
- **Acima de 5%:** Muito arriscado

### **TakeProfitPips vs StopLossPips:**
- **Proporção 2:1** (TP=100, SL=50) → Recomendado
- **Proporção 3:1** (TP=150, SL=50) → Agressivo
- **Proporção 1:1** (TP=50, SL=50) → Scalping

### **BreakEvenPips:**
- Deve ser **MENOR** que TakeProfitPips
- Recomendado: 10-20% do TP
- Exemplo: Se TP=100, use BreakEven=10-20

### **TrailingStopPips:**
- Deve ser **MENOR** que TakeProfitPips
- Recomendado: 10-20% do TP
- Muito pequeno → Fecha cedo demais
- Muito grande → Não protege lucro

### **TrailingStepPips:**
- Recomendado: 50% do TrailingStopPips
- Exemplo: TrailingStop=10 → Step=5
- Muito pequeno → Muitas modificações
- Muito grande → SL demora a mover

---

## ⚠️ CONVERSÃO DE PIPS

### **Para XAUUSD (Ouro):**
- 1 pip = 0.10
- 10 pips = 1.00
- 50 pips = 5.00
- 100 pips = 10.00

**No código:** Multiplicamos por 10 pontos
```
StopLossPips = 50 → 50 * 10 * point = 5.00
```

### **Para Forex (EUR/USD, etc):**
- 1 pip = 0.0001
- 10 pips = 0.0010
- 50 pips = 0.0050
- 100 pips = 0.0100

**Se você negociar Forex:** Remova a multiplicação por 10 no código.

---

## 📊 EXEMPLO PRÁTICO

**Configuração:**
```
TradingSymbol = "XAUUSD"
RiskPercent = 2.0
TakeProfitPips = 100
StopLossPips = 50
EnableBreakeven = true
BreakEvenPips = 10
BreakEvenExtraPips = 2
EnableTrailingStop = true
TrailingStopPips = 10
TrailingStepPips = 5
```

**Cenário - Posição BUY em 2650.00:**

1. **Ordem Aberta:**
   - Entry: 2650.00
   - SL: 2645.00 (-50 pips)
   - TP: 2660.00 (+100 pips)

2. **Preço atinge 2660.00 (+10 pips):**
   - ✅ Breakeven ativado
   - SL movido para: 2650.20 (+2 pips)
   - Lucro garantido!

3. **Preço continua subindo para 2665.00:**
   - ✅ Trailing ativado
   - SL movido para: 2655.00 (10 pips abaixo)

4. **Preço atinge 2670.00:**
   - ✅ Trailing continua
   - SL movido para: 2660.00 (10 pips abaixo)

5. **Preço cai para 2660.00:**
   - 🎯 Ordem fechada no SL 2660.00
   - Lucro: +10 pips (ao invés de 0!)

---

## 🎯 AJUSTE FINO POR ATIVO

### **XAUUSD (Ouro):**
```
TakeProfitPips = 80-150
StopLossPips = 40-75
BreakEvenPips = 8-15
TrailingStopPips = 8-20
```

### **EUR/USD:**
```
TakeProfitPips = 20-50
StopLossPips = 10-25
BreakEvenPips = 5-10
TrailingStopPips = 5-15
```

### **BTC/USD:**
```
TakeProfitPips = 200-500
StopLossPips = 100-250
BreakEvenPips = 50-100
TrailingStopPips = 50-150
```

---

## ✅ CHECKLIST DE OTIMIZAÇÃO

- [ ] Testei em conta demo
- [ ] Ajustei RiskPercent conforme meu perfil
- [ ] Configurei proporção TP:SL adequada
- [ ] Testei breakeven com diferentes valores
- [ ] Testei trailing stop com diferentes valores
- [ ] Verifiquei os logs no MT5
- [ ] Acompanhei pelo menos 10 trades
- [ ] Ajustei parâmetros baseado nos resultados
- [ ] Documentei minhas configurações
- [ ] Estou satisfeito com o desempenho

---

## 📚 DOCUMENTAÇÃO RELACIONADA

- **BREAKEVEN_TRAILING_GUIDE.md** - Guia detalhado de uso
- **TRADINGVIEW_SETUP.md** - Configuração do TradingView
- **TROUBLESHOOTING.md** - Resolução de problemas
- **RESUMO_FINAL.md** - Visão geral do sistema

---

**Lembre-se:** Sempre teste em conta DEMO antes de usar em conta real!
