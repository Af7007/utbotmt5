# 📐 Guia de Configuração em Pontos

## ✅ MUDANÇA IMPORTANTE

O EA agora trabalha **diretamente com PONTOS** ao invés de PIPS, eliminando conversões e possíveis erros.

---

## 🎯 ENTENDENDO PONTOS

### **O que são Pontos?**
Pontos são a menor unidade de preço que um símbolo pode se mover.

### **Para XAUUSD (Ouro):**
```
1 ponto = 0.01
10 pontos = 0.10
100 pontos = 1.00
500 pontos = 5.00
1000 pontos = 10.00
```

**Exemplo:**
- Preço: 2650.00
- SL em 500 pontos = 2650.00 - 5.00 = 2645.00
- TP em 1000 pontos = 2650.00 + 10.00 = 2660.00

### **Para EUR/USD (Forex com 5 dígitos):**
```
1 ponto = 0.00001
10 pontos = 0.0001 (1 pip)
100 pontos = 0.001
1000 pontos = 0.01
```

---

## ⚙️ NOVOS PARÂMETROS

### **Trading Settings:**

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `TakeProfitPoints` | int | 1000 | TP em pontos (ex: 1000 = $10 para XAUUSD) |
| `StopLossPoints` | int | 500 | SL em pontos (ex: 500 = $5 para XAUUSD) |

### **Breakeven Settings:**

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `BreakEvenPoints` | int | 100 | Ativa após X pontos de lucro |
| `BreakEvenExtraPoints` | int | 20 | Pontos além da entrada |

### **Trailing Stop Settings:**

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `TrailingStopPoints` | int | 100 | Distância do SL (pontos) |
| `TrailingStepPoints` | int | 50 | Move a cada X pontos |

---

## 🔢 TABELA DE CONVERSÃO (XAUUSD)

| Valor Desejado | Pontos | Comentário |
|----------------|--------|------------|
| $1.00 | 100 | Movimento de $1 |
| $2.50 | 250 | |
| $5.00 | 500 | **SL padrão** |
| $7.50 | 750 | |
| $10.00 | 1000 | **TP padrão** |
| $15.00 | 1500 | |
| $20.00 | 2000 | |
| $50.00 | 5000 | |
| $100.00 | 10000 | |

---

## 🎯 CONFIGURAÇÕES RECOMENDADAS (XAUUSD)

### **Conservador (Swing Trading):**
```
TakeProfitPoints = 1500      // $15
StopLossPoints = 750         // $7.50
BreakEvenPoints = 150        // $1.50
BreakEvenExtraPoints = 50    // $0.50
TrailingStopPoints = 200     // $2.00
TrailingStepPoints = 100     // $1.00
```

### **Moderado (PADRÃO):**
```
TakeProfitPoints = 1000      // $10
StopLossPoints = 500         // $5
BreakEvenPoints = 100        // $1.00
BreakEvenExtraPoints = 20    // $0.20
TrailingStopPoints = 100     // $1.00
TrailingStepPoints = 50      // $0.50
```

### **Agressivo (Scalping):**
```
TakeProfitPoints = 500       // $5
StopLossPoints = 250         // $2.50
BreakEvenPoints = 50         // $0.50
BreakEvenExtraPoints = 10    // $0.10
TrailingStopPoints = 50      // $0.50
TrailingStepPoints = 20      // $0.20
```

### **Day Trading:**
```
TakeProfitPoints = 800       // $8
StopLossPoints = 400         // $4
BreakEvenPoints = 80         // $0.80
BreakEvenExtraPoints = 20    // $0.20
TrailingStopPoints = 80      // $0.80
TrailingStepPoints = 40      // $0.40
```

---

## 📊 EXEMPLO PRÁTICO

### **Configuração:**
```
TakeProfitPoints = 1000
StopLossPoints = 500
BreakEvenPoints = 100
BreakEvenExtraPoints = 20
TrailingStopPoints = 100
TrailingStepPoints = 50
```

### **Cenário - Posição BUY em 2650.00:**

**1. Ordem Aberta:**
```
Entry: 2650.00
SL: 2645.00 (500 pontos = $5 abaixo)
TP: 2660.00 (1000 pontos = $10 acima)
```

