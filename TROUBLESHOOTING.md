# 🔧 Troubleshooting - Por que a Ordem Não Abriu?

## ✅ CHECKLIST DE VERIFICAÇÃO

### 1. **Verificar se o Webhook Está Recebendo os Sinais**

```bash
# Ver últimos logs
tail -20 logs/webhook.log
```

**✅ SUCESSO:** Você deve ver:
```
Signal received: long -> buy
Signal written to file successfully
```

**❌ ERRO:** Se ver "Request is not JSON":
- O TradingView não enviou JSON válido
- **SOLUÇÃO:** Veja seção "Configuração Correta do TradingView" abaixo

---

### 2. **Verificar se o Arquivo signal.json Foi Criado**

```bash
cat "%APPDATA%\MetaQuotes\Terminal\Common\Files\signal.json"
```

**✅ SUCESSO:** Deve mostrar algo como:
```json
{"action": "buy", "timestamp": "2025-12-12T17:14:28.913136+00:00"}
```

**❌ ERRO:** Se o arquivo não existe ou está vazio:
- Problema no webhook
- Verifique permissões de escrita na pasta

---

### 3. **Verificar se o EA (tv.mq5) Está Rodando no MT5**

**No MetaTrader 5:**

1. **Verifique se o Expert Advisor está ativo:**
   - Vá até a aba **"Navigator"** (Ctrl+N)
   - Expanda **"Expert Advisors"**
   - Você deve ver **"tv"** na lista

2. **Verifique se está rodando no gráfico:**
   - Abra o gráfico do **XAUUSD** (ou outro símbolo)
   - No canto superior direito, deve aparecer **"tv"** com um sorriso 😊
   - Se estiver triste 😞 = EA com erro
   - Se não aparecer nada = EA não está rodando

3. **Ativar o EA no gráfico:**
   - Arraste **"tv"** da janela Navigator para o gráfico
   - Vai abrir uma janela de configuração
   - Clique em **"OK"**

---

### 4. **Verificar se o AutoTrading Está Habilitado**

**No MetaTrader 5:**

1. Na barra superior, procure o botão **"AutoTrading"** (ícone de play/robô)
2. Deve estar **VERDE** e **ATIVO**
3. Se estiver vermelho, clique nele para ativar

**OU use o atalho:** `Ctrl + E`

---

### 5. **Verificar os Logs do EA no MT5**

**No MetaTrader 5:**

1. Abra a aba **"Experts"** (parte inferior da tela)
2. Procure por mensagens do EA "tv"
3. Deve mostrar algo como:

```
=== Processing Trade Signal ===
Action: buy
Closing all positions for XAUUSD
Volume calculated: Equity=10000 Risk=200 Volume=0.01
BUY SUCCESS: Vol=0.01 Entry=2656.50 SL=2651.50 TP=2666.50
=== Trade Signal Processed ===
```

**❌ POSSÍVEIS ERROS:**

- **"Invalid volume":** Ajuste o parâmetro RiskPercent
- **"SL/TP too close":** Aumente os valores de TakeProfitPips e StopLossPips
- **"Trade context busy":** Aguarde alguns segundos e tente novamente
- **"Not enough money":** Saldo insuficiente
- **"Invalid stops":** O broker não aceita SL/TP tão próximos

---

### 6. **Verificar Configuração do EA**

**No gráfico onde o EA está rodando:**

1. Clique com o botão direito no gráfico
2. **"Expert Advisors"** → **"Properties"**
3. Na aba **"Inputs"**, verifique:

```
TradingSymbol = "XAUUSD"        # Deve ser o símbolo correto
MagicNumber = 12345             # Qualquer número único
RiskPercent = 2.0               # 1-5% é seguro
TakeProfitPips = 100            # Ajuste conforme estratégia
StopLossPips = 50               # Ajuste conforme estratégia
PollingIntervalSec = 1          # 1 segundo é bom
SignalFilePath = "signal.json"  # Nome do arquivo
```

4. Na aba **"Common"**, verifique:
   - ✅ **"Allow Algo Trading"** deve estar marcado
   - ✅ **"Allow live trading"** deve estar marcado

---

## 📋 CONFIGURAÇÃO CORRETA DO TRADINGVIEW

### **Passo a Passo:**

1. **Criar/Editar Alerta no TradingView**
2. **Em "Notificações":**
   - ✅ Marque **"Webhook URL"**
   - Cole: `https://livelier-nonpurposively-monty.ngrok-free.dev/sinais`

