# 🎯 Guia de Breakeven e Trailing Stop

## 📊 NOVAS FUNCIONALIDADES IMPLEMENTADAS

O EA **tv.mq5** agora inclui:
- ✅ **Breakeven** (Mover SL para ponto de entrada após lucro)
- ✅ **Trailing Stop** (Seguir o preço com SL em lucro)

---

## ⚙️ PARÂMETROS CONFIGURÁVEIS

### **Breakeven Settings:**

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `EnableBreakeven` | bool | true | Ativar/Desativar Breakeven |
| `BreakEvenPips` | int | 10 | Lucro necessário para ativar (em pips) |
| `BreakEvenExtraPips` | int | 2 | Pips além do ponto de entrada |

### **Trailing Stop Settings:**

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `EnableTrailingStop` | bool | true | Ativar/Desativar Trailing Stop |
| `TrailingStopPips` | int | 10 | Distância do SL em relação ao preço |
| `TrailingStepPips` | int | 5 | Mover SL a cada X pips |

---

## 🎯 COMO FUNCIONA O BREAKEVEN

### **Conceito:**
Quando a posição atinge um determinado lucro, o Stop Loss é movido para o ponto de entrada (ou próximo dele) para garantir que você não tenha prejuízo.

### **Exemplo Prático:**

**Configuração:**
- `EnableBreakeven = true`
- `BreakEvenPips = 10`
- `BreakEvenExtraPips = 2`

**Cenário - Posição BUY:**
1. Ordem aberta em **2650.00**
2. SL inicial em **2645.00** (50 pips)
3. TP em **2660.00** (100 pips)

**Quando o preço atinge 2660.00 (lucro de 10 pips):**
- ✅ EA move o SL para **2650.20** (entrada + 2 pips)
- 🎉 **Agora você tem lucro garantido de 2 pips!**

### **Cenário - Posição SELL:**
1. Ordem aberta em **2650.00**
2. SL inicial em **2655.00** (50 pips)
3. TP em **2640.00** (100 pips)

**Quando o preço atinge 2640.00 (lucro de 10 pips):**
- ✅ EA move o SL para **2649.80** (entrada - 2 pips)
- 🎉 **Lucro garantido de 2 pips!**

---

## 📈 COMO FUNCIONA O TRAILING STOP

### **Conceito:**
O Stop Loss "segue" o preço mantendo uma distância fixa. À medida que o preço se move a seu favor, o SL também se move, protegendo seus lucros.

### **Exemplo Prático:**

**Configuração:**
- `EnableTrailingStop = true`
- `TrailingStopPips = 10`
- `TrailingStepPips = 5`

**Cenário - Posição BUY:**
1. Ordem aberta em **2650.00**
2. Preço atual: **2660.00**
3. SL será movido para **2650.00** (10 pips abaixo do preço atual)

**À medida que o preço sobe:**
- Preço: **2665.00** → SL move para **2655.00** (10 pips abaixo)
- Preço: **2670.00** → SL move para **2660.00** (10 pips abaixo)
- Preço: **2675.00** → SL move para **2665.00** (10 pips abaixo)

**Se o preço cair:**
- Preço: **2674.00** → SL **NÃO MOVE** (permanece em 2665.00)
- Preço: **2665.00** → **ORDEM FECHADA** com lucro de 15 pips!

### **Parâmetro TrailingStepPips:**
Controla a frequência de movimento do SL.

- `TrailingStepPips = 5` → SL só move a cada 5 pips de lucro adicional
- Evita atualizações excessivas e rejeições do broker

---

## 🔄 INTERAÇÃO ENTRE BREAKEVEN E TRAILING STOP

Quando ambos estão ativos, eles trabalham juntos:

### **Sequência de Operação:**

1. **Posição Aberta**
   - SL inicial: -50 pips
   - TP: +100 pips

2. **Preço sobe 10 pips → BREAKEVEN ATIVADO**
   - SL movido para entrada + 2 pips
   - Lucro garantido: +2 pips

