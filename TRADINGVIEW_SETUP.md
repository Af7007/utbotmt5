# Configuração TradingView + Webhook

## 🔗 URLs Importantes

### Webhook Endpoint
```
https://livelier-nonpurposively-monty.ngrok-free.dev/sinais
```

### Endpoints de Monitoramento
- **Health Check:** `https://livelier-nonpurposively-monty.ngrok-free.dev/health`
- **Status:** `https://livelier-nonpurposively-monty.ngrok-free.dev/status`

---

## 📝 Como Configurar no TradingView

### Passo 1: Criar Alerta
1. Abra seu gráfico no TradingView
2. Clique no ícone de **"Alertas"** (sino) no topo direito
3. Clique em **"Criar alerta"** ou **"+"**

### Passo 2: Configurar Condição
1. Escolha a condição do alerta (exemplo: "Preço cruza acima/abaixo")
2. Configure o símbolo e intervalo de tempo

### Passo 3: Configurar Webhook
1. Role para baixo até a seção **"Notificações"**
2. Marque a opção **"Webhook URL"**
3. Cole a URL do webhook:
   ```
   https://livelier-nonpurposively-monty.ngrok-free.dev/sinais
   ```

### Passo 4: Configurar Mensagem
Na caixa **"Message"** ou **"Alert message"**, cole o JSON apropriado:

#### Para Sinal de COMPRA (LONG):
```json
{"action": "long"}
```

#### Para Sinal de VENDA (SHORT):
```json
{"action": "short"}
```

#### Usando Variáveis do TradingView (Strategy):
Se você estiver usando uma estratégia, pode usar:
```json
{"action": "{{strategy.order.action}}"}
```

### Passo 5: Salvar
1. Dê um nome ao alerta
2. Clique em **"Criar"**

---

## 🧪 Como Testar

### Teste 1: Health Check
Abra no navegador ou use curl:
```bash
curl https://livelier-nonpurposively-monty.ngrok-free.dev/health
```

Resposta esperada:
```json
{"status": "ok", "service": "webhook_receiver"}
```

### Teste 2: Verificar Status
```bash
curl https://livelier-nonpurposively-monty.ngrok-free.dev/status
```

### Teste 3: Enviar Sinal Manual (COMPRA)
```bash
curl -X POST https://livelier-nonpurposively-monty.ngrok-free.dev/sinais \
  -H "Content-Type: application/json" \
  -d '{"action": "long"}'
```

### Teste 4: Enviar Sinal Manual (VENDA)
```bash
curl -X POST https://livelier-nonpurposively-monty.ngrok-free.dev/sinais \
  -H "Content-Type: application/json" \
  -d '{"action": "short"}'
```

---

## 📊 Exemplos de Configuração de Alertas

### Exemplo 1: Alerta de Cruzamento de Média Móvel
**Condição:** "Quando EMA(9) cruza acima EMA(21)"
**Mensagem:**
```json
{"action": "long"}
```

### Exemplo 2: Alerta de RSI
**Condição:** "Quando RSI(14) cruza abaixo de 30"
**Mensagem:**
```json
{"action": "long"}
```

**Condição:** "Quando RSI(14) cruza acima de 70"
**Mensagem:**
```json
{"action": "short"}
```

### Exemplo 3: Alerta de Breakout
**Condição:** "Quando preço cruza acima de resistência"
**Mensagem:**
```json
{"action": "long"}
```

---

## 🔍 Monitoramento e Logs

### Ver Logs do Webhook
Os logs ficam salvos em:
```
C:\utbot\logs\webhook.log
```

Para ver em tempo real:
```bash
tail -f logs/webhook.log
```

### Ver Último Sinal Recebido
O último sinal fica salvo em:
```
%APPDATA%\MetaQuotes\Terminal\Common\Files\signal.json
```

---

## ⚠️ Troubleshooting

### Webhook não recebe sinais
1. Verifique se o servidor Flask está rodando:
   ```bash
   curl http://localhost:8080/health
   ```

2. Verifique se o ngrok está ativo:
   ```bash
   curl https://livelier-nonpurposively-monty.ngrok-free.dev/health
   ```

3. Verifique os logs:
   ```bash
   cat logs/webhook.log
   ```

### Ngrok expired ou mudou de URL
Se o ngrok mudar de URL, você precisa:
1. Atualizar a URL no TradingView
2. Atualizar este documento

### MT5 não executa as ordens
1. Verifique se o EA está rodando no MT5
2. Verifique se o AutoTrading está habilitado
3. Verifique se o arquivo signal.json está sendo criado
4. Verifique os logs do MT5 (na aba "Experts")

---

## 🚀 Manutenção

### Iniciar Sistema Completo
```bash
# 1. Iniciar Flask
python webhook_receiver.py &

# 2. Iniciar ngrok (se não estiver rodando)
ngrok http 8080 --domain=livelier-nonpurposively-monty.ngrok-free.dev &

# 3. Abrir MT5 e ativar o EA
```

### Parar Sistema
```bash
# Parar Flask
pkill -f webhook_receiver.py

# Parar ngrok
pkill ngrok
```

---

## 📌 Notas Importantes

1. **Segurança:** O webhook não tem autenticação por padrão. Qualquer pessoa com a URL pode enviar sinais.
2. **Ngrok Free:** A URL do ngrok pode mudar se você reiniciar. Use domínio reservado (já configurado).
3. **Rate Limits:** TradingView tem limites de alertas por conta.
4. **Latência:** Pode haver delay de 1-3 segundos entre o alerta e a execução.

---

## 🎯 Próximos Passos

- [ ] Configurar autenticação no webhook (API Key)
- [ ] Adicionar validação de IP do TradingView
- [ ] Implementar fila de sinais para evitar perda
- [ ] Adicionar notificações (Telegram/Email)
- [ ] Dashboard de monitoramento