**2. Preço sobe para 2651.00 (+100 pontos = $1):**
```
✅ BREAKEVEN ATIVADO!
SL movido para: 2650.20 (20 pontos = $0.20 acima da entrada)
Lucro garantido: $0.20
```

**3. Preço sobe para 2652.00 (+200 pontos = $2):**
```
✅ TRAILING ATIVADO!
SL movido para: 2651.00 (100 pontos = $1 abaixo do preço)
Lucro protegido: $1
```

**4. Preço sobe para 2655.00 (+500 pontos = $5):**
```
✅ TRAILING CONTINUA!
SL agora em: 2654.00 (100 pontos = $1 abaixo)
Lucro protegido: $4
```

**5. Preço cai para 2654.00:**
```
🎯 ORDEM FECHADA NO SL!
Lucro final: $4 (400 pontos)

SEM trailing: Lucro seria $0.20 (apenas breakeven)
COM trailing: $4 garantidos! 🎉
```

---

## 🔍 COMO VERIFICAR OS VALORES NO MT5

Quando você iniciar o EA, verá nos logs:

```
=== HttpTrader EA Initialized (Simple/No DLL) ===
Symbol: XAUUSD
Point Size: 0.01
Digits: 2
Take Profit: 1000 points (10.0 price distance)
Stop Loss: 500 points (5.0 price distance)
```

**Interpretação:**
- `Point Size: 0.01` → 1 ponto = $0.01 para XAUUSD
- `1000 points (10.0 price distance)` → 1000 × 0.01 = $10

---

## 🔧 COMO CONFIGURAR

1. **Abra o gráfico** com o EA
2. **Clique direito** → Expert Advisors → Properties
3. **Aba "Inputs"** - Ajuste os valores:

```
TakeProfitPoints = 1000     // Para $10 de TP
StopLossPoints = 500        // Para $5 de SL
BreakEvenPoints = 100       // Ativa com $1 de lucro
TrailingStopPoints = 100    // Mantém SL $1 abaixo do preço
```

4. **Clique OK**

---

## ⚠️ IMPORTANTE

### **Calcule o Point Size do seu símbolo:**

```mql5
// No MT5, vá em Tools → Options → Symbols
// Ou veja nos logs do EA quando iniciar
```

**XAUUSD:**
- Point = 0.01
- 100 pontos = $1

**EUR/USD (5 dígitos):**
- Point = 0.00001
- 10 pontos = 1 pip
- 100 pontos = 10 pips

### **Se você operar outro ativo:**

1. Verifique o Point Size
2. Calcule quantos pontos precisa
3. Configure os parâmetros

**Exemplo para BTC/USD (point = 0.01):**
- Para SL de $100 → 10000 pontos
- Para TP de $300 → 30000 pontos

---

## 📝 VANTAGENS DO SISTEMA EM PONTOS

✅ **Sem conversão** - Não precisa multiplicar/dividir por 10
✅ **Mais preciso** - Funciona com qualquer símbolo
✅ **Mais claro** - Valor exato que aparece no código
✅ **Sem erro** - Não depende de "adivinhar" o multiplicador
✅ **Universal** - Funciona para Forex, Ouro, Índices, Cripto

---

## 🎯 CHECKLIST DE CONFIGURAÇÃO

- [ ] Verificar Point Size do símbolo no MT5
- [ ] Calcular quantos pontos = valor desejado em $
- [ ] Configurar TakeProfitPoints
- [ ] Configurar StopLossPoints
- [ ] Configurar BreakEvenPoints
- [ ] Configurar TrailingStopPoints
- [ ] Testar em conta DEMO
- [ ] Verificar logs para confirmar valores
- [ ] Ajustar conforme resultados

---

## 💡 DICA RÁPIDA

**Para XAUUSD:**
Se você quer um SL de **$X dólares**, use:
```
StopLossPoints = X × 100
```

Exemplos:
- $3 → 300 pontos
- $5 → 500 pontos
- $7.50 → 750 pontos
- $10 → 1000 pontos

---

**Agora você tem controle total e preciso sobre seus stops!** 🎯