3. **⚠️ IMPORTANTE - Em "Message":**

   **Para alerta de COMPRA (LONG):**
   ```json
   {"action": "long"}
   ```

   **Para alerta de VENDA (SHORT):**
   ```json
   {"action": "short"}
   ```

   **⚠️ NÃO ADICIONE NADA ALÉM DISSO!**
   - ❌ Não adicione texto antes ou depois
   - ❌ Não use `{{ticker}}` ou outras variáveis
   - ❌ Não adicione quebras de linha
   - ✅ Cole APENAS o JSON puro

4. **Salvar o Alerta**

---

## 🧪 TESTE MANUAL (SEM TRADINGVIEW)

Se você quer testar se o sistema está funcionando SEM usar o TradingView:

### **Teste 1: Enviar Sinal de COMPRA**
```bash
curl -X POST https://livelier-nonpurposively-monty.ngrok-free.dev/sinais \
  -H "Content-Type: application/json" \
  -d '{"action": "long"}'
```

**Espere 1-2 segundos** e verifique no MT5 se a ordem foi aberta.

### **Teste 2: Enviar Sinal de VENDA**
```bash
curl -X POST https://livelier-nonpurposively-monty.ngrok-free.dev/sinais \
  -H "Content-Type: application/json" \
  -d '{"action": "short"}'
```

### **Teste 3: Verificar se Chegou**
```bash
cat "%APPDATA%\MetaQuotes\Terminal\Common\Files\signal.json"
```

---

## 🔍 VERIFICAR LOGS EM TEMPO REAL

### **Terminal 1 - Logs do Webhook:**
```bash
tail -f logs/webhook.log
```

### **Terminal 2 - Enviar Sinais de Teste:**
```bash
# Compra
curl -X POST https://livelier-nonpurposively-monty.ngrok-free.dev/sinais \
  -H "Content-Type: application/json" \
  -d '{"action": "long"}'

# Aguardar 5 segundos

# Venda
curl -X POST https://livelier-nonpurposively-monty.ngrok-free.dev/sinais \
  -H "Content-Type: application/json" \
  -d '{"action": "short"}'
```

### **MT5 - Aba "Experts":**
- Deve mostrar as mensagens de processamento
- Deve abrir as ordens automaticamente

---

## ⚠️ PROBLEMAS COMUNS

### **Problema 1: "Request is not JSON"**
**Causa:** TradingView enviou mensagem sem formato JSON
**Solução:** Configure a mensagem do alerta com JSON puro (veja acima)

### **Problema 2: EA não processa o sinal**
**Causa:** EA não está rodando ou AutoTrading desabilitado
**Solução:**
- Ative AutoTrading (botão verde na barra superior)
- Verifique se o EA está no gráfico (deve aparecer no canto)
- Recompile o EA e adicione novamente ao gráfico

### **Problema 3: "Invalid volume"**
**Causa:** Volume calculado é muito pequeno ou muito grande
**Solução:** Ajuste o `RiskPercent` nas configurações do EA

### **Problema 4: "Not enough money"**
**Causa:** Saldo insuficiente para abrir a ordem
**Solução:** Reduza o `RiskPercent` ou aumente o saldo da conta

### **Problema 5: "Trade context busy"**
**Causa:** MT5 está processando outra ordem
**Solução:** Aguarde 2-3 segundos e tente novamente

### **Problema 6: Ngrok offline**
**Causa:** O túnel ngrok caiu
**Solução:** Reinicie o ngrok:
```bash
ngrok http 8080 --domain=livelier-nonpurposively-monty.ngrok-free.dev
```

---

## 🎯 FLUXO COMPLETO (O QUE DEVE ACONTECER)

1. **TradingView** dispara alerta
   ⬇️
2. **Ngrok** recebe requisição HTTPS
   ⬇️
3. **Flask** recebe JSON `{"action": "long"}`
   ⬇️
4. **Flask** converte para `{"action": "buy"}`
   ⬇️
5. **Flask** salva em `signal.json`
   ⬇️
6. **MT5 EA** lê arquivo a cada 1 segundo
   ⬇️
7. **MT5 EA** processa sinal
   ⬇️
8. **MT5 EA** fecha posições abertas
   ⬇️
9. **MT5 EA** calcula volume
   ⬇️
10. **MT5 EA** abre nova ordem (BUY ou SELL)
   ⬇️
11. **✅ ORDEM ABERTA!**

---

## 📞 PRECISA DE AJUDA?

Se após seguir todos os passos acima a ordem ainda não abriu:

1. **Tire um screenshot:**
   - Da aba "Experts" do MT5
   - Do gráfico mostrando o EA ativo
   - Da configuração do alerta no TradingView

2. **Copie os últimos logs:**
   ```bash
   tail -30 logs/webhook.log
   ```

3. **Verifique o arquivo signal.json:**
   ```bash
   cat "%APPDATA%\MetaQuotes\Terminal\Common\Files\signal.json"
   ```

E compartilhe essas informações para diagnóstico!