3. **Preço sobe mais → TRAILING STOP ASSUME**
   - SL começa a seguir o preço
   - Mantém 10 pips de distância
   - Move a cada 5 pips de progresso

4. **Resultado:**
   - Proteção inicial com breakeven
   - Maximização de lucro com trailing stop

---

## ⚙️ CONFIGURAÇÕES RECOMENDADAS

### **Trading Conservador:**
```
EnableBreakeven = true
BreakEvenPips = 15
BreakEvenExtraPips = 5

EnableTrailingStop = true
TrailingStopPips = 20
TrailingStepPips = 10
```

**Características:**
- Breakeven mais distante (precisa de mais lucro)
- Trailing mais largo (dá mais respiro ao preço)
- Menos movimentações de SL

### **Trading Moderado (PADRÃO):**
```
EnableBreakeven = true
BreakEvenPips = 10
BreakEvenExtraPips = 2

EnableTrailingStop = true
TrailingStopPips = 10
TrailingStepPips = 5
```

**Características:**
- Equilíbrio entre proteção e liberdade
- Breakeven rápido
- Trailing moderado

### **Trading Agressivo:**
```
EnableBreakeven = true
BreakEvenPips = 5
BreakEvenExtraPips = 1

EnableTrailingStop = true
TrailingStopPips = 5
TrailingStepPips = 2
```

**Características:**
- Breakeven muito rápido
- Trailing bem apertado
- Máxima proteção de lucro
- ⚠️ Pode ser fechado prematuramente em mercados voláteis

### **Apenas Breakeven (Sem Trailing):**
```
EnableBreakeven = true
BreakEvenPips = 10
BreakEvenExtraPips = 2

EnableTrailingStop = false
```

**Quando usar:**
- Mercados laterais/consolidação
- Quando você quer deixar o TP trabalhar
- Apenas proteger contra reversões

### **Apenas Trailing (Sem Breakeven):**
```
EnableBreakeven = false

EnableTrailingStop = true
TrailingStopPips = 15
TrailingStepPips = 7
```

**Quando usar:**
- Tendências fortes
- Quando você quer maximizar lucro
- Aceita o risco inicial

---

## 📝 LOGS NO MT5

Quando o EA move o SL, você verá mensagens na aba **"Experts"**:

### **Breakeven:**
```
BREAKEVEN APPLIED: Ticket=123456789 New SL=2650.20 (+2 pips)
```

### **Trailing Stop:**
```
TRAILING STOP: Ticket=123456789 Old SL=2650.00 New SL=2655.00 (10 pips from price)
```

### **Erros:**
```
BREAKEVEN FAILED: Invalid stops
TRAILING STOP FAILED: Trade context busy
```

---

## 🧪 COMO TESTAR

### **Teste 1: Verificar Breakeven**

1. Abra uma posição (via webhook ou manual)
2. Observe o preço
3. Quando atingir `BreakEvenPips` de lucro, verifique se o SL foi movido
4. Confira os logs na aba "Experts"

### **Teste 2: Verificar Trailing Stop**

1. Abra uma posição com lucro (aguarde o preço se mover)
2. Observe o preço continuando a se mover a seu favor
3. Verifique se o SL está "seguindo" o preço
4. Confira os logs mostrando as atualizações

### **Teste 3: Conta Demo**

⚠️ **IMPORTANTE:** Sempre teste em conta DEMO primeiro!

```
1. Configure os parâmetros desejados
2. Envie um sinal de teste (LONG ou SHORT)
3. Simule movimento de preço
4. Observe o comportamento do SL
5. Ajuste parâmetros conforme necessário
```

---

## ⚠️ CONSIDERAÇÕES IMPORTANTES

### **Distância Mínima (Stop Level):**
Cada broker tem uma distância mínima para SL/TP. Se você configurar valores muito pequenos:
- Você pode ver erros: `"SL/TP too close"`
- **Solução:** Aumente os valores de pips

### **Spread:**
- Em mercados com spread alto, o trailing pode não funcionar suavemente
- **Solução:** Aumente `TrailingStepPips`

### **Volatilidade:**
- Em mercados muito voláteis, trailing apertado pode fechar posições cedo
- **Solução:** Use trailing mais largo

### **Custo de Modificação:**
- Alguns brokers cobram por modificar ordens
- **Solução:** Aumente `TrailingStepPips` para reduzir modificações

---

## 🎯 CENÁRIOS DE USO

### **Cenário 1: News Trading**
```
EnableBreakeven = true
BreakEvenPips = 5
BreakEvenExtraPips = 1

EnableTrailingStop = true
TrailingStopPips = 8
TrailingStepPips = 3
```
**Por quê?** Movimentos rápidos, precisa proteger lucro rapidamente.

### **Cenário 2: Swing Trading**
```
EnableBreakeven = true
BreakEvenPips = 20
BreakEvenExtraPips = 5

EnableTrailingStop = true
TrailingStopPips = 30
TrailingStepPips = 15
```
**Por quê?** Posições de longo prazo, precisa dar espaço para respirar.

### **Cenário 3: Scalping**
```
EnableBreakeven = true
BreakEvenPips = 3
BreakEvenExtraPips = 1

EnableTrailingStop = false
```
**Por quê?** Lucros pequenos, proteger rapidamente e deixar TP fechar.

---

## 🔧 TROUBLESHOOTING

### **SL não está movendo:**

**Verifique:**
1. ✅ `EnableBreakeven` ou `EnableTrailingStop` está `true`?
2. ✅ Posição tem lucro suficiente?
3. ✅ `TrailingStepPips` não está muito grande?
4. ✅ Broker permite modificação de SL?
5. ✅ Confira logs na aba "Experts"

### **Erro "Invalid stops":**

**Causa:** SL muito próximo do preço atual
**Solução:** Aumente os valores de pips

### **Erro "Trade context busy":**

**Causa:** MT5 está processando outra operação
**Solução:** Normal, o EA vai tentar novamente no próximo tick

---

## 📊 RESUMO VISUAL

```
POSIÇÃO BUY - XAUUSD

Entrada: 2650.00
SL Inicial: 2645.00 (-50 pips)
TP: 2660.00 (+100 pips)

[Preço sobe para 2660.00 - Lucro: +10 pips]
→ BREAKEVEN ATIVADO
   SL movido para: 2650.20 (+2 pips)

[Preço sobe para 2665.00 - Lucro: +15 pips]
→ TRAILING STOP ATIVADO
   SL movido para: 2655.00 (10 pips abaixo)

[Preço sobe para 2670.00 - Lucro: +20 pips]
→ TRAILING CONTINUA
   SL movido para: 2660.00 (10 pips abaixo)

[Preço cai para 2660.00]
→ ORDEM FECHADA no SL
   Lucro final: +10 pips (graças ao trailing!)
```

---

## ✅ CHECKLIST DE CONFIGURAÇÃO

- [ ] Abri o MT5
- [ ] Arrastei o EA "tv" para o gráfico
- [ ] Configurei os parâmetros de Breakeven
- [ ] Configurei os parâmetros de Trailing Stop
- [ ] Ativei AutoTrading (botão verde)
- [ ] Testei em conta DEMO primeiro
- [ ] Verifiquei os logs na aba "Experts"
- [ ] Enviei um sinal de teste
- [ ] Observei o comportamento do SL
- [ ] Ajustei parâmetros conforme necessário

---

## 🎉 PRONTO PARA USAR!

Agora seu EA está equipado com gestão avançada de risco:
- ✅ Proteção automática com Breakeven
- ✅ Maximização de lucro com Trailing Stop
- ✅ Totalmente configurável em pips
- ✅ Funciona para BUY e SELL

**Boa sorte nos trades!** 🚀
